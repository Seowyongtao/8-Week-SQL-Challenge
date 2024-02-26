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

#### Question 1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

#### Solution: 

```sql
SELECT DATE_TRUNC('week', registration_date)::DATE + 4 AS week,
       COUNT(*) AS number_of_runners_signed_up
FROM pizza_runner.runners
GROUP BY DATE_TRUNC('week', registration_date)::DATE + 4
ORDER BY DATE_TRUNC('week', registration_date)::DATE + 4
```

#### Answer:
| week       | number_of_runners_signed_up |
|------------|-----------------------------|
| 2021-01-01 | 2                           |
| 2021-01-08 | 1                           |
| 2021-01-15 | 1                           |

---
#### Question 2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

#### Solution: 

```sql
WITH cleaned_joined_table AS (

  SELECT DISTINCT customer_orders.order_id, 
                  runner_id,
                  order_time, 
                  pickup_time,
                  (EXTRACT(EPOCH FROM pickup_time::TIMESTAMP) - EXTRACT(EPOCH FROM order_time::TIMESTAMP)) / (60)  as time_difference_minutes
  FROM pizza_runner.customer_orders
  INNER JOIN pizza_runner.runner_orders
  ON customer_orders.order_id = runner_orders.order_id
  WHERE pickup_time != 'null'

)

SELECT runner_id,
       ROUND(AVG(time_difference_minutes), 2) average_minutes
FROM cleaned_joined_table
GROUP BY runner_id
ORDER BY runner_id
```

#### Answer:
| runner_id | average_minutes |
|-----------|-----------------|
| 1         | 14.33           |
| 2         | 20.01           |
| 3         | 10.47           |

---
#### Question 3: Is there any relationship between the number of pizzas and how long the order takes to prepare?

#### Solution: 

```sql
WITH time_taken_for_every_orderid AS (

  SELECT DISTINCT customer_orders.order_id, 
                  order_time, 
                  pickup_time,
                  (EXTRACT(EPOCH FROM pickup_time::TIMESTAMP) 
                  - EXTRACT(EPOCH FROM order_time::TIMESTAMP)) 
                  / (60)  as time_taken_to_prepare_in_minutes
  FROM pizza_runner.customer_orders
  INNER JOIN pizza_runner.runner_orders
  ON customer_orders.order_id = runner_orders.order_id
  WHERE pickup_time != 'null'

),

number_of_pizza_for_every_orderID AS (

SELECT order_id,
       COUNT(*) AS number_of_pizzas
FROM pizza_runner.customer_orders
GROUP BY order_id

)

SELECT number_of_pizzas,
       ROUND(AVG(time_taken_to_prepare_in_minutes), 2 ) AS average_time_taken_to_prepare_in_minutes
FROM time_taken_for_every_orderid a
INNER JOIN number_of_pizza_for_every_orderID b
ON a.order_id = b.order_id
GROUP BY number_of_pizzas
```

#### Answer:
| number_of_pizzas | average_time_taken_to_prepare_in_minutes |
|------------------|------------------------------------------|
| 3                | 29.28                                    |
| 2                | 18.38                                    |
| 1                | 12.36                                    |

Yes, when the number of pizzas prepared increased, the average time taken to prepare increased as well

---
#### Question 4: What was the average distance travelled for each customer?

#### Solution: 

```sql
WITH cleaned_customer_order_distance AS (

  SELECT DISTINCT runner_orders.order_id,
                  customer_id, 
                  UNNEST(REGEXP_MATCH(distance, '(^[0-9,.]+)'))::NUMERIC AS distance
  FROM pizza_runner.customer_orders 
  INNER JOIN pizza_runner.runner_orders
  ON customer_orders.order_id = runner_orders.order_id
  WHERE pickup_time != 'null'

)

SELECT customer_id,
       ROUND(AVG(distance), 2) AS average_distance
FROM cleaned_customer_order_distance
GROUP BY customer_id
ORDER BY customer_id
```

#### Answer:
| customer_id | average_distance |
|-------------|------------------|
| 101         | 20.00            |
| 102         | 18.40            |
| 103         | 23.40            |
| 104         | 10.00            |
| 105         | 25.00            |

---
#### Question 5: What was the difference between the longest and shortest delivery times for all orders?

#### Solution: 

```sql
WITH cleaned_runner_order_duration AS (

  SELECT order_id,
         UNNEST(REGEXP_MATCH(duration, '(^[0-9,.]+)'))::NUMERIC AS delivery_times
  FROM pizza_runner.runner_orders
  WHERE pickup_time != 'null'

)

SELECT MAX(delivery_times) AS longest_delivery_times,
       MIN (delivery_times) AS shortest_delivery_times,
       ( MAX(delivery_times) - MIN(delivery_times) ) AS difference
FROM cleaned_runner_order_duration
```

#### Answer:
| longest_delivery_times | shortest_delivery_times | difference |
|------------------------|-------------------------|------------|
| 40                     | 10                      | 30         |

---
#### Question 6: What was the average speed for each runner for each delivery and do you notice any trend for these values?

#### Solution: 

```sql
WITH cleaned_runner_orders AS (

SELECT runner_id, 
       UNNEST(REGEXP_MATCH(distance, '(^[0-9,.]+)'))::NUMERIC AS distance,
       UNNEST(REGEXP_MATCH(duration, '(^[0-9,.]+)'))::NUMERIC AS delivery_times,
       ( UNNEST(REGEXP_MATCH(distance, '(^[0-9,.]+)'))::NUMERIC /
         UNNEST(REGEXP_MATCH(duration, '(^[0-9,.]+)'))::NUMERIC ) AS speed
FROM pizza_runner.runner_orders
WHERE pickup_time != 'null'

)

SELECT runner_id, 
       ROUND( AVG(speed), 2) AS average_speed
FROM cleaned_runner_orders
GROUP BY runner_id
```

#### Answer:
| runner_id | average_speed |
|-----------|---------------|
| 3         | 0.67          |
| 2         | 1.05          |
| 1         | 0.76          |

Runner 2's average speed is way higher than the average speed of both runner 1 and 3!

---
#### Question 7: What is the successful delivery percentage for each runner?

#### Solution: 

```sql
SELECT runner_id,
       ( 100 * SUM(CASE WHEN pickup_time != 'null' THEN 1 ELSE 0 END) /
         COUNT(*) ) AS successful_delivery_percentage
FROM pizza_runner.runner_orders
GROUP BY runner_id
ORDER BY runner_id
```

#### Answer:
| runner_id | successful_delivery_percentage |
|-----------|--------------------------------|
| 1         | 100                            |
| 2         | 75                             |
| 3         | 50                             |

## C. Ingredient Optimization

#### Question 1: What are the standard ingredients for each pizza?

#### Solution: 

```sql
WITH cleaned_pizza_recipes AS (

  SELECT pizza_recipes.pizza_id,
         pizza_names.pizza_name,
         REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
  FROM pizza_runner.pizza_recipes
  INNER JOIN pizza_runner.pizza_names
  ON pizza_recipes.pizza_id = pizza_names.pizza_id

)

SELECT pizza_id,
       pizza_name,
       STRING_AGG(pizza_toppings.topping_name::TEXT, ', ') AS toppings
FROM cleaned_pizza_recipes
INNER JOIN pizza_runner.pizza_toppings
ON cleaned_pizza_recipes.topping_id = pizza_toppings.topping_id
GROUP BY pizza_id, pizza_name
ORDER BY pizza_id
```

#### Answer:

| pizza_id | pizza_name | toppings                                                                |
|----------|------------|-------------------------------------------------------------------------|
| 1        | Meatlovers | "Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami" |
| 2        | Vegetarian | "Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce"            |

---
#### Question 2: What was the most commonly added extra?

#### Solution: 

```sql
WITH CTE AS (

  SELECT REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
  FROM pizza_runner.customer_orders
  WHERE extras NOT IN ('', 'null') 
  AND extras IS NOT NULL 

)

SELECT topping_name AS most_commonly_added_extras
FROM CTE 
INNER JOIN pizza_runner.pizza_toppings
ON CTE.topping_id = pizza_toppings.topping_id
GROUP BY topping_name
ORDER BY COUNT(*) DESC
LIMIT 1
```

#### Answer:
| most_commonly_added_extras |
|----------------------------|
| Bacon                      |

---
#### Question 3: What was the most common exclusion?

#### Solution: 

```sql
WITH CTE AS (

  SELECT REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
  FROM pizza_runner.customer_orders
  WHERE exclusions NOT IN ('', 'null') 
  AND exclusions IS NOT NULL 

)

SELECT topping_name AS most_commonly_exclusion
FROM CTE 
INNER JOIN pizza_runner.pizza_toppings
ON CTE.topping_id = pizza_toppings.topping_id
GROUP BY topping_name
ORDER BY COUNT(*) DESC
LIMIT 1
```

#### Answer:
| most_commonly_exclusion |
|-------------------------|
| Cheese                  |

---
#### Question 4: Generate an order item for each record in the  `customers_orders`  table in the format of one of the following:

-   `Meat Lovers`
-   `Meat Lovers - Exclude Beef`
-   `Meat Lovers - Extra Bacon`
-   `Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers`

#### Solution: 

```sql
WITH CTE1 AS (

  SELECT order_id,
         customer_id,
         pizza_id,
         (CASE
           WHEN exclusions IN ('', 'null') THEN NULL
           ELSE exclusions 
         END) AS exclusions,
         (CASE
           WHEN extras IN ('', 'null','NaN') THEN NULL
           ELSE extras
          END) AS extras,
         order_time,
         ROW_NUMBER() OVER () AS original_row_number
  FROM pizza_runner.customer_orders

),

CTE2 AS (

  SELECT order_id,
         customer_id,
         pizza_id,
         REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS exclusions_topping_id,
         REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS extras_topping_id,
         order_time,
         original_row_number
    FROM CTE1
    
  UNION
  
    SELECT order_id,
           customer_id,
           pizza_id,
           NULL AS exclusions_topping_id,
           NULL AS extras_topping_id,
           order_time,
           original_row_number
    FROM CTE1
    WHERE exclusions IS NULL AND extras IS NULL
    
),

CTE3 AS (

  SELECT a.order_id,
       a.customer_id,
       a.pizza_id,
       b.pizza_name,
       a.order_time,
       a.original_row_number,
       STRING_AGG(c.topping_name, ', ') AS exclusions,
       STRING_AGG(d.topping_name, ', ') AS extras
  FROM CTE2 a
  INNER JOIN pizza_runner.pizza_names b
    ON a.pizza_id = b.pizza_id
  LEFT JOIN pizza_runner.pizza_toppings c
    ON a.exclusions_topping_id = c.topping_id
  LEFT JOIN pizza_runner.pizza_toppings AS d
    ON a.exclusions_topping_id = d.topping_id
  GROUP BY
    a.order_id,
    a.customer_id,
    a.pizza_id,
    b.pizza_name,
    a.order_time,
    a.original_row_number

),

CTE4 AS (

  SELECT order_id,
         customer_id,
         pizza_id,
         order_time,
         original_row_number,
         pizza_name,
         CASE WHEN exclusions IS NULL THEN '' ELSE ' - Exclude ' || exclusions END AS exclusions,
         CASE WHEN extras IS NULL THEN '' ELSE ' - Extra ' || exclusions END AS extras
  FROM CTE3
  
)

SELECT order_id,
       customer_id,
       pizza_id,
       order_time,
       pizza_name || exclusions || extras AS order_item
  FROM CTE4
```

#### Answer:
| order_id | customer_id | pizza_id | order_time              | order_item                                                               |
|----------|-------------|----------|-------------------------|--------------------------------------------------------------------------|
| 1        | 101         | 1        | 2021-01-01 18:05:02.000 | Meatlovers                                                               |
| 2        | 101         | 1        | 2021-01-01 19:00:52.000 | Meatlovers                                                               |
| 3        | 102         | 1        | 2021-01-02 23:51:23.000 | Meatlovers                                                               |
| 3        | 102         | 2        | 2021-01-02 23:51:23.000 | Vegetarian                                                               |
| 4        | 103         | 1        | 2021-01-04 13:23:46.000 | Meatlovers - Exclude Cheese - Extra Cheese                               |
| 4        | 103         | 1        | 2021-01-04 13:23:46.000 | Meatlovers - Exclude Cheese - Extra Cheese                               |
| 4        | 103         | 2        | 2021-01-04 13:23:46.000 | Vegetarian - Exclude Cheese - Extra Cheese                               |
| 5        | 104         | 1        | 2021-01-08 21:00:29.000 | Meatlovers                                                               |
| 6        | 101         | 2        | 2021-01-08 21:03:13.000 | Vegetarian                                                               |
| 7        | 105         | 2        | 2021-01-08 21:20:29.000 | Vegetarian                                                               |
| 8        | 102         | 1        | 2021-01-09 23:54:33.000 | Meatlovers                                                               |
| 9        | 103         | 1        | 2021-01-10 11:22:59.000 | Meatlovers - Exclude Cheese - Extra Cheese                               |
| 10       | 104         | 1        | 2021-01-11 18:34:49.000 | Meatlovers                                                               |
| 10       | 104         | 1        | 2021-01-11 18:34:49.000 | "Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra BBQ Sauce, Mushrooms" |

---
#### Question 5: Generate an alphabetically ordered comma separated ingredient list for each pizza order from the  `customer_orders`  table and add a  `2x`  in front of any relevant ingredients

-   For example:  `"Meat Lovers: 2xBacon, Beef, ... , Salami"`

#### Solution: 
```
working in progress
```


#### Answer:

---
#### Question 6: What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-   For example:  `"Meat Lovers: 2xBacon, Beef, ... , Salami"`

#### Solution: 
```
working in progress
```

#### Answer:

## D. Pricing and Ratings

#### Question 1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

#### Solution: 

```sql
SELECT SUM ( 
        CASE 
          WHEN pizza_name = 'Meatlovers' THEN 12
          ELSE 10
        END
      ) AS sales
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.pizza_names
ON customer_orders.pizza_id = pizza_names.pizza_id
INNER JOIN pizza_runner.runner_orders 
ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.pickup_time != 'null'
```

#### Answer:
| sales |
|-------|
| 138   |

---
#### Question 2: What if there was an additional $1 charge for any pizza extras?

-   Add cheese is $1 extra

#### Solution: 

```sql
WITH CTE AS (

  SELECT customer_orders.order_id,
         customer_id,
         pizza_id,
         (CASE
           WHEN extras IN ('', 'null','NaN') THEN NULL
           ELSE extras
          END) AS extras,
         order_time,
         ROW_NUMBER() OVER () AS original_row_number
  FROM pizza_runner.customer_orders
  INNER JOIN pizza_runner.runner_orders 
  ON customer_orders.order_id = runner_orders.order_id
  WHERE runner_orders.pickup_time != 'null'

)

SELECT SUM(
        CASE
          WHEN pizza_id = 1 THEN 12
          ELSE 10
        END 
      ) +
      SUM ( COALESCE( CARDINALITY(REGEXP_SPLIT_TO_ARRAY(extras, '[,\s]+')),0)) AS sales
FROM CTE
```

#### Answer:
| sales |
|-------|
| 142   |

---
#### Question 3: The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

---
#### Question 4: Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?

-   `customer_id`
-   `order_id`
-   `runner_id`
-   `rating`
-   `order_time`
-   `pickup_time`
-   Time between order and pickup
-   Delivery duration
-   Average speed
-   Total number of pizzas

---
#### Question 5: If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

#### Solution: 

```sql
WITH delivery_cost AS (

  SELECT UNNEST(REGEXP_MATCH(distance, '(^[0-9,.]+)'))::NUMERIC * 0.3 AS delivery_cost
  FROM pizza_runner.runner_orders
  WHERE pickup_time != 'null'
  
), 

total_delivery_cost AS (

  SELECT SUM(delivery_cost) AS total_delivery_cost
  FROM delivery_cost

),

total_sales AS (

  SELECT SUM ( 
          CASE 
            WHEN pizza_name = 'Meatlovers' THEN 12
            ELSE 10
          END
        ) AS sales
  FROM pizza_runner.customer_orders
  INNER JOIN pizza_runner.pizza_names
  ON customer_orders.pizza_id = pizza_names.pizza_id
  INNER JOIN pizza_runner.runner_orders 
  ON customer_orders.order_id = runner_orders.order_id
  WHERE runner_orders.pickup_time != 'null'

),

union_table AS (

  SELECT sales AS amount
  FROM total_sales
  
  UNION ALL 
  
  SELECT - (total_delivery_cost) AS amount
  FROM total_delivery_cost

)


SELECT SUM(amount) AS total_money_left
FROM union_table
```

#### Answer:
| total_money_left |
|------------------|
| 94.44            |
