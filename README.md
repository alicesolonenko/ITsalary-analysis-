
# IT Salary Analysis

## Project structure


data/
  raw/          → Put your employee_data.csv here
  interim/      → Cleaned data
  processed/    → Analysis-ready data
outputs/
  tables/       → Summary CSVs
  figures/      → Charts & graphs
src/python/     → 3 Python scripts (run in order)
`src/stata/`  → 3 Stata .do scripts (`clean.do`, `prepare_data.do`, `graphs.do`)  

`run.do` → Master Stata script that runs the whole Stata pipeline


## How It Works
## Python 

1. Clean the data (`load_clean.py`)
- Fixes messy formatting
- Removes duplicates and invalid entries
- Keeps only valid salaries (>$0) and experience (0-60 years)

2. Prepare analysis (`transform_data.py`)
- Filters to 5 key positions: Software Engineer, Web Developer, Data Analyst, DevOps Engineer, IT Manager
- Focuses on employees with 2+ years experience
- Creates summary tables by position and gender

3. Generate visualizations (`visualize_data.py`)
- Salary distributions
- Pay by position
- Experience vs salary trends
- Gender pay gap analysis

## Stata 

1. **Clean the data** (`src/stata/clean.do`)
   - Imports `data/raw/employee_data.csv` with UTF-8 encoding  
   - Converts ID, Salary, Experience_Years to numeric  
   - Drops invalid salaries (≤ 0) and negative experience  
   - Fills missing gender as `"Unknown"`  
   - Removes duplicate employees by `ID`  
   - Saves cleaned dataset as `data/processed/employee_clean.dta`

2. **Prepare analysis sample** (`src/stata/prepare_data.do`)
   - Uses `employee_clean.dta`  
   - Keeps employees with at least 1 year of experience  
   - Keeps key variables: `ID`, `Gender`, `Position`, `Experience_Years`, `Salary`  
   - Adds:
     - `log_salary` = log of salary  
     - `exp_group` = experience category (Junior / Mid / Senior)  
   - Saves analysis sample as `data/processed/employee_sample.dta`

3. **Create summary tables & graphs** (`src/stata/graphs.do`)
   - Builds summary tables:
     - `outputs/tables/stata_summary_by_position.csv`
     - `outputs/tables/stata_summary_by_pos_gender.csv`
   - Reproduces key Python charts:
     - `salary_hist_stata.png` – salary distribution  
     - `exp_vs_salary_stata.png` – salary vs experience  
     - `salary_bar_by_position_stata.png` – average salary by position  
     - `gender_pay_gap_by_position_stata.png` – average salary by position and gender  


## Setup
## Python 

Install dependencies:

pip install pandas numpy matplotlib


Run the pipeline:

python src/python/load_clean.py
python src/python/transform_data.py
python src/python/visualize_data.py


Check results:
- Charts in outputs/figures/
- Summary tables in outputs/tables/


## Stata 

Requirements:

- Stata 16+

- Working directory set to the project root (folder with run.do)

- Run the full Stata pipeline from Stata:

cd "/path/to/ITsalary-analysis-"
do run.do

## Your CSV Needs

Required columns: ID, Gender, Position, Experience (Years), Salary