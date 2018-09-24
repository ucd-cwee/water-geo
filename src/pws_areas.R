
library(tidyverse)
library(httr)
library(sf)
library(units)

# download data ----------------------------------------------------------------

# California Water Service Areas
source("src/get_data/cal_water_service_areas.R")
cal_water_sa <- st_read("data/water_service_areas/service_areas_valid.shp")

# Calculate areas --------------------------------------------------------------

cal_water_sa_sqkm <- cal_water_sa %>% 
  group_by(pwsid, pws_name = name) %>% 
  summarise() %>% 
  ungroup() %>% 
  mutate(sq_km = set_units(st_area(geometry), km^2)) %>% 
  st_set_geometry(NULL)

write_csv(cal_water_sa_sqkm, "data/pws_sqkm.csv")
