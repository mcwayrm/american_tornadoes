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

setwd("C:/Users/Ryry/Dropbox/American Tornadoes/scripts")
# setwd("jessie local")
# setwd("lilla local")
########################################

########################################
#     Step 1: Import Libraries
########################################

# Handling Dataframes
library(tidyverse)
library(dplyr)
library(reshape2)
# Importing excels
library(readxl) #TODO: Only need this package if we end up using fips...
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
  

# TODO: Unsure if we need the fips and tiger2017 data. Will have to see as we progress

#       2.3: Spatial Data
# fips <- read_excel("../input/US_FIPS_Codes.xls", col_names=TRUE, na= "") %>% 
#   rename(
#     state = "State",
#     county = "County Name",
#     fip_state = "FIPS State",
#     fip_county = "FIPS County"
#   )
# 
# tiger2017 <- read_sf("../input/tiger_2017/tl_2017_us_cbsa.shp") 
########################################

########################################
#     Step 3: Clean
########################################

#       3.1: Drop and add variables in MSA
ma_gdp <- ma_gdp %>% 
  select(ma_gdp, -Region, -TableName, -Unit, -ComponentName) ## TODO: WHY DOESN"T THIS WORK?
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

#       4.2: Merge GDP data with nado shapefiles
nados <-  subset(nados, year > 2000)
nados$key2 <-  paste(nados$state, nados$year, sep = '')
master <- merge(nados, ma_gdp, by = c('key2'), duplicateGeoms = TRUE)
  # TODO: Succesfully need to merge nados with gdp data on year and state, may need to do this by creating unique key
      
########################################

########################################
#     Step 5: Export
########################################

write_sf(master, path= "../edit/master_nados.shp", na= "", col.names = TRUE)

