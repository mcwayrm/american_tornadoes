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

// Bring in master dataset
import delimited using `home'\edits\master.csv, clear

// To put tables in the outputs sub-directory
cd `home'\outputs

***************************************************************
//			Step 1:	Remove Midwest
***************************************************************

// Removing the Midwestern States
drop if midwest == 1

// Fixed Effects

	// Metro and Year fixed effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		foreach treatment in count_nados highest_cat{
			reghdfe log_gdp_in_mill `treatment' if industryid == 85, absorb(i.geoid_metro i.year)
				outreg2 using minus_midwest_fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		}

		reghdfe log_gdp_in_mill	nado_intensity if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

	// Metro and Year fixed effects with controls
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 memi if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_controls.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		foreach treatment in count_nados highest_cat{
			reghdfe log_gdp_in_mill `treatment' memi if industryid == 85, absorb(i.geoid_metro i.year)
				outreg2 using minus_midwest_fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		}

		reghdfe log_gdp_in_mill	nado_intensity memi if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

	// 1 Year Lagged Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_lag1.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		
	// 2 Year Lagged Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 count_cat_0_lag2 count_cat_1_lag2 count_cat_2_lag2 count_cat_3_lag2 count_cat_4_lag2 count_cat_5_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_lag2.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lag1 count_nados_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 highest_cat_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_midwest_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

// Sectoral Analysis


// Poverty Trap


***************************************************************
//			Step 2:	Remove South
***************************************************************

// Bring in master dataset
import delimited using `home'\edits\master.csv, clear

// Removing the Southern States
drop if southern == 1

// Fixed Effects

	// Metro and Year fixed effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		foreach treatment in count_nados highest_cat{
			reghdfe log_gdp_in_mill `treatment' if industryid == 85, absorb(i.geoid_metro i.year)
				outreg2 using minus_south_fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		}

		reghdfe log_gdp_in_mill	nado_intensity if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

	// Metro and Year fixed effects with controls
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 memi if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_controls.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		foreach treatment in count_nados highest_cat{
			reghdfe log_gdp_in_mill `treatment' memi if industryid == 85, absorb(i.geoid_metro i.year)
				outreg2 using minus_south_fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		}

		reghdfe log_gdp_in_mill	nado_intensity memi if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

	// 1 Year Lagged Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_lag1.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		
	// 2 Year Lagged Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 count_cat_0_lag2 count_cat_1_lag2 count_cat_2_lag2 count_cat_3_lag2 count_cat_4_lag2 count_cat_5_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_lag2.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lag1 count_nados_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 highest_cat_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

// Sectoral Analysis


// Poverty Trap


***************************************************************
//			Step 3:	Remove Tornado Alley
***************************************************************

// Bring in master dataset
import delimited using `home'\edits\master.csv, clear

// Remove both midwestern and southern states
drop if tornado_alley == 1

// Fixed Effects

	// Metro and Year fixed effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		foreach treatment in count_nados highest_cat{
			reghdfe log_gdp_in_mill `treatment' if industryid == 85, absorb(i.geoid_metro i.year)
				outreg2 using minus_tornado_alley_fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		}

		reghdfe log_gdp_in_mill	nado_intensity if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

	// Metro and Year fixed effects with controls
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 memi if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_south_fe_metro_year_controls.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		foreach treatment in count_nados highest_cat{
			reghdfe log_gdp_in_mill `treatment' memi if industryid == 85, absorb(i.geoid_metro i.year)
				outreg2 using minus_tornado_alley_fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		}

		reghdfe log_gdp_in_mill	nado_intensity memi if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

	// 1 Year Lagged Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_lag1.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		
	// 2 Year Lagged Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 count_cat_0_lag2 count_cat_1_lag2 count_cat_2_lag2 count_cat_3_lag2 count_cat_4_lag2 count_cat_5_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_lag2.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lag1 count_nados_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 highest_cat_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using minus_tornado_alley_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

// Sectoral Analysis


// Poverty Trap


***************************************************************
//			Step 4:	Only Tornado Alley
***************************************************************

// Bring in master dataset
import delimited using `home'\edits\master.csv, clear

// Keep only the midwestern and souther states
keep if tornado_alley == 1

// Fixed Effects

	// Metro and Year fixed effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		foreach treatment in count_nados highest_cat{
			reghdfe log_gdp_in_mill `treatment' if industryid == 85, absorb(i.geoid_metro i.year)
				outreg2 using only_tornado_alley_fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		}

		reghdfe log_gdp_in_mill	nado_intensity if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

	// Metro and Year fixed effects with controls
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 memi if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_south_fe_metro_year_controls.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		foreach treatment in count_nados highest_cat{
			reghdfe log_gdp_in_mill `treatment' memi if industryid == 85, absorb(i.geoid_metro i.year)
				outreg2 using only_tornado_alley_fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		}

		reghdfe log_gdp_in_mill	nado_intensity memi if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

	// 1 Year Lagged Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_lag1.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		
	// 2 Year Lagged Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 count_cat_0_lag2 count_cat_1_lag2 count_cat_2_lag2 count_cat_3_lag2 count_cat_4_lag2 count_cat_5_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_lag2.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lag1 count_nados_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 highest_cat_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using only_tornado_alley_fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

// Sectoral Analysis


// Poverty Trap

***************************************************************
//			Step 5:	Placebo Test
***************************************************************

// Bring in master dataset
import delimited using `home'\edits\master.csv, clear

// Note: Leading Tornadoes should have no effect on current outcomes

// Fixed Effects

	// 1 Year Leading Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lead1 count_cat_1_lead1 count_cat_2_lead1 count_cat_3_lead1 count_cat_4_lead1 count_cat_5_lead1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using placebo_fe_metro_year_lead1.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lead1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using placebo_fe_metro_year_lead1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lead1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using placebo_fe_metro_year_lead1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lead1 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using placebo_fe_metro_year_lead1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
		
	// 2 Year Leading Treatment Effects
		reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lead1 count_cat_1_lead1 count_cat_2_lead1 count_cat_3_lead1 count_cat_4_lead1 count_cat_5_lead1 count_cat_0_lead2 count_cat_1_lead2 count_cat_2_lead2 count_cat_3_lead2 count_cat_4_lead2 count_cat_5_lead2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using placebo_fe_metro_year_lead2.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
			
		reghdfe log_gdp_in_mill	count_nados count_nados_lead1 count_nados_lead2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using placebo_fe_metro_year_lead2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	highest_cat highest_cat_lead1 highest_cat_lead2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using placebo_fe_metro_year_lead2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
			
		reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lead1 nado_intensity_lead2 if industryid == 85, absorb(i.geoid_metro i.year)
			outreg2 using placebo_fe_metro_year_lead2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))


// Sectoral Analysis


// Poverty Trap


***************************************************************
//				  ~ Complete Log File ~
***************************************************************

cap log close
cd `home'\log_files
translate 5_Robustness.smcl 5_Robustness.pdf, replace