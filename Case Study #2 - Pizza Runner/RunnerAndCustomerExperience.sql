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

