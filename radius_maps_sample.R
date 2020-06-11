library(dplyr)
library(magrittr)
library(geosphere)
library(tidyr)
library(readxl)
library(readr)
#Function to clan up column names
source('~/work/clean_names.R')


#load data sources
countydata <- readRDS("~/work/countydata.Rds")
load("~/ms_map.rda")
msjudicialdistricts_20200527 <- read_excel("~/msjudicialdistricts_20200527.xlsx", sheet = "Sheet2") %>%
  gather(county,value, c1:c11, na.rm = TRUE) %>%
  select(-county)
cps_summary_1_ <- read_csv("C:/Users/Scott Swafford/Downloads/cps_summary (1).csv") %>%
  clean_names()
county_coords <- read_excel("~/county_coords.xlsx") %>%
  mutate(geoid = as.character(geoid)) 

#Correct county assignement for one cac
countydata <- within(countydata, {
  f <- geographic_area_1 == "Jefferson County" & cac == "None" & home_county == "None"
  cac[f] <- "Natchez Children's Services"
  home_county[f] <- "Official Service Area"
})

#Filter and select lat and long coordinates for cac home offices
cac_lat_long <- county_coords %>% select(CAC, cac_id,office_type, Latitude, Longitude) %>% filter(office_type == "h")

#Select FIPS code, cac name, and county type for all ms counties
county_service_area <- countydata %>%
  select(geoid, cac, home_county)

#Add lat and lon coordinates for cacs'
county_service_area_lat_long <- county_service_area %>%
    left_join(cac_lat_long, by = c("cac" = "CAC"))
#Join county ploygon coordinates with cac coordinates
county_full <- ms_map %>%
  left_join(county_service_area_lat_long, by = c("State FIPS" = "geoid" ))  

#Calculate distance between all county coordinates and cac coordinates
county_full$distance <- distHaversine(county_full[,1:2],county_full[,21:20])/1609.35


#Add indicators to distance data for mapping in tableau
a <- county_full %>%
  group_by(`State FIPS`) %>%
  mutate(radius60_status_full = as.numeric(all(distance<60))) %>%
  mutate(radius60_status_partial = as.numeric(any(distance<60))) %>%
  mutate(radius60_status_none = as.numeric(all(distance>=60))) %>%
  mutate(radius60_distance_avg = mean(distance)) %>%
  mutate(radius40_status_full = as.numeric(all(distance<40))) %>%
  mutate(radius40_status_partial = as.numeric(any(distance<40))) %>%
  mutate(radius40_status_none = as.numeric(all(distance>=40))) %>%
  mutate(radius40_distance_avg = mean(distance)) %>%
  mutate(radius60_status_combined = case_when(
    radius60_status_full == 1 ~ "Full",
    radius60_status_partial == 1 ~ "Partial",
    radius60_status_none == 1 ~"None",
    TRUE ~ "Non-Offical Service Area"
  )) %>%
  mutate(radius40_status_combined = case_when(
    radius40_status_full == 1 ~ "Full",
    radius40_status_partial == 1 ~ "Partial",
    radius40_status_none == 1 ~"None",
    TRUE ~ "Non-Offical Service Area"
  )) %>%
  arrange(radius40_distance_avg) %>%
  distinct(County,`State FIPS`, .keep_all = TRUE) 

#join county FIPS and name with cps data
county_geo <- countydata %>% select(geoid,name) %>% left_join(cps_summary_1_) %>%
  select(-name)

#Join distance data, cps data, and demographic data into source for tableau workbook
b <- a %>%
  left_join(county_geo, by = c("State FIPS" = "geoid")) %>%
  left_join(msjudicialdistricts_20200527, by = c("County" = "value")) %>%
  left_join(countydata %>% select(geoid, `Total Pop`, `Under 18`), by  = c("State FIPS" = "geoid"))
write.csv(b, "map_test.csv")         
