## Case Study #1 - Danny's Dinner 

### Questions and Solutions

#### Question 1: What is the total amount each customer spent at the restaurant?

#### Solution: 

```sql
SELECT customer_id, 
	   SUM(price) as total_amount_spent
FROM dannys_diner.sales a
JOIN dannys_diner.menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id
ORDER BY a.customer_id
```

#### Answer:
| customer_id | total_amount_spent |
|-------------|--------------------|
| A           | 76                 |
| B           | 74                 |
| C           | 36                 |

---
#### Question 2: How many days has each customer visited the restaurant?

#### Solution: 

```sql
SELECT customer_id, 
       COUNT(DISTINCT order_date) AS number_of_days
FROM dannys_diner.sales
GROUP BY customer_id
```
#### Answer:
| customer_id | number_of_days |
|-------------|----------------|
| A           | 4              |
| B           | 6              |
| C           | 2              |


---
#### Question 3: What was the first item from the menu purchased by each customer?

#### Solution: 

```sql
WITH EarliestOrderDates AS (

  SELECT customer_id, 
         MIN(order_date) AS min_order_date
  FROM dannys_diner.sales 
  GROUP BY customer_id

)

SELECT a.customer_id, 
       b.min_order_date, 
       product_name
FROM dannys_diner.sales a
INNER JOIN EarliestOrderDates b
ON a.customer_id = b.customer_id
INNER JOIN dannys_diner.menu c
ON a.product_id = c.product_id
WHERE a.order_date = b.min_order_date
ORDER BY customer_id
```
#### Answer:
| customer_id | min_order_date | product_name |
|-------------|----------------|--------------|
| A           | 2021-01-01     | sushi        |
| A           | 2021-01-01     | curry        |
| B           | 2021-01-01     | curry        |
| C           | 2021-01-01     | ramen        |
| C           | 2021-01-01     | ramen        |

---
#### Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?

#### Solution: 

```sql
SELECT menu.product_id, 
       menu.product_name,
       COUNT(*) AS number_of_purchased
FROM dannys_diner.sales 
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY menu.product_id, menu.product_name
ORDER BY number_of_purchased DESC
```
#### Answer:
| product_id | product_name | number_of_purchases |
|------------|--------------|---------------------|
| 3          | ramen        | 8                   |
| 2          | curry        | 4                   |
| 1          | sushi        | 3                   |

---
#### Question 5: Which item was the most popular for each customer?

#### Solution: 

```sql
WITH CustomerProductPurchaseRank_CTE AS (

  SELECT a.customer_id,
         b.product_id,
         b.product_name,
         COUNT(*) AS number_of_purchases,
         RANK() OVER (PARTITION BY a.customer_id ORDER BY COUNT(*) DESC) AS item_rank
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.menu b
  ON a.product_id = b.product_id
  GROUP BY a.customer_id, b.product_id, b.product_name

)

SELECT customer_id, product_name, number_of_purchases
FROM CustomerProductPurchaseRank_CTE
WHERE item_rank = 1
```
#### Answer:
| customer_id | product_name | number_of_purchases |
|-------------|--------------|---------------------|
| A           | ramen        | 3                   |
| B           | sushi        | 2                   |
| B           | ramen        | 2                   |
| B           | curry        | 2                   |
| C           | ramen        | 3                   |

---
#### Question 6: Which item was purchased first by the customer after they became a member?

#### Solution: 

```sql
WITH CTE AS (

  SELECT a.customer_id, 
         a.order_date, 
         b.join_date, 
         c.product_name, 
         RANK() OVER( PARTITION BY a.customer_id ORDER BY order_date) AS date_rank
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.members b
  ON a.customer_id = b.customer_id
  INNER JOIN dannys_diner.menu c
  ON a.product_id = c.product_id
  WHERE a.order_date >= b.join_date

)

SELECT customer_id, 
       order_date, 
       join_date, 
       product_name
  FROM CTE 
 WHERE date_rank = 1
```
#### Answer:
| customer_id | order_date | join_date  | product_name |
|-------------|------------|------------|--------------|
| A           | 2021-01-07 | 2021-01-07 | curry        |
| B           | 2021-01-11 | 2021-01-09 | sushi        |

---
#### Question 7: Which item was purchased just before the customer became a member?

#### Solution: 

```sql
WITH CTE AS (

  SELECT a.customer_id, 
         a.order_date, 
         b.join_date, 
         c.product_name,
         RANK() OVER( PARTITION BY a.customer_id ORDER BY order_date DESC ) AS date_rank
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.members b
  ON a.customer_id = b.customer_id
  INNER JOIN dannys_diner.menu c
  ON a.product_id = c.product_id
  WHERE a.order_date < b.join_date

)

SELECT customer_id, 
       order_date, 
       join_date, 
       product_name
  FROM CTE 
 WHERE date_rank = 1
```
#### Answer:
| customer_id | order_date | join_date  | product_name |
|-------------|------------|------------|--------------|
| A           | 2021-01-01 | 2021-01-07 | sushi        |
| A           | 2021-01-01 | 2021-01-07 | curry        |
| B           | 2021-01-04 | 2021-01-09 | sushi        |

---
#### Question 8: What is the total items and amount spent for each member before they became a member?

#### Solution: 

```sql
WITH PreJoinPurchases AS (

  SELECT a.customer_id, 
         a.order_date, 
         b.join_date, 
         c.product_name,
         c.price
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.members b
  ON a.customer_id = b.customer_id
  INNER JOIN dannys_diner.menu c
  ON a.product_id = c.product_id
  WHERE a.order_date < b.join_date

)

SELECT customer_id, 
       COUNT(*) AS total_items_purchased,
       SUM(price) AS total_amount_spent
FROM PreJoinPurchases
GROUP BY customer_id
ORDER BY customer_id
```
#### Answer:
| customer_id | total_items_purchased | total_amount_spent |
|-------------|-----------------------|--------------------|
| A           | 2                     | 25                 |
| B           | 3                     | 40                 |

---
#### Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

#### Solution: 

```sql
WITH PointsCalculation AS (

  SELECT a.customer_id,
         b.product_name,
         b.price,
         (CASE 
            WHEN b.product_name = 'sushi' THEN 20
            ELSE 10
          END) AS points_per_$1,
         (CASE 
            WHEN b.product_name = 'sushi' THEN b.price * 20
            ELSE b.price * 10
          END) AS points_gained
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.menu b
  ON a.product_id = b.product_id

)

SELECT customer_id,
       SUM(points_gained) AS total_points_gained
FROM PointsCalculation 
GROUP BY customer_id
ORDER BY customer_id
```
#### Answer:
| customer_id | total_points_gained |
|-------------|---------------------|
| A           | 860                 |
| B           | 940                 |
| C           | 360                 |

---
#### Question 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

#### Solution: 

```sql
WITH PointsCalculationWithMembership AS (

  SELECT a.customer_id,
         b.product_name,
         b.price,
         a.order_date,
         c.join_date AS join_date,
         (CASE 
            WHEN (order_date >= join_date AND order_date < join_date + 7) THEN 20
            WHEN (b.product_name = 'sushi') THEN 20
            ELSE 10
          END) AS points_per_$1,
          (CASE 
            WHEN (order_date >= join_date AND order_date < join_date + 7) THEN b.price * 20
            WHEN (b.product_name = 'sushi') THEN b.price * 20
            ELSE b.price * 10
          END) AS points_gained
  FROM dannys_diner.sales a
  INNER JOIN dannys_diner.menu b
  ON a.product_id = b.product_id 
  INNER JOIN dannys_diner.members c
  ON a.customer_id = c.customer_id
  WHERE a.order_date < '2021-02-01'

)

SELECT customer_id,
       SUM(points_gained) AS total_points_gained
FROM PointsCalculationWithMembership
GROUP BY customer_id
ORDER BY customer_id
```
#### Answer:
| customer_id | total_points_gained |
|-------------|---------------------|
| A           | 1370                |
| B           | 820                 |

---
#### Bonus Question 11: Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL Recreate the following table output using the available data.

#### Solution: 

```sql
SELECT a.customer_id,
       a.order_date,
       c.product_name,
       c.price,
       (CASE
          WHEN a.order_date >= b.join_date THEN 'Y'
          ELSE 'N'
        END) AS member
FROM dannys_diner.sales a
LEFT JOIN dannys_diner.members b
ON a.customer_id = b.customer_id
LEFT JOIN dannys_diner.menu c
ON a.product_id = c.product_id
ORDER BY a.customer_id, a.order_date
```
#### Answer:
| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

---
#### Bonus Question 12: Danny also requires further information about the  `ranking`  of customer products, but he purposely does not need the ranking for non-member purchases so he expects null  `ranking`  values for the records when customers are not yet part of the loyalty program.

#### Solution: 

```sql
WITH SalesWithMembership AS (

  SELECT a.customer_id,
         a.order_date,
         c.product_name,
         c.price,
         (CASE
            WHEN a.order_date >= b.join_date THEN 'Y'
            ELSE 'N'
          END) AS member
  FROM dannys_diner.sales a
  LEFT JOIN dannys_diner.members b
  ON a.customer_id = b.customer_id
  LEFT JOIN dannys_diner.menu c
  ON a.product_id = c.product_id
  ORDER BY a.customer_id, a.order_date

)

SELECT *,
       (CASE 
          WHEN member = 'N' THEN NULL
          ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)  
        END ) AS ranking
FROM SalesWithMembership
```
#### Answer:
| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | sushi        | 10    | N      |         |
| A           | 2021-01-01 | curry        | 15    | N      |         |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      |         |
| B           | 2021-01-02 | curry        | 15    | N      |         |
| B           | 2021-01-04 | sushi        | 10    | N      |         |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      |         |
| C           | 2021-01-01 | ramen        | 12    | N      |         |
| C           | 2021-01-07 | ramen        | 12    | N      |         |
