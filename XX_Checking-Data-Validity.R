# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(skimr)


# Load Data ---------------------------------------------------------------
data <- read_rds(here("full_data/Full_Agg_Data.RDS"))


# Overview of the data ----------------------------------------------------
#Feels like there are some absolutely wildin' values in here. One county has *7436* primary  &
# secondary schools?? 
data %>% skim()

#Turns out these "wild" values always happen in these major cities, so maybe the aren't *too* crazy
data %>% 
  filter(year==2017) %>% 
  arrange(desc(Primary_and_Secondary_Schools)) 

#Let's scale by pop to find out!
# Oh boy, some of the values have now become *even worse*
# 23163 physicians per 1000 people? 
# 1775 hospitals per 1000 people?
# 2566  pharmacies?
# 63105 non-grocery retail stores?
# 22384 personal care establishments?
# 28281 restaurants
# 2001     Bars?
# etc etc
data %>% 
  mutate(across(where(is.numeric), ~((.x/population)*1000))) %>% 
  filter(!is.na(population) & population!=0) %>% 
  skim()

###hmmm... looks like for those ridiculous values, we are not properly dividing by population somehow? it seems that after the population column itself 
# things stop getting divided... maybe because the population column

#A ha! The issue was we divided population by itself in the above code. Then it took that newly calculated population value (1)
# and divided subsequent columns by it, which naturally led to issues
data %>% 
  mutate(across(where(is.numeric) & !contains("population"), ~((.x/population)*1000))) %>% 
  filter(!is.na(population) & population!=0) %>% 
  skim()


# Let's compare census pop estimates to my derived values -----------------
census_pops <- tidycensus::get_estimates(geography = "county", product = "population")
mydata_vs_census <- data %>% 
  filter(year==2017) %>% 
  select(state_name,county,fips,population) %>% 
  left_join(census_pops %>% filter(variable=="POP"),by=c("fips"="GEOID")) %>% 
  mutate(diff=population-value)  

#Not bad! My big misses on the downside are places like Maricopa Arizona which have grown since 2017 and cook county,
# which has shrunk
mydata_vs_census %>% View()


# I recall hospitals being a big issue ------------------------------------
#My data says there are 57,379 hospitals in the US. 
# The AHA says there are only ***6,090***. So I am off by an order of 10: https://www.aha.org/statistics/fast-facts-us-hospitals
data %>% 
  filter(year==2017) %>% 
  pull(all_hospitals) %>% 
  sum()


data %>% 
  filter(year==2017) %>% 
  select(where(is.numeric)) %>% 
  map_dbl(sum) %>% 
  as_tibble(rownames = "variable") %>% 
  View()

#I say there are 749,588 restaurants, Statisca says closer to 647,000 https://www.statista.com/statistics/244616/number-of-qsr-fsr-chain-independent-restaurants-in-the-us/#:~:text=The%20number%20of%20restaurants%20in,a%20little%20over%20two%20percent.&text=The%20two%20main%20categories%20of,full%20service%20restaurants%20(FSR'S).
# I say there are 468,787 physicians, FSMB says 985,000 https://www.fsmb.org/siteassets/advocacy/publications/2018census.pdf
# I say there are 38,305 colleges + universities, google says like 5k
# A lot of mine do seem to be overestimates... maybe I should have only grabbed the cols where they verified there were some employes and/or
# sales made..