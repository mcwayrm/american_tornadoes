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
cap log using 4_Analysis.smcl, smcl replace 

/*******************************
********************************
	Title: Analysis of Tornado Data
	Author: Ryan McWay and Lilla Szini

	Description:
	Primary analysis of the tornado MSA data. 
	
	Steps:
		1. Fixed Effects Model
		2. Lagged Treatment Effects
		3. Sectoral Analysis
		4. Examining Poverty Trap
		
*******************************
********************************/

***************************************************************
//			Step 1:	OLS Estimation
***************************************************************

// Bring in master dataset
import delimited using `home'\edits\master.csv, clear

// To put tables in the outputs sub-directory
cd `home'\outputs

***************************************************************
//			Step 1:	Fixed Effects Model
***************************************************************

// Metro and Year fixed effects
reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
foreach treatment in count_nados highest_cat{
	reghdfe log_gdp_in_mill `treatment' if industryid == 85, absorb(i.geoid_metro i.year)
		outreg2 using fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
}
reghdfe log_gdp_in_mill	nado_intensity if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

// Metro and Year fixed effects with controls
reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 memi if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_controls.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
foreach treatment in count_nados highest_cat{
	reghdfe log_gdp_in_mill `treatment' memi if industryid == 85, absorb(i.geoid_metro i.year)
		outreg2 using fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
}
reghdfe log_gdp_in_mill	nado_intensity memi if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_controls.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

***************************************************************
//			Step 2:	Lagged Treatment Effects
***************************************************************

// 1 Year Lagged Treatment Effects
reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_lag1.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
reghdfe log_gdp_in_mill	count_nados count_nados_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_lag1.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
	
// 2 Year Lagged Treatment Effects
reghdfe log_gdp_in_mill count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5 count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1 count_cat_0_lag2 count_cat_1_lag2 count_cat_2_lag2 count_cat_3_lag2 count_cat_4_lag2 count_cat_5_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_lag2.tex, tex ctitle("Log(GDP in Mill)") addstat(F-test, e(F)) replace
reghdfe log_gdp_in_mill	count_nados count_nados_lag1 count_nados_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
reghdfe log_gdp_in_mill	highest_cat highest_cat_lag1 highest_cat_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))
reghdfe log_gdp_in_mill	nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 85, absorb(i.geoid_metro i.year)
	outreg2 using fe_metro_year_lag2.tex, append ctitle("Log(GDP in Mill)") addstat(F-test, e(F))

***************************************************************
//			Step 3:	Sectoral Analysis
***************************************************************

// 	NOTE: You want to ensure that you are isolating for Industry level with highest level of agglomeration

//	Mining and Resources Sector
reghdfe log_gdp_in_mill nado_intensity if industryid == 6, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, tex ctitle("Mining, Oil, Gas") addstat(F-test, e(F)) replace
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 6, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, append ctitle("Mining, Oil, Gas") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 6, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, append ctitle("Mining, Oil, Gas") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity if industryid == 31, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, append ctitle("Petrol and Coal") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 31, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, append ctitle("Petrol and Coal") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 31, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, append ctitle("Petrol and Coal") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity if industryid == 7, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, append ctitle("Gas and Oil Extract") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 7, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, append ctitle("Gas and Oil Extract") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 7, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_resources.tex, append ctitle("Gas and Oil Extract") addstat(F-test, e(F))
	
	
// Construction and Manufacturing Sector
reghdfe log_gdp_in_mill nado_intensity if industryid == 11, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_construction.tex, tex ctitle("Construction") addstat(F-test, e(F)) replace
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 11, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_construction.tex, append ctitle("Construction") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 11, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_construction.tex, append ctitle("Construction") addstat(F-test, e(F))

reghdfe log_gdp_in_mill nado_intensity if industryid == 12, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_construction.tex, append ctitle("Manufacturing") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 12, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_construction.tex, append ctitle("Manufacturing") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 12, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_construction.tex, append ctitle("Manufacturing") addstat(F-test, e(F))
	

// Healthcare Sector 
reghdfe log_gdp_in_mill nado_intensity if industryid == 71, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_healthcare.tex, tex ctitle("Emergency Services") addstat(F-test, e(F)) replace
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 71, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_healthcare.tex, append ctitle("Emergency Services") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 71, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_healthcare.tex, append ctitle("Emergency Services") addstat(F-test, e(F))

reghdfe log_gdp_in_mill nado_intensity if industryid == 72, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_healthcare.tex, append ctitle("Hospitals and Resident Care") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 72, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_healthcare.tex, append ctitle("Hospitals and Resident Care") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag2 nado_intensity_lag2 if industryid == 72, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_healthcare.tex, append ctitle("Hospitals and Resident Care") addstat(F-test, e(F))
	

// Financial Markets 
reghdfe log_gdp_in_mill nado_intensity if industryid == 55, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_finance.tex, tex ctitle("Funds and Trusts") addstat(F-test, e(F)) replace
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 55, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_finance.tex, append ctitle("Funds and Trusts") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 55, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_finance.tex, append ctitle("Funds and Trusts") addstat(F-test, e(F))

reghdfe log_gdp_in_mill nado_intensity if industryid == 52, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_finance.tex, append ctitle("Monetary Authorities") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 52, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_finance.tex, append ctitle("Monetary Authorities") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 52, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_finance.tex, append ctitle("Monetary Authorities") addstat(F-test, e(F))
	
	
// Real Estate Markets
reghdfe log_gdp_in_mill nado_intensity if industryid == 50, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_realestate.tex, tex ctitle("Finance, Insurance, Real Estate, Rental") addstat(F-test, e(F)) replace
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 50, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_realestate.tex, append ctitle("Finance, Insurance, Real Estate, Rental") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 50, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_realestate.tex, append ctitle("Finance, Insurance, Real Estate, Rental") addstat(F-test, e(F))
	
	
// Agricultural Sector 
reghdfe log_gdp_in_mill nado_intensity if industryid == 3, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_agriculture.tex, tex ctitle("Agriculture and Fisheries") addstat(F-test, e(F)) replace
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 3, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_agriculture.tex, append ctitle("Agriculture and Fisheries") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 3, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_agriculture.tex, append ctitle("Agriculture and Fisheries") addstat(F-test, e(F))

reghdfe log_gdp_in_mill nado_intensity if industryid == 4, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_agriculture.tex, append ctitle("Farming") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 if industryid == 4, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_agriculture.tex, append ctitle("Farming") addstat(F-test, e(F))
	
reghdfe log_gdp_in_mill nado_intensity nado_intensity_lag1 nado_intensity_lag2 if industryid == 4, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_agriculture.tex, append ctitle("Farming") addstat(F-test, e(F))

***************************************************************
//			Step 4:	Examining Poverty Trap
***************************************************************




***************************************************************
//				  ~ Complete Log File ~
***************************************************************

cap log close
cd `home'\log_files
translate 4_Analysis.smcl 4_Analysis.pdf, replace