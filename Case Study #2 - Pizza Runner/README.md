# Case Study #2 - Pizza Runner

## A. Pizza Metrics

#### Question 1: How many pizzas were ordered?

#### Solution: 

```sql
SELECT COUNT(*) AS total_number_of_pizza_ordered
FROM pizza_runner.customer_orders
```

#### Answer:

| total_number_of_pizza_ordered |
|-------------------------------|
| 14                            |

---
#### Question 2: How many unique customer orders were made?

#### Solution: 

```sql
SELECT COUNT (DISTINCT order_id)
FROM pizza_runner.customer_orders
```

#### Answer:
| count |
|-------|
| 10    |

---
#### Question 3: How many successful orders were delivered by each runner?

#### Solution: 

```sql
SELECT runner_id, 
       COUNT(*) AS number_of_successful_delivery
FROM pizza_runner.runner_orders
WHERE pickup_time != 'null'
GROUP BY runner_id
ORDER BY runner_id
```

#### Answer:
| runner_id | number_of_successful_delivery |
|-----------|-------------------------------|
| 1         | 4                             |
| 2         | 3                             |
| 3         | 1                             |

---
#### Question 4: How many of each type of pizza was delivered?

#### Solution: 

```sql
SELECT pizza_name, 
       COUNT(*) AS number_of_delivery
FROM pizza_runner.customer_orders 
INNER JOIN pizza_runner.runner_orders 
ON customer_orders.order_id = runner_orders.order_id
INNER JOIN pizza_runner.pizza_names 
ON customer_orders.pizza_id = pizza_names.pizza_id
WHERE pickup_time != 'null'
GROUP BY pizza_names.pizza_name
```

#### Answer:
| pizza_name | number_of_delivery |
|------------|--------------------|
| Meatlovers | 9                  |
| Vegetarian | 3                  |

---
#### Question 5: How many Vegetarian and Meatlovers were ordered by each customer?

#### Solution: 

```sql
SELECT customer_id, 
       pizza_name,
       COUNT(*) AS number_of_orders
FROM pizza_runner.customer_orders 
INNER JOIN pizza_runner.pizza_names
ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id, pizza_name
```

#### Answer:

| customer_id | pizza_name | number_of_orders |
|-------------|------------|------------------|
| 101         | Meatlovers | 2                |
| 101         | Vegetarian | 1                |
| 102         | Meatlovers | 2                |
| 102         | Vegetarian | 1                |
| 103         | Meatlovers | 3                |
| 103         | Vegetarian | 1                |
| 104         | Meatlovers | 3                |
| 105         | Vegetarian | 1                |

---
#### Question 6: What was the maximum number of pizzas delivered in a single order?

#### Solution: 

```sql
WITH CTE AS (

  SELECT order_id,
         COUNT(*) AS number_of_pizzas_ordered
  FROM pizza_runner.customer_orders
  GROUP BY order_id
  ORDER BY number_of_pizzas_ordered

)

SELECT MAX(number_of_pizzas_ordered) as maximun_number_of_pizzas_order 
FROM CTE
```

#### Answer:

| maximun_number_of_pizzas_order |
|--------------------------------|
| 3                              |

---
#### Question 7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

#### Solution: 

```sql
WITH cleaned_table AS (

  SELECT customer_orders.order_id,
         customer_orders.customer_id, 
         customer_orders.pizza_id,
         (CASE
            WHEN (customer_orders.exclusions = 'null' or customer_orders.exclusions = '') THEN NULL
            ELSE customer_orders.exclusions
          END) AS exclusions,
         (CASE
            WHEN (customer_orders.extras = 'NaN' OR customer_orders.extras = 'null' OR customer_orders.extras = '') THEN NULL
            ELSE extras
          END) AS extras,
          customer_orders.order_time
  FROM pizza_runner.customer_orders 
  INNER JOIN pizza_runner.runner_orders 
  ON customer_orders.order_id = runner_orders.order_id
  WHERE runner_orders.pickup_time != 'null'


)

SELECT customer_id,
       SUM(
        CASE 
          WHEN (exclusions IS NOT NULL OR extras IS NOT NULL) THEN 1
          ELSE 0
        END
       ) AS at_least_one_changes,
       SUM(
        CASE 
          WHEN (exclusions IS NULL AND extras IS NULL) THEN 1
          ELSE 0 
        END
       ) AS no_changes
FROM cleaned_table
GROUP BY customer_id
ORDER BY customer_id
```

#### Answer:
| customer_id | at_least_one_changes | no_changes |
|-------------|----------------------|------------|
| 101         | 0                    | 2          |
| 102         | 0                    | 3          |
| 103         | 3                    | 0          |
| 104         | 2                    | 1          |
| 105         | 1                    | 0          |

---
#### Question 8: How many pizzas were delivered that had both exclusions and extras?

#### Solution: 

```sql
WITH cleaned_table AS (

  SELECT customer_orders.order_id,
         customer_orders.customer_id, 
         customer_orders.pizza_id,
         (CASE
            WHEN (customer_orders.exclusions = 'null' or customer_orders.exclusions = '') THEN NULL
            ELSE customer_orders.exclusions
          END) AS exclusions,
         (CASE
            WHEN (customer_orders.extras = 'NaN' OR customer_orders.extras = 'null' OR customer_orders.extras = '') THEN NULL
            ELSE extras
          END) AS extras,
          customer_orders.order_time
  FROM pizza_runner.customer_orders 
  INNER JOIN pizza_runner.runner_orders 
  ON customer_orders.order_id = runner_orders.order_id
  WHERE runner_orders.pickup_time != 'null'


)

SELECT COUNT(*) AS number_of_pizzas_delivered_that_has_both_exclusions_and_extras
FROM cleaned_table
WHERE (exclusions IS NOT NULL AND extras IS NOT NULL)
```

#### Answer:

| number_of_pizzas_delivered_that_has_both_exclusions_and_extras |
|----------------------------------------------------------------|
| 1                                                              |

---
#### Question 9: What was the total volume of pizzas ordered for each hour of the day?

#### Solution: 

```sql
SELECT extract(hour from order_time) AS hour_of_the_day,
       COUNT(*) AS total_volume_of_pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY extract(hour from order_time)
ORDER BY extract(hour from order_time)
```

#### Answer:
| hour_of_the_day | total_volume_of_pizzas_ordered |
|-----------------|--------------------------------|
| 11              | 1                              |
| 13              | 3                              |
| 18              | 3                              |
| 19              | 1                              |
| 21              | 3                              |
| 23              | 3                              |

---
#### Question 10:  What was the volume of orders for each day of the week?

#### Solution: 

```sql
SELECT TO_CHAR(order_time, 'Day') AS day_of_the_week,
       COUNT(*) AS total_volume_of_pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY TO_CHAR(order_time, 'Day')
```

#### Answer:
| day_of_the_week | total_volume_of_pizzas_ordered |
|-----------------|--------------------------------|
| "Saturday "     | 3                              |
| "Sunday   "     | 1                              |
| "Monday   "     | 5                              |
| "Friday   "     | 5                              |

## B. Pizza Metrics
