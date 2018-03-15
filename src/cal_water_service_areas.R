
library(tidyverse)
library(httr)
library(sf)
library(units)

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

# CA Zip Codes -----------------------------------------------------------------

if (!file.exists("data/census_zip/ca_zip.shp")) {
  download.file("https://www2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/tl_2010_06_zcta510.zip",
                "data/tl_2010_06_zcta510.zip")
  unzip("data/tl_2010_06_zcta510.zip", exdir = "data/zip_codes")
  
  # re-project
  ca_zip <- st_read("data/zip_codes/tl_2010_06_zcta510.shp") %>% st_transform(3310)
  st_write(ca_zip, "data/zip_codes/ca_zip.shp", delete_layer = TRUE)
}

# intersect --------------------------------------------------------------------
cal_water_sa <- st_read("data/water_service_areas/service_areas_valid.shp")
ca_zip <- st_read("data/zip_codes/ca_zip.shp")

cal_water_sa_zip <- st_intersection(cal_water_sa, ca_zip) %>% 
  group_by(pwsid, pws_name = name, zip5 = ZCTA5CE10) %>% 
  summarise() %>% 
  ungroup() %>% 
  mutate(sq_km = set_units(st_area(geometry), km^2)) %>% 
  st_set_geometry(NULL)

write_csv(cal_water_sa_zip, "data/cal_water_sa_zip.csv")
