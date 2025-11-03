import pandas as pd
import numpy as np
from pathlib import Path
RAW = Path("data/raw")
INTERIM = Path("data/interim"); INTERIM.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(RAW / "employee_data.csv")

# trim spaces in string columns 
for col in ["Gender", "Position"]:
    df[col] = df[col].astype(str).str.strip()

# standardize categories
df["Gender"] = df["Gender"].str.upper().replace({"FEMALE": "F", "MALE": "M"})

# string→number; -> NaN (missing)
num_cols = ["ID", "Experience (Years)", "Salary"]
for c in num_cols:
    df[c] = pd.to_numeric(df[c], errors="coerce")

# drop rows with key fields missing
df = df.dropna(subset=["ID", "Salary", "Experience (Years)"])

# remove duplicates by primary key
df = df.drop_duplicates(subset=["ID"])

# validity checks
df = df[df["Salary"] > 0]
df = df[(df["Experience (Years)"] >= 0) & (df["Experience (Years)"] <= 60)]


df.to_csv(INTERIM / "employee_clean.csv", index=False)


