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
# Local Directory Paths

setwd("C:/Users/Ryry/Dropbox/American Tornadoes/scripts") # Ryan local
# setwd("~/Dropbox/American Tornadoes/scripts") # Lilla local
########################################

########################################
#     Step 1: Import Libraries
########################################

# Handling Dataframes
library('tidyverse')
library('dplyr')
library('reshape2')
library('plyr')
# Importing excels
library('readxl')
# Geospatial Packages
library('sf')
library('raster')
library('rgdal')

########################################

########################################
#     Step 2: Import Data
########################################

#       2.1: Tornado Data
torn_as_path <- read_sf("../input/1950-2017-torn-aspath/1950-2017-torn-aspath.shp") 
torn_as_path <- rename(torn_as_path,
    instance_by_year = om,
    time_zone = tz,
    year = yr,
    month = mo,
    day = dy,
    state = st,
    magnitude = mag,
    state_fip = stf,
    crop_loss_mill = closs,
    start_lat = slat,
    start_lon = slon,
    end_lat = elat,
    end_lon = elon,
    injuries = inj,
    fatalities = fat,
    property_loss = loss,
    length_miles = len,
    width_yards = wid,
    magnitude_color = stroke
  )

#       2.2: Economic Data
ma_gdp <- read.csv("../input/MAGDP2_2001_2017_ALL_AREAS.csv", header = TRUE, na.strings = "(NA)") 
ma_gdp <-  rename(ma_gdp,
    city_state = GeoName,
    industry_id = IndustryId,
    industry_class = IndustryClassification,
    sector = Description
  ) 

cbsa <-  read_sf("../input/CBSA/tl_2017_us_cbsa.shp")

## TODO: What the hell is (D) in the dataset? Mark (D) as NA as well

#       2.3: Spatial Data
census_track <-  read_sf("../input/census/tl_2019_us_county.shp")

fips <- read_excel("../input/US_FIPS_Codes.xls", col_names=TRUE, na= "") %>% 
  rename(
    state = "State",
    county = "County Name",
    fip_state = "FIPS State",
    fip_county = "FIPS County"
  )

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
# Remove the citations at the bottom: The data came from US Burea of Commerce
ma_gdp <- ma_gdp[-c(568001, 568002, 568003, 568004),] 

#       3.3: Standardize variables for nados
torn_as_path$property_loss <- as.character(torn_as_path$property_loss)
# if(torn_as_path$year < 1997) 
torn_as_path$property_loss <- revalue(torn_as_path$property_loss, c('0' =  NA,'1' = '0.000025', '2' = '0.000275', '3' = '0.00275', '4' = '0.0275', '5' = '0.275', '6' = '2.75', '7' = '27.5', '8' = '275', '9' = '5000'))
torn_as_path$property_loss <- as.numeric(torn_as_path$property_loss)
torn_as_path$property_loss <- torn_as_path$property_loss * 1000000

# TODO: Remark 0 to NA where suppose to
# TODO: Length is wrong from what they give us, so will have to calcuate length for accuracy. Will have to take width at their word

########################################

########################################
#     Step 4: Merge
########################################

#       4.1: MSA to CBSA shapefile
merge_gdp <- full_join.sf(cbsa, ma_gdp, by.x = GEOID, by.y = GeoFIPS)


########################################

########################################
#     Step 5: Export
########################################

#     5.1 Save clean nado_paths
st_write(torn_as_path, paste0("C:\Users\Ryry\Dropbox\American Tornadoes\edit\nados_edit.shp"))

#     5.2 Save merged census track
st_write(merge_gdp, paste0("C:\Users\Ryry\Dropbox\American Tornadoes\edit\nados_edit.shp"))

#######################
# Next Step: Merge in ArcGIS
#######################

---------------------------------------------------------------------------------
########################################
#     Spatial Line Vectors
      # EXTRA #
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