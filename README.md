
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


## How It Works

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

## Setup

Install dependencies:

pip install pandas numpy matplotlib


Run the pipeline:

python src/python/load_clean.py
python src/python/transform_data.py
python src/python/visualize_data.py


Check results:
- Charts in outputs/figures/
- Summary tables in outputs/tables/

## Your CSV Needs

Required columns: ID, Gender, Position, Experience (Years), Salary