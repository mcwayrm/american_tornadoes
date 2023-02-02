# Clear Variables
remove(list = ls())
# Capture Today's Date
today <- Sys.Date()
today <- format(today, format = "%y%m%d")

# Set Working Directory
user <- Sys.info()["user"]
if (user == "ryanm") {
  # Ryan 
  setwd("C:/Users/ryanm/Dropbox (Personal)/American_Tornadoes/")
}
if (user == "rmcway") {
  # Ryan 
  setwd("C:/Users/rmcway/Dropbox (Personal)/American_Tornadoes/")
}

#################################
#       Path Directories
#################################

# Scripts 
path_script_setup <- "./scripts/"
# Data 
path_data_nados   <- "./inputs/1950-2017-torn-aspath/"
path_data_msa     <- "./inputs/CBSA_tracks/"
path_data_county  <- "./inputs/census_tracks/"
path_data_states  <- "./inputs/state_tracks/"
# Output 
path_output_setup <- "./edits/"

#################################
#       Declare Dependencies
#################################

#----------------------------------------------------------------------
# Handling Dataframes
library("tidyverse")
# Export as Stata 
library("haven")
# Add Variable Labels 
library("expss")
# Plotting
library("ggplot2") 
# Spatial Backbones
library("sf")
library("rgdal")
# Spatial Mapping
library("leaflet")
library("leaflet.extras")
library("ggmap")
# Set Seed
set.seed(1234)
#---------------------------------------------------------------------- 


#################################
#       Update Version
#################################

# Create a dated version 
file.copy(paste0(path_script_setup,"1_spatial_match.R"),
          paste0(path_script_setup,"dated/"), 
          overwrite = TRUE)
file.rename(paste0(path_script_setup,"dated/1_spatial_match.R"),
            paste0(path_script_setup,"dated/1_spatial_match_",today,".R"))


####################################################
#       Bring in Datasets
#################################################### 

# TODO: Question for Jesse, US territories in data? Makes sense to me to do so. 

# Reference for source of administrative boundaries
  # https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html

# Bring in County Polygons
sf_counties <- read_sf(paste0(path_data_county,"tl_2019_us_county.shp"))
  # Declare Reference System as WGS84 as datum and Azimuthal equidistant projection (preserve distance)
  sf_counties <- st_transform(sf_counties, crs = "+proj=latlon +datum=WGS84")

  # TODO: Double Check County Count = N
  assertthat::are_equal(nrow(sf_counties), 3,243)
    # NOTE: 100 counties in US territories, so 3,143 for contiguous US
  
# TBring in MSA Polygons 
sf_msa <- read_sf(paste0(path_data_msa,"tl_2017_us_cbsa.shp"))
  # Declare Reference System as WGS84 as datum and Azimuthal equidistant projection (preserve distance)
  sf_msa <- st_transform(sf_msa, crs = "+proj=latlon +datum=WGS84")

  # TODO: Double Check MSA Count = N
  assertthat::are_equal(nrow(sf_msa), 927)
    # NOTE: 927 Core Base Statistical Areas 
    # NOTE: 384 Metropolitian Statistical Areas
  
# Bring in State Polygons 
sf_states <- read_sf(paste0(path_data_states,"cb_2018_us_state_500k.shp"))
  # Declare Reference System as WGS84 as datum and Azimuthal equidistant projection (preserve distance)
  sf_states <- st_transform(sf_states, crs = "+proj=latlon +datum=WGS84")

  # TODO: Double Check State Count = N
  assertthat::are_equal(nrow(sf_states), 50)
    # NOTE: Including territories then 56 

# Bring in Tornado Polylines 
sf_nados <- read_sf(paste0(path_data_nados,"1950-2017-torn-aspath.shp"))
  # Declare Reference System as WGS84 as datum and Azimuthal equidistant projection (preserve distance)
  sf_nados <- st_transform(sf_nados, crs = "+proj=latlon +datum=WGS84")

  
####################################################
#       Visually Check 
#################################################### 
  
# Plot the nados and the various data levels to check that everything looks good 
map_nados <- leaflet() %>%
    # Add Basemap
    addTiles(group = "Default") %>%
    # Add State Boundaries
    addPolylines(data = sf_states,
                color = "blue", 
                weight = 1, 
                group = "State", 
                popup = ~ paste0(NAME)) %>% 
    # Add MSA Boundaries
    addPolylines(data = sf_msa,
                color = "red", 
                weight = 1, 
                group = "MSA", 
                popup = ~ paste0(NAME)) %>% 
    # Add County Boundaries
    addPolylines(data = sf_counties,
                color = "green", 
                weight = 1, 
                group = "County",
                popup = ~ paste0(NAME)) %>% 
    # Add Tornado Lines
    addPolylines(data = sf_nados,
                 color = "black", 
                 weight = 1, 
                 group = "Tornadoes",
                 popup = ~ paste0("Magnitude ", mag, ": Date ", date)) %>% 
  addLayersControl(
    baseGroups = c("Default"),
    overlayGroups = c("Tornadoes", "State", "MSA", "County"),
    options = layersControlOptions(collapsed = FALSE)
  ) 
  
# Map out to view
map_nados %>% 
  setView(-93.65, 42.0285, zoom = 4) %>% 
  addDrawToolbar(position = "bottomright",
                 targetGroup = "draw") %>% 
  addMeasure(position = "bottomleft",
             primaryLengthUnit = "meters",
             primaryAreaUnit = "sqmeters",
             activeColor = "#3D535D",
             completedColor = "#7D4479") %>%
  addMiniMap(toggleDisplay = TRUE,
             position = "topleft") 

####################################################
#       Matching based on Within 
#################################################### 
  
# NOTE: This matching will match nados to the polygons for which they are within. If it crosses boundaries, will be assigned to both.
  
# County Match 
df_within_county <- sf::st_contains(x = sf_counties, 
                                    y = sf_nados)
  
  # Make a matrix of indicators for if nado (col) are in county (row)
  df_within_county <- as.data.frame(df_within_county)
  
  # 1 row for each county, with a var with the tornadoes within county
  df_within_county <- df_within_county %>% 
    select(col.id, row.id) %>% 
    group_by(row.id) %>% 
    mutate(tornadoes_witihin = paste0(col.id, collapse = ",")) %>%
    distinct(row.id, tornadoes_witihin, .keep_all = TRUE) %>% 
    select(row.id, tornadoes_witihin) %>% 
    rename(id_county = row.id)

# MSA Match 
df_within_msa <- sf::st_contains(x = sf_msa, 
                                 y = sf_nados)

  # Make a matrix of indicators for if nado (col) are in MSA (row)
  df_within_msa <- as.data.frame(df_within_msa)
  
  # 1 row for each MSA, with a var with the tornadoes within county
  df_within_msa <- df_within_msa %>% 
    select(col.id, row.id) %>% 
    group_by(row.id) %>% 
    mutate(tornadoes_witihin = paste0(col.id, collapse = ",")) %>%
    distinct(row.id, tornadoes_witihin, .keep_all = TRUE) %>% 
    select(row.id, tornadoes_witihin) %>% 
    rename(id_msa = row.id)
  
# State Match
df_within_state <- sf::st_contains(x = sf_states, 
                                   y = sf_nados)

  # Make a matrix of indicators for if nado (col) are in MSA (row)
  df_within_state <- as.data.frame(df_within_state)
  
  # 1 row for each MSA, with a var with the tornadoes within county
  df_within_state <- df_within_state %>% 
    select(col.id, row.id) %>% 
    group_by(row.id) %>% 
    mutate(tornadoes_witihin = paste0(col.id, collapse = ",")) %>%
    distinct(row.id, tornadoes_witihin, .keep_all = TRUE) %>% 
    select(row.id, tornadoes_witihin) %>% 
    rename(id_state = row.id)
  
####################################################
#       Matching based on Intersection
#################################################### 

# NOTE: This matchin will match nados to the polylines that it intersects with. If it crosses boundaries, it will be assigned to both. 
  
# County Match 
df_intersect_county <- sf::st_intersects(x = sf_counties,
                                         y = sf_nados)

  # Make a matrix of indicators for if nado (col) are in county (row)
  df_intersect_county <- as.data.frame(df_intersect_county)
  
  # 1 row for each county, with a var with the tornadoes within county
  df_intersect_county <- df_intersect_county %>% 
    select(col.id, row.id) %>% 
    group_by(row.id) %>% 
    mutate(tornadoes_intersect = paste0(col.id, collapse = ",")) %>%
    distinct(row.id, tornadoes_intersect, .keep_all = TRUE) %>% 
    select(row.id, tornadoes_intersect) %>% 
    rename(id_county = row.id)

# MSA Match 
df_intersect_msa <- sf::st_intersects(x = sf_msa,
                                      y = sf_nados)
  
  # Make a matrix of indicators for if nado (col) are in county (row)
  df_intersect_msa <- as.data.frame(df_intersect_msa)
  
  # 1 row for each county, with a var with the tornadoes within county
  df_intersect_msa <- df_intersect_msa %>% 
    select(col.id, row.id) %>% 
    group_by(row.id) %>% 
    mutate(tornadoes_intersect = paste0(col.id, collapse = ",")) %>%
    distinct(row.id, tornadoes_intersect, .keep_all = TRUE) %>% 
    select(row.id, tornadoes_intersect) %>% 
    rename(id_msa = row.id)

# State Match
df_intersect_state <- sf::st_intersects(x = sf_states,
                                        y = sf_nados)
  
  # Make a matrix of indicators for if nado (col) are in county (row)
  df_intersect_state <- as.data.frame(df_intersect_state)
  
  # 1 row for each county, with a var with the tornadoes within county
  df_intersect_state <- df_intersect_state %>% 
    select(col.id, row.id) %>% 
    group_by(row.id) %>% 
    mutate(tornadoes_intersect = paste0(col.id, collapse = ",")) %>%
    distinct(row.id, tornadoes_intersect, .keep_all = TRUE) %>% 
    select(row.id, tornadoes_intersect) %>% 
    rename(id_state = row.id)

####################################################
#       Save Datasets
#################################################### 
  
# Save the County level spatial matches
write.csv(x = df_within_county, 
          file = paste0(path_output_setup, "spatial_match/match_county_within.csv"))
write.csv(x = df_intersect_county, 
          file = paste0(path_output_setup, "spatial_match/match_county_intersect.csv"))
  
# Save the MSA level spatial matches
write.csv(x = df_within_msa, 
          file = paste0(path_output_setup, "spatial_match/match_msa_within.csv"))
write.csv(x = df_intersect_msa, 
          file = paste0(path_output_setup, "spatial_match/match_msa_intersect.csv"))
  
#  Save the State level spatial matches
write.csv(x = df_within_state, 
          file = paste0(path_output_setup, "spatial_match/match_state_within.csv"))
write.csv(x = df_intersect_state, 
          file = paste0(path_output_setup, "spatial_match/match_state_intersect.csv"))
  
  # TODO: Now IN STATA: 
    # TODO: Reshape very long
    # TODO: Merge on tornado ID to get info 
    # TODO: Create treatment measures by collapsing on admin level and Year
          # NOTE: Year too long a difference in time (attenuation of treatment effects)
    # TODO: Can combine the WITHIN and INTERSECT at same admin level (so has all treatment var)
    # TODO: Clean and Merge in Admin level data varying by Year
