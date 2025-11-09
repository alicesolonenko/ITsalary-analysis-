*import CSV with proper encoding and delimiter
import delimited using "$raw/employee_data.csv", varnames(1) encoding("UTF-8") delimiter(",") clear

*ensure proper format 
rename id ID
rename gender Gender
rename position Position
rename salary Salary
rename exper* Experience_Years
capture destring ID, replace ignore(",")
capture destring Salary, replace ignore(",") 
capture destring Experience_Years, replace ignore(",") 

*adjusting data to avoid negative or irreleant values
replace Salary = . if Salary <= 0
drop if missing(Salary)
replace Experience_Years = . if Experience_Years < 0
replace Gender = "Unknown" if missing(Gender)
duplicates drop ID, force

save "$proc/employee_clean.dta", replace



