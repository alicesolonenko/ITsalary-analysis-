
use "$proc/employee_clean.dta", clear

keep if Experience_Years >= 1

keep ID Gender Experience_Years Position Salary

gen log_salary = log(Salary)
label var log_salary "Log salary"

* categorize experience 
gen exp_group = .
replace exp_group = 1 if Experience_Years < 3
replace exp_group = 2 if inrange(Experience_Years, 3, 6)
replace exp_group = 3 if Experience_Years > 6

label define exp_lbl 1 "Junior" 2 "Mid" 3 "Senior"
label values exp_group exp_lbl
label var exp_group "Experience group"

save "$proc/employee_sample.dta", replace


