# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(stringr)
library(tidycensus)
library(glue)


# Load Data ---------------------------------------------------------------
data("fips_codes")
data <- read_rds(here("full_data/full_data.rds"))


# Validate I have good state-county fips -------------------------------------------------
#Get a full state-county fip code column in the census fips data
fips_codes <- fips_codes %>% as_tibble() %>% 
  mutate(fips=glue("{state_code}{county_code}"))

#Check the unique state-county fips I have
my_fips <- data %>% 
  distinct(tract_fips10) %>% 
  mutate(fips=substr(tract_fips10,1,5)) %>% 
  distinct(fips)

#These are the counties I do not have in my data
(missed <- fips_codes %>% anti_join(my_fips))
saveRDS(missed,here("full_data/missed_counties.rds"))

# Aggregate by State-County Fips ------------------------------------------
#Aggregate sums (everything besides avg download/upload speed and the binary for any park)
data_agg <- data %>% 
  #Removing these for now because these need to be averaged or maxed, not summed up
  select(-avg_download_speed,-avg_upload_speed,-any_open_park) %>%   
  mutate(fips=substr(tract_fips10,1,5)) %>% 
  select(-tract_fips10) %>% 
  group_by(fips,year) %>% 
  summarise_all(~sum(.,na.rm = T)) %>% 
  ungroup()

#Now average the broadband speed variables
agg_broad <- data %>%
  mutate(fips=substr(tract_fips10,1,5)) %>%
  select(-tract_fips10) %>% 
  select(fips,year,avg_download_speed,-avg_upload_speed) %>% 
  group_by(fips,year) %>% 
  summarise_all(~mean(.,na.rm=T)) %>% 
  ungroup() 

#Join the broadband back in
data_agg <- data_agg %>% left_join(agg_broad)


#Join in county and state names
data_agg <- data_agg %>% left_join(fips_codes %>% select(state,state_name,county,fips))         

#Clean up column placement
data_agg <- data_agg %>% relocate(c(state,state_name,county),.before = everything())

#Save
saveRDS(data_agg,here("full_data/Full_Agg_Data.RDS"))
