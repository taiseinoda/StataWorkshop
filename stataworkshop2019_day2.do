/*****************************************************************************
							Stata Workshop 2019 DAY 2
							2019/6/18 GSE Taisei NODA
******************************************************************************/
/************************************
				Set up
************************************/

*"Routine work". Ensure that no dataset or log is remained used in your Stata.
clear
capture log close
*avoid interruption
set more off

*open your log file
log using stata2019_day2.log,replace

*change working directory
cd "E:"
*If your folder locates in "E:", write cd "E:"
*display filenames in working directory
*Make sure that "wb.xlsx" is displayed
dir

/*************************************
			Import Data
*************************************/

*We use pre-installed data ("Auto" data)
import delimited "wb.csv",varnames(1)

/*
Note:If you want to import dta file,
use wb.dta,clear
If you want to import excel file,
import excel "wb.xlsx",firstrow
*/

/**************************************
		Replace Parts of Data
**************************************/
*Remove column(variable)
drop var2 var7
*Select specific column
keep countryname countrycode var1 var3 var4 var5 var6 var9

*summarize the variables
su
*why no observations?
browse
*You need to transform the strings to numeric values
*Can you do that?
destring var1,replace

*Before that, you have to replace ".." with "."
*Loop: same operation for each variable in the variable list
foreach var of varlist var1 var3 var6 {
replace `var'="." if `var'==".."
}
destring _all,replace
*Change row values
replace var9=0 if var9==2
*Make sure that the data is successfully converted
su
*change column(variable) names
rename var1 expend
*We can change multple column names in one line
rename (var3 var4 var5 var6 var9)(enroll math read gni_pc asia)

/**********************************
			Label Data
**********************************/
*label for a variable
label variable math "PISA math, median"
label variable read "PISA reading, median"
label variable gni_pc "GNI per capita"
label variable enroll "Net enrollment rate(%), secondary"
label variable asia "Asia dummy"
label variable expend "Gov expenditure on education as % of GDP"
*label for values
label define asia_label 1 "yes" 0 "no"
label values asia asia_label
*see your label
browse
/*********************************
		Summary Stat
*********************************/
*ssc install outreg2
outreg2 using "summary.xls",replace sum(log)
/***********************************
		Visualization
***********************************/

*histogram
hist math,width(5) title("PISA Math")
gr save math.gph,replace
hist read,width(5) title("PISA Reading")
gr save read.gph,replace
gr combine math.gph read.gph, col(1) xcommon

*scatter
twoway scatter gni_pc math, title("Math VS GNI")
*with fitted line
twoway scatter gni_pc math|| lfit gni_pc math, title("Math VS GNI with fitted line")
/**************************************
		Data Analysis
**************************************/

*Correlation
corr gni_pc math read enroll expend

*T-test
ttest math,by(asia)
*Regression: simple regression
reg gni_pc math
*Post estimation
outreg2 using "result.xls",replace
*Regression: multiple regression
reg gni_pc math asia expend
*outreg2 with append option adds the result to the table you produced
outreg2 using "result.xls",append

*Calculate the residuals based on the last fit model
predict double resid,residuals
scatter resid gni_pc,yline(0)
*coefplot descrbes regression result visually
reg gni_pc math expend asia
coefplot,xline(0) drop(_cons) title("Result")
/*************************************
		Save & Export Data
**************************************/
*Save dta file
save pisa.dta,replace
*Downgrade the data (NOTE: Older version cannot open file saved by the newest version)
saveold pisa_old.dta,replace
*CSV file
export delimited pisa.csv,delimiter(",") replace
/***************************************
		Import Data
***************************************/
use pisa.dta,clear

log close
