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



data %>% 
  filter(year==2017) %>% 
  slice_max(n=10, order_by = Restaurants) %>% 
  relocate(population,.after = county) %>% 
  View()


census_pops <- tidycensus::get_estimates(geography = "county", product = "population")
mydata_vs_census <- data %>% 
  filter(year==2017) %>% 
  select(state_name,county,fips,population) %>% 
  left_join(census_pops %>% filter(variable=="POP"),by=c("fips"="GEOID")) %>% 
  mutate(diff=population-value)  

mydata_vs_census %>% View()
