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
foreach package in reghdfe outreg2 {
	cap which `package'
	if _rc di "This script needs -`package'-, please install first (try -ssc install `package'-)"
}
 
***************************************************************
//					 ~ Path Directories ~
***************************************************************

// Team Member Directories
if "`c(username)'" == "ryanm" {
		// Ryan's Directory
		global home "C:\Users\ryanm\Dropbox\American_Tornadoes"     
	}
	else if "`c(username)'" == "/Users/lillaszini/Dropbox/American Tornadoes" {
		// Lilla's Directory
		global home "" 
	}
	else {
		// Jesse's Directory
		global dir "C:\Users\jesse\Dropbox\American Tornadoes\" 
	}	

// Folder Navigation
cd "$home"

***************************************************************
//				  ~ Start Log File ~
***************************************************************

cap log using $home\log_files\4_Analysis.smcl, smcl replace 

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
		4. Log Difference Analysis
		5. Damage Plots
		6. Checks
		
*******************************
********************************/

// Set GG Plot Scheme
set scheme plottig

***************************************************************
//					 ~ Toggle Sections ~
***************************************************************

	// NOTE: To switch on select 'on'; To switch off select 'off'

// Toggle Which Sections to Run
global step1fe			"off"
global step2lagfe		"off"
global step3sect		"off"
global step4logdiff		"off"
global step5plots		"off"
global step6check		"off"
global step7crosssec	"off"
global step8sectors		"on"

***************************************************************
//			Step 1:	Fixed Effects Model
***************************************************************

// Bring in master dataset
use "$home\edits\master.dta", clear

// To put tables in the outputs sub-directory
// cd $home\outputs

if "$step1fe" == "on" {


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

}

***************************************************************
//			Step 2:	Lagged Treatment Effects
***************************************************************

if "$step2lagfe" == "on" {

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

}
	
***************************************************************
//			Step 3:	Sectoral Analysis
***************************************************************

if "$step3sect" == "on" {

// 	NOTE: Want to ensure that you are isolating for Industry level with highest level of agglomeration

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

}
	
***************************************************************
//			Step 4:	Log Diff Analysis
***************************************************************

if "$step4logdiff" == "on" {

// Loop to create all regression outputs for these sectors:
	** all, privte, agr, electric, cars, tech, insure, money, fin, homes, edu health, hospital, arts, food, gov, milt, state gov, mine, trade
	
foreach sector_name in  all privte agr electric cars tech insure money fin homes edu_health hospital arts food gov milt state_gov mine trade {
	reghdfe log_ind_gdp_`sector_name'_diff nado_intensity, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_`sector_name'_log_diff.tex, tex ctitle("Log(`sector_name') Difference") addstat(F-test, e(F)) replace
	
	reghdfe log_ind_gdp_`sector_name'_diff log_ind_gdp_`sector_name'_diff_lag1 nado_intensity, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_`sector_name'_log_diff.tex, append ctitle("Log(`sector_name') Difference") addstat(F-test, e(F))
	
	reghdfe log_ind_gdp_`sector_name'_diff log_ind_gdp_`sector_name'_diff_lag1 log_ind_gdp_`sector_name'_diff_lag2 nado_intensity, absorb(i.geoid_metro i.year)
	outreg2 using sector_effects_`sector_name'_log_diff.tex, append ctitle("Log(`sector_name') Difference") addstat(F-test, e(F))
	}

reghdfe unemp_adj_rate nado_intensity, absorb(i.geoid_metro i.year)
	outreg2 using unemp_rate_nado.tex, tex ctitle("Unemployement Rate") addstat(F-test, e(F)) replace
reghdfe unemp_adj_rate l1.unemp_adj_rate nado_intensity, absorb(i.geoid_metro i.year)
	outreg2 using unemp_rate_nado.tex, append ctitle("Unemployement Rate") addstat(F-test, e(F))
reghdfe unemp_adj_rate l1.unemp_adj_rate l2.unemp_adj_rate nado_intensity, absorb(i.geoid_metro i.year)
	outreg2 using unemp_rate_nado.tex, append ctitle("Unemployement Rate") addstat(F-test, e(F))

}
	
***************************************************************
//			Step 5: Damage Plots
***************************************************************
	
if "$step5plots" == "on" {
 
	
global regressors 	"count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5"
global regressors_lag 	"count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1"
global gph_opts		"cirecast(rline) yline(0) vertical drop(_cons) xlabel(, angle(45))"

// Damage Regressions
	// No Lag Regressions
	reghdfe fatalities $regressors, absorb(i.geoid_metro i.year)
		outreg2 using damage.tex, tex ctitle("Fatalities") addstat(F-test, e(F)) replace

	reghdfe injuries $regressors, absorb(i.geoid_metro i.year)
		outreg2 using damage.tex, append ctitle("Injuries") addstat(F-test, e(F))	
		
	reghdfe property_loss $regressors, absorb(i.geoid_metro i.year)
		outreg2 using damage.tex, append ctitle("Property Losses") addstat(F-test, e(F))	
		
	reghdfe crop_lossin_mill $regressors, absorb(i.geoid_metro i.year)
		outreg2 using damage.tex, append ctitle("Crop Losses") addstat(F-test, e(F))	
		

	//	1 Year Lag Regressions
	xtset geoid_metro year

	reghdfe l1.fatalities $regressors, absorb(i.geoid_metro i.year)
		outreg2 using lag_damage.tex, tex ctitle("Fatalities") addstat(F-test, e(F)) replace

	reghdfe l1.injuries $regressors, absorb(i.geoid_metro i.year)
		outreg2 using lag_damage.tex, append ctitle("Injuries") addstat(F-test, e(F))	
		
	reghdfe l1.property_loss $regressors, absorb(i.geoid_metro i.year)
		outreg2 using lag_damage.tex, append ctitle("Property loss in $$") addstat(F-test, e(F))	
		
	reghdfe l1.crop_lossin_mill $regressors, absorb(i.geoid_metro i.year)
		outreg2 using lag_damage.tex, append ctitle("Crop loss in $$") addstat(F-test, e(F))
	

// Figure 1: Fatalities, Injuries, Prop and Crop Loss

	// Fatalities
	reghdfe fatalities $regressors, absorb(i.geoid_metro i.year)
		estimates store Fatalities
		
		coefplot, $gph_opts ///
		title("Fatalities Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Count") ///
		name("plot_fat", replace)

	// Injuries
	reghdfe injuries $regressors, absorb(i.geoid_metro i.year)
		estimates store Injuries
		
		coefplot, $gph_opts ///
		title("Injuries Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Count") ///
		name("plot_inj", replace)
	
	// Property Loss
	reghdfe property_loss $regressors, absorb(i.geoid_metro i.year)
		estimates store Property_Loss
		
		coefplot, $gph_opts ///
		title("Property Loss Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("$$") ///
		name("plot_prop", replace)
		// NOTE: Want to look into this one
		// NOTE: The variable says in Mill but the values are still quite large.

	// Crop Loss
	reghdfe crop_lossin_mill $regressors, absorb(i.geoid_metro i.year)
		estimates store Crop_Loss
		
		coefplot, $gph_opts ///
		title("Crop Loss Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("$$") ///
		name("plot_crop", replace)

	// Version 1
	coefplot Fatalities Injuries Property_Loss Crop_Loss, $gph_opts ///
		xtitle("Tornado Category (Magnitude)") ytitle("Count / $$") ///
		title("Figure 1: Damage Plot", pos(12)) ///
		name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_1_v1.png",  ///
			as(png) ///
			name("plot_damage_plot") replace

	// Version 2
		graph combine plot_fat plot_inj plot_prop plot_crop, ///
			xcommon col(2) rows(2) ///
			name("plot_damage_plot", replace)
// 			title("Figure 1: Damage Plot", pos(12)) ///
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_1_v2.png", ///
			as(png) ///
			name("plot_damage_plot") replace

// Figure 2: 1 Year Lag Fatalities, Injuries, Prop and Crop Loss
	
// 	// Fatalities
// 	reghdfe l1.fatalities $regressors, absorb(i.geoid_metro i.year)
// 		estimates store Fatalities_L1
//		
// 		coefplot, $gph_opts ///
// 		title("Lagged Fatalities Damage Plot on Tornado Category") ///
// 		xtitle("Tornado Category (Magnitude)") ytitle("Coefficient Value") ///
// 		name("plot_fat_l1", replace)
//		
// 	// Injuries
// 	reghdfe l1.injuries $regressors, absorb(i.geoid_metro i.year)
// 		estimates store Injuries_L1
//		
// 		coefplot, $gph_opts ///
// 		title("Lagged Injuries Damage Plot on Tornado Category") ///
// 		xtitle("Tornado Category (Magnitude)") ytitle("Coefficient Value") ///
// 		name("plot_inj_l1", replace)
//
// 	// Property Loss
// 	reghdfe l1.property_loss $regressors, absorb(i.geoid_metro i.year)
// 		estimates store Property_Loss_L1
//		
// 		coefplot, $gph_opts ///
// 		title("Lagged Property Loss Damage Plot on Tornado Category") ///
// 		xtitle("Tornado Category (Magnitude)") ytitle("Coefficient Value") ///
// 		name("plot_prop_l1", replace)
//
// 	// Crop Loss
// 	reghdfe l1.crop_lossin_mill $regressors, absorb(i.geoid_metro i.year)
// 		estimates store Crop_Loss_L1
//		
// 		coefplot, $gph_opts ///
// 		title("Lagged Crop Loss Damage Plot on Tornado Category") ///
// 		xtitle("Tornado Category (Magnitude)") ytitle("Coefficient Value") ///
// 		name("plot_crop_l1", replace)
//
// 	// Version 1
// 	coefplot Fatalities_L1 Injuries_L1 Property_Loss_L1 Crop_Loss_L1, $gph_opts ///
// 		xtitle("Tornado Category (Magnitude)") ytitle("Coefficient Value") ///
// 		title("Figure 2", pos(12)) ///
// 		name("plot_damage_plot", replace)
//		
// 		// Export Graph 
// 		graph export "$home\outputs\damage_plots\figure_2_v1.png", ///
// 			as(png) ///
// 			name("plot_damage_plot") replace
//
// 	// Version 2
// 		graph combine plot_fat plot_inj plot_prop plot_crop, ///
// 			xcommon col(2) rows(2) iscale(*.7) ///
// 			title("Figure 2", pos(12)) ///
// 			name("plot_damage_plot", replace)
//		
// 		// Export Graph 
// 		graph export "$home\outputs\damage_plots\figure_2_v2.png", name("plot_damage_plot") replace


// Figure 3: All GDP, Private, Public

	// All GDP
	reghdfe log_ind_gdp_all $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Total GDP Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_all_gdp", replace)
		
	// Private Sector
	reghdfe log_ind_gdp_privte $regressors, absorb(i.geoid_metro i.year)
		estimates store Private
		
		coefplot, $gph_opts ///
		title("Private Sector GDP Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_private", replace)

	// Public Sector
	reghdfe log_ind_gdp_gov $regressors, absorb(i.geoid_metro i.year)
		estimates store Public
		
		coefplot, $gph_opts ///
		title("Public Sector Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_public", replace)
		
	// Version 1
	coefplot All_GDP Private Public, $gph_opts ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		title("Figure 3: Contemporaneous GDP Effect", pos(12)) ///
		name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_3_v1.png", ///
			as(png) ///
			name("plot_damage_plot") replace

	// Version 2
		graph combine plot_all_gdp plot_private plot_public, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
// 			title("Figure 3: Contemporaneous GDP Effect", pos(12)) ///
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_3_v2.png", name("plot_damage_plot") replace
		
// Figure 4: 1 Year Lag All GDP, Private, Public

	// All GDP
	reghdfe log_ind_gdp_all $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store All_GDP_L1
		
		coefplot, $gph_opts ///
		title("Total GDP Damage Plot on Tornado Category") ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Log(GDP)") ///
		name("plot_all_gdp_l1", replace)
		
	// Private Sector
	reghdfe log_ind_gdp_privte $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store Private_L1
		
		coefplot, $gph_opts ///
		title("Private Sector GDP Damage Plot on Tornado Category") ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Log(GDP)") ///
		name("plot_private_l1", replace)

	// Public Sector
	reghdfe log_ind_gdp_gov $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store Public_L1
		
		coefplot, $gph_opts ///
		title("Public Sector Damage Plot on Tornado Category") ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Log(GDP)") ///
		name("plot_public_l1", replace)
		
	// Version 1
	coefplot All_GDP_L1 Private_L1 Public_L1, $gph_opts ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Log(GDP)") ///
		title("Figure 4: Lag Effect on GDP", pos(12)) ///
		name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_4_v1.png", ///
			as(png) ///
			name("plot_damage_plot") replace

	// Version 2
		graph combine plot_all_gdp_l1 plot_private_l1 plot_public_l1, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
// 			title("Figure 4: Lag Effect on GDP", pos(12)) ///

		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_4_v2.png", name("plot_damage_plot") replace

		
// Figure 5: Log Differences

	// All GDP
	reghdfe log_ind_gdp_all_diff $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP_diff
		
		coefplot, $gph_opts ///
		title("Total GDP Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP) Difference") ///
		name("plot_all_gdp", replace)
		
	// Private Sector
	reghdfe log_ind_gdp_privte_diff $regressors, absorb(i.geoid_metro i.year)
		estimates store Private_diff
		
		coefplot, $gph_opts ///
		title("Private Sector GDP Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP) Difference") ///
		name("plot_private", replace)

	// Public Sector
	reghdfe log_ind_gdp_gov_diff $regressors, absorb(i.geoid_metro i.year)
		estimates store Public_diff
		
		coefplot, $gph_opts ///
		title("Public Sector Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP) Difference") ///
		name("plot_public", replace)
		
	// Version 1
	coefplot All_GDP_diff Private_diff Public_diff, $gph_opts ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP) Difference") ///
		title("Figure 5: Contemporaneous GDP Difference", pos(12)) ///
		name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_5_v1.png", ///
			as(png) ///
			name("plot_damage_plot") replace

	// Version 2
		graph combine plot_all_gdp_l1 plot_private_l1 plot_public_l1, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
// 			title("Figure 5: Contemporaneous GDP Difference", pos(12)) ///

		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_5_v2.png", name("plot_damage_plot") replace  

// Figure 6: 1 Year Lag Log Differences

	// All GDP
	reghdfe log_ind_gdp_all_diff $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store All_GDP_diff_L1
		
		coefplot, $gph_opts ///
		title("Total GDP Damage Plot on Tornado Category") ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Log(GDP) Difference") ///
		name("plot_all_gdp_l1", replace)
		
	// Private Sector
	reghdfe log_ind_gdp_privte_diff $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store Private_diff_L1
		
		coefplot, $gph_opts ///
		title("Private Sector GDP Damage Plot on Tornado Category") ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Log(GDP) Difference") ///
		name("plot_private_l1", replace)

	// Public Sector
	reghdfe log_ind_gdp_gov_diff $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store Public_diff_L1
		
		coefplot, $gph_opts ///
		title("Public Sector Damage Plot on Tornado Category") ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Log(GDP) Difference") ///
		name("plot_public_l1", replace)
		
	// Version 1
	coefplot All_GDP_diff_L1 Private_diff_L1 Public_diff_L1, $gph_opts ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Log(GDP) Difference") ///
		title("Figure 6: Lag Effect on Log(GDP) Difference", pos(12)) ///
		name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_6_v1.png", ///
			as(png) ///
			name("plot_damage_plot") replace

	// Version 2
		graph combine plot_all_gdp_l1 plot_private_l1 plot_public_l1, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
// 			title("Figure 6: Lag Effect on Log(GDP) Difference", pos(12)) ///
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_6_v2.png", name("plot_damage_plot") replace  

// Figure: Subsectors 


// Figure 7: Unemployment

	// Unemployment
	reghdfe unemp_adj_rate $regressors, absorb(i.geoid_metro i.year)
		estimates store UNEMP
		
		coefplot, $gph_opts ///
		title("Unemployment Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Unemployment Rate") ///
		name("plot_unemp", replace)
		
	// Version 1
	coefplot UNEMP, $gph_opts ///
		xtitle("Tornado Category (Magnitude)") ytitle("Unemployment Rate") ///
		title("Figure 7: Contemporaneous Unemployment", pos(12)) ///
		name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_7_v1.png", ///
			as(png) ///
			name("plot_damage_plot") replace

	// Version 2
		graph combine plot_unemp, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
// 			title("Figure 7: Contemporaneous Unemployment", pos(12)) ///
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_7_v2.png", name("plot_damage_plot") replace



// Figure 8: 1 Year Lag Unemployment

	// Unemployment
	reghdfe unemp_adj_rate $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store UNEMP
		
	// Version 1
	coefplot UNEMP, $gph_opts ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Unemployment Rate") ///
		title("Figure 8: Lag Effect on Unemployment", pos(12)) ///
		name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_8_v1.png", ///
			as(png) ///
			name("plot_damage_plot") replace

	// Version 2
		graph combine plot_unemp, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
// 			title("Figure 8: Lag Effect on Unemployment", pos(12)) ///
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_8_v2.png", name("plot_damage_plot") replace

}

***************************************************************
//			Step 6: Checks
***************************************************************

if "$step6check" == "on" {

// Lagged Tornadoes not affect fatalities / injuries today

global regressors_lag 	"count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1"
global gph_opts		"cirecast(rline) yline(0) vertical drop(_cons) xlabel(, angle(45))"

	// Fatalities
	reghdfe fatalities $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store Fatalities_lag
		
		coefplot, $gph_opts ///
		title("Fatalities Damage Plot on Lag(Tornado Category)") ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Count") ///
		name("plot_fat", replace)

	// Injuries
	reghdfe injuries $regressors_lag, absorb(i.geoid_metro i.year)
		estimates store Injuries_lag
		
		coefplot, $gph_opts ///
		title("Injuries Damage Plot on Lag(Tornado Category)") ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Count") ///
		name("plot_inj", replace)

	// Version 1
	coefplot Fatalities_lag Injuries_lag, $gph_opts ///
		xtitle("Lag(Tornado Category (Magnitude))") ytitle("Count") ///
		title("Figure X: Check Lag Effect", pos(12)) ///
		name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_1_check_v1.png",  ///
			as(png) ///
			name("plot_damage_plot") replace

	// Version 2
		graph combine plot_fat plot_inj, ///
			xcommon col(2) rows(2) ///
			name("plot_damage_plot", replace)
// 			title("Figure X: Check Lag Effect", pos(12)) ///
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_1_check_v2.png", ///
			as(png) ///
			name("plot_damage_plot") replace
}

***************************************************************
//			Step 7: Cross-Section Averages
***************************************************************

if "$step7crosssec" == "on" {

preserve

// Collapse to MSA level
collapse (firstnm) log_avg_gdppc avg_nados, by(geoid_metro)

// Figure 9: Cross Sectional Average

	// Average GDP on Average Nados
	reg log_avg_gdppc avg_nados, robust
		estimates store Cross_Sect
		
	// Version 1
	coefplot, $gph_opts ///
		xtitle("Average Tornado Counts 1980 - 2010") ytitle("Average GDP 2010 - 2018") ///
		title("Figure 9: Cross-Section Averages", pos(12)) ///
		name("plot_cross_sect", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\figure_9_v1.png", ///
			as(png) ///
			name("plot_cross_sect") replace
			
restore

}

***************************************************************
//			Step 8: Sectoral Damage Plots
***************************************************************
	
if "$step8sectors" == "on" {
	
global regressors 	"count_cat_0 count_cat_1 count_cat_2 count_cat_3 count_cat_4 count_cat_5"
global regressors_lag 	"count_cat_0_lag1 count_cat_1_lag1 count_cat_2_lag1 count_cat_3_lag1 count_cat_4_lag1 count_cat_5_lag1"
global gph_opts		"cirecast(rline) yline(0) vertical drop(_cons) xlabel(, angle(45))"
	
// Sector: Resources
  
	// Agricultural
	reghdfe log_ind_gdp_agr $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Agricultural Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_agr", replace)
		
		
	// Mining
	reghdfe log_ind_gdp_mine $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Mining Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_mine", replace)
		
		
	// Electric
	reghdfe log_ind_gdp_electric $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Electric Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_electric", replace)
		
	// Version 2
		graph combine plot_agr plot_mine plot_electric, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\plot_sect_res_v2.png", name("plot_damage_plot") replace
		

// Sector: Manufacturing 
   
	// Cars
	reghdfe log_ind_gdp_cars $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Automobiles Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_auto", replace)
		
	// Tech
	reghdfe log_ind_gdp_tech $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Technology Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_tech", replace)
		
	// Homes
	reghdfe log_ind_gdp_homes $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Home Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_home", replace)
		
	// Food
	reghdfe log_ind_gdp_food  $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Food Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_food", replace)
		
	// Version 2
		graph combine plot_home plot_tech plot_food plot_auto, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\plot_sect_man_v2.png", name("plot_damage_plot") replace


// Sector: Government 
 
	// Military
	reghdfe log_ind_gdp_milt $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Military Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_milt", replace)
		
	// State Government
	reghdfe log_ind_gdp_state_gov $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("State Government Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_state", replace)
	
	// Version 2
		graph combine plot_state plot_milt, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\plot_sect_gov_v2.png", name("plot_damage_plot") replace

// Sector: Finance 

	// Insurance
	reghdfe log_ind_gdp_insure $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Insurance Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_insure", replace)

	// Banking
	reghdfe log_ind_gdp_money $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Banking Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_bank", replace)
		
	// Financial
	reghdfe log_ind_gdp_fin $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Financial Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_fin", replace)
		
	// Trade
	reghdfe log_ind_gdp_trade $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Trade Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_trade", replace)
		
	// Version 2
		graph combine plot_insure plot_bank plot_fin plot_trade, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\plot_sect_fin_v2.png", name("plot_damage_plot") replace
	
// Sector: Health
 
	// Health
	reghdfe log_ind_gdp_edu_health $regressors, absorb(i.geoid_metro i.year)
		estimates store All_GDP
		
		coefplot, $gph_opts ///
		title("Health Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_health", replace)
		
	// Hospitals
	reghdfe log_ind_gdp_hospital $regressors, absorb(i.geoid_metro i.year)
		estimates store Private
		
		coefplot, $gph_opts ///
		title("Hospital GDP Damage Plot on Tornado Category") ///
		xtitle("Tornado Category (Magnitude)") ytitle("Log(GDP)") ///
		name("plot_hospital", replace)
		

	// Version 2
		graph combine plot_health plot_hospital, ///
			xcommon col(2) rows(2) iscale(*.7) ///
			name("plot_damage_plot", replace)
		
		// Export Graph 
		graph export "$home\outputs\damage_plots\plot_sect_health_v2.png", name("plot_damage_plot") replace
	
}
	
***************************************************************
//				  ~ Complete Log File ~
***************************************************************

cap log close
translate $home\log_files\4_Analysis.smcl $home\log_files\4_Analysis.pdf, replace
