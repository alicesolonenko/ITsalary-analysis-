Quick start 
1) create & activate a virtual env 
python3 -m venv .venv
source .venv/bin/activate

2) install deps
python3 -m pip install pandas matplotlib

3) run the pipeline 
python3 src/python/load_clean.py -reads CSV, fixes data quality issues
python3 src/python/transform_data.py  -filters obs/vars, creates transforms, saves sample and summaries
python3 src/python/visualize_data.py - draws graphs 


