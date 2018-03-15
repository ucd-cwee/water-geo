
library(tidyverse)
library(httr)
library(sf)

# California Water Service Areas -----------------------------------------------
if (!file.exists("data/water_service_areas/service_areas.shp")) {
  r <- GET("http://www.cehtp.org/",
           path = "geoserver/ows",
           query = list(service = "wfs",
                        version = "1.1.0",
                        request = "GetFeature",
                        typeName = "water:service_areas",
                        srsName = "epsg:4326",
                        outputFormat = "shape-zip"),
           write_disk("data/water_service_areas.zip", overwrite = TRUE))
  unzip("data/water_service_areas.zip", exdir = "data/water_service_areas")
  
  # fix geometry errors & re-project
  cal_water_sa <- st_read("data/water_service_areas/service_areas.shp") %>% st_transform(3310)
  cal_water_sa_valid <- cal_water_sa %>% st_buffer(0)
  geo_valid <- st_is_valid(cal_water_sa_valid)
  if (!all(geo_valid)) {
    warning("remaining invalid geometries will be dropped")
    cal_water_sa_valid <- cal_water_sa_valid[geo_valid, ]
  }
  st_write(cal_water_sa_valid, "data/water_service_areas/service_areas_valid.shp", delete_layer = TRUE)
}

