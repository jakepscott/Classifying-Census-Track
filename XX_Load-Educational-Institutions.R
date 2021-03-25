# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)

nanda_edtrain_tract_2003_2017_01P <- read_csv("data/nanda_edtrain_tract_2003-2017_01P.csv")
data <- nanda_edtrain_tract_2003_2017_01P


# Only Keep Cols of Interest ----------------------------------------------
#Only keep tract column, year column, population column, land area column, and columns with
# "count" and "sales" in the name
data <- data %>% 
  select(tract_fips10,year,population,aland10,
         ends_with("6111"), #elementary+secondary stores
         ends_with("6112"), #Junior Colleges
         ends_with("6113")) %>% #Colleges,universities, professional schools
  select(tract_fips10,year,population,aland10,
         contains("count")) %>% ##Keep just the count columns
  select(tract_fips10,year,population,aland10,
         contains("sales")) #Keep just the columns with sales>=2
  

#Pivot the columns to a longer form so I can more easily rename entries based on category
data <- data %>% 
  pivot_longer(cols=-c(tract_fips10,year,population,aland10))

#Rename the rows to more descriptive names
data <- data %>% 
  mutate(name=str_replace(name,pattern = "sales_6111",replacement = "Primary_and_Secondary_Schools"),
         name=str_replace(name,"sales_6112", "Junior_and_Community_Colleges"),
         name=str_replace(name,"sales_6113", "Colleges_and_Universities"),
         name=str_remove(name,"count_")) #Remove the count part of the name



#Pivot wider so each row is one census tract
data <- data %>% 
  pivot_wider(names_from = name,
              values_from = value)

saveRDS(data,here("data_clean/Educational-Institutions.rds"))
