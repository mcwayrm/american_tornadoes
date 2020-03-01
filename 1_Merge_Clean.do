***************************************************************
//				~ Resetting Stata ~
***************************************************************

clear
set more off
clear matrix
clear mata
log close _all
timer clear

***************************************************************
//					 ~ Macros ~
***************************************************************

local home C:\Users\Ryry\Dropbox\American_Tornadoes
cd "`home'"

***************************************************************
//				  ~ Start Log File ~
***************************************************************

cd log_files
cap log using 1_Merge_Clean.smcl, smcl replace 

/*******************************
********************************
	Title: Merge and Clean Tornadoes Data
	Author: Ryan McWay and Lilla Szini

	Description:
	Clean the spaital data and the MSA GDP data. Merge the two together and create the treatment variables. 
	
	Steps:
		1. Clean the MSA GDP Data
		2. Clean the Spatial Join
		3. Create Treatment Variables
		4. Collapse to MSA, Year Level
		5. Merge MSA and Spatial Join Data
		
*******************************
********************************/

***************************************************************
//			Step 1:	Clean the MSA GDP Data
***************************************************************

// Start with Muni GDP Data
import excel using `home'\inputs\MAGDP2_2001_2017_clean.xlsx, firstrow clear
rename (K L M N O P Q R S T U V W X Y Z AA) (X2001 X2002 X2003 X2004 X2005 X2006 X2007 X2008 X2009 X2010 X2011 X2012 X2013 X2014 X2015 X2016 X2017)

// Reshape wide to long. Unique id on metropolitian and industry id
egen geoid_place_by_industry = concat(GeoFIPS IndustryId)
reshape long X, i(geoid_place_by_industry) j(year)
rename X gdp_in_mill

// Clean unneed variables
drop Wrong* ComponentName Unit TableName Region
rename GeoFIPS geoid_metro

// Log GDP
gen log_gdp_in_mill	= log(gdp_in_mill)

// Save as .dta prior for merge
save `home'\edits\MAGDP2_2001_2017_clean.dta, replace


***************************************************************
//			Step 2:	Clean the Spatial Join Data
***************************************************************

// Import the simple spatial join of CBSA metro area polygons with tornado paths
import excel using `home'\inputs\simple_spatial_join.xlsx, firstrow clear

// Rename labels they are understandable
rename (FID Join_Count om yr mo dy tz st stf mag inj fat loss closs slat slon elat elon len wid GEOID NAME LSAD) (unique_tornado_id if_nado_joined_muni tornado_id_per_year year month day timezone state state_fip magnitude injuries fatalities property_loss crop_lossin_mill start_lat_tornado start_lon_tornado end_lat_tornado end_lon_tornado length_miles width_yards geoid_metro metro_name metro_micro_id)

// Recode the missing info
recode magnitude (-9 = .)

// Recode for consistency of measure across obeservations
// crop, property loss measures

// Note: if Join_Count == 0 then the tornado did not have a county to match with. Therefore the tornado was not important, and can be dropped
drop if if_nado_joined_muni == 0

// We do not have MSA data before 2001, so dropping now will make _merge indicators clearer
drop if year < 2001

***************************************************************
//			Step 3:	Create Treatment Variables
***************************************************************

// Note: Besides highest_cat, the treatment will be aggregated for MSA, Year via the collapse

// Highest Category that hit an MSA in a given year
egen highest_cat = max(magnitude), by(geoid_metro year)

// Dummy for the category of a tornado
gen if_cat_0 = 0
replace if_cat_0 = 1 if magnitude == 0
gen if_cat_1 = 0
replace if_cat_1 = 1 if magnitude == 1
gen if_cat_2 = 0 
replace if_cat_2 = 1 if magnitude == 2
gen if_cat_3 = 0 
replace if_cat_3 = 1 if magnitude == 3
gen if_cat_4 = 0 
replace if_cat_4 = 1 if magnitude == 4
gen if_cat_5 = 0 
replace if_cat_5 = 1 if magnitude == 5

// Note: How do we want to address length and width of the tornado? Do we keep it after the collapse?

***************************************************************
//			Step 4:	Collapse to MSA, Year Level
***************************************************************

collapse (sum) if_nado_joined_muni if_cat_0 if_cat_1 if_cat_2 if_cat_3 if_cat_4 if_cat_5 injuries fatalities property_loss crop_lossin_mill (firstnm) highest_cat state state_fip metro_name metro_micro_id MEMI, by(geoid_metro year)

rename (if_nado_joined_muni if_cat_0 if_cat_1 if_cat_2 if_cat_3 if_cat_4 if_cat_5) (count_nados count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5)

// Total Tornadoes hit wieghted by category
gen nado_intensity = 0
replace nado_intensity = count_cat_0 * 1 + count_cat_1 * 2 + count_cat_2 * 3 + count_cat_3 * 4 + count_cat_4 * 5 + count_cat_5 * 6

// Lagged Effects
egen metro_id = group(geoid_metro)
xtset metro_id year

// Lagged Intensity
gen nado_intensity_lag1 = l.nado_intensity
gen nado_intensity_lag2 = l2.nado_intensity

// Lagged Count
gen count_nados_lag1 = l.count_nados
gen count_nados_lag2 = l2.count_nados

// Lagged Highest Cat
gen highest_cat_lag1 = l.highest_cat
gen highest_cat_lag2 = l2.highest_cat

// Lagged Cat 0 Count
gen count_cat_0_lag1 = l.count_cat_0
gen count_cat_0_lag2 = l2.count_cat_0

// Lagged Cat 1 Count
gen count_cat_1_lag1 = l.count_cat_1
gen count_cat_1_lag2 = l2.count_cat_1

// Lagged Cat 2 Count
gen count_cat_2_lag1 = l.count_cat_2
gen count_cat_2_lag2 = l2.count_cat_2

// Lagged Cat 3 Count
gen count_cat_3_lag1 = l.count_cat_3
gen count_cat_3_lag2 = l2.count_cat_3

// Lagged Cat 4 Count
gen count_cat_4_lag1 = l.count_cat_4
gen count_cat_4_lag2 = l2.count_cat_4

// Lagged Cat 5 Count
gen count_cat_5_lag1 = l.count_cat_5
gen count_cat_5_lag2 = l2.count_cat_5

***************************************************************
//			Step 5:	Merge MSA and Spatial Join
***************************************************************

// For a given MSA in a given year, there should be 1 for the many sectors of that MSA in that time. Therefore, 1:m
merge 1:m geoid_metro year using `home'\edits\MAGDP2_2001_2017_clean.dta

// The issue is for master not matching, when they should match.
drop if _merge == 1

// Replace null values for control areas

foreach v in count_nados count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 nado_intensity{
	replace `v' = 0 if _merge == 2
}

// Dummy variable for treatment status
gen treated = 0
replace treated = 1 if _merge == 3

// Remove _merge incase we want to merge more data
drop _merge

// Save as .csv 
export delimited using `home'\edits\master.csv, replace

***************************************************************
//				  ~ Complete Log File ~
***************************************************************

cap log close
cd `home'\log_files
translate 1_Merge_Clean.smcl 1_Merge_Clean.pdf, replace
