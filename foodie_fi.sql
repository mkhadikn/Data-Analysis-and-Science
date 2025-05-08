-- Challenge: https://8weeksqlchallenge.com/case-study-3/
-- Solved by khadik

DROP TABLE IF EXISTS plans;
CREATE TABLE plans (
  plan_id INTEGER,
  plan_name VARCHAR(13),
  price DECIMAL(5,2)
);

INSERT INTO plans
  (plan_id, plan_name, price)
VALUES
  ('0', 'trial', '0'),
  ('1', 'basic monthly', '9.90'),
  ('2', 'pro monthly', '19.90'),
  ('3', 'pro annual', '199'),
  ('4', 'churn', null);

ALTER TABLE subscriptions
MODIFY COLUMN start_date TIMESTAMP;

SELECT * FROM plans;
SELECT * FROM subscriptions; -- csv

-- A. Customer Journey

DROP TABLE IF EXISTS journey;
CREATE TEMPORARY TABLE journey
SELECT s.customer_id,
       p.plan_id,
       plan_name,
       price,
       start_date,
       TIMESTAMPDIFF(day, (LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date)),start_date ) AS days_diff,
       TIMESTAMPDIFF(month,(LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date)),start_date) AS months_diff
FROM   subscriptions AS s
JOIN   plans AS p
ON     s.plan_id = p.plan_id;
SELECT * FROM journey;

-- simple analysis

SELECT COUNT(customer_id) total_data,
	   COUNT(DISTINCT customer_id) total_cust, 
       SUM(price) revenue, 
       TIMESTAMPDIFF(DAY, MIN(start_date), MAX(start_date)) total_day 
FROM journey;

-- B. Data Analysis Questions

-- 2. What is the monthly distribution of trial plan start_date values for our dataset
--    use the start of the month as the group by value

SELECT MONTH(start_date) month, YEAR(start_date) year, SUM(CASE WHEN plan_id = 0 THEN 1 ELSE 0 END) total_trial 
FROM journey GROUP BY month, year ORDER BY year, month;

