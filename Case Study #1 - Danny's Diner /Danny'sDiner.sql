--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

---------------------------------------
--CASE STUDY #1 Questions and Solutions--
---------------------------------------

-- Question 1: What is the total amount each customer spent at the restaurant? 

SELECT a.customer_id, 
       sum(b.price) AS total_amount_spent
FROM dannys_diner.sales AS a
INNER JOIN dannys_diner.menu AS b
ON a.product_id = b.product_id
GROUP BY a.customer_id;


-- Question 2: How many days has each customer visited the restaurant?

SELECT customer_id, 
       COUNT(DISTINCT(order_date)) AS number_of_visits
FROM dannys_diner.sales
GROUP BY customer_id;


-- Question 3: What was the first item from the menu purchased by each customer?

SELECT sub.customer_id,
       m.product_name AS first_product_purchased
FROM (
        SELECT customer_id, order_date, product_id, 
        ROW_NUMBER () OVER 
        (PARTITION BY customer_id ORDER BY order_date) AS row
        FROM dannys_diner.sales
  	 ) sub
JOIN dannys_diner.menu m
ON m.product_id = sub.product_id
WHERE sub.row =1;
          
          
--  Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name AS most_purchased_item, 
	     COUNT(s.product_id) AS  number_of_purchases
FROM dannys_diner.sales s 
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchased DESC
LIMIT 1;
 

--  Question 5: Which item was the most popular for each customer?

SELECT DISTINCT sub2.customer_id, 
				        m.product_name AS most_popular_item
FROM (
        SELECT sub.customer_id, 
  			       sub.product_id, 
               sub.purchased_times,
        	     RANK() OVER (PARTITION BY sub.customer_id ORDER BY sub.purchased_times DESC) AS ranking
        FROM (
                SELECT customer_id,
                       product_id,
                       COUNT (product_id) OVER (PARTITION BY customer_id,product_id)
                AS purchased_times
                FROM dannys_diner.sales
             ) sub
	   ) sub2
JOIN dannys_diner.menu m
ON m.product_id = sub2.product_id
WHERE sub2.ranking = 1;


-- Question 6: Which item was purchased first by the customer after they became a member?

SELECT sub.customer_id,
	     m.product_name AS first_product_purchased_after_joining_as_member
FROM (
		    SELECT s.customer_id,
               s.product_id, 
               s.order_date,
               ROW_NUMBER () OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS row
        FROM dannys_diner.sales s
        JOIN dannys_diner.members m 
        ON s.customer_id = m.customer_id
        WHERE s.order_date >= m.join_date
	  ) sub 
JOIN dannys_diner.menu m
ON sub.product_id = m.product_id
WHERE sub.row = 1


-- Question 7: Which item was purchased just before the customer became a member?

SELECT sub.customer_id,
	     m.product_name AS item_purchased_just_before_joining_as_member
FROM(
      SELECT s.customer_id,
             s.product_id, 
             s.order_date,
             RANK () OVER (PARTITION BY s.customer_id ORDER BY 				   s.order_date DESC) AS row
       FROM dannys_diner.sales s
       JOIN dannys_diner.members m 
       ON s.customer_id = m.customer_id
       WHERE s.order_date < m.join_date
  	 ) sub
JOIN dannys_diner.menu m
ON sub.product_id = m.product_id
WHERE sub.row = 1;

-- Question 8: What is the total items and amount spent for each member before they became a member?

SELECT DISTINCT s.customer_id,
                COUNT(s.product_id) OVER (PARTITION BY s.customer_id) AS total_items_purchased,
                SUM(menu.price) OVER (PARTITION BY s.customer_id) AS amount_spent
FROM dannys_diner.sales s
JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
JOIN dannys_diner.menu menu
ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date 

-- Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, 
	     SUM(sub.points) AS total_points
FROM (
        SELECT product_id, 
               CASE WHEN product_id = 1 THEN price*20
               ELSE price*10 END AS points
        FROM dannys_diner.menu
  	 ) sub
JOIN dannys_diner.sales s
ON sub.product_id = s.product_id
GROUP BY s.customer_id

-- Question 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT sub.customer_id,
	     sum(sub.points) AS total_points
FROM (
        SELECT s.customer_id,
               s.order_date, 
               CASE WHEN s.order_date <= mem.join_date + 7 THEN 					   m.price*20
               WHEN s.product_id = 1 THEN m.price*20
               ELSE m.price*10 END AS points
        FROM dannys_diner.sales s
        JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
        JOIN dannys_diner.members mem
        ON s.customer_id = mem.customer_id
        WHERE s.order_date >= mem.join_date 
	  ) sub
GROUP BY sub.customer_id

-- Bonus questions

-- Question 1

SELECT s.customer_id, 
	     s.order_date,
       menu.product_name,
       menu.price,
       CASE WHEN s.order_date >= m.join_date THEN 'Y'
       ELSE 'N' END AS member
FROM dannys_diner.sales s
JOIN dannys_diner.menu menu
ON s.product_id = menu.product_id
LEFT JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
ORDER BY s.customer_id, s.order_date

-- Question 2

SELECT sub.*,
	     CASE WHEN sub.member = 'Y' THEN 
       RANK () OVER (PARTITION BY sub.customer_id, sub.member ORDER BY 		  sub.order_date) 
       ELSE NULL END AS ranking
FROM (
        SELECT s.customer_id, 
               s.order_date,
               menu.product_name,
               menu.price,
               CASE WHEN s.order_date >= m.join_date THEN 'Y'
               ELSE 'N' END AS member
        FROM dannys_diner.sales s
        JOIN dannys_diner.menu menu
        ON s.product_id = menu.product_id
        LEFT JOIN dannys_diner.members m
        ON s.customer_id = m.customer_id
        ORDER BY s.customer_id, s.order_date
  	 ) sub