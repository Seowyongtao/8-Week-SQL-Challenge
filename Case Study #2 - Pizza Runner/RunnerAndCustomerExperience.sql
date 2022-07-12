-----------------------------------------
--CASE STUDY #2 Questions and Solutions--
-----------------------------------------

-- B. Runner And Customer Experience--

-- Question 1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT to_char(registration_date, 'W') AS registration_week,
	   COUNT(registration_date) AS number_of_runner_signedup
FROM pizza_runner.runners
GROUP BY to_char(registration_date, 'W')
ORDER BY to_char(registration_date, 'W') ASC;

-- Question 2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT sub.runner_id,
	   AVG(sub.time_different) AS average_time_taken_minutes
FROM (
        SELECT distinct
  			r.runner_id,
  			EXTRACT(minute from (r.pickup_time::timestamp - c.order_time)) AS time_different
        FROM pizza_runner.customer_orders c
        JOIN pizza_runner.runner_orders r
        ON c.order_id = r.order_id
        WHERE r.pickup_time != 'null'
      ) sub
GROUP BY sub.runner_id;

-- Question 3: Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT number_of_pizzas,
	   AVG(time_taken) AS average_prepare_time_mins
FROM (
      SELECT order_id, 
             count(order_id) AS number_of_pizzas
      FROM pizza_runner.customer_orders
      GROUP BY order_id
     ) sub
JOIN (
        SELECT distinct
            c.order_id,
            EXTRACT(minute from (r.pickup_time::timestamp - c.order_time)) AS time_taken
        FROM pizza_runner.customer_orders c
        JOIN pizza_runner.runner_orders r
        ON c.order_id = r.order_id
        WHERE r.pickup_time != 'null'
      ) sub2
ON sub.order_id = sub2.order_id
GROUP BY number_of_pizzas

-- Question 4: What was the average distance travelled for each customer?

SELECT sub1.customer_id, 
	   AVG(sub2.new_distance) AS average_distance
FROM (
      SELECT DISTINCT order_id, customer_id
      FROM pizza_runner.customer_orders
     ) sub1
JOIN (
      SELECT order_id, 
             CAST(CASE WHEN distance LIKE '%km' THEN TRIM('km' from distance)
             ELSE distance END AS FLOAT )AS new_distance
      FROM pizza_runner.runner_orders
      WHERE distance != 'null'
	   ) sub2
ON sub1.order_id = sub2.order_id
GROUP BY sub1.customer_id
ORDER BY sub1.customer_id

-- Question 5: What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(sub.new_duration) - MIN(sub.new_duration) AS 					   dilivery_times_different
FROM (
      SELECT order_id,
             CAST(CASE WHEN duration LIKE '%minutes' 
             THEN TRIM ('minutes' from duration)
             WHEN duration LIKE '%mins'
             THEN TRIM ('mins' from duration) 
             WHEN duration LIKE '%minute'
             THEN TRIM ('minute' from duration)
             ELSE duration END AS INT) AS new_duration
      FROM pizza_runner.runner_orders
      WHERE distance != 'null'
     ) sub
