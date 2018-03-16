# CA Zip Codes -----------------------------------------------------------------
cal_zip_file <- "data/zip_codes/ca_zip.shp"

if (!file.exists(cal_zip_file)) {
  download.file("https://www2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/tl_2010_06_zcta510.zip",
                "data/tl_2010_06_zcta510.zip")
  unzip("data/tl_2010_06_zcta510.zip", exdir = "data/zip_codes")
  
  # re-project
  ca_zip <- st_read("data/zip_codes/tl_2010_06_zcta510.shp") %>% st_transform(3310)
  st_write(ca_zip, cal_zip_file, delete_layer = TRUE)
}

message("California Zip Codes:    ", cal_zip_file)
