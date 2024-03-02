# Case Study #3 - Foodie-Fi

## A. Customer Journey

Based off the 8 sample customers provided in the sample from the  `subscriptions`  table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

### Solution:
```sql
SELECT customer_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
LEFT JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE subscriptions.customer_id IN (1,2,11,13,15,16,18,19)
ORDER BY customer_id, start_date
```

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 1           | trial         | 2020-08-01 |
| 1           | basic monthly | 2020-08-08 |
| 2           | trial         | 2020-09-20 |
| 2           | pro annual    | 2020-09-27 |
| 11          | trial         | 2020-11-19 |
| 11          | churn         | 2020-11-26 |
| 13          | trial         | 2020-12-15 |
| 13          | basic monthly | 2020-12-22 |
| 13          | pro monthly   | 2021-03-29 |
| 15          | trial         | 2020-03-17 |
| 15          | pro monthly   | 2020-03-24 |
| 15          | churn         | 2020-04-29 |
| 16          | trial         | 2020-05-31 |
| 16          | basic monthly | 2020-06-07 |
| 16          | pro annual    | 2020-10-21 |
| 18          | trial         | 2020-07-06 |
| 18          | pro monthly   | 2020-07-13 |
| 19          | trial         | 2020-06-22 |
| 19          | pro monthly   | 2020-06-29 |
| 19          | pro annual    | 2020-08-29 |

### Customer’s Onboarding Journey Description

#### Customer 1:

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 1           | trial         | 2020-08-01 |
| 1           | basic monthly | 2020-08-08 |

- Customer 1 joined free trial on 2020-08-01 and downgraded to basic monthly plan one week after the free trial.

#### Customer 2:

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 2           | trial         | 2020-09-20 |
| 2           | pro annual    | 2020-09-27 |

- Customer 2 joined on 2020-09-20 and upgraded to pro annual plan one week after the free trial.

#### Customer 11:

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 11          | trial         | 2020-11-19 |
| 11          | churn         | 2020-11-26 |

- Customer 11 joined on 2020-11-19 and cancelled the plan right after the free trial.

#### Customer 13:

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 13          | trial         | 2020-12-15 |
| 13          | basic monthly | 2020-12-22 |
| 13          | pro monthly   | 2021-03-29 |

- Customer 13 joined on 2020-12-15 and downgraded to basic monthly plan after the free trial. 
- He/She then upgraded to pro monthly plan from basic monthly plan on 2021-03-29.

#### Customer 15:

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 15          | trial         | 2020-03-17 |
| 15          | pro monthly   | 2020-03-24 |
| 15          | churn         | 2020-04-29 |

- Customer 15 joined on 2020-03-17 and remain as pro monthly plan after the one week free trial.

#### Customer 16:

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 16          | trial         | 2020-05-31 |
| 16          | basic monthly | 2020-06-07 |
| 16          | pro annual    | 2020-10-21 |

- Customer 16 joined on 2020-05-31 and downgraded to basic monthly plan after the free trial.
- He/She then upgraded to pro annual plan from basic monthly plan on 2020-10-21.

#### Customer 18:

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 18          | trial         | 2020-07-06 |
| 18          | pro monthly   | 2020-07-13 |

- Customer 18 joined on 2020-07-06 and remain pro monthly plan after the one week free trial.

#### Customer 19:

| customer_id | plan_name     | start_date |
|-------------|---------------|------------|
| 19          | trial         | 2020-06-22 |
| 19          | pro monthly   | 2020-06-29 |
| 19          | pro annual    | 2020-08-29 |

- Customer 19 joined on 2020-06-22 and remain pro monthly plan after the one week free trial.
- He/She then upgraded to pro annual from pro monthly plan on 2020-08-29.

## B. Data Analysis Questions

#### Question 1: How many customers has Foodie-Fi ever had? 

#### Solution: 

```sql
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM foodie_fi.subscriptions
```

#### Answer:
| total_customers |
|-----------------|
| 1000            |

---
#### Question 2: What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

#### Solution: 

```sql
WITH TrialSubscriptionsBeginningOfMonth AS (

  SELECT customer_id,
         plan_name,
         DATE_TRUNC('MONTH', start_date)::DATE AS beginning_of_the_month
  FROM foodie_fi.subscriptions
  LEFT JOIN foodie_fi.plans
  ON subscriptions.plan_id = plans.plan_id
  WHERE plan_name = 'trial'

)

SELECT beginning_of_the_month,
       COUNT(*)
FROM TrialSubscriptionsBeginningOfMonth
GROUP BY beginning_of_the_month
ORDER BY beginning_of_the_month
```

#### Answer:
| beginning_of_the_month | count |
|------------------------|-------|
| 2020-01-01             | 88    |
| 2020-02-01             | 68    |
| 2020-03-01             | 94    |
| 2020-04-01             | 81    |
| 2020-05-01             | 88    |
| 2020-06-01             | 79    |
| 2020-07-01             | 89    |
| 2020-08-01             | 88    |
| 2020-09-01             | 87    |
| 2020-10-01             | 79    |
| 2020-11-01             | 75    |
| 2020-12-01             | 84    |

---
#### Question 3: What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

#### Solution: 

```sql
WITH SubscriptionStartMonthWithPlanInfo AS (

  SELECT DATE_TRUNC('MONTH', start_date)::DATE AS beginning_of_the_month,
         subscriptions.plan_id,
         plan_name
  FROM foodie_fi.subscriptions
  LEFT JOIN foodie_fi.plans
  ON subscriptions.plan_id = plans.plan_id
  WHERE DATE_TRUNC('MONTH', start_date)::DATE > '2020-12-31'

)

SELECT plan_id,
       plan_name,
       COUNT(*) AS event_count
FROM SubscriptionStartMonthWithPlanInfo 
GROUP BY plan_id, plan_name
ORDER BY plan_id
```

#### Answer:
| plan_id | plan_name     | event_count |
|---------|---------------|-------------|
| 1       | basic monthly | 8           |
| 2       | pro monthly   | 60          |
| 3       | pro annual    | 63          |
| 4       | churn         | 71          |

---
#### Question 4: What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

#### Solution: 

```sql
SELECT SUM ( CASE WHEN plan_name = 'churn' THEN 1 ELSE 0 END )  AS count_customer_churned,
       ROUND( 
        100 * SUM (CASE WHEN plan_name = 'churn' THEN 1 ELSE 0 END ) /
        COUNT(DISTINCT customer_id)::numeric, 
        1
       ) AS percentage_of_customers_churned
FROM foodie_fi.subscriptions
LEFT JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
```

#### Answer:
| count_customer_churned | percentage_of_customers_churned |
|------------------------|---------------------------------|
| 307                    | 30.7                            |

---
#### Question 5: How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

#### Solution: 

```sql
WITH SubscriptionWithPreviousPlan AS (

  SELECT customer_id,
         plan_name,
         LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) AS previous_plan_name
  FROM foodie_fi.subscriptions 
  LEFT JOIN foodie_fi.plans
  ON subscriptions.plan_id = plans.plan_id

)

SELECT SUM ( CASE WHEN (plan_name = 'churn' AND previous_plan_name = 'trial') THEN 1 ELSE 0 END )  AS count_customer_churned_straight_after_free_trial,
       ROUND( 
        100 * SUM (CASE WHEN (plan_name = 'churn' AND previous_plan_name = 'trial') THEN 1 ELSE 0 END ) /
        COUNT(DISTINCT customer_id)::numeric, 
        1
       ) AS percentage
FROM SubscriptionWithPreviousPlan
```

#### Answer:
| count_customer_churned_straight_after_free_trial | percentage |
|--------------------------------------------------|------------|
| 92                                               | 9.2        |

---
#### Question 6: What is the number and percentage of customer plans after their initial free trial?

#### Solution: 

```sql
WITH SubscriptionWithPreviousPlan AS (

  SELECT customer_id,
         subscriptions.plan_id,
         plan_name,
         LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) AS previous_plan_name
  FROM foodie_fi.subscriptions 
  LEFT JOIN foodie_fi.plans
  ON subscriptions.plan_id = plans.plan_id

)

SELECT plan_id,
       plan_name,
       COUNT(*) AS number_of_customers,
       ROUND(
        100 * COUNT(*) / SUM(COUNT(*)) OVER ()
       ) AS percentage
FROM SubscriptionWithPreviousPlan 
WHERE previous_plan_name = 'trial'
GROUP BY plan_name, plan_id
ORDER BY plan_id
```

#### Answer:
| plan_id | plan_name     | number_of_customers | percentage |
|---------|---------------|---------------------|------------|
| 1       | basic monthly | 546                 | 55         |
| 2       | pro monthly   | 325                 | 33         |
| 3       | pro annual    | 37                  | 4          |
| 4       | churn         | 92                  | 9          |

---
#### Question 7: What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

#### Solution: 

```sql
WITH FilteredRankedSubscriptions AS (

  SELECT customer_id,
         subscriptions.plan_id,
         start_date,
         plan_name,
         RANK() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS start_date_rank
  FROM foodie_fi.subscriptions
  LEFT JOIN foodie_fi.plans
  ON subscriptions.plan_id = plans.plan_id
  WHERE subscriptions.start_date <= '2020-12-31'

)

SELECT plan_id,
       plan_name,
       COUNT(DISTINCT customer_id) AS number_of_customers,
       ROUND(
        ( 100 * COUNT(DISTINCT customer_id) /
        SUM(COUNT(DISTINCT customer_id)) OVER () ),
        1
       ) AS percentage
  FROM FilteredRankedSubscriptions
  WHERE start_date_rank = 1 
  GROUP BY plan_id, plan_name
```

#### Answer:
| plan_id | plan_name     | number_of_customers | percentage |
|---------|---------------|---------------------|------------|
| 0       | trial         | 19                  | 1.9        |
| 1       | basic monthly | 224                 | 22.4       |
| 2       | pro monthly   | 326                 | 32.6       |
| 3       | pro annual    | 195                 | 19.5       |
| 4       | churn         | 236                 | 23.6       |

---
#### Question 8: How many customers have upgraded to an annual plan in 2020?

#### Solution: 

```sql
SELECT COUNT(DISTINCT customer_id) AS number_of_customers
FROM foodie_fi.subscriptions
WHERE plan_id = 3
AND start_date >= '2020-01-01'
AND start_date <= '2020-12-31'
```

#### Answer:
| number_of_customers |
|---------------------|
| 195                 |

---
#### Question 9: How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

#### Solution: 

```sql
WITH CustomerSubscriptionsWithJoinDate AS (

  SELECT customer_id, 
         plan_id,
         start_date,
         LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS join_date
  FROM foodie_fi.subscriptions
  WHERE customer_id IN (
  
    SELECT DISTINCT customer_id
    FROM foodie_fi.subscriptions
    WHERE plan_id = 3

  )
  AND plan_id IN (0,3)

),

CustomerUpgradeToAnnualPlan AS (

  SELECT customer_id,
         start_date AS upgraded_to_annual_date,
         join_date,
         (start_date - join_date) :: numeric AS day_taken
  FROM CustomerSubscriptionsWithJoinDate 
  WHERE plan_id = 3

)

SELECT ROUND( AVG(day_taken) ) AS average_days_taken
FROM CustomerUpgradeToAnnualPlan
```

#### Answer:
| average_days_taken |
|--------------------|
| 105                |

---
#### Question 10: Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

#### Solution: 

```sql
WITH CTE AS (

  SELECT customer_id, 
         plan_id,
         start_date,
         LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS join_date
  FROM foodie_fi.subscriptions
  WHERE customer_id IN (
  
    SELECT DISTINCT customer_id
    FROM foodie_fi.subscriptions
    WHERE plan_id = 3

  )
  AND plan_id IN (0,3)

),

CTE2 AS (

  SELECT customer_id,
         start_date AS upgraded_to_annual_date,
         join_date,
         (start_date - join_date) :: numeric AS day_taken
  FROM CTE 
  WHERE plan_id = 3

),

CTE3 AS (

  SELECT width_bucket( day_taken, 1, 361, 12) AS bucket_width,
         customer_id
  FROM CTE2

)

SELECT
  (bucket_width - 1) * 30 || '-' || bucket_width * 30 || ' days' AS breakdown_period,
  COUNT(*) AS number_of_customers
FROM CTE3
GROUP BY bucket_width
ORDER BY bucket_width
```

#### Answer:
| breakdown_period | number_of_customers |
|------------------|---------------------|
| 0-30 days        | 49                  |
| 30-60 days       | 24                  |
| 60-90 days       | 34                  |
| 90-120 days      | 35                  |
| 120-150 days     | 42                  |
| 150-180 days     | 36                  |
| 180-210 days     | 26                  |
| 210-240 days     | 4                   |
| 240-270 days     | 5                   |
| 270-300 days     | 1                   |
| 300-330 days     | 1                   |
| 330-360 days     | 1                   |

---
#### Question 11: How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

#### Solution: 

```sql
WITH FilteredSubscriptionWithPreviousPlan AS (

  SELECT customer_id,
         plan_name,
         LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) AS previous_plan_name
  FROM foodie_fi.subscriptions 
  LEFT JOIN foodie_fi.plans
  ON subscriptions.plan_id = plans.plan_id
  WHERE start_date <= '2020-12-31'

)

SELECT COUNT(DISTINCT customer_id) AS number_of_customers
FROM FilteredSubscriptionWithPreviousPlan 
WHERE plan_name = 'basic monthly'
AND previous_plan_name = 'pro monthly'
```

#### Answer:

| number_of_customers |
|---------------------|
| 0                   |

## C. Challenge Payment Question

The Foodie-Fi team wants you to create a new  `payments`  table for the year 2020 that includes amounts paid by each customer in the  `subscriptions`  table with the following requirements:

-   monthly payments always occur on the same day of month as the original  `start_date`  of any monthly paid plan
-   upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-   upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-   once a customer churns they will no longer make payments

Example outputs for this table might look like the following:

| customer_id | plan_id | plan_name     | payment_date | amount | payment_order |
|-------------|---------|---------------|--------------|--------|---------------|
| 1           | 1       | basic monthly | 2020-08-08   | 9.90   | 1             |
| 1           | 1       | basic monthly | 2020-09-08   | 9.90   | 2             |
| 1           | 1       | basic monthly | 2020-10-08   | 9.90   | 3             |
| 1           | 1       | basic monthly | 2020-11-08   | 9.90   | 4             |
| 1           | 1       | basic monthly | 2020-12-08   | 9.90   | 5             |
| 2           | 3       | pro annual    | 2020-09-27   | 199.00 | 1             |
| 7           | 1       | basic monthly | 2020-02-12   | 9.90   | 1             |
| 7           | 1       | basic monthly | 2020-03-12   | 9.90   | 2             |
| 7           | 1       | basic monthly | 2020-04-12   | 9.90   | 3             |
| 7           | 1       | basic monthly | 2020-05-12   | 9.90   | 4             |
| 7           | 2       | pro monthly   | 2020-05-22   | 10.00  | 5             |
| 7           | 2       | pro monthly   | 2020-06-22   | 19.90  | 6             |
| 7           | 2       | pro monthly   | 2020-07-22   | 19.90  | 7             |
| 7           | 2       | pro monthly   | 2020-08-22   | 19.90  | 8             |
| 7           | 2       | pro monthly   | 2020-09-22   | 19.90  | 9             |
| 7           | 2       | pro monthly   | 2020-10-22   | 19.90  | 10            |
| 7           | 2       | pro monthly   | 2020-11-22   | 19.90  | 11            |
| 7           | 2       | pro monthly   | 2020-12-22   | 19.90  | 12            |
| 13          | 1       | basic monthly | 2020-12-22   | 9.90   | 1             |
| 15          | 2       | pro monthly   | 2020-03-24   | 19.90  | 1             |
| 15          | 2       | pro monthly   | 2020-04-24   | 19.90  | 2             |
| 16          | 1       | basic monthly | 2020-06-07   | 9.90   | 1             |
| 16          | 1       | basic monthly | 2020-07-07   | 9.90   | 2             |
| 16          | 1       | basic monthly | 2020-08-07   | 9.90   | 3             |
| 16          | 1       | basic monthly | 2020-09-07   | 9.90   | 4             |
| 16          | 1       | basic monthly | 2020-10-07   | 9.90   | 5             |
| 16          | 3       | pro annual    | 2020-10-21   | 189.10 | 6             |
| 18          | 2       | pro monthly   | 2020-07-13   | 19.90  | 1             |
| 18          | 2       | pro monthly   | 2020-08-13   | 19.90  | 2             |
| 18          | 2       | pro monthly   | 2020-09-13   | 19.90  | 3             |
| 18          | 2       | pro monthly   | 2020-10-13   | 19.90  | 4             |
| 18          | 2       | pro monthly   | 2020-11-13   | 19.90  | 5             |
| 18          | 2       | pro monthly   | 2020-12-13   | 19.90  | 6             |
| 19          | 2       | pro monthly   | 2020-06-29   | 19.90  | 1             |
| 19          | 2       | pro monthly   | 2020-07-29   | 19.90  | 2             |
| 19          | 3       | pro annual    | 2020-08-29   | 199.00 | 3             |
| 25          | 1       | basic monthly | 2020-05-17   | 9.90   | 1             |
| 25          | 2       | pro monthly   | 2020-06-16   | 10.00  | 2             |
| 25          | 2       | pro monthly   | 2020-07-16   | 19.90  | 3             |
| 25          | 2       | pro monthly   | 2020-08-16   | 19.90  | 4             |
| 25          | 2       | pro monthly   | 2020-09-16   | 19.90  | 5             |
| 25          | 2       | pro monthly   | 2020-10-16   | 19.90  | 6             |
| 25          | 2       | pro monthly   | 2020-11-16   | 19.90  | 7             |
| 25          | 2       | pro monthly   | 2020-12-16   | 19.90  | 8             |
| 39          | 1       | basic monthly | 2020-06-04   | 9.90   | 1             |
| 39          | 1       | basic monthly | 2020-07-04   | 9.90   | 2             |
| 39          | 1       | basic monthly | 2020-08-04   | 9.90   | 3             |
| 39          | 2       | pro monthly   | 2020-08-25   | 10.00  | 4             |

#### Solution:

```sql
WITH lead_plans AS (

  SELECT
    customer_id,
    plan_id,
    start_date,
    LEAD(plan_id) OVER (
        PARTITION BY customer_id
        ORDER BY start_date
      ) AS lead_plan_id,
    LEAD(start_date) OVER (
        PARTITION BY customer_id
        ORDER BY start_date
      ) AS lead_start_date
  FROM foodie_fi.subscriptions
  WHERE DATE_PART('year', start_date) = 2020
  AND plan_id != 0
  
),

-- case 1: non churn monthly customers
case_1 AS (
  
  SELECT customer_id,
         plan_id,
         start_date,
         DATE_PART('mon', AGE('2020-12-31'::DATE, start_date))::INTEGER AS month_diff
  FROM lead_plans
  WHERE lead_plan_id is null
  -- not churn and annual customers
  AND plan_id NOT IN (3, 4)
    
),

-- generate a series to add the months to each start_date
case_1_payments AS (

    SELECT customer_id,
           plan_id,
           (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
    FROM case_1
  
),

-- case 2: churn customers
case_2 AS (

  SELECT customer_id,
         plan_id,
         start_date,
         DATE_PART('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  -- churn accounts only
  WHERE lead_plan_id = 4
  
),

case_2_payments AS (

  SELECT customer_id,
         plan_id,
         (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  from case_2
  
),

-- case 3: customers who move from basic to pro plans
case_3 AS (

  SELECT customer_id,
         plan_id,
         start_date,
         DATE_PART('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  WHERE plan_id = 1 AND lead_plan_id IN (2, 3)
  
),

case_3_payments AS (

  SELECT customer_id,
         plan_id,
         (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
    
  from case_3
  
),

-- case 4: pro monthly customers who move up to annual plans
case_4 AS (

  SELECT customer_id,
         plan_id,
         start_date,
         DATE_PART('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  WHERE plan_id = 2 AND lead_plan_id = 3
  
),

case_4_payments AS (

  SELECT customer_id,
         plan_id,
         (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  from case_4
  
),

-- case 5: annual pro payments
case_5_payments AS (

  SELECT customer_id,
         plan_id,
         start_date
  FROM lead_plans
  WHERE plan_id = 3
  
),


union_output AS (

  SELECT * FROM case_1_payments
  UNION ALL
  SELECT * FROM case_2_payments
  UNION ALL
  SELECT * FROM case_3_payments
  UNION ALL
  SELECT * FROM case_4_payments
  UNION ALL
  SELECT * FROM case_5_payments
  
)

SELECT customer_id,
       plans.plan_id,
       plans.plan_name,
       start_date AS payment_date,
       CASE
         WHEN union_output.plan_id IN (2, 3) AND
           LAG(union_output.plan_id) OVER w = 1
         THEN plans.price - 9.90
         ELSE plans.price
         END AS amount,
       RANK() OVER w AS payment_order
FROM union_output
INNER JOIN foodie_fi.plans
  ON union_output.plan_id = plans.plan_id
WHERE customer_id IN (1, 2, 7, 11, 13, 15, 16, 18, 19, 25, 39)
WINDOW w AS (
  PARTITION BY union_output.customer_id
  ORDER BY start_date
)
ORDER BY customer_id, payment_date
