
library(httr)

# California Water Service Areas
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
