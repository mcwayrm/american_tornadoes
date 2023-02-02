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
//					 ~ Dependencies ~
***************************************************************

// Flag in the beginning to download ado files needed to run
foreach package in sutex2 ietoolkit {
	cap which `package'
	if _rc di "This script needs -`package'-, please install first (try -ssc install `package'-)"
}
 
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

cd `home'\log_files
cap log using 2_Descriptives.smcl, smcl replace 

/*******************************
********************************
	Title: Descriptives on Tornado Data
	Author: Ryan McWay and Lilla Szini

	Description:
	Provide descriptive statistics on the tornado MSA data. 
	
	Steps:
		1. Summary Statistics
		2. Balance Table
		3. Box Plots
		
*******************************
********************************/

***************************************************************
//					 ~ Toggle Sections ~
***************************************************************

	// NOTE: To switch on select 'on'; To switch off select 'off'

// Toggle Which Sections to Run
global step1sum		"off"
global step2bal		"on"
global step3box		"off"


***************************************************************
//			Step 1:	Summary Statistics
***************************************************************

// Bring in master dataset
use `home'\edits\master.dta, clear

// Change to output subdirectory
cd `home'\outputs

if "$step1sum" == "on" {

// MSA Level Summary Stats: Industry
sutex2 ind_gdp_all ind_gdp_privte ind_gdp_agr ind_gdp_electric ind_gdp_cars ind_gdp_tech ind_gdp_insure ind_gdp_money ind_gdp_fin ind_gdp_homes ind_gdp_edu_health ind_gdp_hospital ind_gdp_arts ind_gdp_food ind_gdp_gov ind_gdp_milt ind_gdp_state_gov ind_gdp_mine ind_gdp_trade, ///
	varlabels minmax digits(2) saving(`home'\outputs\sum_stat_ind.tex) replace

// MSA Level Summary Stats: Employment & Population
sutex2 pop_estimate pop_int_mig pop_dom_mig unemp_adj_rate, ///
	varlabels minmax digits(2)  saving(`home'\outputs\sum_stat_pop.tex) replace


// MSA Level Summary Stats: Various 
sutex2 hlth_covered_emp hlth_covered_unemp pov_all_per emp_labfor_per inc_hh inc_hh_med inc_hh_mean, ///
	varlabels minmax digits(2) saving(`home'\outputs\sum_stat_var.tex) replace

	
// Tornado Summary Stats
sutex2 treated count_nados count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 highest_cat injuries fatalities midwest southern tornado_alley, ///
	varlabels minmax digits(2) saving(`home'\outputs\sum_stat_nado.tex) replace

// Master Summary Stats 
// Tornado Summary Stats
estpost summ
	estout using "`home'\outputs\sum_stat_all.xls", ///
		cells("count mean sd min max") replace

}
	
***************************************************************
//			Step 2:	Balance Table
***************************************************************

if "$step2bal" == "on" {

// bysort treated: summarize gdp_in_mill metro_micro_id
// 	orth_out gdp_in_mill metro_micro_id using balance_table.tex, by(treated) bdec(2) se count overall pcompare stars latex replace
	
// Balance by Recieving Tornadoes
iebaltab ind_gdp_all ind_gdp_privte ind_gdp_gov unemp_adj_rate, ///
	grpvar(treated) pttest ///
	savetex(balance_table_treatment.tex) replace

// Balance by Tornado Alley
iebaltab count_nados count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 highest_cat injuries fatalities property_loss crop_lossin_mill, ///
	grpvar(tornado_alley) pttest ///
	savetex(balance_table_nado_alley.tex) replace

// Balance by Dixie Alley
iebaltab count_nados count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 highest_cat injuries fatalities property_loss crop_lossin_mill, ///
	grpvar(dixie_alley) pttest ///
	savetex(balance_table_dixie_alley.tex) replace
	
}
	
***************************************************************
//			Step 3:	Box Plots
***************************************************************

if "$step3box" == "on" {

// Box Plot to show raw differences in size of sectors in the economy across sample (which are large and which are small)

}

***************************************************************
//				  ~ Complete Log File ~
***************************************************************

cap log close
cd `home'\log_files
translate 2_Descriptives.smcl 2_Descriptives.pdf, replace