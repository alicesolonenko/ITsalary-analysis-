
*1. Summary by position 
use "$proc/employee_sample.dta", clear

collapse (mean) mean_salary = Salary mean_experience = Experience_Years, by(Position)
order Position mean_salary mean_experience

export delimited using "$tables/stata_summary_by_position.csv", replace encoding("UTF-8")


*2. Summary by position and gender 
use "$proc/employee_sample.dta", clear

collapse (mean) mean_salary = Salary, by(Position Gender)
order Position Gender mean_salary

export delimited using "$tables/stata_summary_by_pos_gender.csv", replace encoding("UTF-8")


* 3. Plots (to mirror Python) 

* 1- salary_hist.png - overall salary distribution.
histogram Salary, ///
    title("Salary distribution") ///
    xtitle("Salary") ///
    ytitle("Frequency") ///
    name(salary_hist, replace)

graph export "$figs/salary_hist_stata.png", replace

* 2- exp_vs_salary.png - experience vs salary - check if more experience is linked with higher pay.
twoway scatter Salary Experience_Years, ///
    title("Salary vs experience") ///
    xtitle("Experience (years)") ///
    ytitle("Salary") ///
    name(exp_vs_salary, replace)

graph export "$figs/exp_vs_salary_stata.png", replace

* 3 - salary_bar_by_position.png - average salary by position- shows the average pay for each job role in descending order.
graph bar (mean) Salary, ///
    over(Position, sort(1) descending) ///
    title("Average salary by position") ///
    ylabel(, angle(horizontal)) ///
    name(salary_bar_by_position, replace)

graph export "$figs/salary_bar_by_position_stata.png", replace

* 4 - gender_pay_gap_by_position.png - gender pay gap by position-compare the average salary of men and women in each job, positive difference means men earn more on average.
graph bar (mean) Salary, ///
    over(Gender) ///
    over(Position) ///
    title("Average salary by position and gender") ///
    legend(order(1 "Female" 2 "Male")) ///
    name(gender_pay_gap_by_position, replace)

graph export "$figs/gender_pay_gap_by_position_stata.png", replace
