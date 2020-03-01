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
cap log using 5_Robustness.smcl, smcl replace 

/*******************************
********************************
	Title: Analysis of Tornado Data
	Author: Ryan McWay and Lilla Szini

	Description:
	Robustness checks for the analysis. Looking at the compositional sensitivitiy of the sample as well as testing a placebo test.
	
	Steps:
		1. Remove Midwestern Metros
		2. Remove Southern Metros
		3. Remove Tornado Alley
		4. Keep Only Tornado Alley
		5. Placebo Test of Future Tornadoes on Current GDP
		
*******************************
********************************/

***************************************************************
//			Step 1:	Remove Midwest
***************************************************************

***************************************************************
//			Step 2:	Remove South
***************************************************************


***************************************************************
//			Step 3:	Remove Tornado Alley
***************************************************************


***************************************************************
//			Step 4:	Only Tornado Alley
***************************************************************

***************************************************************
//			Step 5:	Placebo Test
***************************************************************

// Future Tornadoes shouldn't effect gdp today


***************************************************************
//				  ~ Complete Log File ~
***************************************************************

cap log close
cd `home'\log_files
translate 5_Robustness.smcl 5_Robustness.pdf, replace