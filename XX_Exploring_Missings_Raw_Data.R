# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(tictoc)
library(naniar)

# Load Data ---------------------------------------------------------------
data("fips_codes")
data <- read_rds(here("full_data/full_data.rds"))
data %>% slice_sample(prop = .10) %>% 
  naniar::vis_miss()
  
missing <- data %>% naniar::miss_summary()

#So I am missing 100% of rows for any_open_park, count_open_parks, tot_park_area_sqmiles,count_ntm_stops
# and a 78.6% of rows for avg_download_speed, avg_upload_speed, and num_high_speed_broadband_providers.
# Otherwise things are looking really quite good!
missing$miss_var_summary[[1]] %>% View()


# Let's explore the 100% missings -----------------------------------------
parks <- read_rds(here("data_clean/Parks.rds")) # so the variables any_open_park, count_open_parks,
# and tot_park_area_sqmiles are missing because the parks data is from 2018 and the rest of the data is 
# between 2003 and 2017

stops <- read_rds(here("data_clean/Transit-Stops.rds")) #Same thing here, the obs are from 2018


# Let's look at broadband -------------------------------------------------
broadband <- read_rds(here("data_clean/Broadband.rds"))
broadband %>% distinct(year) #Starts in 2014 and goes to 2018, so missing 2003 to 2013. So it makes sense 
# 75ish % of obs would be missing 
