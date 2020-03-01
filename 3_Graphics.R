
#########################################
#       Title: Graphical Descriptives
#       Author: Ryan McWay and Lilla Szini

#       Description: This script creates the graphical descriptives of the merged data. 

#       Steps:
#           1. Tornado Frequency
#           2. CDF to Check Consistency
#           3. Sector Box Plot

########################################

# Set Working Directory
setwd("C:/Users/Ryry/Dropbox/American_Tornadoes") # Ryan's Directory

#################################
#       Declare Dependencies
#################################
#----------------------------------------------------------------------

# Handling Dataframes
library("tidyverse")
# Stata tools converted 
library("haven")
# Plotting tools
library("ggplot2")
library("ggthemes")
# Spatial Stuff
library("sf")
library("rnaturalearth")
library("rnaturalearthdata")
library("ggspatial")

#----------------------------------------------------------------------

####################################################
#       Step 1.  Tornado Frequency
####################################################

# Total Count, as well as the count by category

####################################################
#       Step 2.  Cummulative Distribution Function
####################################################

# Show consistency of measure (ideally a linear pattern over the time frame)

####################################################
#       Step 3.  Industry Box Plot
####################################################

# What are the dominating sectors in the economic sample?
