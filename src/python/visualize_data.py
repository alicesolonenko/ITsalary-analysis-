import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

INTERIM = Path("data/interim")
OUT_FIG = Path("outputs/figures"); OUT_FIG.mkdir(parents=True, exist_ok=True)

# read the cleaned employee dataset
df = pd.read_csv(INTERIM / "employee_clean.csv")

#Draw a simple histogram of all salaries-overall salary distribution.

plt.figure(figsize=(7,4))
df["Salary"].plot(kind="hist", bins=20, color="#6aa84f", edgecolor="white")
plt.title("Salary distribution")
plt.xlabel("Salary")
plt.ylabel("Number of employees")
plt.tight_layout()
plt.savefig(OUT_FIG / "salary_hist.png")
plt.close()

# Bar chart: average salary by position- shows the average pay for each job role in descending order.

plt.figure(figsize=(10, 5))

# calculate mean salary by job position and sort from highest to lowest
avg_salary = (
    df.groupby("Position")["Salary"]
      .mean()
      .sort_values(ascending=False)
)

# make the bar chart
avg_salary.plot(kind="bar", color="#6fa8dc", edgecolor="black")

plt.title("Average Salary by Job Position")
plt.ylabel("Average Salary (USD)")
plt.xlabel("Job Position")
plt.xticks(rotation=45, ha="right")  # rotate labels for readability
plt.tight_layout()
plt.savefig(OUT_FIG / "salary_bar_by_position.png")
plt.close()


#Scatter plot: Experience vs Salary- check if more experience is linked with higher pay.

plt.figure(figsize=(7,4))
plt.scatter(df["Experience (Years)"], df["Salary"], s=20, color="#3c78d8", alpha=0.7)
plt.title("Experience vs Salary")
plt.xlabel("Experience (Years)")
plt.ylabel("Salary")
plt.tight_layout()
plt.savefig(OUT_FIG / "exp_vs_salary.png")
plt.close()

# Gender pay gap by position-compare the average salary of men and women in each job, positive difference means men earn more on average.

plt.figure(figsize=(10,5))

# group by position and gender, calculate mean salary
avg_by_gender = (
    df.groupby(["Position", "Gender"])["Salary"]
      .mean()
      .unstack()  # turn gender into columns
)

# calculate pay gap (male - female)
avg_by_gender["gap"] = avg_by_gender["M"] - avg_by_gender["F"]

# sort by gap size
avg_by_gender = avg_by_gender.sort_values("gap", ascending=True)

# plot horizontal bars
avg_by_gender["gap"].plot(
    kind="barh",
    color=avg_by_gender["gap"].apply(lambda x: "#6aa84f" if x < 0 else "#cc0000"),
    edgecolor="black"
)

plt.title("Gender Pay Gap by Position")
plt.xlabel("Average Salary Difference (M - F)")
plt.ylabel("Job Position")
plt.axvline(0, color="black", linewidth=1)
plt.tight_layout()
plt.savefig(OUT_FIG / "gender_pay_gap_by_position.png")
plt.close()

numeric_columns = ["Salary", "Experience (Years)", "log_salary"]
for col in numeric_columns:
    plt.figure(figsize=(6,4))
    df[col].plot(kind="hist", bins=20, edgecolor="white")
    plt.title(f"Distribution of {col}")
    plt.xlabel(col); plt.ylabel("Number of employees")
    plt.tight_layout()
    plt.savefig(OUT_FIG / f"hist_{col}.png")
    plt.close()
