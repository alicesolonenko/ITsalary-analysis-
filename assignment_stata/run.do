
* === TOEDIT HERE =====================
global XVAR      "years_experience"   // независимая переменная (пример)
global YVAR      "salary"             // зависимая переменная (пример)
global GROUPVAR  "job_title"          // категориальная (пример)


capture mkdir "data/interim"
capture mkdir "outputs"
capture mkdir "outputs/tables"
capture mkdir "outputs/figs"

import delimited using ///
"https://raw.githubusercontent.com/alicesolonenko/ITsalary-analysis-/main/data/raw/employee_data.csv", ///
    clear varnames(1) encoding("UTF-8")

capture confirm string variable $XVAR
if !_rc destring $XVAR, replace ignore(",") force

capture confirm string variable $YVAR
if !_rc destring $YVAR, replace ignore(",") force

drop if missing($XVAR) | missing($YVAR)


capture drop ln_* z_*

gen ln_`= "$XVAR"' = ln($XVAR) if $XVAR>0
gen ln_`= "$YVAR"' = ln($YVAR) if $YVAR>0

quietly summarize $XVAR
gen z_`= "$XVAR"' = ($XVAR - r(mean))/r(sd)

quietly summarize $YVAR
gen z_`= "$YVAR"' = ($YVAR - r(mean))/r(sd)


save "data/interim/analysis_sample.dta", replace
export delimited using "outputs/tables/final_clean.csv", replace


tabstat $XVAR $YVAR ln_`= "$XVAR"' ln_`= "$YVAR"' z_`= "$XVAR"' z_`= "$YVAR"', ///
    statistics(n mean sd min p25 p50 p75 max) columns(stat) save

matrix S = r(StatTotal)
matrix colnames S = N mean sd min p25 p50 p75 max
matrix rownames S = $XVAR $YVAR ln_`= "$XVAR"' ln_`= "$YVAR"' z_`= "$XVAR"' z_`= "$YVAR"'

putexcel set "outputs/tables/summary.xlsx", replace
putexcel A1 = "Summary statistics"
putexcel A3 = matrix(S), names

twoway (scatter $YVAR $XVAR, msize(small)) (lfit $YVAR $XVAR), ///
       title("$YVAR vs $XVAR") xtitle("$XVAR") ytitle("$YVAR")
graph export "outputs/figs/scatter_${YVAR}_vs_${XVAR}.png", width(2000) replace

histogram $YVAR, bin(30) normal title("Histogram of $YVAR") xtitle("$YVAR")
graph export "outputs/figs/hist_${YVAR}.png", width(2000) replace

capture confirm variable $GROUPVAR
if !_rc {
    graph box $YVAR, over($GROUPVAR) title("$YVAR by $GROUPVAR")
    graph export "outputs/figs/box_${YVAR}_by_${GROUPVAR}.png", width(2000) replace
}


