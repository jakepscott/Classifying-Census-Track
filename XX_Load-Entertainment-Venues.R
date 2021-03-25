# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)

nanda_artsentrec_tract_2003_2017_01P <- read_csv("data/nanda_artsentrec_tract_2003-2017_01P.csv")
data <- nanda_artsentrec_tract_2003_2017_01P


# Only Keep Cols of Interest ----------------------------------------------
#Only keep tract column, year column, population column, land area column, and columns with
# "count" and "sales" in the name
data <- data %>% 
  select(tract_fips10,year,population,aland10,
         ends_with("7111"), # Performing arts orgs
         ends_with("7112"), #spectator sports orgs
         ends_with("712"), # museums
         ends_with("51912"), #libraries/archives
         ends_with("7131"), # amusement parks
         ends_with("7132"), #Casinos
         ends_with("721120"), #Casino hotels
         ends_with("7139")) %>% # all golf, skiing, boating, fitness, bowling, other
  select(tract_fips10,year,population,aland10,
         contains("count")) %>% ##Keep just the count columns
  select(tract_fips10,year,population,aland10,
         contains("sales")) #Keep just the columns with sales>=2


#Pivot the columns to a longer form so I can more easily rename entries based on category
data <- data %>% 
  pivot_longer(cols=-c(tract_fips10,year,population,aland10))

#Group by census tract-year pair
summarized <- data %>% 
  group_by(tract_fips10,year,population,aland10) %>% 
  summarise(entertainment_venues=sum(value))

saveRDS(data,here("data_clean/Entertainment-Venues.rds"))
