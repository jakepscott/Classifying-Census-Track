# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(skimr)


# Load Data ---------------------------------------------------------------
data <- read_rds(here("full_data/Full_Agg_Data.RDS"))

nested_data <- data %>% 
  select(-state) %>% 
  group_by(state_name,county,fips,year) %>% 
  nest()

data %>% skim()
data %>% 
  filter(year==2017) %>% 
  arrange(desc(liquor_tobacco_stores)) %>% 
  View()

data %>% 
  mutate(across(where(is.numeric), ~((.x/population)*1000))) %>% 
  filter(!is.na(population)) %>% 
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
