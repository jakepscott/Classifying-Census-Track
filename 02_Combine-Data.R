# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(glue)
library(readr)
library(vroom)

# Load Data ---------------------------------------------------------------
files <- list.files(here("data_clean/")) %>% 
  as_tibble() %>% 
  filter(value!="full_data.rds") %>% 
  pull(value)

# for (i in files) {
#   assign(i,vroom(here(glue("data_clean//{i}"))))
# }


Alcohol_Tobacco <- read_rds(here("data_clean/Alcohol-Tobacco.rds"))
data <- Alcohol_Tobacco %>% select(tract_fips10,year)

for(i in files){
  data <- data %>% left_join(read_rds(here(glue("data_clean/{i}"))))
  Sys.sleep(0.01)
  rm(list=setdiff(ls(), "data"))
}



saveRDS(data,here("full_data/full_data.rds"))
