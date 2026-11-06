# Financial Fraud and Transaction Analysis

An end-to-end data analysis project that examines financial transactions, flags suspicious activity with a rule-based risk score, and reports the results in a Power BI dashboard.

**Tools:** Python (pandas, Google Colab) · MySQL · Excel · Power BI

---

## Project goal

Examine financial transactions and visualize potential fraud indicators, such as unusual transaction amounts and timing, so that suspicious transactions can be prioritized for review.

## Dataset

- **Source:** PaySim, a synthetic mobile-money transaction dataset (11 columns, 6,362,620 rows in the full file).
- **Sample used:** 10,000 rows, built from 500 fraud rows and 9,500 legitimate rows (random seed 42).
- **Why a sample:** the full file is 471 MB, which is too large for a quick MySQL import. The original fraud rate is only about 0.13%, so a plain random sample would contain too few fraud cases to analyze.
- **Important:** the sample's fraud rate (5%) is **boosted on purpose**. Percentages in this project describe the sample, not real-world fraud rates.

| Column | Meaning |
|---|---|
| step | Hour of the simulation (1 step = 1 hour) |
| type | CASH_IN, CASH_OUT, DEBIT, PAYMENT, TRANSFER |
| amount | Transaction amount |
| nameOrig / nameDest | Sender and receiver IDs |
| oldbalanceOrg / newbalanceOrig | Sender balance before and after |
| oldbalanceDest / newbalanceDest | Receiver balance before and after |
| isFraud | 1 if fraud, 0 otherwise |
| isFlaggedFraud | The system's own flag |

## Workflow

### 1. Python (Google Colab): cleaning and feature engineering
- Checked the data for missing values and duplicates.
- Created new columns:
  - `hour_of_day` = step % 24 and `day` = step // 24 + 1
  - `orig_emptied`: 1 if the sender's balance went from above 0 to exactly 0
  - `balance_error` and `amount_to_balance` (share of the sender's balance that was moved; set to 0 when the starting balance was 0)
  - `high_amount`: 1 if the amount is in the top 10% (above about 410,900)
  - `risky_type`: 1 for TRANSFER or CASH_OUT
- Built a simple **risk score** = `risky_type` + 2 × `orig_emptied` + `high_amount`, then grouped it into **High** (3 or more), **Medium** (2) and **Low** (0 to 1).
- Exported the cleaned file to `transactions_clean.csv`.

### 2. MySQL: aggregation queries
- Loaded the cleaned file into a `fraud_analysis` database.
- Wrote queries for fraud by transaction type, fraud rate by hour, fraud versus normal amounts, the top fraud transactions, and the accuracy of the built-in `isFraud` flag.
- The CSV was accidentally imported twice (20,000 rows). I fixed this by creating a de-duplicated copy with `SELECT DISTINCT` and checking the row count (10,000) before replacing the original table.

### 3. Excel: exploration
- Pivot tables and pivot charts for fraud by transaction type, risk level and hour.
- Data Analysis ToolPak: descriptive statistics for `amount` and a correlation table against `isFraud`.

### 4. Power BI: dashboard
- Four KPI cards: Total Transactions, High Risk, Fraud Rate, Fraud Cases.
- Donut chart of fraud by transaction type.
- Column chart of fraud rate by hour of day.
- Bar chart of transactions by risk level.
- Line chart of fraud cases by day.
- Table of the top fraud transactions by amount.

## Key findings (from the 10,000-row sample)

1. **All fraud is in two transaction types.** CASH_OUT has 254 fraud cases and TRANSFER has 246. PAYMENT, CASH_IN and DEBIT have none.
2. **Fraud transactions are much larger.** The average fraud amount is about 1.4 million, roughly 8 times the average legitimate amount (about 181,000).
3. **Fraud clusters in the early hours.** The fraud rate is highest from about hour 1 to hour 8 and peaks at 100% at hour 4. After hour 8 it stays below about 10%.
4. **Emptying the account is a strong clue.** The sender's balance was driven to zero in 486 of the 500 fraud cases.
5. **The risk levels separate fraud well.** High-risk transactions contain 486 of the 500 fraud cases (2,249 transactions in total). Medium has 12 fraud cases (834 transactions), and Low has 2 (6,917 transactions).
6. **The built-in flag misses almost everything.** `isFlaggedFraud` marked only 1 of the 500 fraud transactions.
7. **Amounts are highly skewed.** The median amount is about 85,000, but the mean is about 242,000 and the maximum is about 31.5 million, so a few very large transactions pull the average up.

## Limitations

- The data is **synthetic**, and the fraud rate in the sample is boosted to 5%.
- The risk score is a simple rule-based method, not a trained model. It was built and checked on the same sample, so its results should not be taken as real-world accuracy.
- Fraud in PaySim only appears in TRANSFER and CASH_OUT, which makes the `risky_type` rule very effective here but not necessarily in other datasets.
- Some hours have few transactions (for example, hour 5 has 29), so rates for those hours are based on small counts.

## Repository structure

```
├── README.md
├── data/
│   └── transactions_clean.csv
├── notebooks/
│   └── fraud_analysis.ipynb
├── sql/
│   └── fraud_queries.sql
├── excel/
│   └── fraud_analysis.xlsx
├── powerbi/
│   └── fraud_Analysis.pbix
└── images/
    └── dashboard.png
```

## How to run

1. Open the notebook in Google Colab and upload the 10,000-row sample to recreate `transactions_clean.csv`.
2. Create the `fraud_analysis` database in MySQL and import the CSV into a `transactions` table, then run the queries in `sql/fraud_queries.sql`.
3. Open `fraud_Analysis.pbix` in Power BI Desktop. If the data source path is different on your computer, update it under **Transform data → Data source settings**.

## Author

**Faham Falki**
B.Tech Computer Science and Engineering, Centurion University of Technology and Management
[LinkedIn](#) · [GitHub](#)
