/**********************************************************************
  run.do  — Stata part of "Coding for Economists" assignment
  Author: Alisa Solonenko

  This script reproduces a simple analysis of the salary dataset
  (employee_data.csv) used in the Python part.

  It demonstrates Stata-side requirements:
   1. Folder structure & file operations
   4. Break work into logical components (sections below)
   5. Read CSV, fix data quality (string vs numeric, missing)
   6. Prepare analysis sample:
        a filter observations
        b filter variables
        c create transformed variables
   7. Save cleaned data
   8. Create summary statistics table
   9. Create graphs
  10. Save graphs as files
 12–13. Appropriate names and comments
 15. Self-documenting script (this file) for reproducibility

  HOW TO RUN:
   1 Clone the GitHub repo ITsalary-analysis-.
   2 Place this file in: assignment_stata/run.do
   3 Open Stata and change directory to the repo root, e.g.
        cd "C:\Users\Alisa\Documents\ITsalary-analysis-"
      or on Mac:
        cd "/Users/alicesolonenko/Documents/ITsalary-analysis-"
   4 Run:
        do "assignment_stata/run.do"
   5 Clean data, tables, and graphs will be created in:
        data/interim/
        outputs/tables/
        outputs/figs/
**********************************************************************/

version 16
set more off


*====================================================================*
* 0. PROJECT SETUP: FOLDER STRUCTURE & GLOBALS                       *
*====================================================================*

* Define folder structure (relative to repo root)
global DIR_RAW      "data/raw"
global DIR_INTERIM  "data/interim"
global DIR_TBL      "outputs/tables"
global DIR_FIG      "outputs/figs"

* Create folders if they do not exist (file operations in Stata)
capture mkdir "data"
capture mkdir "$DIR_RAW"
capture mkdir "$DIR_INTERIM"
capture mkdir "outputs"
capture mkdir "$DIR_TBL"
capture mkdir "$DIR_FIG"

* Name of the CSV file (same as in Python)
global CSV_FILE "employee_data.csv"

* >>> IMPORTANT: set variable names exactly as in the CSV <<<
* Check with:  import delimited ... , clear  +  describe
* Typical Kaggle-like names: YearsExperience and Salary
global XVAR "YearsExperience"   // independent variable: years of experience
global YVAR "Salary"           // dependent variable: salary


*====================================================================*
* 1. IMPORT CSV + BASIC DATA CLEANING                                *
*====================================================================*

* 1.1 Import CSV from local repo (preferred)
capture confirm file "$DIR_RAW/$CSV_FILE"
if !_rc {
    import delimited using "$DIR_RAW/$CSV_FILE", ///
        clear varnames(1) encoding("UTF-8")
}
else {
    * fallback: read directly from GitHub raw URL if local file missing
    import delimited using ///
    "https://raw.githubusercontent.com/alicesolonenko/ITsalary-analysis-/main/data/raw/employee_data.csv", ///
        clear varnames(1) encoding("UTF-8")
}

* Quick check: list variable names and first observations
describe
list in 1/5


* 1.2 Fix string vs numeric and missing values for key variables
* If YearsExperience or Salary accidentally come in as strings, convert:
capture confirm string variable $XVAR
if !_rc {
    destring $XVAR, replace ignore(",") force
}

capture confirm string variable $YVAR
if !_rc {
    destring $YVAR, replace ignore(",") force
}

* Drop observations where either key variable is missing
drop if missing($XVAR) | missing($YVAR)


*====================================================================*
* 2. PREPARE ANALYSIS SAMPLE                                         *
*    a) filter observations                                          *
*    b) filter variables                                             *
*    c) create transformations                                      *
*====================================================================*

* 2.a Filter observations: keep only reasonable values

* Keep only non-negative experience and positive salary
keep if $XVAR >= 0
keep if $YVAR > 0

* Optionally trim extreme outliers (1st and 99th percentiles)
quietly summarize $XVAR, detail
local x_p1  = r(p1)
local x_p99 = r(p99)
keep if inrange($XVAR, `x_p1', `x_p99')

quietly summarize $YVAR, detail
local y_p1  = r(p1)
local y_p99 = r(p99)
keep if inrange($YVAR, `y_p1', `y_p99')


* 2.b Filter variables: keep only what we need for analysis
* For this assignment we only use:
*  - experience (XVAR)
*  - salary (YVAR)
preserve
    ds
    local keepvars "$XVAR $YVAR"
    foreach v of varlist `r(varlist)' {
        if strpos(" `keepvars' ", " `v' ") == 0 {
            drop `v'
        }
    }
restore, not   // do not restore original dropped variables


* 2.c Create transformations: log and standardized (z-score)

* Create locals for convenience
local x $XVAR
local y $YVAR

* Drop existing transformed variables if re-running the script
capture drop ln_`x' ln_`y' z_`x' z_`y'

* Log-transform (only for strictly positive values)
gen ln_`x' = ln(`x') if `x' > 0
label variable ln_`x' "log of `x'"

gen ln_`y' = ln(`y') if `y' > 0
label variable ln_`y' "log of `y'"

* Standardize (z-score)
quietly summarize `x'
gen z_`x' = (`x' - r(mean)) / r(sd)
label variable z_`x' "standardized `x' (z-score)"

quietly summarize `y'
gen z_`y' = (`y' - r(mean)) / r(sd)
label variable z_`y' "standardized `y' (z-score)"


*====================================================================*
* 3. SAVE CLEANED / MODIFIED DATA                                    *
*====================================================================*

* Save as Stata dataset
save "$DIR_INTERIM/salary_clean.dta", replace

* Also save as CSV so it can be compared with Python results
export delimited using "$DIR_TBL/salary_clean.csv", replace


*====================================================================*
* 4. SUMMARY STATISTICS TABLE                                        *
*====================================================================*

* Calculate summary statistics for original and transformed variables
tabstat `x' `y' ln_`x' ln_`y' z_`x' z_`y', ///
    statistics(n mean sd min p25 p50 p75 max) ///
    columns(stat) save

matrix S = r(StatTotal)
matrix colnames S = N mean sd min p25 p50 p75 max
matrix rownames S = `x' `y' ln_`x' ln_`y' z_`x' z_`y'

* Export to Excel file
putexcel set "$DIR_TBL/salary_summary_stats.xlsx", replace
putexcel A1 = "Summary statistics for salary dataset"
putexcel A3 = matrix(S), names


*====================================================================*
* 5. GRAPHS + SAVE AS FILES                                          *
*====================================================================*

* 5.1 Scatter plot of Salary vs YearsExperience with fitted line
twoway ///
    (scatter `y' `x', msize(small)) ///
    (lfit `y' `x', lcolor(black)), ///
    title("Salary vs experience") ///
    xtitle("Years of experience") ///
    ytitle("Salary")

graph export "$DIR_FIG/scatter_`y'_vs_`x'.png", ///
    width(1600) replace


* 5.2 Histogram of Salary
histogram `y', bin(15) normal ///
    title("Distribution of salary") ///
    xtitle("Salary")

graph export "$DIR_FIG/hist_`y'.png", ///
    width(1600) replace


*====================================================================*
* 6. END: MESSAGE FOR USER                                           *
*====================================================================*

display as result "✓ Stata run.do completed."
display as result "   Clean data:      data/interim/salary_clean.dta"
display as result "   Clean CSV:       outputs/tables/salary_clean.csv"
display as result "   Summary table:   outputs/tables/salary_summary_stats.xlsx"
display as result "   Figures:         outputs/figs/*.png"

