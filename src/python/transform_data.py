import pandas as pd
import numpy as np
from pathlib import Path

# paths to read the cleaned data and to save summary tables
INTERIM = Path("data/interim")
PROCESSED = Path("data/processed"); PROCESSED.mkdir(parents=True, exist_ok=True)
OUT_TAB = Path("outputs/tables"); OUT_TAB.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(INTERIM / "employee_clean.csv")
# ensure log_salary exists for downstream steps (Salary > 0 ensured in cleaning)
if "log_salary" not in df.columns:
    df["log_salary"] = np.log(df["Salary"]).astype(float)

#filtering by roles and then columns for analysis sample 
core_roles = [
    "Software Engineer", "Web Developer", "Data Analyst",
    "DevOps Engineer", "IT Manager"
]
mask = (df["Position"].isin(core_roles)) & (df["Experience (Years)"] >= 2)
df_sample = df.loc[mask].copy()

sample_cols = ["ID", "Gender", "Position", "Experience (Years)", "Salary", "log_salary"]
df_sample = df_sample[sample_cols]

df_sample["exp_sq"] = df_sample["Experience (Years)"] ** 2
df_sample["high_salary"] = (df_sample["Salary"] >= 150_000).astype(int)

df_sample.to_csv(PROCESSED / "analysis_sample.csv", index=False)

# create a summary table grouped by job position and gender:average salary, median salary, № of people, average experience.
grp = (
    df.groupby(["Position", "Gender"], as_index=False)
      .agg(
          mean_salary=("Salary", "mean"),
          median_salary=("Salary", "median"),
          n=("ID", "count"),
          mean_experience=("Experience (Years)", "mean")
      )
      .sort_values(["Position", "Gender"])
)

# create summary by position to see which jobs are paid the most on average.
by_pos = (
    df.groupby("Position", as_index=False)
      .agg(
          mean_salary=("Salary", "mean"),
          median_salary=("Salary", "median"),
          n=("ID", "count"),
          mean_experience=("Experience (Years)", "mean")
      )
      .sort_values("mean_salary", ascending=False)
)

# save tables
grp.to_csv(OUT_TAB / "py_summary_by_pos_gender.csv", index=False)
by_pos.to_csv(OUT_TAB / "py_summary_by_position.csv", index=False)

#automate
num_cols = ["Salary", "Experience (Years)", "log_salary"]
for col in num_cols:
    mean_val = df[col].mean()
    std_val = df[col].std()
    print(f"{col}: mean = {mean_val:.2f}, std = {std_val:.2f}")
