# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(stringr)
library(tidycensus)
library(glue)


# Load Data ---------------------------------------------------------------
data("fips_codes")
data <- read_rds(here("data_clean/full_data.rds"))


# Validate I have good state-county fips -------------------------------------------------
#Get a full state-county fip code column in the census fips data
fips_codes <- fips_codes %>% as_tibble() %>% 
  mutate(fips=glue("{state_code}{county_code}"))

#Check the unique state-county fips I have
my_fips <- data %>% distinct(tract_fips10) %>% 
  mutate(fips=substr(tract_fips10,1,5)) %>% 
  distinct(fips)

#These are the counties I do not have in my data
fips_codes %>% anti_join(my_fips)


# Aggregate by State-County Fips ------------------------------------------
#Aggregate
data_agg <- data %>% 
  mutate(fips=substr(tract_fips10,1,5)) %>% 
  select(-tract_fips10) %>% 
  group_by(fips,year) %>% 
  summarise_all(~sum(.,na.rm = T)) #MAKE SURE TO PUT NAS FOR PRE 2014 YEARS FOR BROADBAND***

#Join in county and state names
data_agg <- data_agg %>% left_join(fips_codes %>% select(state,state_name,county,fips))         

#Clean up column placement
data_agg <- data_agg %>% relocate(c(state,state_name,county),.before = everything())

#Save
saveRDS(data_agg,here("full_data/Full_Agg_Data.RDS"))
