***************************************************************
//				~ Resetting Stata ~
***************************************************************

clear
set more off
clear matrix
clear mata
eststo clear
log close _all
timer clear

***************************************************************
//					 ~ Dependencies ~
***************************************************************

// Flag in the beginning to download ado files needed to run
foreach package in egen {
	cap which `package'
	if _rc di "This script needs -`package'-, please install first (try -ssc install `package'-)"
}

***************************************************************
//					 ~ Macros ~
***************************************************************

// 			NOTE: Switch directory on your local server and this will run smoothly conditional your data is entirely in this subdirectory.
 
***************************************************************
//					 ~ Path Directories ~
***************************************************************

// Team Member Directories
if "`c(username)'" == "ryanm" {
		// Ryan's Directory
		global dir "C:\Users\ryanm\Dropbox"     
	}
	else if "`c(username)'" == "" {
		// Lilla's Directory
		global dir "" 
	}
	else {
		// Jesse's Directory
		global dir "" 
	}	

// Folder Navigation
local home $dir\American_Tornadoes

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
		1. Clean MSA GDP Data
		2. Clean MSA Unemployment Data
		3. Clean MSA Population Data
		4. Clean MSA Various Data
		5. Create MSA Bankruptcy Data 
		6. Clean Housing Data
		7. Clean Wage Data
		8. Clean the Spatial Join
		9. Create Treatment Variables
		10. Collapse to MSA, Year Level
		11. Merge MSA-Year Data and Spatial-Year Data

		
*******************************
********************************/

***************************************************************
//					 ~ Toggle Sections ~
***************************************************************

	// NOTE: To switch on select 'on'; To switch off select 'off'

// Toggle Which Sections to Run
global step1gdp		"off"
global step2unemp	"off"
global step3pop		"off"
global step4vary	"off"
global step5bank	"off"
global step6house	"off"
global step7wage	"off"
global step8nado	"on"
global step9treat	"on"
global step10collapse "on"
global step11merge	"on"

***************************************************************
//			Step 1:	Clean the MSA GDP Data
***************************************************************

if "$step1gdp" == "on" {

// Import MSA GDP Data
import excel using `home'\inputs\MSA_data\MSA_GDP_2001_2017_raw.xlsx, firstrow clear

// Rename Variables
rename (J K L M N O P Q R S T U V W X Y Z Description) ///
		(X2001 X2002 X2003 X2004 X2005 X2006 X2007 X2008 X2009 X2010 X2011 X2012 X2013 X2014 X2015 X2016 X2017 Industry_Type)

// Trim non-observations in data
drop if _n > 33408

// Reshape wide to long. Unique id on metropolitian and industry id
reshape long X, i(GeoFIPS IndustryId) j(year)
rename (X GeoFIPS GeoName) (gdp_in_mill geoid_metro msa_name)

// Clean unneed variables
drop ComponentName Unit TableName Region

// Recode GDP Missing and Null Values 
replace gdp_in_mill = "" if gdp_in_mill == "(D)"
replace gdp_in_mill = "0" if gdp_in_mill == "(NA)"
replace gdp_in_mill = "0" if gdp_in_mill == "(L)"
  
destring gdp_in_mill, replace

// Clean GEOID string
gen geoid_2 = substr(geoid_metro,-7,5)
	drop geoid_metro
	rename (geoid_2) (geoid_metro)
	
// Drop USA Totals
drop if geoid_metro == "00998"

// Keep only the big industries 
keep if IndustryId == 1 | IndustryId == 2 | IndustryId == 3 | IndustryId == 20 | IndustryId == 21 | IndustryId == 49 | IndustryId == 50 | IndustryId == 52 | IndustryId == 53 | IndustryId == 56 | IndustryId == 68 | IndustryId == 72 | IndustryId == 74 | IndustryId == 80 | IndustryId == 82 | IndustryId == 84 | IndustryId == 85 | IndustryId == 86 | IndustryId == 87 

// Create Industry Variables and Collapse on Metro and Year
gen ind_gdp_all 		= gdp_in_mill if IndustryId == 1
gen ind_gdp_privte 		= gdp_in_mill if IndustryId	== 2
gen ind_gdp_agr 		= gdp_in_mill if IndustryId == 3
gen ind_gdp_electric 	= gdp_in_mill if IndustryId == 20
gen ind_gdp_cars 		= gdp_in_mill if IndustryId == 21
gen ind_gdp_tech 		= gdp_in_mill if IndustryId == 49
gen ind_gdp_insure 		= gdp_in_mill if IndustryId == 50
gen ind_gdp_money 		= gdp_in_mill if IndustryId == 52
gen ind_gdp_fin 		= gdp_in_mill if IndustryId == 53
gen ind_gdp_homes 		= gdp_in_mill if IndustryId == 56
gen ind_gdp_edu_health 	= gdp_in_mill if IndustryId == 68
gen ind_gdp_hospital 	= gdp_in_mill if IndustryId == 72
gen ind_gdp_arts 		= gdp_in_mill if IndustryId == 74
gen ind_gdp_food 		= gdp_in_mill if IndustryId == 80
gen ind_gdp_gov 		= gdp_in_mill if IndustryId == 82
gen ind_gdp_milt 		= gdp_in_mill if IndustryId == 84
gen ind_gdp_state_gov 	= gdp_in_mill if IndustryId == 85
gen ind_gdp_mine 		= gdp_in_mill if IndustryId == 86
gen ind_gdp_trade 		= gdp_in_mill if IndustryId == 87
	
collapse (firstnm) msa_name (max) ind_gdp_all ind_gdp_privte ind_gdp_agr ind_gdp_electric  ind_gdp_cars  ind_gdp_tech  ind_gdp_insure ind_gdp_money ind_gdp_fin ind_gdp_homes ind_gdp_edu_health ind_gdp_hospital ind_gdp_arts ind_gdp_food ind_gdp_gov ind_gdp_milt ind_gdp_state_gov ind_gdp_mine ind_gdp_trade, by(geoid_metro year)

// Log GDP Transformation
foreach v in all privte agr electric cars tech insure money fin homes edu_health hospital arts food gov milt state_gov mine trade {
	    gen log_ind_gdp_`v' = log(ind_gdp_`v')
			label var log_ind_gdp_`v' "Log(GDP in Mill `v')"
	}

// Create Missing Dummy Variables, Recode new Var for Missing
foreach v in all privte agr electric cars tech insure money fin homes edu_health hospital arts food gov milt state_gov mine trade {
	    
		// Dummy for Missing
		gen ind_gdp_`v'_miss = 0
			replace ind_gdp_`v'_miss = 1 if ind_gdp_`v' == .
			label var ind_gdp_`v'_miss "Dummy Missing: GDP in Mill `v'"
		gen log_ind_gdp_`v'_miss = 0
			replace log_ind_gdp_`v'_miss = 1 if log_ind_gdp_`v' == .
			label var log_ind_gdp_`v'_miss "Dummy Missing: Log(GDP in Mill `v')"
		
		// New Var Recoding Missing
		gen ind_gdp_`v'_no_miss = ind_gdp_`v'
			recode ind_gdp_`v'_no_miss (. = 0)
			label var ind_gdp_`v'_no_miss "Recode No Missing: GDP in Mill `v'"
		gen log_ind_gdp_`v'_no_miss = log_ind_gdp_`v'
			recode log_ind_gdp_`v'_no_miss (. = 0)
			label var log_ind_gdp_`v'_no_miss "Recode No Missing: Log(GDP in Mill `v')"
	}

// Create Average GDP from 2010 On
egen avg_gdp = mean(ind_gdp_all) if year > 2009, by(geoid_metro)

	
// Label Vars
	// General Info.
	label var year						"Calendar Year"
	label var geoid_metro				"MSA FIPS"
	label var msa_name					"MSA Area Name"
	// Industries
	label var ind_gdp_all		"GDP in Mill: All Industry"
	label var ind_gdp_privte	"GDP in Mill: Private Industry"
	label var ind_gdp_agr		"GDP in Mill: Agr., Forest, Fish, Hunt"
	label var ind_gdp_electric	"GDP in Mill: Electric, Applicance, Components"	
	label var ind_gdp_cars		"GDP in Mill: Motor Vehicles, Parts"
	label var ind_gdp_tech		"GDP in Mill: Data, Hosting, Info."
	label var ind_gdp_insure	"GDP in Mill: Finance, Insure, Real Estate, Lease"
	label var ind_gdp_money		"GDP in Mill: Monetary Authorities"
	label var ind_gdp_fin		"GDP in Mill: Securities, Commodities, Fin. Invest"
	label var ind_gdp_homes		"GDP in Mill: Real Estate, Rental, Lease"	
	label var ind_gdp_edu_health "GDP in Mill: Educ., Health, Social Asst."	
	label var ind_gdp_hospital	"GDP in Mill: Hospitals, Nurse, Resident Care"
	label var ind_gdp_arts		"GDP in Mill: Arts, Rec, Enter., Accomodate, Food"
	label var ind_gdp_food		"GDP in Mill: Food, Drink Places"
	label var ind_gdp_gov		"GDP in Mill: Gov. and Gov Enterprises"
	label var ind_gdp_milt		"GDP in Mill: Military"
	label var ind_gdp_state_gov	"GDP in Mill: State, Local Gov."
	label var ind_gdp_mine		"GDP in Mill: Natural Resource, Mining"
	label var ind_gdp_trade		"GDP in Mill: Trade"
	
// Save as .dta prior for merge
save `home'\edits\MSA_GDP_2001_2017_clean.dta, replace

}

***************************************************************
//			Step 2:	Clean the MSA Unemployment Data
***************************************************************

if "$step2unemp" == "on" {

// Import Annual MSA Unemployment
use `home'\inputs\MSA_data\MSA_Unemployment_1990_2018.dta, clear 
drop _merge
rename (DATE MSACode LAUMT) (date geoid_metro unemp_adj_rate)

// Create Year Var 
gen year = year(date)
drop date

// Clean MSA GeoID 
replace geoid_metro = substr(geoid_metro,3,5)

// Label Vars
label var geoid_metro 		"MSA FIPS"
label var unemp_adj_rate 	"Unemployment Adjusted Rate"
label var year 				"Calendar Year"

// Save as .dta prior for merge
save `home'\edits\MSA_Unemp_1990_2018_clean.dta, replace 
 
}
 
***************************************************************
//			Step 3:	Clean the MSA Population Data
***************************************************************

if "$step3pop" == "on" {

// Import 2000 and 2010 Population Data 
import delimited using `home'\inputs\MSA_data\MSA_Population_2000_2010.csv, clear 
	drop if _n < 9
	drop v6
	drop if v1 == ""
duplicates tag v1, gen(dup)
	drop if dup == 1
	drop dup

	// Create Var Names 
	rename (v1 v2 v3 v4 v5) ///
			(msa_name pop_2000 pop_2010 pop_change_00_10_num_2010 pop_change_00_10_per_2010)
			
	// Reshape Vars to long
	reshape long pop_ pop_change_00_10_num_ pop_change_00_10_per_, i(msa_name) j(year)
	
	// Rename Vars 
	rename (pop_ pop_change_00_10_num_ pop_change_00_10_per_) ///
			(pop_census pop_chg_00_10_num pop_chg_00_10_per)
			
	// Drop Obs which is a comment
	drop if msa_name == "/1 Broomfield County, CO was formed from parts of Adams, Boulder, Jefferson, and Weld Counties, CO on November 15, 2001.  For purposes of presenting data for metropolitan and micropolitan statistical areas for Census 2000, Broomfield is treated as if it were a county, coextensive with Broomfield city, at the time of the census."
	
	// Create GeoID for MSAs
		// TODO: Find systematic way to do this... may need to do long way...
		gen geoid_metro = ""
// 			replace geoid_metro = "" if msa_name == 
			
	// Collapse to the MSA Level
		
	// Label Vars
	label var msa_name			"MSA Area Name"
	label var year				"Calendar Year"
	label var pop_census		"Census Recorded Population"
	label var pop_chg_00_10_num "# Population Change 2000-2010"
	label var pop_chg_00_10_per	"% Population Change 2000-2010"

	// Save as .dta prior to merge
	save `home'\edits\MSA_Pop_2000_2010.dta, replace 

// Import 2010 - 2018 Population Data
import delimited using `home'\inputs\MSA_data\MSA_Population_2010_2018.csv, clear 

	// Keep only MSA level data 
	keep if lsad == "Metropolitan Statistical Area"
	drop mdiv stcou lsad 

	// Reshape Vars to long 
	rename (census2010pop) (census_pop2010)
	reshape long census_pop estimatebase popestimate npopchg births deaths naturalinc internationalmig domesticmig netmig residual, i(cbsa) j(year)
	
	// Rename Vars 
	rename (census_pop estimatebase popestimate npopchg naturalinc internationalmig domesticmig netmig residual cbsa name) /// 
			(pop_census pop_estimate_base pop_estimate pop_chg pop_nat_increase pop_int_mig pop_dom_mig pop_net_mig pop_estimate_residual geoid_metro msa_name)
			
	// GeoID to String
	tostring geoid_metro, replace

	// Label Vars 
	label var pop_census			"Census Recorded Population"
	label var pop_estimate_base		"Estimated Population Base in 2010"
	label var pop_estimate			"Estimated Population"
	label var pop_chg				"Annual Population Change"
	label var pop_nat_increase		"Natural Annual Increase"
	label var births				"Annual Births"
	label var deaths				"Annual Deaths"
	label var pop_int_mig			"Net Annual Int. Migration"
	label var pop_dom_mig			"Net Annual Domestic Migration"
	label var pop_net_mig			"Net Annual Migration"
	label var pop_estimate_residual	"Residual Estimated Population Change"
	label var geoid_metro			"MSA FIPS"
	label var msa_name				"MSA Area Name"
	label var year					"Calendar Year"
	
	// Save as .dta prior to merge
	save `home'\edits\MSA_Pop_2010_2018.dta, replace 
	
}
	
***************************************************************
//			Step 4:	Clean the MSA Various Data
***************************************************************

if "$step4vary" == "on" {

// Editing Cross-Sections 

foreach num of numlist 2010/2018 {
	
	// Import Cross-Section
	import delimited using `home'\inputs\MSA_data\MSA_Emp_Commute_Occ_Ind_Class_Inc_Health_Pov_`num'.csv, clear
	
	// Add Year 
	gen year = `num'
	
	// Save as .dta prior to append
	save `home'\edits\MSA_various_`num'.dta, replace
	
}

// Appending Cross-seciton Data
clear
foreach num of numlist 2010/2018 {
	append using `home'\edits\MSA_various_`num'.dta, force
}

// Drop Margins of Errors
drop *m

// Clean MSA FIP 
split geo_id, parse("US")
drop geo_id1 geo_id
rename geo_id2 geoid_metro

// Clean Var Names 
	
	// Employment 
	rename (dp03_0001e dp03_0001pe dp03_0002e dp03_0002pe dp03_0003e dp03_0003pe dp03_0004e dp03_0004pe dp03_0005e dp03_0005pe dp03_0006e dp03_0006pe dp03_0007e dp03_0007pe dp03_0010e dp03_0010pe dp03_0015e dp03_0015pe dp03_0016e dp03_0016pe) ///
		(emp_pop emp_pop_per emp_labfor emp_labfor_per emp_labfor_civilian emp_labfor_civilian_per emp_labfor_civilian_in emp_labfor_civilian_in_per emp_labfor_civilian_out emp_labfor_civilian_out_per emp_labfor_milt emp_labfor_milt_per emp_no_labfor emp_no_labfor_per emp_pop_fem emp_pop_fem_per emp_all_parent_labfor emp_all_parent_labfor_per emp_pop_teen emp_pop_teen_per)
	
	// Commute
	rename (dp03_0018e dp03_0018pe dp03_0019e dp03_0019pe dp03_0020e dp03_0020pe dp03_0021e dp03_0021pe dp03_0022e dp03_0022pe dp03_0023e dp03_0023pe dp03_0024e dp03_0024pe dp03_0025e) ///
		(comm_all_work comm_all_work_per comm_alone comm_alone_per comm_carpool comm_carpool_per comm_public comm_public_per comm_walk comm_walk_per comm_oth comm_oth_per comm_athome comm_athome_per comm_trav_time)
	
	// Occupation
	rename (dp03_0026e dp03_0026pe dp03_0027e dp03_0027pe dp03_0028e dp03_0028pe dp03_0029e dp03_0029pe dp03_0030e dp03_0030pe dp03_0031e dp03_0031pe) ///
		(occ_civilian occ_civilian_per occ_biz occ_biz_per occ_service occ_service_per occ_sales occ_sales_per occ_construct occ_construct_per occ_transport occ_transport_per)

	
	// Class of Worker 
	rename (dp03_0046e dp03_0046pe dp03_0047e dp03_0047pe dp03_0048e dp03_0048pe dp03_0049e dp03_0049pe dp03_0050e dp03_0050pe) ///
		(class_work_civilian class_work_civilian_per class_work_private class_work_private_per class_work_gov class_work_gov_per class_work_self_emp class_work_self_emp_per class_work_unpaid_fam class_work_unpaid_fam_per)
	
	// Income 
	rename (dp03_0051e dp03_0051pe dp03_0052e dp03_0052pe dp03_0053e dp03_0053pe dp03_0054e dp03_0054pe dp03_0055e dp03_0055pe dp03_0056e dp03_0056pe dp03_0057e dp03_0057pe dp03_0058e dp03_0058pe dp03_0059e dp03_0059pe dp03_0060e dp03_0060pe dp03_0061e dp03_0061pe dp03_0062e dp03_0062pe dp03_0063e dp03_0063pe dp03_0064e dp03_0064pe dp03_0065e dp03_0065pe dp03_0066e dp03_0066pe dp03_0067e dp03_0067pe dp03_0068e dp03_0068pe dp03_0069e dp03_0069pe dp03_0070e dp03_0070pe dp03_0071e dp03_0071pe dp03_0072e dp03_0072pe dp03_0073e dp03_0073pe dp03_0074e dp03_0074pe dp03_0075e dp03_0075pe dp03_0088e dp03_0088pe dp03_0092e dp03_0092pe dp03_0093e dp03_0093pe dp03_0094e dp03_0094pe) ///
		(inc_hh inc_hh_per inc_hh_less_10 inc_hh_less_10_per inc_hh_10_15 inc_hh_10_15_per inc_hh_15_25 inc_hh_15_25_per inc_hh_25_35 inc_hh_25_35_per inc_hh_35_50 inc_hh_35_50_per inc_hh_50_75 inc_hh_50_75_per inc_hh_75_100 inc_hh_75_100_per inc_hh_100_150 inc_hh_100_150_per inc_hh_150_200 inc_hh_150_200_per inc_hh_more_200 inc_hh_more_200_per inc_hh_med inc_hh_med_per inc_hh_mean inc_hh_mean_per inc_hh_earn inc_hh_earn_per inc_hh_earn_mean inc_hh_earn_mean_per inc_hh_soc inc_hh_soc_per inc_hh_soc_mean inc_hh_soc_mean_per inc_hh_retir inc_hh_retir_per inc_hh_retir_mean inc_hh_retir_mean_per inc_hh_supp inc_hh_supp_per inc_hh_supp_mean inc_hh_supp_mean_per inc_hh_asst inc_hh_asst_per inc_hh_asst_mean inc_hh_asst_mean_per inc_hh_snap inc_hh_snap_per inc_hh_fam inc_hh_fam_per inc_per_cap inc_per_cap_per inc_workers_med inc_workers_med_per inc_worker_med_male inc_worker_med_male_per inc_worker_med_fem inc_worker_med_fem_per)
	
	// Healthcare
	rename (dp03_0095e dp03_0095pe dp03_0096e dp03_0096pe dp03_0097e dp03_0097pe dp03_0098e dp03_0098pe dp03_0099e dp03_0099pe dp03_0100e dp03_0100pe dp03_0102e dp03_0102pe dp03_0103e dp03_0103pe dp03_0104e dp03_0104pe dp03_0105e dp03_0105pe dp03_0106e dp03_0106pe dp03_0107e dp03_0107pe dp03_0108e dp03_0108pe dp03_0109e dp03_0109pe dp03_0110e dp03_0110pe dp03_0111e dp03_0111pe dp03_0112e dp03_0112pe dp03_0113e dp03_0113pe dp03_0114e dp03_0114pe dp03_0115e dp03_0115pe dp03_0116e dp03_0116pe dp03_0117e dp03_0117pe dp03_0118e dp03_0118pe) ///
		(hlth_civilian hlth_civilian_per hlth_covered hlth_covered_per hlth_covered_prvt hlth_covered_prvt_per hlth_covered_pub hlth_covered_pub_per hlth_no_covered hlth_no_covered_per hlth_civilian_und_18 hlth_civilian_und_18_per hlth_civilian_18_64 hlth_civilian_18_64_per hlth_labfor hlth_labfor_per hlth_emp hlth_emp_per hlth_covered_emp hlth_covered_emp_per hlth_covered_prvt_emp hlth_covered_prvt_emp_per hlth_covered_pub_emp hlth_covered_pub_emp_per hlth_no_covered_emp hlth_no_covered_emp_per hlth_unemp hlth_unemp_per hlth_covered_unemp hlth_covered_unemp_per hlth_covered_prvt_unemp hlth_covered_prvt_unemp_per hlth_covered_pub_unemp hlth_covered_pub_unemp_per hlth_no_covered_unemp hlth_no_covered_unemp_per hlth_no_labfor hlth_no_labfor_per hlth_covered_no_labfor hlth_covered_no_labfor_per hlth_covered_prvt_no_labfor hlth_covered_prvt_no_labfor_per hlth_covered_pub_no_labfor hlth_covered_pub_no_labfor_per hlth_no_covered_no_labfor hlth_no_covered_no_labfor_per)
	
	// Poverty Measures
	rename (dp03_0119e dp03_0119pe dp03_0120e dp03_0120pe dp03_0121e dp03_0121pe dp03_0122e dp03_0122pe dp03_0123e dp03_0123pe dp03_0124e dp03_0124pe dp03_0125e dp03_0125pe dp03_0126e dp03_0126pe dp03_0127e dp03_0127pe dp03_0128e dp03_0128pe dp03_0129e dp03_0129pe dp03_0130e dp03_0130pe dp03_0131e dp03_0131pe dp03_0132e dp03_0132pe dp03_0133e dp03_0133pe dp03_0134e dp03_0134pe dp03_0135e dp03_0135pe) ///
		(pov_fam pov_fam_per pov_fam_und_18 pov_fam_und_18_per pov_fam_und_5 pov_fam_und_5_per pov_married pov_married_pov pov_married_und_18 pov_married_und_18_per pov_married_und_5 pov_married_und_5_per pov_no_husb pov_no_husb_per pov_no_husb_und_18 pov_no_husb_und_18_per pov_no_husb_und_5 pov_no_husb_und_5_per pov_all pov_all_per pov_und_18 pov_und_18_per pov_und_18_child pov_und_18_child_per pov_und_5 pov_und_5_per pov_5_17 pov_5_17_per pov_above_18 pov_above_18_per pov_18_64 pov_18_64_per pov_above_65 pov_above_65_per)


// Remove extra variable not wanted
drop dp*

// Ensure measures are Numeric
	foreach var in pov_fam pov_fam_und_18 pov_fam_und_5 pov_married pov_married_und_18 pov_married_und_5 pov_no_husb pov_no_husb_und_18 pov_no_husb_und_5 pov_all pov_und_18  pov_und_18_child pov_und_5 pov_5_17 pov_above_18 pov_18_64 pov_above_65 inc_hh_med_per inc_hh_mean_per inc_hh_earn_mean_per inc_hh_soc_mean_per inc_hh_retir_mean_per inc_hh_supp_mean_per inc_hh_asst_mean_per inc_per_cap_per inc_workers_med_per inc_worker_med_male_per inc_worker_med_fem_per {
		// Replace Strings, Then Destring
		replace `var' = "" if `var' == "(X)"
			destring `var', replace
	}
	
	foreach var in emp_all_parent_labfor emp_all_parent_labfor_per emp_pop_teen emp_pop_teen_per comm_all_work comm_all_work_per comm_alone comm_alone_per comm_carpool comm_carpool_per comm_public comm_public_per comm_walk comm_walk_per comm_oth comm_oth_per comm_athome comm_athome_per occ_civilian occ_civilian_per occ_biz occ_biz_per occ_service occ_service_per occ_sales occ_sales_per occ_construct occ_construct_per occ_transport occ_transport_per inc_hh_supp_mean inc_hh_asst_mean {
		// Replace Strings, Then Destring
		replace `var' = "" if `var' == "N"
			destring `var', replace
	}
	
// Label Vars 

	// Employment 	
	label var emp_pop 					"# Employ Status: Pop. Older than 16"
	label var emp_pop_per				"% Employ Status: Pop. Older than 16"
	label var emp_labfor 				"# Employ Status: Labor Force"
	label var emp_labfor_per 			"% Employ Status: Labor Force"
	label var emp_labfor_civilian 		"# Employ Status: Civilian Labor Force"
	label var emp_labfor_civilian_per 	"% Employ Status: Civilian Labor Force"
	label var emp_labfor_civilian_in 	"# Employ Status: Civilian Employed"
	label var emp_labfor_civilian_in_per "% Employ Status: Civilian Employed"
	label var emp_labfor_civilian_out	"# Employ Status: Civilian Unemp"
	label var emp_labfor_civilian_out_per "% Employ Status: Civilian Unemp"
	label var emp_labfor_milt 			"# Employ Status: Military Labor Force"
	label var emp_labfor_milt_per 		"% Employ Status: Military Labor Force"
	label var emp_no_labfor 			"# Employ Status: Not in Labor Force"
	label var emp_no_labfor_per			"% Employ Status: Not in Labor Force" 
	label var emp_pop_fem 				"# Employ Status: Pop. Fem. Older than 16"
	label var emp_pop_fem_per 			"% Employ Status: Pop. Fem. Older than 16"
	label var emp_all_parent_labfor 	"# Employ Status: All Parents in Labor Force"
	label var emp_all_parent_labfor_per "% Employ Status: All Parents in Labor Force"
	label var emp_pop_teen 				"# Employ Status: Pop. Between 6 - 17"
	label var emp_pop_teen_per			"% Employ Status: Pop. Between 6 - 17"
	
	// Commute 
	label var comm_all_work 			"# Commuters: Workers over 16"
	label var comm_all_work_per 		"% Commuters: Workers over 16"
	label var comm_alone 				"# Commuters: Drive Alone"
	label var comm_alone_per 			"% Commuters: Drive Alone"
	label var comm_carpool 				"# Commuters: Carpool"
	label var comm_carpool_per 			"% Commuters: Carpool"
	label var comm_public 				"# Commuters: Public Transit"
	label var comm_public_per 			"% Commuters: Public Transit"
	label var comm_walk 				"# Commuters: Walk"
	label var comm_walk_per 			"% Commuters: Walk"
	label var comm_oth					"# Commuters: Other Means"
	label var comm_oth_per 				"% Commuters: Other Means"
	label var comm_athome				"# Commuters: Work at Home"
	label var comm_athome_per 			"% Commuters: Work at Home"
	label var comm_trav_time 			"Commuters: Mean Travel Time"
	
	// Occupation 
	label var occ_civilian 				"# Occupation: Civilians"
	label var occ_civilian_per 			"% Occupation: Civilians"
	label var occ_biz 					"# Occupation: Mmgt., Biz, Sci., Arts"
	label var occ_biz_per 				"% Occupation: Mmgt., Biz, Sci., Arts"
	label var occ_service 				"# Occupation: Services"
	label var occ_service_per 			"% Occupation: Services"
	label var occ_sales 				"# Occupation: Sales and Office"
	label var occ_sales_per 			"% Occupation: Sales and Office"
	label var occ_construct 			"# Occupation: Nat. Res., Construct., Maintence"
	label var occ_construct_per 		"% Occupation: Nat. Res., Construct., Maintence"
	label var occ_transport 			"# Occupation: Prod., Transport, Material Move"
	label var occ_transport_per			"% Occupation: Prod., Transport, Material Move"
	
	// Class of Worker 
	label var class_work_civilian 		"# Workers Employed: Civilians"
	label var class_work_civilian_per 	"% Workers Employed: Civilians"
	label var class_work_private 		"# Workers Employed: Private Wage & Salary"
	label var class_work_private_per 	"% Workers Employed: Private Wage & Salary"
	label var class_work_gov 			"# Workers Employed: Government"
	label var class_work_gov_per 		"% Workers Employed: Government"
	label var class_work_self_emp 		"# Workers Employed: Self-Employed Not Inc."
	label var class_work_self_emp_per 	"% Workers Employed: Self-Employed Not Inc."
	label var class_work_unpaid_fam 	"# Workers Employed: Unpaid Family Work"
	label var class_work_unpaid_fam_per	"% Workers Employed: Unpaid Family Work"
	
	// Income 
	label var inc_hh 					"# Income: Household"
	label var inc_hh_per 				"% Income: Household"
	label var inc_hh_less_10 			"# Income: Households Under $10 K"
	label var inc_hh_less_10_per 		"% Income: Household Under $10 K"
	label var inc_hh_10_15 				"# Income: Households Between $10 - $15 K"
	label var inc_hh_10_15_per 			"% Income: Households Between $10 - $15 K"
	label var inc_hh_15_25 				"# Income: Households Between $15 - $25 K"
	label var inc_hh_15_25_per 			"% Income: Households Between $15 - $25 K"
	label var inc_hh_25_35 				"# Income: Households Between $25 - $35 K"
	label var inc_hh_25_35_per 			"% Income: Households Between $25 - $35 K"
	label var inc_hh_35_50 				"# Income: Households Between $35 - $50 K"
	label var inc_hh_35_50_per 			"% Income: Households Between $35 - $50 K"
	label var inc_hh_50_75 				"# Income: Households Between $50 - $75 K"
	label var inc_hh_50_75_per 			"% Income: Households Between $50 - $75 K"
	label var inc_hh_75_100 			"# Income: Households Between $75 - $100 K"
	label var inc_hh_75_100_per 		"% Income: Households Between $75 - $100 K"
	label var inc_hh_100_150			"# Income: Households Between $100 - $150 K"
	label var inc_hh_100_150_per 		"% Income: Households Between $100 - $150 K"
	label var inc_hh_150_200 			"# Income: Households Between $150 - $200 K"
	label var inc_hh_150_200_per 		"% Income: Households Between $150 - $200 K"
	label var inc_hh_more_200 			"# Income: Households Above $200 K"
	label var inc_hh_more_200_per 		"% Income: Households Above $200 K"
	label var inc_hh_med 				"# Income: Median HH"
	label var inc_hh_med_per 			"% Income: Median HH"
	label var inc_hh_mean 				"# Income: Mean HH"
	label var inc_hh_mean_per 			"% Income: Mean HH"
	label var inc_hh_earn 				"# Income: From Earnings"
	label var inc_hh_earn_per 			"% Income: From Earnings"
	label var inc_hh_earn_mean 			"# Income: Mean Earnings"
	label var inc_hh_earn_mean_per 		"% Income: Mean Earnings"
	label var inc_hh_soc 				"# Income: From Social Security"
	label var inc_hh_soc_per 			"% Income: From Social Security"
	label var inc_hh_soc_mean 			"# Income: Mean Social Security"
	label var inc_hh_soc_mean_per 		"% Income: Mean Social Security"
	label var inc_hh_retir 				"# Income: From Retirement"
	label var inc_hh_retir_per 			"% Income: From Retirement"
	label var inc_hh_retir_mean 		"# Income: Mean Retirement"
	label var inc_hh_retir_mean_per 	"% Income: Mean Retirement"
	label var inc_hh_supp 				"# Income: From Supplemental Securities"
	label var inc_hh_supp_per 			"% Income: From Supplemental Securities"
	label var inc_hh_supp_mean 			"# Income: Mean Supplemental Securities"
	label var inc_hh_supp_mean_per 		"% Income: Mean Supplemental Securities"
	label var inc_hh_asst 				"# Income: From Public Assistance"
	label var inc_hh_asst_per 			"% Income: From Public Assistance"
	label var inc_hh_asst_mean 			"# Income: Mean Public Assistance"
	label var inc_hh_asst_mean_per 		"% Income: Mean Public Assistance"
	label var inc_hh_snap 				"# Income: From SNAP / Food Stamps"
	label var inc_hh_snap_per 			"% Income: From SNAP / Food Stamps"
	label var inc_hh_fam 				"# Income: From Family"
	label var inc_hh_fam_per 			"% Income: From Family"
	label var inc_per_cap 				"# Income: Per Capita"
	label var inc_per_cap_per 			"% Income: Per Capita"
	label var inc_workers_med 			"# Income: Median Workers Earnings"
	label var inc_workers_med_per 		"% Income: Median Workers Earnings"
	label var inc_worker_med_male 		"# Income: Median Male Workers Earnings"
	label var inc_worker_med_male_per 	"% Income: Median Male Workers Earnings"
	label var inc_worker_med_fem 		"# Income: Median Female Workers Earnings"
	label var inc_worker_med_fem_per	"% Income: Median Female Workers Earnings"
	
	// Healthcare 
	label var hlth_civilian 			"# Health Cov: Civilian Non-Inst. Pop."
	label var hlth_civilian_per			"% Health Cov: Civilian Non-Inst. Pop."
	label var hlth_covered 				"# Health Cov: With Health Coverage"
	label var hlth_covered_per 			"% Health Cov: With Health Coverage"
	label var hlth_covered_prvt 		"# Health Cov: With Private Health Coverage"
	label var hlth_covered_prvt_per 	"% Health Cov: With Private Health Coverage"
	label var hlth_covered_pub 			"# Health Cov: With Public Health Coverage"
	label var hlth_covered_pub_per 		"% Health Cov: With Public Health Coverage"
	label var hlth_no_covered 			"# Health Cov: No Health Coverage"
	label var hlth_no_covered_per 		"% Health Cov: No Health Coverage"
	label var hlth_civilian_und_18 		"# Health Cov: Civilian Non-Inst. Pop. Under 18"
	label var hlth_civilian_und_18_per 	"% Health Cov: Civilian Non-Inst. Pop. Under 18"
	label var hlth_civilian_18_64 		"# Health Cov: Civilian Non-Inst. Pop. 18 - 64"
	label var hlth_civilian_18_64_per 	"% Health Cov: Civilian Non-Inst. Pop. 18 - 64"
	label var hlth_labfor 				"# Health Cov: In Labor Force"
	label var hlth_labfor_per			"% Health Cov: In Labor Force"
	label var hlth_emp 					"# Health Cov: Employed"
	label var hlth_emp_per 				"% Health Cov: Employed"
	label var hlth_covered_emp 			"# Health Cov: Employed With Coverage"
	label var hlth_covered_emp_per 		"% Health Cov: Employed With Coverage"
	label var hlth_covered_prvt_emp 	"# Health Cov: Employed with Private Coverage"
	label var hlth_covered_prvt_emp_per "% Health Cov: Employed with Private Coverage"
	label var hlth_covered_pub_emp 		"# Health Cov: Employed with Public Coverage"
	label var hlth_covered_pub_emp_per 	"% Health Cov: Employed with Public Coverage"
	label var hlth_no_covered_emp 		"# Health Cov: Employed with No Coverage"
	label var hlth_no_covered_emp_per 	"% Health Cov: Employed with No Coverage"
	label var hlth_unemp 				"# Health Cov: Unemployed"
	label var hlth_unemp_per 			"% Health Cov: Unemployed"
	label var hlth_covered_unemp 		"# Health Cov: Unemployed With Coverage"
	label var hlth_covered_unemp_per 	"% Health Cov: Unemployed With Coverage"
	label var hlth_covered_prvt_unemp 	"# Health Cov: Unemployed with Private Coverage"
	label var hlth_covered_prvt_unemp_per "% Health Cov: Unemployed with Private Coverage"
	label var hlth_covered_pub_unemp 	"# Health Cov: Unemployed with Public Coverage"
	label var hlth_covered_pub_unemp_per "% Health Cov: Unemployed with Public Coverage"
	label var hlth_no_covered_unemp 	"# Health Cov: Unemployed with No Coverage"
	label var hlth_no_covered_unemp_per "% Health Cov: Unemployed with No Coverage"
	label var hlth_no_labfor			"# Health Cov: No Labor Force"
	label var hlth_no_labfor_per 		"% Health Cov: No Labor Force"
	label var hlth_covered_no_labfor 	"# Health Cov: No Labor Force with Coverage"
	label var hlth_covered_no_labfor_per "% Health Cov: No Labor Force with Coverage"
	label var hlth_covered_prvt_no_labfor "# Health Cov: No Labor Force with Private Coverage"
	label var hlth_covered_prvt_no_labfor_per "% Health Cov: No Labor Force with Private Coverage"
	label var hlth_covered_pub_no_labfor "# Health Cov: No Labor Force with Public Coverage"
	label var hlth_covered_pub_no_labfor_per "% Health Cov: No Labor Force with Public Coverage" 
	label var hlth_no_covered_no_labfor "# Health Cov: No Labor Force with No Coverage"
	label var hlth_no_covered_no_labfor_per "% Health Cov: No Labor Force with No Coverage"
	
	// Poverty Measures
	label var pov_fam 					"# Poverty: Families"
	label var pov_fam_per 				"% Poverty: Families"
	label var pov_fam_und_18 			"# Poverty: Families w/ Under 18"
	label var pov_fam_und_18_per 		"% Poverty: Families w/ Under 18"
	label var pov_fam_und_5 			"# Poverty: Families w/ Under 5"
	label var pov_fam_und_5_per 		"% Poverty: Families w/ Under 5"
	label var pov_married 				"# Poverty: Married Couples"
	label var pov_married_pov 			"% Poverty: Married Couples"
	label var pov_married_und_18 		"# Poverty: Married Couples w/ Under 18"
	label var pov_married_und_18_per 	"% Poverty: Married Couples w/ Under 18"
	label var pov_married_und_5 		"# Poverty: Married Couples w/ Under 5"
	label var pov_married_und_5_per 	"% Poverty: Married Couples w/ Under 5"
	label var pov_no_husb 				"# Poverty: Families w/ No Husband"
	label var pov_no_husb_per 			"% Poverty: Families w/ No Husband"
	label var pov_no_husb_und_18 		"# Poverty: Families w/ No Husband w/ Under 18"
	label var pov_no_husb_und_18_per	"% Poverty: Families w/ No Husband w/ Under 18"
	label var pov_no_husb_und_5 		"# Poverty: Families w/ No Husband w/ Under 5"
	label var pov_no_husb_und_5_per 	"% Poverty: Families w/ No Husband w/ Under 5"
	label var pov_all 					"# Poverty: All Ind."
	label var pov_all_per 				"% Poverty: All Ind."
	label var pov_und_18				"# Poverty: Ind. Under 18"
	label var pov_und_18_per			"% Poverty: Ind. Under 18"
	label var pov_und_18_child 			"# Poverty: Ind. Under 18 Who is Child"
	label var pov_und_18_child_per		"% Poverty: Ind. Under 18 Who is Child"
	label var pov_und_5 				"# Poverty: Ind. Under 5"
	label var pov_und_5_per				"% Poverty: Ind. Under 5"
	label var pov_5_17 					"# Poverty: Ind. 5 - 17"
	label var pov_5_17_per				"% Poverty: Ind. 5 - 17"
	label var pov_above_18				"# Poverty: Ind. Above 18"
	label var pov_above_18_per			"% Poverty: Ind. Above 18"
	label var pov_18_64 				"# Poverty: Ind. 18 - 64"
	label var pov_18_64_per				"% Poverty: Ind. 18 - 64"
	label var pov_above_65				"# Poverty: Ind. Above 65"
	label var pov_above_65_per			"% Poverty: Ind. Above 65"
	
// Save as .dta prior to merge
	save `home'\edits\MSA_various_2010_2018.dta, replace 

}
	
***************************************************************
//			Step 5:	Clean the MSA Bankruptcy Data
***************************************************************

if "$step5bank" == "on" {

// Classify Counties as MSA 
	
	// NOTE: Use MSA County Crosswalk, Merge on the crosswalk (county id), then collapse to MSA level

// 

}

***************************************************************
//			Step 6:	Clean Housing Data
***************************************************************

if "$step6house" == "on" {

// Combine Homeowner Rates

// Combine Homeowner Vacancy Rates

// Combine Rental Vacancy Rates

}

***************************************************************
//			Step 7:	Clean Wage Data
***************************************************************

if "$step7wage" == "on" {

// Pull the first observation of each file, save as small .csv

// append the .csv files

}

***************************************************************
//			Step 8:	Clean the Spatial Join Data
***************************************************************

if "$step8nado" == "on" {

// Import the simple spatial join of CBSA metro area polygons with tornado paths
import excel using `home'\edits\simple_spatial_join.xlsx, firstrow clear

// Rename labels they are understandable
rename (FID Join_Count om yr mo dy tz st stf mag inj fat loss closs slat slon elat elon len wid GEOID NAME LSAD) (unique_tornado_id if_nado_joined_muni tornado_id_per_year year month day timezone state state_fip magnitude injuries fatalities property_loss crop_lossin_mill start_lat_tornado start_lon_tornado end_lat_tornado end_lon_tornado length_miles width_yards geoid_metro metro_name metro_micro_id)

// Recode the missing info
recode magnitude (-9 = .)

// Recode for consistency of measure across obeservations
// crop, property loss measures

// Note: if Join_Count == 0 then the tornado did not have a county to match with. Therefore the tornado was not important, and can be dropped
drop if if_nado_joined_muni == 0

// Create average tornadoes 1980 - 2010 by MSA 
egen tot_nados = total(if_nado_joined_muni) if year > 1979 & year < 2011, by(geoid_metro)
gen avg_nados = tot_nados/32 
	// NOTE: 32 Years from 1979 to 2011
	label var avg_nados	"Average Tornado Count: 1980 - 2010"
		// TODO: Replace Null for before 2010 on average

// We do not have MSA data before 2001, so dropping now will make _merge indicators clearer
drop if year < 2001

}

***************************************************************
//			Step 9:	Create Treatment Variables
***************************************************************

if "$step9treat" == "on" {

// Note: Besides highest_cat, the treatment will be aggregated for MSA, Year via the collapse

// Highest Category that hit an MSA in a given year
egen highest_cat = max(magnitude), by(geoid_metro year)

// Dummy for the category of a tornado
forvalue i = 0/5 {
    gen if_cat_`i' = 0
	replace if_cat_`i' = 1 if magnitude == `i'
	}

}

***************************************************************
//			Step 10:	Collapse to MSA, Year Level
***************************************************************

if "$step10collapse" == "on" {

collapse (sum) if_nado_joined_muni if_cat_0 if_cat_1 if_cat_2 if_cat_3 if_cat_4 if_cat_5 injuries fatalities property_loss crop_lossin_mill (firstnm) highest_cat state state_fip metro_name metro_micro_id MEMI avg_nados, by(geoid_metro year)

// Rename Variables
rename (if_nado_joined_muni if_cat_0 if_cat_1 if_cat_2 if_cat_3 if_cat_4 if_cat_5) (count_nados count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5)

// Total Tornadoes hit wieghted by category
gen nado_intensity = 0
	replace nado_intensity = count_cat_0 * 1 + count_cat_1 * 2 + count_cat_2 * 3 + count_cat_3 * 4 + count_cat_4 * 5 + count_cat_5 * 6
	label var nado_intensity "Tornado Intensity: Category * Category Count"

// Lagged Effects
egen metro_id = group(geoid_metro)
xtset metro_id year

	// Lagged Intensity
	gen nado_intensity_lag1 = L.nado_intensity
		label var nado_intensity_lag1	"Tornado Intensity: 1 Year Lag"
	gen nado_intensity_lag2 = L2.nado_intensity
		label var nado_intensity_lag2	"Torndao Intensity: 2 Year Lag"

	// Lagged Count
	gen count_nados_lag1 = L.count_nados
		label var count_nados_lag1 		"Tornado Count: 1 Year Lag"
	gen count_nados_lag2 = L2.count_nados
		label var count_nados_lag2		"Tornado Count: 2 Year Lag"

	// Lagged Highest Cat
	gen highest_cat_lag1 = L.highest_cat
		label var highest_cat_lag1		"Highest Category Tornado: 1 Year Lag"
	gen highest_cat_lag2 = L2.highest_cat
		label var highest_cat_lag2		"Highest Category Tornado: 2 Year Lag"

// Create Nado Category Count
forvalue i = 0/5 {
    gen count_cat_`i'_lag1 = L.count_cat_`i'
		label var count_cat_`i'_lag1	"Tornado Count Cat `i': 1 Year Lag"
	gen count_cat_`i'_lag2 = L2.count_cat_`i'
		label var count_cat_`i'_lag2	"Tornado Count Cat `i': 2 Year Lag"
}

// Leading Effects

	// Leading Intensity
	gen nado_intensity_lead1 = F.nado_intensity
		label var nado_intensity_lead1	"Tornado Intensity: 1 Year Lead"
	gen nado_intensity_lead2 = F2.nado_intensity
		label var nado_intensity_lead2	"Tornado Intensity: 2 Year Lead"

	// Leading Count
	gen count_nados_lead1 = F.count_nados
		label var count_nados_lead1		"Tornado Count: 1 Year Lead"
	gen count_nados_lead2 = F2.count_nados
		label var count_nados_lead2		"Tornado Count: 2 Year Lead"

	// Leading Highest Cat
	gen highest_cat_lead1 = F.highest_cat
		label var highest_cat_lead1		"Highest Category Tornado: 1 Year Lead"
	gen highest_cat_lead2 = F2.highest_cat
		label var highest_cat_lead2		"Highest Category Tornado: 2 Year Lead"

// Create Lead Nado Category Count
forvalue i = 0/5 {
    gen count_cat_`i'_lead1 = F.count_cat_`i'
		label var count_cat_`i'_lead1	"Tornado Count Cat `i': 1 Year Lead"
	gen count_cat_`i'_lead2 = F2.count_cat_`i'
		label var count_cat_`i'_lead2	"Tornado Count Cat `i': 2 Year Lead"
}

// Label Tornado Variables	
label var year				"Calendar Year"
label var geoid_metro		"MSA FIPS"
label var count_nados		"Tornado Count"
label var count_cat_0		"Tornado Count Cat 0"
label var count_cat_1		"Tornado Count Cat 1"
label var count_cat_2 		"Tornado Count Cat 2"
label var count_cat_3 		"Tornado Count Cat 3"
label var count_cat_4 		"Tornado Count Cat 4"
label var count_cat_5 		"Tornado Count Cat 5"
label var injuries			"# of Tornado Injuries"
label var fatalities		"# of Tornado Deaths"
label var property_loss		"Property Loss from Tornadoes in Mill"
label var crop_lossin_mill 	"Crop Loss from Tornadoes in Mill"
label var highest_cat		"Highest Category Tornado"
label var state				"State Abbr."
label var state_fip			"State FIPS Code"

}

***************************************************************
//			Step 11:	Merge MSA-Year Data and Spatial-Year Data
***************************************************************

if "$step11merge" == "on" {

// Merge to GDP Sector Data
merge 1:1 geoid_metro year using `home'\edits\MSA_GDP_2001_2017_clean.dta

	// The issue is for master not matching, when they should match.
	drop if _merge == 1 & MEMI == "2"
		// NOTE: We need to revist this...

	// Replace null values for control areas
	foreach v in count_nados count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 nado_intensity{
		replace `v' = 0 if _merge == 2
	}
		
	// Remove _merge incase we want to merge more data
	drop _merge	

// Merge to Unemployment Data
merge 1:1 geoid_metro year using `home'\edits\MSA_Unemp_1990_2018_clean.dta

	// Drop _Merge
	drop if _merge == 2
	drop _merge

// Merge to Population Data
// merge 1:1 geoid_metro year using `home'\edits\MSA_Pop_2000_2010.dta

merge 1:1 geoid_metro year using `home'\edits\MSA_Pop_2010_2018.dta

	// Drop _Merge
	drop if _merge == 2
	drop _merge

// Merge to Various Data
merge 1:1 geoid_metro year using `home'\edits\MSA_various_2010_2018.dta

	// Drop _Merge
	drop if _merge == 2
	drop _merge
	
// Merge to Bankruptcy Data	
	
// Merge to Housing Data 

// Merge to Wage Data

// Recode Missing to Zero
recode property_loss crop_lossin_mill fatalities injuries (. = 0)

// Switch Geoid to Numeric
destring geoid_metro, replace

xtset geoid_metro year

// Dummy variable for treatment status
gen treated = 0
	replace treated = 1 if count_nados > 0
	label var treated 	"Treated: Exp. Tornado Activity"

// Create Log Difference Measurements
	// GDP Sectors
	foreach v in all privte agr electric cars tech insure money fin homes edu_health hospital arts food gov milt state_gov mine trade {
	    gen log_ind_gdp_`v'_diff = log_ind_gdp_`v' - L.log_ind_gdp_`v'
			label var log_ind_gdp_`v'_diff "Log Diff: GDP in Mill `v'"
		gen log_ind_gdp_`v'_diff_lag1 = L.log_ind_gdp_`v' - L2.log_ind_gdp_`v'
			label var log_ind_gdp_`v'_diff_lag1 "Log Diff Lag 1: GDP in Mill `v'"
		gen log_ind_gdp_`v'_diff_lag2 = L2.log_ind_gdp_`v' - L3.log_ind_gdp_`v'
			label var log_ind_gdp_`v'_diff_lag2 "Log Diff Lag 2: GDP in Mill `v'"		
	}
	
// Dummy for the Midwest
gen midwest = 0
	replace midwest = 1 if state_fip == 19 | state_fip == 17 | state_fip == 18 | state_fip == 20 | state_fip == 29 | state_fip == 39 | state_fip == 40 | state_fip == 46 | state_fip == 55

// Dummy for the South
gen southern = 0
	replace southern = 1 if state_fip == 1 | state_fip == 5 | state_fip == 12 | state_fip == 13 | state_fip == 21 | state_fip == 22 | state_fip == 28 | state_fip == 37 | state_fip == 45 | state_fip == 47 | state_fip == 48 

// Dummy for Tornado Alley
gen tornado_alley = 0
	replace tornado_alley = 1 if state_fip == 19 | state_fip ==20 | state_fip == 27 | state_fip == 29 | state_fip == 31 | state_fip == 40  | state_fip == 46  | state_fip == 48
	
// Dummy for Dixie Alley
gen dixie_alley = 0
	replace dixie_alley = 1 if state_fip == 1 | state_fip == 13 | state_fip == 22 | state_fip == 28 | state_fip == 47
	
// Create State ID
split msa_name, gen(st_) parse("," "(" )
	drop st_3 msa_name
	rename (st_1 st_2) ///
		(msa_name state_abb)
	
	replace state_abb = state if state_abb == ""
	egen state_id = group(state_abb)
	
	// TODO: Will need to decide how to assign border states
	
// Create Log(GDP per Capita) for 2010 on
gen log_avg_gdppc = log(avg_gdp/pop_census)
	label var log_avg_gdp "Log(GDP per Capita): 2010 - 2018"
	
// Drop Extra Var Not Needed
drop name metro_name
		
// Sort
sort geoid_metro year

// Order Variables
// order geoid_metro metro_id metro_name gdp_in_mill log_gdp_in_mill Industry*  nado_intensity* treated count_nados* highest_cat* count_cat_0* count_cat_1* count_cat_2* count_cat_3* count_cat_4* count_cat_5* metro_micro_id MEMI midwest southern tornado_alley state state_fip 
	// TODO: Reorder variables after you bring in all the data.

// Save as .csv 
export delimited using `home'\edits\master.csv, replace

// Save as .dta
save `home'\edits\master.dta, replace

}

// Our Time has come to an end...

***************************************************************
//				  ~ Complete Log File ~
***************************************************************

cap log close
cd `home'\log_files
translate 1_Merge_Clean.smcl 1_Merge_Clean.pdf, replace
