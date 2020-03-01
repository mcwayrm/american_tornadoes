#########################################
#           Tornado Data Merge
#             Analysis by: 
# Jessie Antilla-Hughes, Ryan McWay, Lilla Szini
#########################################

########################################
# STEPS:
########################################
#   1. Import Libraries
#   2. Import Data
#   3. Clean Data
#   4. Merge Data Files
#   5. Export Master Dataset
########################################

########################################
# Include your own personal local and comment out the others

#setwd("C:/Users/Ryry/Dropbox/American Tornadoes/scripts") # Ryan local
setwd("~/Dropbox/American Tornadoes/scripts") # Lilla local
setwd("jessie local")
########################################

########################################
#     Step 1: Import Libraries
########################################

# Handling Dataframes
library(tidyverse)
library(dplyr)
library(reshape2)
# Importing excels
library(readxl)
# Geospatial Packages
library(sf)
library(raster)
library(rgdal)  ## TODO: Unsure if we need raster and rgdal if we have the sf package. To be seen.

########################################

########################################
#     Step 2: Import Data
########################################

#       2.1: Tornado Data
tornados <- read.csv("../input/1950-2017_actual_tornadoes.csv", header = TRUE) %>%
  rename(
    time_zone = tz,
    year = yr,
    state = st,
    magnitude = mag,
    state_fip = stf,
    state_num = stn,
    crop_loss = closs,
    start_lat = slat,
    start_lon = slon,
    end_lat = elat,
    end_lon = elon,
    length = len,
    width = wid,
    fip1 = f1,
    fip2 = f2,
    fip3 = f3,
    fip4 = f4
  )

torn_as_path <- read_sf("../input/1950-2017-torn-aspath/1950-2017-torn-aspath.shp") %>% 
  rename(
    time_zone = tz,
    year = yr,
    state = st,
    magnitude = mag,
    state_fip = stf,
    crop_loss = closs,
    start_lat = slat,
    start_lon = slon,
    end_lat = elat,
    end_lon = elon
  )

#       2.2: Economic Data
ma_gdp <- read.csv("../input/MAGDP2_2001_2017_ALL_AREAS.csv", header = TRUE, na.strings = "(NA)") %>% 
  rename(
    GEOID = GeoFIPS,
    city_state = GeoName,
    industry_id = IndustryId,
    industry_class = IndustryClassification,
    sector = Description
  ) 
## TODO: What the hell is (D) in the dataset?

#       2.3: Spatial Data
fips <- read_excel("../input/US_FIPS_Codes.xls", col_names=TRUE, na= "") %>% 
  rename(
    state = "State",
    county = "County Name",
    fip_state = "FIPS State",
    fip_county = "FIPS County"
  )
# 
# tiger2017 <- read_sf("../input/tiger_2017/tl_2017_us_cbsa.shp") 
########################################

########################################
#     Step 3: Clean
########################################

#       3.1: Drop and add variables in MSA
ma_gdp$Region <- NULL
ma_gdp$TableName <- NULL
ma_gdp$Unit <- NULL
ma_gdp$ComponentName <- NULL
ma_gdp$city_state <- as.character(ma_gdp$city_state)

ma_gdp <- ma_gdp %>% 
  separate(city_state, sep = ",", c("city", "state")) %>% 
  separate(state, sep = " ", c(NA, 'state'))

#       3.2: Reshape GDP so it is state by year with one variable year
ma_gdp <- ma_gdp %>% 
  gather(`X2001`, `X2002`, `X2003`, `X2004`, `X2005`, `X2006`, `X2007`, `X2008`, `X2009`, `X2010`, `X2011`, `X2012`, `X2013`, `X2014`, `X2015`, `X2016`, `X2017`, key = "year", value = "gdp") %>% 
  separate(year, sep = "X", c(NA, 'year'))

#       3.3: Create Key for merging 
tornados$key <- paste(tornados$year, tornados$om, sep = '')
torn_as_path$key <- paste(torn_as_path$year, torn_as_path$om, sep = '')
ma_gdp$key2 <-  paste(ma_gdp$state, ma_gdp$year, sep = '')

########################################

########################################
#     Step 4: Merge
########################################

#       4.1: Merge tornado data
nados <- merge(torn_as_path, tornados, by = c('key'), duplicateGeoms = TRUE) %>% 
  rename(
    year = year.x,
    state = state.x
  ) 

#   Might not be necessary but would be usefull to have state names
#   But this merge is iffy and im trying to work it out
#nados1 <- merge(nados, fips, by.x = c("state_fip.x","fip1"), by.y = c("fip_state","fip_county") , all.x = TRUE)

#       4.2: Merge GDP data with nado shapefiles
nados <-  subset(nados, year > 2000)
nados$key2 <-  paste(nados$state, nados$year, sep = '')
  # Doing this part in ARCGIS
# master <- merge(nados, ma_gdp, by = c('key2'), duplicateGeoms = TRUE)

########################################

########################################
#     Step 5: Export
########################################

write.csv(ma_gdp, path = '../edit/merge_prep_gdp.csv', na = "")
st_write(nados, )


#######################
# Next Steps from Jesse
#######################

# (1) Use the shape files with lat/long start and end points and overlay with data
#       Might have to do this in arcgis but Im not sure

# (2) Ibtracs Data
#       Take line segments and map to shapes


########################################
#     Spatial Line Vectors
########################################

library(sp)
library(rgdal)
library(raster)
library(ggplot2)
library(rgeos)
library(mapview)
library(leaflet)
library(broom)
library(maptools)
library(zipcode)
library(ggmap)
library(sp)
library(rworldmap)
options(stringsasfacotrs = FALSE)

nados_loc<-nados[,c("start_lat.x","start_lon.x","end_lat.x","end_lon.x","key")]
map<-get_map(location='united_states',zoom=4,maptype='terrain',source='google',color='color')
plot_nado_loc <- st_as_sf(nados_loc1, coords = c("start.lat.x", "start.lon.x"), crs = utm18nCRS)

map<-getMap(resosultion="low")

shape_file <- st_read("../input/1950-2017-torn-aspath/1950-2017-torn-aspath.shp")
st_geometry_type(shape_file)
st_crs(shape_file)
st_bbox(shape_file)
ggplot() + 
  geom_sf(data = shape_file, size = 3, color = "black", fill = "cyan1") + 
  ggtitle("Tornado Plot") + 
  coord_sf()

plot(shape_file, col="cyan1", border="black", lwd=3,
     main="Tornado Plot")
plot(shape_file)