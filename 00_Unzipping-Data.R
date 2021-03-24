# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(glue)

#This goes into the zipped directory and removed the .zip at the end of all the folders, 
# should only need to be run once
file.rename(from = list.files(here('zipped/'), full.names = T),
            to = str_remove(list.files(here('zipped/'),full.names = T), '.zip'))

#Grab the zipped folders we want to look at
files <- list.files(here('zipped/'))

#Let's just grab the first one for now
filename_1 <- files[1]
# Load Libs ---------------------------------------------------------------
library(tidyverse)
library(here)
library(glue)

#This goes into the zipped directory and removed the .zip at the end of all the folders, 
# should only need to be run once
file.rename(from = list.files(here('data/'), full.names = T),
            to = str_remove(list.files(here('data/'),full.names = T), '.zip'))

#Grab the zipped folders we want to look at
files <- list.files(here('zipped/')) %>% 
  as_tibble() %>% 
  filter(!str_detect(value,"Level")) %>% 
  pull(value)


for (i in files) {
  #Let's just grab the first one for now
  filename_1 <- i
  #We set the out directory to zipped/Level_1/name of the file we set
  out_dir_1 <- here(glue("zipped/Level_1/{filename_1}"))
  
  #Unzip first level
  #So the zipped folder is in zipped under the filename we just set above
  unzip(zipfile = here(glue('zipped/{filename_1}')),
        exdir = out_dir_1)
  
  
  #Grab the name of the zip that contains the csv
  #Okay now in this first unzipped level we have a bunch of stupid files like sas and dta
  #I want to unzip the zipped folder in there to get the the csv
  
  #So I grab the zipped folder
  filename_2 <- 
    #So list the files in the level 1 output directory
    list.files(out_dir_1) %>% 
    as_tibble() %>% 
    #Grabbed the zipped folder in there
    filter(str_detect(value,"readme.zip"))
  
  #The zipped folder name is actually too long. 
  # So here I go to the folder where I just unzipped things to, called "filename_1"
  # and I look for that crazily named compressed file. I then rename it to just csv.zip 
  file.rename(from=here(glue("zipped/Level_1/{filename_1}/{filename_2}")), 
              to=here(glue("zipped/Level_1/{filename_1}/csv.zip")))
  
  #Get the second level directory I want to unzip to
  out_dir_2 <- here(glue("zipped/Level_2/{filename_2}"))
  
  #Unzip second level (actually get the CSV)
  unzip(zipfile = glue("{out_dir_1}/csv.zip"),
        exdir = out_dir_2)
  
  file_to_copy <- list.files(here(glue("zipped/Level_2/{filename_2}"))) %>% 
    as_tibble() %>% 
    filter(!str_detect(value,".txt"))
  
  file.copy(from = here(glue("zipped/Level_2/{filename_2}/{file_to_copy}")),
            to = here(glue("data/{file_to_copy}")))
}

