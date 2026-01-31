# Case Study #7 - Balanced Tree Clothing Co.

<img alt="Case Study 7" src="https://8weeksqlchallenge.com/images/case-study-designs/7.png" width="60%" height="60%" />

## 📚 Table of Contents
- [Introduction](#introduction)
- [A. High Level Sales Analysis](#a-high-level-sales-analysis)
- [B. Transaction Analysis](#b-transaction-analysis)
- [C. Product Analysis](#c-product-analysis)

## Introduction 

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

Full details for this case study: https://8weeksqlchallenge.com/case-study-7/

## A. High Level Sales Analysis

#### Question 1: What was the total quantity sold for all products?

#### Solution: 

```sql
SELECT product_name, 
	   SUM(qty) AS total_quantity_sold
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id
GROUP BY product_name;
```

#### Answer:
| product_name                     | total_quantity_sold |
| -------------------------------- | ------------------- |
| White Tee Shirt - Mens           | 3800                |
| Navy Solid Socks - Mens          | 3792                |
| Grey Fashion Jacket - Womens     | 3876                |
| Navy Oversized Jeans - Womens    | 3856                |
| Pink Fluro Polkadot Socks - Mens | 3770                |
| Khaki Suit Jacket - Womens       | 3752                |
| Black Straight Jeans - Womens    | 3786                |
| White Striped Socks - Mens       | 3655                |
| Blue Polo Shirt - Mens           | 3819                |
| Indigo Rain Jacket - Womens      | 3757                |
| Cream Relaxed Jeans - Womens     | 3707                |
| Teal Button Up Shirt - Mens      | 3646                |

---
#### Question 2: What is the total generated revenue for all products before discounts?

#### Solution: 

```sql
SELECT product_name, 
	   SUM(a.price * qty) AS total_revenue
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id
GROUP BY product_name;
```

#### Answer:
| product_name                     | total_revenue |
| -------------------------------- | ------------- |
| White Tee Shirt - Mens           | 152000        |
| Navy Solid Socks - Mens          | 136512        |
| Grey Fashion Jacket - Womens     | 209304        |
| Navy Oversized Jeans - Womens    | 50128         |
| Pink Fluro Polkadot Socks - Mens | 109330        |
| Khaki Suit Jacket - Womens       | 86296         |
| Black Straight Jeans - Womens    | 121152        |
| White Striped Socks - Mens       | 62135         |
| Blue Polo Shirt - Mens           | 217683        |
| Indigo Rain Jacket - Womens      | 71383         |
| Cream Relaxed Jeans - Womens     | 37070         |
| Teal Button Up Shirt - Mens      | 36460         |

---
#### Question 3: What was the total discount amount for all products?

#### Solution: 

```sql
SELECT product_name, 
	   SUM(a.price * qty * discount/100) AS total_discount
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id
GROUP BY product_name;
```

#### Answer:
| product_name                     | total_discount |
| -------------------------------- | -------------- |
| White Tee Shirt - Mens           | 17968          |
| Navy Solid Socks - Mens          | 16059          |
| Grey Fashion Jacket - Womens     | 24781          |
| Navy Oversized Jeans - Womens    | 5538           |
| Pink Fluro Polkadot Socks - Mens | 12344          |
| Khaki Suit Jacket - Womens       | 9660           |
| Black Straight Jeans - Womens    | 14156          |
| White Striped Socks - Mens       | 6877           |
| Blue Polo Shirt - Mens           | 26189          |
| Indigo Rain Jacket - Womens      | 8010           |
| Cream Relaxed Jeans - Womens     | 3979           |
| Teal Button Up Shirt - Mens      | 3925           |

---
## B. Transaction Analysis

#### Question 1: How many unique transactions were there?

#### Solution: 

```sql
SELECT COUNT( DISTINCT txn_id ) AS unique_transactions
FROM balanced_tree.sales;
```

#### Answer:
| unique_transactions |
| ------------------- |
| 2500                |

---
#### Question 2: What is the average unique products purchased in each transaction?

#### Solution: 

```sql
WITH txn_no_purchase_cte AS (
  
SELECT txn_id, 
  	   COUNT( DISTINCT prod_id ) AS no_unique_product
FROM balanced_tree.sales
GROUP BY txn_id
  
)

SELECT ROUND(AVG(no_unique_product)) AS avg_unique_product
FROM txn_no_purchase_cte;
```

#### Answer:
| avg_unique_product |
| ------------------ |
| 6                  |

---
#### Question 3: What are the 25th, 50th and 75th percentile values for the revenue per transaction?

---
#### Question 4: What is the average discount value per transaction?

#### Solution: 

```sql
WITH txn_discount_cte AS (

SELECT txn_id, 
	   SUM(price * qty * discount/100) AS total_discount_value
FROM balanced_tree.sales
GROUP BY txn_id
  
)

SELECT ROUND(AVG(total_discount_value), 2) AS avg_discount
FROM txn_discount_cte;
```

#### Answer:
| avg_discount |
| ------------ |
| 59.79        |

---
#### Question 5: What is the percentage split of all transactions for members vs non-members?

#### Solution: 

```sql
WITH txn_count_cte AS (

SELECT SUM(CASE WHEN member = 't' THEN 1 ELSE 0 END) AS member_transactions, 
	   SUM(CASE WHEN member = 'f' THEN 1 ELSE 0 END) AS non_member_transactions, 
       COUNT(txn_id) AS total_transactions
FROM balanced_tree.sales

)

SELECT ROUND(100 * member_transactions::NUMERIC/total_transactions, 2) AS member_txn_percentage, 
	   ROUND(100 * non_member_transactions::NUMERIC/total_transactions, 2) AS non_member_txn_percentage
FROM txn_count_cte;
```

#### Answer:
| member_txn_percentage | non_member_txn_percentage |
| --------------------- | ------------------------- |
| 60.03                 | 39.97                     |

---
#### Question 6: What is the average revenue for member transactions and non-member transactions?

#### Solution: 

```sql
WITH revenue_cte AS (
  
  SELECT member,
  	     txn_id,
    	 SUM(price * qty) AS revenue
  FROM balanced_tree.sales
  GROUP BY member, txn_id
  
)

SELECT member,
       ROUND(AVG(revenue),2) AS avg_revenue
FROM revenue_cte
GROUP BY member;
```

#### Answer:
| member | avg_revenue |
| ------ | ----------- |
| false  | 515.04      |
| true   | 516.27      |

---
## C. Product Analysis

#### Question 1: What are the top 3 products by total revenue before discount?

#### Solution: 

```sql
SELECT b.product_id,
	   b.product_name, 
	   SUM(a.price * a.qty) AS total_revenue
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id
GROUP BY b.product_id, b.product_name
ORDER BY total_revenue DESC
LIMIT 3;
```

#### Answer:
| product_id | product_name                 | total_revenue |
| ---------- | ---------------------------- | ------------- |
| 2a2353     | Blue Polo Shirt - Mens       | 217683        |
| 9ec847     | Grey Fashion Jacket - Womens | 209304        |
| 5d267b     | White Tee Shirt - Mens       | 152000        |

---
#### Question 2: What is the total quantity, revenue and discount for each segment?

#### Solution: 

```sql
SELECT c.level_text AS segment, 
	   SUM(a.qty) AS total_quantity,
	   SUM(a.price * a.qty) AS total_revenue, 
       SUM(a.price * a.qty * a.discount/100) AS total_discount
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id
LEFT JOIN balanced_tree.product_hierarchy c 
ON b.segment_id = c.id
GROUP BY c.level_text;
```

#### Answer:
| segment | total_quantity | total_revenue | total_discount |
| ------- | -------------- | ------------- | -------------- |
| Shirt   | 11265          | 406143        | 48082          |
| Jeans   | 11349          | 208350        | 23673          |
| Jacket  | 11385          | 366983        | 42451          |
| Socks   | 11217          | 307977        | 35280          |

---
#### Question 3: What is the top selling product for each segment?

#### Solution: 

```sql
WITH segment_ranking_cte AS (

  SELECT c.level_text AS segment, 
         b.product_id, 
         b.product_name,
         SUM(a.qty) AS total_quantity, 
         RANK() OVER (PARTITION BY c.level_text ORDER BY SUM(a.qty) DESC) AS ranking
  FROM balanced_tree.sales a 
  LEFT JOIN balanced_tree.product_details b 
  ON a.prod_id = b.product_id
  LEFT JOIN balanced_tree.product_hierarchy c 
  ON b.segment_id = c.id
  GROUP BY c.level_text, b.product_id, b.product_name
  
)

SELECT segment, 
	   product_name AS top_selling_product
FROM segment_ranking_cte 
WHERE ranking = 1;
```

#### Answer:
| segment | top_selling_product           |
| ------- | ----------------------------- |
| Jacket  | Grey Fashion Jacket - Womens  |
| Jeans   | Navy Oversized Jeans - Womens |
| Shirt   | Blue Polo Shirt - Mens        |
| Socks   | Navy Solid Socks - Mens       |

---
#### Question 4: What is the total quantity, revenue and discount for each category?

#### Solution: 

```sql
SELECT c.level_text AS category, 
	   SUM(a.qty) AS total_quantity,
	   SUM(a.price * a.qty) AS total_revenue, 
       SUM(a.price * a.qty * a.discount/100) AS total_discount
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id
LEFT JOIN balanced_tree.product_hierarchy c 
ON b.category_id = c.id
GROUP BY c.level_text;
```

#### Answer:
| category | total_quantity | total_revenue | total_discount |
| -------- | -------------- | ------------- | -------------- |
| Mens     | 22482          | 714120        | 83362          |
| Womens   | 22734          | 575333        | 66124          |

---
#### Question 5: What is the top selling product for each category?

#### Solution: 

```sql
WITH category_ranking_cte AS (

  SELECT c.level_text AS category, 
         b.product_id, 
         b.product_name,
         SUM(a.qty) AS total_quantity, 
         RANK() OVER (PARTITION BY c.level_text ORDER BY SUM(a.qty) DESC) AS ranking
  FROM balanced_tree.sales a 
  LEFT JOIN balanced_tree.product_details b 
  ON a.prod_id = b.product_id
  LEFT JOIN balanced_tree.product_hierarchy c 
  ON b.category_id = c.id
  GROUP BY c.level_text, b.product_id, b.product_name
  
)

SELECT category, 
	   product_name AS top_selling_product
FROM category_ranking_cte
WHERE ranking = 1;
```

#### Answer:
| category | top_selling_product          |
| -------- | ---------------------------- |
| Mens     | Blue Polo Shirt - Mens       |
| Womens   | Grey Fashion Jacket - Womens |

---
#### Question 6: What is the percentage split of revenue by product for each segment?

#### Solution: 

```sql
WITH segment_prod_revenue_cte AS (

SELECT segment_name, product_name, 
       SUM(a.price * a.qty) AS revenue
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id 
GROUP BY segment_name, product_name

)

SELECT segment_name, product_name, 
	   revenue, 
       ROUND( 100 * revenue::NUMERIC/SUM(revenue) OVER (PARTITION BY segment_name), 2) AS revenue_percentage
FROM segment_prod_revenue_cte
ORDER BY segment_name, revenue_percentage;
```

#### Answer:
| segment_name | product_name                     | revenue | revenue_percentage |
| ------------ | -------------------------------- | ------- | ------------------ |
| Jacket       | Indigo Rain Jacket - Womens      | 71383   | 19.45              |
| Jacket       | Khaki Suit Jacket - Womens       | 86296   | 23.51              |
| Jacket       | Grey Fashion Jacket - Womens     | 209304  | 57.03              |
| Jeans        | Cream Relaxed Jeans - Womens     | 37070   | 17.79              |
| Jeans        | Navy Oversized Jeans - Womens    | 50128   | 24.06              |
| Jeans        | Black Straight Jeans - Womens    | 121152  | 58.15              |
| Shirt        | Teal Button Up Shirt - Mens      | 36460   | 8.98               |
| Shirt        | White Tee Shirt - Mens           | 152000  | 37.43              |
| Shirt        | Blue Polo Shirt - Mens           | 217683  | 53.60              |
| Socks        | White Striped Socks - Mens       | 62135   | 20.18              |
| Socks        | Pink Fluro Polkadot Socks - Mens | 109330  | 35.50              |
| Socks        | Navy Solid Socks - Mens          | 136512  | 44.33              |

---
#### Question 7: What is the percentage split of revenue by segment for each category?

#### Solution: 

```sql
WITH categoty_segment_revenue_cte AS (

SELECT category_name, segment_name, 
       SUM(a.price * a.qty) AS revenue
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id 
GROUP BY category_name, segment_name

)

SELECT category_name, segment_name,  
	   revenue, 
       ROUND( 100 * revenue::NUMERIC/SUM(revenue) OVER (PARTITION BY category_name), 2) AS revenue_percentage
FROM categoty_segment_revenue_cte
ORDER BY category_name, segment_name;
```

#### Answer:
| category_name | segment_name | revenue | revenue_percentage |
| ------------- | ------------ | ------- | ------------------ |
| Mens          | Shirt        | 406143  | 56.87              |
| Mens          | Socks        | 307977  | 43.13              |
| Womens        | Jacket       | 366983  | 63.79              |
| Womens        | Jeans        | 208350  | 36.21              |

---
#### Question 8: What is the percentage split of total revenue by category?

#### Solution: 

```sql
WITH categoty_revenue_cte AS (

SELECT category_name, 
       SUM(a.price * a.qty) AS revenue
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id 
GROUP BY category_name

)

SELECT category_name,  
	   revenue, 
       ROUND( 100 * revenue::NUMERIC/SUM(revenue) OVER (), 2) AS revenue_percentage
FROM categoty_revenue_cte
ORDER BY category_name;
```

#### Answer:
| category_name | revenue | revenue_percentage |
| ------------- | ------- | ------------------ |
| Mens          | 714120  | 55.38              |
| Womens        | 575333  | 44.62              |

---
#### Question 9: What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

#### Solution: 

```sql
WITH prod_transactions_cte AS (

SELECT a.prod_id, b.product_name,
       COUNT(DISTINCT a.txn_id) AS number_of_txn
FROM balanced_tree.sales a 
LEFT JOIN balanced_tree.product_details b 
ON a.prod_id = b.product_id 
GROUP BY a.prod_id, b.product_name
  
),

total_transactions_cte AS (
  
SELECT COUNT(DISTINCT txn_id) AS total_txn
FROM balanced_tree.sales

) 

SELECT prod_id, product_name, 
	   ROUND( 100 * number_of_txn::NUMERIC/total_txn, 2) AS penetration
FROM prod_transactions_cte
CROSS JOIN total_transactions_cte
ORDER BY penetration DESC;
```

#### Answer:
| prod_id | product_name                     | penetration |
| ------- | -------------------------------- | ----------- |
| f084eb  | Navy Solid Socks - Mens          | 51.24       |
| 9ec847  | Grey Fashion Jacket - Womens     | 51.00       |
| c4a632  | Navy Oversized Jeans - Womens    | 50.96       |
| 2a2353  | Blue Polo Shirt - Mens           | 50.72       |
| 5d267b  | White Tee Shirt - Mens           | 50.72       |
| 2feb6b  | Pink Fluro Polkadot Socks - Mens | 50.32       |
| 72f5d4  | Indigo Rain Jacket - Womens      | 50.00       |
| d5e9a6  | Khaki Suit Jacket - Womens       | 49.88       |
| e83aa3  | Black Straight Jeans - Womens    | 49.84       |
| e31d39  | Cream Relaxed Jeans - Womens     | 49.72       |
| b9a74d  | White Striped Socks - Mens       | 49.72       |
| c8d436  | Teal Button Up Shirt - Mens      | 49.68       |

---
#### Question 10: What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

---
