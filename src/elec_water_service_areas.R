
library(tidyverse)
library(httr)
library(sf)
library(units)

# download data ----------------------------------------------------------------

# California Electric Service Areas
cal_elec_sa <- st_read("https://opendata.arcgis.com/datasets/800f1e68396f447396a3b1dda0cd8fe6_0.geojson") %>%
  st_transform(3310)

# California Water Service Areas
source("src/get_data/cal_water_service_areas.R")
cal_water_sa <- st_read("data/water_service_areas/service_areas_valid.shp")

# spatial intersection ---------------------------------------------------------
elec_water_sa <- cal_elec_sa %>% 
  select(elec_name = Name) %>% 
  st_intersection(cal_water_sa) %>% 
  group_by(elec_name, pwsid, pws_name = name) %>% 
  summarise() %>% 
  ungroup() %>% 
  mutate(sq_km = set_units(st_area(geometry), km^2))

# save SCE & SDGE list ---------------------------------------------------------
elec_water_sa_sub <- elec_water_sa %>%
  filter(elec_name %in% c("San Diego Gas & Electric", "Southern California Edison")) %>% 
  st_set_geometry(NULL)

write_csv(elec_water_sa_sub, "data/elec_water_sa_sub.csv")
