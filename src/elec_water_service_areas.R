
library(tidyverse)
library(httr)
library(sf)
library(units)
library(withr)
library(fs)

# download data ----------------------------------------------------------------

# California Electric Service Areas
cal_elec_sa <- st_read("https://opendata.arcgis.com/datasets/800f1e68396f447396a3b1dda0cd8fe6_0.geojson") %>%
  st_transform(3310)

# California Water Service Areas
source("src/get_data/cal_water_service_areas.R")
cal_water_sa <- st_read("data/water_service_areas/service_areas_valid.shp")

# SCE & SDGE -------------------------------------------------------------------
sce_sdge <- cal_elec_sa %>%
  filter(Name %in% c("San Diego Gas & Electric", "Southern California Edison")) %>% 
  select(elec_name = Name, acronym = Acronym, category = Category)

sce_sdge_water <- cal_water_sa %>% 
  filter(map_lgl(st_intersects(., sce_sdge), ~ length(.x) != 0))

sce_sdge_water_summary <- st_intersection(sce_sdge, sce_sdge_water) %>% 
  group_by(elec_name, pwsid, pws_name = name) %>% 
  summarise() %>% 
  ungroup() %>% 
  mutate(sq_km = set_units(st_area(geometry), km^2)) %>% 
  st_set_geometry(NULL)

# save shp & csv
shp_dir <- "data/sce_sdge_water"
if (!dir_exists(shp_dir)) dir_create(shp_dir)
st_write(sce_sdge, path(shp_dir, "sce_sdge.shp"), delete_layer = TRUE)
st_write(sce_sdge_water, path(shp_dir, "sce_sdge_water.shp"), delete_layer = TRUE)
with_dir("data/sce_sdge_water", zip("../sce_sdge_water.zip", dir_ls()))

write_csv(sce_sdge_water_summary, "data/sce_sdge_water_summary.csv")
