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
//			Step 1:	Summary Statistics
***************************************************************

// Bring in master dataset
import delimited using `home'\edits\master.csv, clear

// Change to output subdirectory
cd `home'\outputs

// MSA Summary Stats
sum treated gdp_in_mill metro_micro_id 
	
	
// Tornado Descriptives Stats
sum count_nados count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 highest_cat injuries fatalities property_loss crop_lossin_m*
	

***************************************************************
//			Step 2:	Balance Table
***************************************************************

bysort treated: summarize gdp_in_mill metro_micro_id
	orth_out gdp_in_mill metro_micro_id using balance_table.tex, by(treated) bdec(2) se count overall pcompare stars latex replace

***************************************************************
//			Step 3:	Box Plots
***************************************************************

// Box Plot to show raw differences in size of sectors in the economy across sample (which are large and which are small)

***************************************************************
//				  ~ Complete Log File ~
***************************************************************

cap log close
cd `home'\log_files
translate 2_Descriptives.smcl 2_Descriptives.pdf, replace