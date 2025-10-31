Quick start 
working on mac
1) create & activate a virtual env 
python3 -m venv .venv
source .venv/bin/activate

2) install deps
python3 -m pip install pandas matplotlib

3) run the pipeline 
python3 src/python/load_clean.py -reads CSV, fixes data quality issues
python3 src/python/transform_data.py  -filters obs/vars, creates transforms, saves sample and summaries
python3 src/python/visualize_data.py - draws graphs 


-Input data: data/raw/employee_data.csv
-Intermediate (ignored by git): data/interim/employee_clean.csv
-Final sample: data/processed/analysis_sample.csv
-Tables: outputs/tables/py_summary_by_pos_gender.csv, outputs/tables/py_summary_by_position.csv
-Figures: outputs/figures/1_salary_distribution.png, 2_avg_salary_by_position.png,
3_experience_vs_salary.png, 4_gender_pay_gap.png
