# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)

nanda_retail_tract_2003_2017_01P <- read_csv("data/nanda_retail_tract_2003-2017_01P.csv")
data <- nanda_retail_tract_2003_2017_01P


# Only Keep Cols of Interest ----------------------------------------------
data <- data %>% 
  select(tract_fips10,year,population,aland10,
         contains("count")) #Keep just the count columns
  
data <- data %>% 
  pivot_longer(cols=-c(tract_fips10,year,population,aland10))

data <- data %>% 
  filter(!str_detect(name, "popden") &
           !str_detect(name, "aden")) %>%  #Keep only rows where the variable is pop densitydensity
  filter(str_detect(name,"sales")) 

summarized <- data %>% 
  group_by(tract_fips10,year,population,aland10) %>% 
  summarise(non_grocery_retail_stores=sum(value))

saveRDS(data,here("data_clean/Non-Grocery-Retailers.rds"))
