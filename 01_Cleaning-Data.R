# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(vroom)

select_function <- function(data) {
  data %>% 
    select(tract_fips10,year,
           contains("count")) %>% #Keep just the count columns
    select(tract_fips10,year,
           !contains("emp")) %>% #Don't keep the columns of firms with only a certain # of employees
    select(tract_fips10,year,
           !contains("sales"))
}


# Healthcare --------------------------------------------------------------

# Load the data 
nanda_healthcare_tract_2003_2017_02P <- vroom(here("data/nanda_healthcare_tract_2003-2017_02P.csv"))
data <- nanda_healthcare_tract_2003_2017_02P 


# Only keep columns of interest. Don't use select_function() here because I need population and
# aland10 vars
data <- data %>% 
  select(tract_fips10,year,population,aland10,
         ends_with("6211"), #Keep physicians columns
         ends_with("622"), #Keep hospitals
         ends_with("623"), #keep nursing/residential homes
         contains("446110")) %>% #Keep pharmacies
  select(tract_fips10,year,population,aland10,
         contains("count")) %>% #Keep just the count columns
  select(tract_fips10,year,population,aland10,
         !contains("emp")) %>% #Don't keep the columns of firms with only a certain # of employees
  select(tract_fips10,year,population,aland10,
         !contains("sales")) %>% #Don't keep the columns of firms with only a certain # of sales
  rename("all_physicians"=count_6211,
         "all_hospitals"=count_6211,
         "nursing_residential_homes"=count_623,
         "pharmacies"=count_446110)

saveRDS(data,here("data_clean/Healthcare_Data.rds"))
#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data"))

# Non-Grocery Retailers ---------------------------------------------------
nanda_retail_tract_2003_2017_01P <- vroom("data/nanda_retail_tract_2003-2017_01P.csv",
                                          col_select=!c(population,aland10))


# Only Keep Cols of Interest 
data <- 
  nanda_retail_tract_2003_2017_01P %>% 
  select_function()

#Pivot longer so I can summarise all categories into just one general non-grocery retail column
data <- data %>% 
  pivot_longer(cols=-c(tract_fips10,year))

summarized <- data %>% 
  group_by(tract_fips10,year) %>% 
  summarise(non_grocery_retail_stores=sum(value))

saveRDS(summarized,here("data_clean/Non-Grocery-Retailers.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data"))


# Educational Institutions ------------------------------------------------
nanda_edtrain_tract_2003_2017_01P <- vroom("data/nanda_edtrain_tract_2003-2017_01P.csv",
                                           col_select=!c(population,aland10))



# Only Keep Cols of Interest 
data <- nanda_edtrain_tract_2003_2017_01P %>% 
  select_function() %>% 
  select(tract_fips10,year,
         ends_with("6111"), #elementary+secondary stores
         ends_with("6112"), #Junior Colleges
         ends_with("6113")) #Colleges,universities, professional schools


#Rename columns
data <- data %>% 
  rename("Primary_and_Secondary_Schools"=count_6111, 
         "Junior_and_Community_Colleges"=count_6112,
         "Colleges_and_Universities"=count_6113)


saveRDS(data,here("data_clean/Educational-Institutions.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data"))


# Entertainment Venues ----------------------------------------------------

nanda_artsentrec_tract_2003_2017_01P <- vroom("data/nanda_artsentrec_tract_2003-2017_01P.csv",
                                              col_select=!c(population,aland10))

# Only Keep Cols of Interest 
data <- nanda_artsentrec_tract_2003_2017_01P %>% 
  select_function() %>% 
  select(tract_fips10,year,
         "performing_arts_orgs"=ends_with("7111"), # Performing arts orgs
         "spectator_sports_orgs"=ends_with("7112"), 
         "museums"=ends_with("712"), # 
         "libraries_archives"=ends_with("51912"),
         "amusement_parks"=ends_with("7131"),
         "casinos"=ends_with("7132"), 
         "casino_hotels"=ends_with("721120"),
         "sports_and_fitness_recreation"=ends_with("7139"))

data <- data %>% 
  mutate(casinos=casinos+casino_hotels) %>% 
  select(-casino_hotels)

saveRDS(data,here("data_clean/Entertainment-Venues.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data"))

# Social Services ---------------------------------------------------------
nanda_socsvcs_tract_2003_2017_01P <- vroom("data/nanda_socsvcs_tract_2003-2017_01P.csv")

# Only Keep Cols of Interest
data <- nanda_socsvcs_tract_2003_2017_01P %>% 
  select_function() %>% 
  select(tract_fips10,year,
         ends_with("624"))

#Group by census tract-year pair
summarized <- data %>% 
  group_by(tract_fips10,year) %>% 
  summarise(social_services=sum(count_624))

saveRDS(summarized,here("data_clean/Social-Services.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data"))


# Restaurants and Bars ----------------------------------------------------
nanda_eatdrink_tract_2003_2017_01P <- vroom("data/nanda_eatdrink_tract_2003-2017_01P.csv")


# Only Keep Cols of Interest
#Only keep tract column, year column, population column, land area column, and columns with
# "count" and "sales" in the name
data <- nanda_eatdrink_tract_2003_2017_01P %>% 
  select_function() %>% 
  select(tract_fips10,year,
         ends_with("7225"), #restaurants
         ends_with("722410"))#bars

#Rename columns to be descriptive
data <- data %>% rename("Restaurants"=count_7225,
                        "Bars" = count_722410)

saveRDS(data,here("data_clean/Restaurants-and-Bars.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))


# Law Enforcement ---------------------------------------------------------
nanda_lawenf_tract_2003_2017_01P <- vroom("data/nanda_lawenf_tract_2003-2017_01P.csv")


# Only Keep Cols of Interest 
data <- nanda_lawenf_tract_2003_2017_01P %>% 
  select_function() %>% 
  select(tract_fips10,year,
         "courts"=ends_with("922110"), #courts
         "police_depts"=ends_with("922120"), #police deps
         "correctional_facilities"=ends_with("922140"), # Correctional facilities
         "fire_depts"=ends_with("922160")) #fire depts
  
saveRDS(data,here("data_clean/Law-Enforcement.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))


# Personal Care and Laundromats -------------------------------------------
nanda_pclaund_tract_2003_2017_01P <- vroom("data/nanda_pclaund_tract_2003-2017_01P.csv")

# Only Keep Cols of Interest 
data <- 
  nanda_pclaund_tract_2003_2017_01P %>% 
  select_function()

#Pivot longer so I can summarise all categories into just one general personal care column
data <- data %>% 
  pivot_longer(cols=-c(tract_fips10,year))

summarized <- data %>% 
  group_by(tract_fips10,year) %>% 
  summarise(personal_care_establishments=sum(value))

saveRDS(summarized,here("data_clean/Personal-Care_Establishments.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data"))


# Alcohol and Tobacco -----------------------------------------------------
nanda_lqtbcon_tract_2003_2017_01P <- vroom("data/nanda_lqtbcon_tract_2003-2017_01P.csv")

# Only Keep Cols of Interest 
data <- nanda_lqtbcon_tract_2003_2017_01P %>% 
  select_function() #fire depts

data <- data %>% 
  mutate(liquor_tobacco_stores=count_4453+count_453991,
         convenience_stores=count_445120+count_447110) %>% 
  select(tract_fips10, year,
         liquor_tobacco_stores,
         convenience_stores)

saveRDS(data,here("data_clean/Alcohol-Tobacco.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))


# Grocery Stores ----------------------------------------------------------
nanda_grocery_tract_2003 <- vroom("data/nanda_grocery_tract_2003-2017_01P.csv")

data <- nanda_grocery_tract_2003 %>% 
  select_function() 

data <- data %>% 
  mutate(grocery_and_food_stores=count_445110+count_4452) %>% 
  select(tract_fips10,year,grocery_and_food_stores, "supercenter_stores"=count_452311)

saveRDS(data,here("data_clean/Grocery-Stores.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))


#  Religious, Civic, and Social Organizations -----------------------------
nanda_relcivsoc_tract_2003_2017_01P <- vroom("data/nanda_relcivsoc_tract_2003-2017_01P.csv")

data <- nanda_relcivsoc_tract_2003_2017_01P %>% 
  select_function() %>% 
  rename("relgious_orgs"=count_8131,
         "civic_and_social_orgs"=count_8134)

saveRDS(data,here("data_clean/Social-and-Religious-Orgs.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))


# Post Offices and Banks --------------------------------------------------
nanda_relcivsoc_tract_2003_2017_01P <- vroom("data/nanda_pobank_tract_2003-2017_01P.csv")

data <- nanda_relcivsoc_tract_2003_2017_01P %>% 
  select_function() %>% 
  rename("post_offices"=count_491,
         "banks"=count_522120,
         "credit_unions"=count_522130)

saveRDS(data,here("data_clean/Post-Officies-and-Banks.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))


# Dollar stores -----------------------------------------------------------
data <- vroom("data/nanda_dollar_tract_2003-2017_01P.csv")

data <- data %>% 
  select_function() %>% 
  rename("dollar_stores"=count_452319)

saveRDS(data,here("data_clean/Dollar-Stores.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))

# Broadband -----------------------------------------------------------
data <- vroom("data/nanda_broadband_tract_2014-2018_01P.csv")

data <- data %>% 
  rename("high_speed_broadband_providers"=tot_hs_providers) %>% 
  select(-res_hs_providers)

saveRDS(data,here("data_clean/Broadband.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))

# Parks -----------------------------------------------------------
data <- vroom("data/nanda_parks_tract_2018_01P.csv")

data <- data %>% 
  select(tract_fips10:count_open_parks,tot_park_area_sqmiles) %>% 
  mutate(year=2018)

saveRDS(data,here("data_clean/Parks.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))

# Transit -----------------------------------------------------------
data <- vroom("data/nanda_transit_tract_2016-2018_05P.csv")

data <- data %>% 
  select(tract_fips,count_ntm_stops) %>% 
  mutate(year=2018)

saveRDS(data,here("data_clean/Transit-Stops.rds"))

#Clean up workspace
rm(list=c(ls(pattern = "nanda*"),"data","summarized"))




