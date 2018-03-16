
library(tidyverse)
library(httr)
library(sf)
library(units)

# download data ----------------------------------------------------------------

# California Water Service Areas
source("src/get_data/cal_water_service_areas.R")
cal_water_sa <- st_read("data/water_service_areas/service_areas_valid.shp")

# CA Zip Codes
source("src/get_data/cal_zip_codes.R")
ca_zip <- st_read("data/zip_codes/ca_zip.shp")

# spatial intersection ---------------------------------------------------------
cal_water_sa_zip <- st_intersection(cal_water_sa, ca_zip) %>% 
  group_by(pwsid, pws_name = name, zip5 = ZCTA5CE10) %>% 
  summarise() %>% 
  ungroup() %>% 
  mutate(sq_km = set_units(st_area(geometry), km^2)) %>% 
  st_set_geometry(NULL)

write_csv(cal_water_sa_zip, "data/cal_water_sa_zip.csv")
