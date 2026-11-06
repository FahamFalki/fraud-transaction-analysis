CREATE DATABASE fraud_analysis;
USE fraud_analysis;
CREATE DATABASE IF NOT EXISTS Transaction DEFAULT CHARACTER SET utf8mb4;
select count(*) from transactions_clean;
rename table transactions_clean to transactions;


select risk_level, count(*) as total, sum(isFraud) as fraud_cases from transactions group by risk_level;
CREATE TABLE transactions_dedup AS
SELECT DISTINCT * FROM transactions;
SELECT COUNT(*) FROM transactions_dedup;
DROP TABLE transactions;
RENAME TABLE transactions_dedup TO transactions;
drop table transactions;
SELECT risk_level, COUNT(*) AS total, SUM(isFraud) AS fraud_cases
FROM transactions
GROUP BY risk_level;


-- Fraud by transaction type
select type, count(*) as total, sum(isFraud) as fraud_cases,round(avg(amount),2) as avg_amount from transactions group by type order by fraud_cases desc;

-- fraud by hour of day
select hour_of_day, count(*) , sum(isfraud) as fraud_cases, round(sum(isFraud) / count(*) * 100, 1) as fraud_rate_pct from transactions group by hour_of_day  order by  fraud_rate_pct desc;

-- fraud vs. normal amounts (“unusual amounts” analysis)
select isFraud, count(*) as total, round(avg(amount),0) as avg_amount, max(amount) as max_amount from transactions group by isFraud;

-- top 10 biggest suspicious transactions
select nameOrig, nameDest, type, amount,hour_of_day, risk_level from transactions where isFraud = 1 order by amount desc limit 10;

-- is the system’s own flag any good?
select isFlaggedFraud, count(*) as total, sum(isFraud) as real_fraud from transactions group by isFlaggedFraud;