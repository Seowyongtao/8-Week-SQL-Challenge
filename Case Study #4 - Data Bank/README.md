# Case Study #4 - Data Bank

<img alt="Case Study 4" src="https://8weeksqlchallenge.com/images/case-study-designs/4.png" width="60%" height="60%" />

## 📚 Table of Contents
- [Introduction](#introduction)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [A. Customer Nodes Exploration](#a-customer-nodes-exploration)
- [B. Customer Transactions](#b-customer-transactions)

## Introduction 

There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

## Entity Relationship Diagram:

<img alt="Case Study 4" src="https://8weeksqlchallenge.com/images/case-study-4-erd.png" width="70%" />

Full details for this case study: https://8weeksqlchallenge.com/case-study-4/

## A. Customer Nodes Exploration

#### Question 1: How many unique nodes are there on the Data Bank system?

#### Solution: 

```sql
SELECT COUNT(DISTINCT node_id) AS unique_nodes_count
FROM data_bank.customer_nodes;
```

#### Answer:

| unique_nodes_count |
| ------------------ |
| 5                  |

---
#### Question 2: What is the number of nodes per region?

#### Solution: 

```sql
SELECT region_name, 
	   COUNT(DISTINCT node_id) AS number_of_nodes
FROM data_bank.customer_nodes 
LEFT JOIN data_bank.regions 
ON customer_nodes.region_id = regions.region_id
GROUP BY regions.region_name;
```

#### Answer:

| region_name | number_of_nodes |
| ----------- | --------------- |
| Africa      | 5               |
| America     | 5               |
| Asia        | 5               |
| Australia   | 5               |
| Europe      | 5               |

---
#### Question 3: How many customers are allocated to each region?

#### Solution: 

```sql
SELECT region_name, 
	   COUNT(customer_id) AS number_of_customers
FROM data_bank.customer_nodes 
LEFT JOIN data_bank.regions 
ON customer_nodes.region_id = regions.region_id
GROUP BY region_name
ORDER BY region_name;
```

#### Answer:

| region_name | number_of_customers |
| ----------- | ------------------- |
| Africa      | 714                 |
| America     | 735                 |
| Asia        | 665                 |
| Australia   | 770                 |
| Europe      | 616                 |

---
#### Question 4: How many days on average are customers reallocated to a different node?

#### Solution: 

```sql
WITH CTE AS (
    SELECT 
        customer_id,
        region_id,
        node_id,
        start_date,
        end_date,
        CASE 
            WHEN node_id = LAG(node_id) OVER (PARTITION BY customer_id ORDER BY start_date) 
            THEN 0 
            ELSE 1 
        END AS is_new_group
    FROM 
        data_bank.customer_nodes
),

CTE2 AS (
 
  SELECT 
      customer_id,
      region_id,
      node_id,
      start_date,
      end_date,
      SUM(is_new_group) OVER (
          PARTITION BY customer_id 
          ORDER BY start_date
      ) AS grouping
  FROM 
      CTE
  
),

CTE3 AS (

  SELECT 
 	  customer_id, 
  	  node_id, 
  	  grouping, 
      MIN(start_date) AS start_date,
      MAX(end_date) AS end_date
  FROM 
	  CTE2
  GROUP BY customer_id, node_id, grouping
  
)

SELECT ROUND(AVG(end_date - start_date)) AS average_reallocation_days
FROM CTE3
WHERE end_date != '9999-12-31';
```

#### Answer:

| average_reallocation_days |
| ------------------------- |
| 18                        |

---
#### Question 5: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

## B. Customer Transactions

#### Question 1: What is the unique count and total amount for each transaction type?

#### Solution: 

```sql
SELECT txn_type, 
	   COUNT(*) AS transaction_unique_count, 
       SUM(txn_amount) AS transaction_total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type;
```

#### Answer:

| txn_type   | transaction_unique_count | transaction_total_amount |
| ---------- | ------------------------ | ------------------------ |
| purchase   | 1617                     | 806537                   |
| deposit    | 2671                     | 1359168                  |
| withdrawal | 1580                     | 793003                   |

---
#### Question 2: What is the average total historical deposit counts and amounts for all customers?

#### Solution: 

```sql
WITH customer_deposit AS (
  
	SELECT customer_id, 
           COUNT(*) AS deposit_count, 
           SUM(txn_amount) AS deposit_amount
    FROM data_bank.customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
  
 )
 
 SELECT AVG(deposit_count) AS average_deposit_counts,
        SUM(deposit_amount)/SUM(deposit_count) AS average_deposit_amount
 FROM customer_deposit; 
```

#### Answer:

| average_deposit_counts | average_deposit_amount |
| ---------------------- | ---------------------- |
| 5.3420000000000000     | 508.8611007113440659   |

---
#### Question 3: For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

#### Solution: 

```sql
WITH transaction_type_cnt AS (

  SELECT customer_id, 
         txn_date,
         txn_type,
         (CASE
           WHEN txn_type = 'deposit' THEN 1
           ELSE 0
         END) AS deposit_cnt, 
         (CASE
           WHEN txn_type = 'withdrawal' THEN 1
           ELSE 0
         END) AS withdrawal_cnt, 
         (CASE
           WHEN txn_type = 'purchase' THEN 1
           ELSE 0
         END) AS purchase_cnt
  FROM data_bank.customer_transactions
  
), 

monthly_transaction_type_cnt AS (

  SELECT customer_id, 
         TO_CHAR(txn_date, 'YYYYMM') AS month, 
         SUM(deposit_cnt) AS deposit_cnt, 
         SUM(withdrawal_cnt) AS withdrawal_cnt, 
         SUM(purchase_cnt) AS purchase_cnt
  FROM transaction_type_cnt
  GROUP BY customer_id, TO_CHAR(txn_date, 'YYYYMM')
  
)

SELECT month, 
       COUNT(DISTINCT customer_id) AS number_of_customers
FROM monthly_transaction_type_cnt
WHERE deposit_cnt > 1 
AND (withdrawal_cnt >= 1 OR purchase_cnt >= 1)
GROUP BY month
ORDER BY month;
```

#### Answer:

| month  | number_of_customers |
| ------ | ------------------- |
| 202001 | 168                 |
| 202002 | 181                 |
| 202003 | 192                 |
| 202004 | 70                  |

---
#### Question 4: What is the closing balance for each customer at the end of the month?

#### Solution: 

```sql
WITH monthly_balance_change AS (

SELECT customer_id, 
	   TO_CHAR(txn_date, 'YYYYMM') AS month,
	   SUM
	   (CASE 
        	WHEN txn_type IN ('purchase', 'withdrawal') THEN - txn_amount
        	ELSE txn_amount
        END) AS monthly_balance_change
FROM data_bank.customer_transactions
GROUP BY customer_id, TO_CHAR(txn_date, 'YYYYMM')
  
  
), 


generated_months AS (
  
  SELECT DISTINCT customer_id, 
    		      month
  FROM data_bank.customer_transactions
  CROSS JOIN (
    VALUES ('202001'), ('202002'), ('202003'), ('202004')
  ) AS m(month)
  
)


SELECT generated_months.customer_id, 
	   generated_months.month,
       COALESCE(monthly_balance_change, 0) AS monthly_balance_change,
       SUM(monthly_balance_change) OVER (
          PARTITION BY generated_months.customer_id
          ORDER BY generated_months.month
       ) AS balance_eom
FROM generated_months
LEFT JOIN monthly_balance_change 
ON generated_months.customer_id = monthly_balance_change .customer_id
AND generated_months.month = monthly_balance_change.month
ORDER BY customer_id, month;
```

#### Answer:

| customer_id | month  | monthly_balance_change | balance_eom |
| ----------- | ------ | ---------------------- | ----------- |
| 1           | 202001 | 312                    | 312         |
| 1           | 202002 | 0                      | 312         |
| 1           | 202003 | -952                   | -640        |
| 1           | 202004 | 0                      | -640        |
| 2           | 202001 | 549                    | 549         |
| 2           | 202002 | 0                      | 549         |
| 2           | 202003 | 61                     | 610         |
| 2           | 202004 | 0                      | 610         |
| 3           | 202001 | 144                    | 144         |
| 3           | 202002 | -965                   | -821        |
| 3           | 202003 | -401                   | -1222       |
| 3           | 202004 | 493                    | -729        |
| ...           | ... | ...                    | ...        |

---
#### Question 5: What is the percentage of customers who increase their closing balance by more than 5%?

#### Solution: 

```sql
CREATE TEMPORARY TABLE monthly_summary AS
WITH monthly_balance_change AS (

SELECT customer_id, 
	   TO_CHAR(txn_date, 'YYYYMM') AS month,
	   SUM
	   (CASE 
        	WHEN txn_type IN ('purchase', 'withdrawal') THEN - txn_amount
        	ELSE txn_amount
        END) AS monthly_balance_change
FROM data_bank.customer_transactions
GROUP BY customer_id, TO_CHAR(txn_date, 'YYYYMM')
  
  
), 


generated_months AS (
  
  SELECT DISTINCT customer_id, 
    		      month
  FROM data_bank.customer_transactions
  CROSS JOIN (
    VALUES ('202001'), ('202002'), ('202003'), ('202004')
  ) AS m(month)
  
)


SELECT generated_months.customer_id, 
	   generated_months.month,
       COALESCE(monthly_balance_change, 0) AS monthly_balance_change,
       SUM(monthly_balance_change) OVER (
          PARTITION BY generated_months.customer_id
          ORDER BY generated_months.month
       ) AS balance_eom
FROM generated_months
LEFT JOIN monthly_balance_change 
ON generated_months.customer_id = monthly_balance_change .customer_id
AND generated_months.month = monthly_balance_change.month
ORDER BY customer_id, month; 




WITH jan_balance AS (

  SELECT customer_id, 
  		 balance_eom AS jan_balance
  FROM monthly_summary
  WHERE month = '202001'
), 

feb_balance AS (
  
  SELECT customer_id, 
  		 balance_eom AS feb_balance, 
  		 monthly_balance_change AS balance_change
  FROM monthly_summary
  WHERE month = '202002'
  
), 

jan_feb_balance AS (
  
  SELECT j.customer_id, 
         j.jan_balance, 
         f.feb_balance, 
         f.balance_change
  FROM jan_balance j
  LEFT JOIN feb_balance f
  ON j.customer_id = f.customer_id
  
), 

condition_count AS (

  SELECT *,
         CASE
          WHEN jan_balance <= 0 THEN 1
          ELSE 0
         END AS negavtive_jan_balance, 
         CASE
          WHEN jan_balance > 0 THEN 1
          ELSE 0
         END AS positive_jan_balance,
  		 CASE
          WHEN jan_balance > 0 THEN (
            CASE 
            WHEN (balance_change/jan_balance) > 0.05 THEN 1 
            ELSE 0 
            END
          )
          ELSE 0
         END AS increase_5,
  		 CASE
          WHEN jan_balance > 0 THEN (
            CASE 
            WHEN (balance_change/jan_balance) < -0.05 THEN 1 
            ELSE 0 
            END
          )
          ELSE 0
         END AS decrease_5, 
         CASE
          WHEN (jan_balance > 0 AND feb_balance <= 0) THEN 1
          ELSE 0
         END AS positive_to_negative, 
         CAST('1' AS INT) AS count
  FROM jan_feb_balance
  
 )
 
 SELECT (100 * SUM(negavtive_jan_balance)/SUM(count)) AS negavtive_jan_balance_pc,
 		(100 * SUM(positive_jan_balance)/SUM(count)) AS positive_jan_balance_pc,
        (100 * SUM(increase_5)/SUM(count)) AS increase_5_pc,
        (100 * SUM(decrease_5)/SUM(count)) AS descrease_5_pc,
        (100 * SUM(positive_to_negative)/SUM(count)) AS positive_to_negative_pc
 FROM condition_count;
```

#### Answer:

| negavtive_jan_balance_pc | positive_jan_balance_pc | increase_5_pc | descrease_5_pc | positive_to_negative_pc |
| ------------------------ | ----------------------- | ------------- | -------------- | ----------------------- |
| 31                       | 68                      | 25            | 34             | 23                      |







