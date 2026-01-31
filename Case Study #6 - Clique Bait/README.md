# Case Study #6 - Clique Bait

<img alt="Case Study 6" src="https://8weeksqlchallenge.com/images/case-study-designs/6.png" width="60%" height="60%" />

## 📚 Table of Contents

## Introduction 

Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Entity Relationship Diagram:

<img alt="Case Study 6" src="https://user-images.githubusercontent.com/98699089/154857965-425e41e6-3e77-4021-a5c5-81d522d0dee0.png" width="70%" />

Full details for this case study: https://8weeksqlchallenge.com/case-study-6/

## A. Enterprise Relationship Diagram

---
## B. Digital Analysis

#### Question 1: How many users are there?

#### Solution: 

```sql
SELECT COUNT(DISTINCT user_id) AS number_of_users
FROM clique_bait.users;
```

#### Answer:
| number_of_users |
| --------------- |
| 500             |

---
#### Question 2: How many cookies does each user have on average? 

#### Solution: 

```sql
WITH cookie_count_cte AS (

  SELECT user_id, COUNT(DISTINCT cookie_id) AS number_of_cookie
  FROM clique_bait.users
  GROUP BY user_id
  
 )
 
SELECT ROUND(AVG(number_of_cookie), 2) AS average_number_of_cookie
FROM cookie_count_cte;
```

#### Answer: 
| average_number_of_cookie |
| ------------------------ |
| 3.56                     |

---
#### Question 3: What is the unique number of visits by all users per month? 

#### Solution: 

```sql
SELECT EXTRACT(MONTH FROM event_time) AS month_number, 
	   COUNT(DISTINCT visit_id) AS unique_number_visits
FROM clique_bait.events
GROUP BY EXTRACT(MONTH FROM event_time)
ORDER BY EXTRACT(MONTH FROM event_time);
```

#### Answer:
| month_number | unique_number_visits |
| ------------ | -------------------- |
| 1            | 876                  |
| 2            | 1488                 |
| 3            | 916                  |
| 4            | 248                  |
| 5            | 36                   |

---
#### Question 4: What is the number of events for each event type? 

#### Solution: 

```sql
SELECT event_identifier.event_type,
	   event_identifier.event_name, 
	   COUNT(*) AS number_of_events
FROM clique_bait.events
LEFT JOIN clique_bait.event_identifier 
ON events.event_type = event_identifier.event_type
GROUP BY event_identifier.event_type, event_identifier.event_name
ORDER BY event_type;
```

#### Answer:
| event_type | event_name    | number_of_events |
| ---------- | ------------- | ---------------- |
| 1          | Page View     | 20928            |
| 2          | Add to Cart   | 8451             |
| 3          | Purchase      | 1777             |
| 4          | Ad Impression | 876              |
| 5          | Ad Click      | 702              |

---
#### Question 5: What is the percentage of visits which have a purchase event? 

#### Solution: 

```sql
WITH visit_with_purchase AS (

  SELECT visit_id, 
         MAX(
           CASE
              WHEN event_type = 3 THEN 1 
              ELSE 0 
           END 
         )AS visit_with_purchase
  FROM clique_bait.events
  GROUP BY visit_id

)

SELECT ROUND(100 * SUM(visit_with_purchase)::NUMERIC/COUNT(*), 2) AS purchase_percentage
FROM visit_with_purchase;
```

#### Answer:
| purchase_percentage |
| ------------------- |
| 49.86               |

---
#### Question 6: What is the percentage of visits which view the checkout page but do not have a purchase event? 

#### Solution: 

```sql
WITH cte AS (

  SELECT visit_id, 
         MAX(
           CASE
              WHEN event_type = 1 AND page_id = 12 THEN 1 
              ELSE 0 
           END 
          ) AS view_checkout, 
          MAX(
           CASE
              WHEN event_type = 3 THEN 1 
              ELSE 0 
           END 
          ) AS purchase
    FROM clique_bait.events
    GROUP BY visit_id
  
)

SELECT ROUND (
	   100 *
	   SUM(
         CASE WHEN purchase = 0 THEN 1 
         ELSE 0 END
       )::NUMERIC /
	   COUNT(visit_id), 
       2 
       ) AS percentage_of_checkout_but_no_purchase
FROM cte
WHERE view_checkout = 1;
```

#### Answer:
| percentage_of_checkout_but_no_purchase |
| -------------------------------------- |
| 15.50                                  |

---
#### Question 7: What are the top 3 pages by number of views? 

#### Solution: 

```sql
SELECT page_name, 
	   COUNT(*) AS number_of_views
FROM clique_bait.events a 
LEFT JOIN clique_bait.page_hierarchy b
ON a.page_id = b.page_id
GROUP BY page_name
ORDER BY COUNT(*) DESC
LIMIT 3;
```

#### Answer:
| page_name    | number_of_views |
| ------------ | --------------- |
| All Products | 4752            |
| Lobster      | 2515            |
| Crab         | 2513            |

---
#### Question 8: What is the number of views and cart adds for each product category? 

#### Solution: 

```sql
SELECT product_category, 
	   SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS no_views,
       SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS no_add_cart
FROM clique_bait.events a 
LEFT JOIN clique_bait.page_hierarchy b
ON a.page_id = b.page_id
WHERE b.product_category IS NOT NULL
GROUP BY b.product_category;
```

#### Answer:
| product_category | no_views | no_add_cart |
| ---------------- | -------- | ----------- |
| Luxury           | 3032     | 1870        |
| Shellfish        | 6204     | 3792        |
| Fish             | 4633     | 2789        |

---
#### Question 9: What are the top 3 products by purchases? 

#### Solution: 

```sql
SELECT page_name AS product, 
       COUNT(*) number_of_purchases
FROM clique_bait.events a 
LEFT JOIN clique_bait.page_hierarchy b 
ON a.page_id = b.page_id
WHERE event_type = 2
AND visit_id IN (
  SELECT DISTINCT visit_id
  FROM clique_bait.events
  WHERE event_type = 3 )
GROUP BY page_name
ORDER BY COUNT(*) DESC
LIMIT 3;
```

#### Answer:
| product | number_of_purchases |
| ------- | ------------------- |
| Lobster | 754                 |
| Oyster  | 726                 |
| Crab    | 719                 |

## C. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

#### Solution:

```sql
DROP TABLE IF EXISTS product_analysis_summary;
CREATE TEMP TABLE product_analysis_summary AS 
WITH visit_id_purchase_flag AS (

  SELECT visit_id, 
         MAX(
           CASE
              WHEN event_type = 3 THEN 1 
              ELSE 0 
           END 
         ) AS purchase_flag
    FROM clique_bait.events
    GROUP BY visit_id
  
), 

cte AS (

  SELECT c.page_name AS product, 
  c.product_category, 
  CASE WHEN event_type = 1 THEN 1 ELSE 0 END AS view,
  CASE WHEN event_type = 2 THEN 1 ELSE 0 END AS add_to_cart, 
  CASE WHEN event_type = 2 AND purchase_flag = 0 THEN 1 ELSE 0 END AS add_to_cart_wo_purchase, 
  CASE WHEN event_type = 2 AND purchase_flag = 1 THEN 1 ELSE 0 END AS purchase
  FROM clique_bait.events a 
  LEFT JOIN visit_id_purchase_flag b 
  ON a.visit_id = b.visit_id
  LEFT JOIN clique_bait.page_hierarchy c
  ON a.page_id = c.page_id
  WHERE c.product_category IS NOT NULL
  
)

SELECT product, product_category, 
	   SUM(view) AS number_of_views, 
       SUM(add_to_cart) AS number_of_add_to_cart, 
       SUM(add_to_cart_wo_purchase) AS number_of_add_to_cart_wo_purchase, 
       SUM(purchase) AS number_of_purchase
FROM cte 
GROUP BY product, product_category;

SELECT *
FROM product_analysis_summary;
```

#### Answer:

| product        | product_category | number_of_views | number_of_add_to_cart | number_of_add_to_cart_wo_purchase | number_of_purchase |
| -------------- | ---------------- | --------------- | --------------------- | --------------------------------- | ------------------ |
| Kingfish       | Fish             | 1559            | 920                   | 213                               | 707                |
| Crab           | Shellfish        | 1564            | 949                   | 230                               | 719                |
| Oyster         | Shellfish        | 1568            | 943                   | 217                               | 726                |
| Lobster        | Shellfish        | 1547            | 968                   | 214                               | 754                |
| Russian Caviar | Luxury           | 1563            | 946                   | 249                               | 697                |
| Tuna           | Fish             | 1515            | 931                   | 234                               | 697                |
| Abalone        | Shellfish        | 1525            | 932                   | 233                               | 699                |
| Salmon         | Fish             | 1559            | 938                   | 227                               | 711                |
| Black Truffle  | Luxury           | 1469            | 924                   | 217                               | 707                |

---
Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Use your 2 new output tables - answer the following questions:

1. Which product had the most views, cart adds and purchases?
2. Which product was most likely to be abandoned?
3. Which product had the highest view to purchase percentage?
4. What is the average conversion rate from view to cart add?
5. What is the average conversion rate from cart add to purchase?

#### Solution:

```sql
DROP TABLE IF EXISTS product_category_analysis_summary;
CREATE TEMP TABLE product_category_analysis_summary AS 

SELECT product_category, 
	   SUM(number_of_views) AS number_of_views, 
       SUM(number_of_add_to_cart) AS number_of_add_to_cart, 
       SUM(number_of_add_to_cart_wo_purchase) AS number_of_add_to_cart_wo_purchase, 
       SUM(number_of_purchase) AS number_of_purchase
FROM product_analysis_summary
GROUP BY product_category; 


SELECT *
FROM product_category_analysis_summary;
```
#### Answer: 

| product_category | number_of_views | number_of_add_to_cart | number_of_add_to_cart_wo_purchase | number_of_purchase |
| ---------------- | --------------- | --------------------- | --------------------------------- | ------------------ |
| Luxury           | 3032            | 1870                  | 466                               | 1404               |
| Shellfish        | 6204            | 3792                  | 894                               | 2898               |
| Fish             | 4633            | 2789                  | 674                               | 2115               |
