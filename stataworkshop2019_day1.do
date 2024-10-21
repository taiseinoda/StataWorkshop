
/*****************************************************************************
							Stata Workshop 2019 DAY 1
							2019/6/11 GSE Taisei NODA
******************************************************************************/

*You can make comments on do-file by putting asterisk in the begining of line
/*
If you want to make comment in multiple lines, enclose your comment by /* and */
(the order does matter), as I am doing.
*/


/************************************
				Set up
************************************/
*"Routine work". Ensure that no dataset or log is remained used in your Stata.
clear
capture log close
*avoid interruption
set more off

*display your current working directory
pwd
*change working directory
cd "D:"
*If your folder locates in "E:", write cd "E:"
*display filenames in working directory
dir

*We use pre-installed data ("Auto" data)
sysuse auto,clear



/***********************************
			Basic Syntax
***********************************/
/*
Template:
[by varlist1:] command [varlist2] [=exp] [if exp] [in range] [weight] [using filename] [,options]

NOTE 1.Stata is sensitive to order and UPPER CASE/lower case. Be aware of that.
NOTE 2.Stata recognizes separated lines as separated codes. Don't split into multiple lines.
NOTE 3.Stata considers space separated letters as a independent word. For instance, "sysuseauto,clear" or "sysuse au to", clear don't work
 
*/
 
*Example: summarize
 
bysort rep78: summarize price if foreign==0&price<=9000,detail
 
*summarize scalculates and displays a variety of univariate summary statistics.
 
summarize
summarize price
*"detail" option displays additional statistics, such as median and quartiles
summarize price , detail
*Stata allows us to use abbreviation
sum price,d

help sum

/***********************************
		Basic Data Operations
***********************************/
*Arithmetic: + add, - subtract, * multiply, / devide, ^ raise to a power
display (2*3-3)/2^4
*Logic(in particular we use these for "if..." 
/*
& and, == equal, ! not, != not equal, | or, < less than, <= less than or equal to
*/
*Example
sum price if foreign!=1& price >=10000
sum price if foreign!=1| price >=10000

/************************************
			Explore Data
************************************/
*Browse observations within the data
browse
/*
Alternatively, hit "ctrl" + "8" on your keyborard.
You can also access to the browser from the menu bar
*/

*Arranges observations to be in ascending
gsort price
*Descending
gsort -price
*Multiple variables: sorting observations with respect to 
gsort rep78 price

*A summary of the dataset in memory (variable type, labels)
describe
*Count the observations satisfying specified conditions
count
count if price >5000
*Overview of variable types, stats etc.
codebook make price
*Quick summary of variable, in partcular the distribution
inspect mpg

/***********************************
			Summarize Data
***********************************/
*One-way table of frequencies ("mi" option lets missing values included)
tabulate rep78,mi
*Two-way table
tab rep78 foreign,mi
/*Note that we cannot create a two-way table for variable taking too many kinds
of values, i.e. continuous variables
*/
*Combination of tabulate and bysort
bysort rep78: tabulate foreign
*Compact table of summary statistics
tabstat price weight mpg,stat(mean sd n)
*"by" option
tabstat price weight mpg,stat(mean sd n) by(foreign)

*Converts the dataset in memory into a dataset of means, sums, medians, etc.
/*
NOTE: This command replaces your original data. Be careful!
*/
collapse (mean) price (max) mpg,by(foreign)

/*
Since we replace the dataset, let us import the original data again
*/
sysuse auto,clear
/**************************************
		Create New Variables
**************************************/
*define a new variable
generate mpgSq=mpg^2
*define an indicator(true/false)
gen byte lowPr=price<4000 if price!=.
*Alternatively,
gen lowPr2=(price<4000) if price!=.
/*
Note: "if price!=." ensures that the indicator is not constructed for 
missing variable
*/
*_n creates a running index of observations
gen id =_n
*A running index of observations in a group
bysort rep78: gen repairIdx=_n
*_N creates a running count of the total observations
generate totRows=_N
*A running count of the total observations in a group
bysort rep78: gen repairTot=_N
*Calculate mean price for each group in foreign
egen meanPrice= mean(price), by(foreign)
/*
Note: egen calculate various statistic values, not only mean. See help egen.
Also, be aware of the difference between "gen" and "egen". "egen" creates 
statistical value for an entire dataset, instead of each individual observation.
*/

/**************************************
		Replace Parts of Data
**************************************/
*change column(variable) names
rename rep78 repairRecord
*We can change multple column names in one line
rename (repairRecord  gear_ratio)(rep78 gearratio)
*Change row values
replace price = 5000 if price <5000
*Alternative: recode
recode price(0/5000=5000)
recode foreign(0=2)(1=1)
*Replace missing values with 9999. This command is useful for exporting data
mvencode _all,mv(9999)
*Replace some specific values (e.g. 9999) with missing. Useful for survey data.
mvdecode _all,mv(9999)
/***************************************
		Select Parts if Data
***************************************/
*Remove column(variable)
drop mpgSq lowPr
*select specific column
keep make price foreign mpg id
*drop specific rows(observations) based on a condition
drop if mpg <20
*drop rows from 1 to 4
drop in 1/4
*keep values of price between $5000-10000(inclusive)
keep if inrange(price, 5000,10000)
/*
NOTE this is identical to "keep if price>=5000&price<=10000"
*/
*keep the specified values of make
keep if inlist(make, "Honda Accord", "Honda Civic", "Subaru")
/****************************************
				Label Data
***************************************/
*label for a variable
label variable id "Car ID"
*label for the values
label define myLabel 1 "US" 2 "Not US"
label values foreign myLabel
*list all lables within the dataset
label list
/*************************************
		Save & Export Data
**************************************/
*Save dta file
save auto.dta,replace
*Downgrade the data (NOTE: Older version cannot open file saved by the newest version)
saveold auto_old.dta
*Export as an excel(.xls)
export excel auto.xls, firstrow(variables) replace
*CSV file
export delimited auto.csv,delimiter(",") replace
/***************************************
		Import Data
***************************************/
use auto.dta,clear

log close
