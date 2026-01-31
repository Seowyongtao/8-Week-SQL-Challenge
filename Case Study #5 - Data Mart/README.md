# Case Study #5 - Data Mart

<img alt="Case Study 5" src="https://8weeksqlchallenge.com/images/case-study-designs/5.png" width="60%" height="60%" />

## 📚 Table of Contents
- [Introduction](#introduction)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [A. Data Cleansing Steps](#a-data-cleansing-steps)
- [B. Data Exploration](#b-data-exploration)
- [C. Before and After Analysis](#c-before-and-after-analysis)

## Introduction 

Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question he wants you to help him answer are the following:

- What was the quantifiable impact of the changes introduced in June 2020?
- Which platform, region, segment and customer types were the most impacted by this change?
- What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?

## Entity Relationship Diagram:

<img alt="Case Study 5" src="https://8weeksqlchallenge.com/images/case-study-5-erd.png" width="30%" />

Full details for this case study: https://8weeksqlchallenge.com/case-study-5/

## A. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`:

- Convert the `week_date` to a `DATE` format
- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a `month_number` with the calendar month for each `week_date` value as the 3rd column
- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called `age_band` after the original `segment` column using the following mapping on the number inside the `segment` value

| segment | age_band     |
|---------|--------------|
| 1       | Young Adults |
| 2       | Middle Aged  |
| 3 or 4  | Retirees     |

- Add a new `demographic` column using the following mapping for the first letter in the `segment` values:

| segment | demographic |
|---------|-------------|
| C       | Couples     |
| F       | Families    |

- Ensure all `null` string values with an `"unknown"` string value in the original `segment` column as well as the new `age_band` and `demographic` columns
- Generate a new `avg_transaction` column as the `sales` value divided by `transactions` rounded to 2 decimal places for each record

#### Solution: 

```sql
CREATE TEMP TABLE clean_weekly_sales AS (
SELECT
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
  region, 
  platform, 
  CASE
  	WHEN segment = 'null' THEN 'unknown'
    ELSE segment
  END AS segment,
  CASE 
    WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
    ELSE 'unknown' 
  END AS age_band,
  CASE 
    WHEN LEFT(segment,1) = 'C' THEN 'Couples'
    WHEN LEFT(segment,1) = 'F' THEN 'Families'
    ELSE 'unknown' 
  END AS demographic,
  customer_type,
  transactions,
  ROUND((sales::NUMERIC/transactions),2) AS avg_transaction,
  sales
FROM data_mart.weekly_sales
);


SELECT *
FROM clean_weekly_sales;
```

---
## B. Data Exploration

#### Question 1: What day of the week is used for each week_date value?

#### Solution: 

```sql
SELECT DISTINCT 
	   TO_CHAR(week_date, 'Day') AS day
FROM clean_weekly_sales;
```

#### Answer:
| day       |
| --------- |
| Monday    |

---
#### Question 2: What range of week numbers are missing from the dataset?

#### Solution: 

```sql
WITH week_number AS (
  SELECT GENERATE_SERIES(1,52) AS week_number
)

SELECT a.week_number AS missing_week_number
FROM week_number a 
LEFT JOIN clean_weekly_sales b 
ON a.week_number = b.week_number
WHERE b.week_number IS NULL
ORDER BY a.week_number;
```

#### Answer:
| missing_week_number |
| ------------------- |
| 1                   |
| 2                   |
| 3                   |
| 4                   |
| 5                   |
| 6                   |
| 7                   |
| 8                   |
| 9                   |
| 10                  |
| 11                  |
| 12                  |
| 37                  |
| 38                  |
| 39                  |
| 40                  |
| 41                  |
| 42                  |
| 43                  |
| 44                  |
| 45                  |
| 46                  |
| 47                  |
| 48                  |
| 49                  |
| 50                  |
| 51                  |
| 52                  |

---
#### Question 3: How many total transactions were there for each year in the dataset? 

#### Solution: 

```sql
SELECT calendar_year, 
       SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
```

#### Answer:
| calendar_year | total_transactions |
| ------------- | ------------------ |
| 2018          | 346406460          |
| 2019          | 365639285          |
| 2020          | 375813651          |

---
#### Question 4: What is the total sales for each region for each month?

#### Solution: 

```sql
SELECT region, calendar_year, month_number, 
	   SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, calendar_year, month_number
ORDER BY region, calendar_year, month_number;
```

#### Answer:
| region        | calendar_year | month_number | total_sales |
| ------------- | ------------- | ------------ | ----------- |
| AFRICA        | 2018          | 3            | 130542213   |
| AFRICA        | 2018          | 4            | 650194751   |
| AFRICA        | 2018          | 5            | 522814997   |
| AFRICA        | 2018          | 6            | 519127094   |
| AFRICA        | 2018          | 7            | 674135866   |
| AFRICA        | 2018          | 8            | 539077371   |
| AFRICA        | 2018          | 9            | 135084533   |
| AFRICA        | 2019          | 3            | 141619349   |
| AFRICA        | 2019          | 4            | 700447301   |
| AFRICA        | 2019          | 5            | 553828220   |
| AFRICA        | 2019          | 6            | 546092640   |
| AFRICA        | 2019          | 7            | 711867600   |
| AFRICA        | 2019          | 8            | 564497281   |
| AFRICA        | 2019          | 9            | 141236454   |
| AFRICA        | 2020          | 3            | 295605918   |
| AFRICA        | 2020          | 4            | 561141452   |
| AFRICA        | 2020          | 5            | 570601521   |
| AFRICA        | 2020          | 6            | 702340026   |
| AFRICA        | 2020          | 7            | 574216244   |
| AFRICA        | 2020          | 8            | 706022238   |
| ASIA          | 2018          | 3            | 119180883   |
| ASIA          | 2018          | 4            | 603716301   |
| ASIA          | 2018          | 5            | 472634283   |
| ASIA          | 2018          | 6            | 462233474   |
| ASIA          | 2018          | 7            | 602910228   |
| ASIA          | 2018          | 8            | 486137188   |
| ASIA          | 2018          | 9            | 122529255   |
| ASIA          | 2019          | 3            | 129174041   |
| ASIA          | 2019          | 4            | 654973051   |
| ASIA          | 2019          | 5            | 511773780   |
| ASIA          | 2019          | 6            | 498386324   |
| ASIA          | 2019          | 7            | 635366443   |
| ASIA          | 2019          | 8            | 514795070   |
| ASIA          | 2019          | 9            | 130307552   |
| ASIA          | 2020          | 3            | 281415869   |
| ASIA          | 2020          | 4            | 545939355   |
| ASIA          | 2020          | 5            | 541877336   |
| ASIA          | 2020          | 6            | 658863091   |
| ASIA          | 2020          | 7            | 530568085   |
| ASIA          | 2020          | 8            | 662388351   |
| CANADA        | 2018          | 3            | 33815571    |
| CANADA        | 2018          | 4            | 163479820   |
| CANADA        | 2018          | 5            | 130367940   |
| CANADA        | 2018          | 6            | 130410790   |
| CANADA        | 2018          | 7            | 164198426   |
| CANADA        | 2018          | 8            | 133635800   |
| CANADA        | 2018          | 9            | 34042238    |
| CANADA        | 2019          | 3            | 36087248    |
| CANADA        | 2019          | 4            | 179830236   |
| CANADA        | 2019          | 5            | 140979946   |
| CANADA        | 2019          | 6            | 138690815   |
| CANADA        | 2019          | 7            | 173991586   |
| CANADA        | 2019          | 8            | 139428879   |
| CANADA        | 2019          | 9            | 35025721    |
| CANADA        | 2020          | 3            | 74731510    |
| CANADA        | 2020          | 4            | 141242538   |
| CANADA        | 2020          | 5            | 141030479   |
| CANADA        | 2020          | 6            | 174745093   |
| CANADA        | 2020          | 7            | 138944935   |
| CANADA        | 2020          | 8            | 174008340   |
| EUROPE        | 2018          | 3            | 8402183     |
| EUROPE        | 2018          | 4            | 44549418    |
| EUROPE        | 2018          | 5            | 36492553    |
| EUROPE        | 2018          | 6            | 38998277    |
| EUROPE        | 2018          | 7            | 50535910    |
| EUROPE        | 2018          | 8            | 39104650    |
| EUROPE        | 2018          | 9            | 9777575     |
| EUROPE        | 2019          | 3            | 8989328     |
| EUROPE        | 2019          | 4            | 46983044    |
| EUROPE        | 2019          | 5            | 36446510    |
| EUROPE        | 2019          | 6            | 36464369    |
| EUROPE        | 2019          | 7            | 47154102    |
| EUROPE        | 2019          | 8            | 36638154    |
| EUROPE        | 2019          | 9            | 9099858     |
| EUROPE        | 2020          | 3            | 17945582    |
| EUROPE        | 2020          | 4            | 35801793    |
| EUROPE        | 2020          | 5            | 36399326    |
| EUROPE        | 2020          | 6            | 47351180    |
| EUROPE        | 2020          | 7            | 39067454    |
| EUROPE        | 2020          | 8            | 46360191    |
| OCEANIA       | 2018          | 3            | 175777460   |
| OCEANIA       | 2018          | 4            | 869324594   |
| OCEANIA       | 2018          | 5            | 692610094   |
| OCEANIA       | 2018          | 6            | 687546255   |
| OCEANIA       | 2018          | 7            | 871333919   |
| OCEANIA       | 2018          | 8            | 714036679   |
| OCEANIA       | 2018          | 9            | 180310608   |
| OCEANIA       | 2019          | 3            | 192331207   |
| OCEANIA       | 2019          | 4            | 953735279   |
| OCEANIA       | 2019          | 5            | 746580473   |
| OCEANIA       | 2019          | 6            | 732354251   |
| OCEANIA       | 2019          | 7            | 934476631   |
| OCEANIA       | 2019          | 8            | 759346286   |
| OCEANIA       | 2019          | 9            | 192154910   |
| OCEANIA       | 2020          | 3            | 415174221   |
| OCEANIA       | 2020          | 4            | 776707747   |
| OCEANIA       | 2020          | 5            | 776466737   |
| OCEANIA       | 2020          | 6            | 951984238   |
| OCEANIA       | 2020          | 7            | 757648850   |
| OCEANIA       | 2020          | 8            | 958930687   |
| SOUTH AMERICA | 2018          | 3            | 16302144    |
| SOUTH AMERICA | 2018          | 4            | 80814046    |
| SOUTH AMERICA | 2018          | 5            | 63685837    |
| SOUTH AMERICA | 2018          | 6            | 63764243    |
| SOUTH AMERICA | 2018          | 7            | 81690746    |
| SOUTH AMERICA | 2018          | 8            | 66079697    |
| SOUTH AMERICA | 2018          | 9            | 16932862    |
| SOUTH AMERICA | 2019          | 3            | 17351683    |
| SOUTH AMERICA | 2019          | 4            | 87069807    |
| SOUTH AMERICA | 2019          | 5            | 67552363    |
| SOUTH AMERICA | 2019          | 6            | 67122227    |
| SOUTH AMERICA | 2019          | 7            | 84577363    |
| SOUTH AMERICA | 2019          | 8            | 68364336    |
| SOUTH AMERICA | 2019          | 9            | 17242721    |
| SOUTH AMERICA | 2020          | 3            | 37369282    |
| SOUTH AMERICA | 2020          | 4            | 70567678    |
| SOUTH AMERICA | 2020          | 5            | 70153609    |
| SOUTH AMERICA | 2020          | 6            | 87360985    |
| SOUTH AMERICA | 2020          | 7            | 69314667    |
| SOUTH AMERICA | 2020          | 8            | 86722019    |
| USA           | 2018          | 3            | 52734998    |
| USA           | 2018          | 4            | 260725717   |
| USA           | 2018          | 5            | 210050720   |
| USA           | 2018          | 6            | 206372070   |
| USA           | 2018          | 7            | 262393377   |
| USA           | 2018          | 8            | 212470882   |
| USA           | 2018          | 9            | 54294291    |
| USA           | 2019          | 3            | 55764198    |
| USA           | 2019          | 4            | 277108603   |
| USA           | 2019          | 5            | 220370520   |
| USA           | 2019          | 6            | 219743295   |
| USA           | 2019          | 7            | 274203066   |
| USA           | 2019          | 8            | 222170302   |
| USA           | 2019          | 9            | 56238077    |
| USA           | 2020          | 3            | 116853847   |
| USA           | 2020          | 4            | 221952003   |
| USA           | 2020          | 5            | 225545881   |
| USA           | 2020          | 6            | 277763625   |
| USA           | 2020          | 7            | 223735311   |
| USA           | 2020          | 8            | 277361606   |

---
#### Question 5: What is the total count of transactions for each platform

#### Solution: 

```sql
SELECT platform,
	   SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;
```

#### Answer:
| platform | total_transactions |
| -------- | ------------------ |
| Retail   | 1081934227         |
| Shopify  | 5925169            |

---
#### Question 6: What is the percentage of sales for Retail vs Shopify for each month? 

#### Solution: 

```sql
WITH monthly_platform_sales AS (

  SELECT calendar_year, month_number, platform,
         SUM(sales) AS sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, month_number, platform
  ORDER BY calendar_year, month_number, platform

)

SELECT calendar_year, 
	   month_number, 
       ROUND(
         100 * MAX(CASE WHEN platform = 'Retail' THEN sales ELSE NULL END) / SUM(sales)::BIGINT,
         2
       ) AS retail_percentage, 
       ROUND(
         100 * MAX(CASE WHEN platform = 'Shopify' THEN sales ELSE NULL END) / SUM(sales)::BIGINT,
         2
       ) AS shopify_percentage
FROM monthly_platform_sales
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;
```

#### Answer:
| calendar_year | month_number | retail_percentage | shopify_percentage |
| ------------- | ------------ | ----------------- | ------------------ |
| 2018          | 3            | 97.00             | 2.00               |
| 2018          | 4            | 97.00             | 2.00               |
| 2018          | 5            | 97.00             | 2.00               |
| 2018          | 6            | 97.00             | 2.00               |
| 2018          | 7            | 97.00             | 2.00               |
| 2018          | 8            | 97.00             | 2.00               |
| 2018          | 9            | 97.00             | 2.00               |
| 2019          | 3            | 97.00             | 2.00               |
| 2019          | 4            | 97.00             | 2.00               |
| 2019          | 5            | 97.00             | 2.00               |
| 2019          | 6            | 97.00             | 2.00               |
| 2019          | 7            | 97.00             | 2.00               |
| 2019          | 8            | 97.00             | 2.00               |
| 2019          | 9            | 97.00             | 2.00               |
| 2020          | 3            | 97.00             | 2.00               |
| 2020          | 4            | 96.00             | 3.00               |
| 2020          | 5            | 96.00             | 3.00               |
| 2020          | 6            | 96.00             | 3.00               |
| 2020          | 7            | 96.00             | 3.00               |
| 2020          | 8            | 96.00             | 3.00               |

---
#### Question 7: What is the percentage of sales by demographic for each year in the dataset?

#### Solution: 

```sql
WITH yearly_total_sales AS (
  
  SELECT calendar_year, 
  		 SUM(sales) as yearly_total_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year
  
)

SELECT cws.demographic, 
       cws.calendar_year, 
       SUM(cws.sales) AS yearly_sales, 
       ROUND( 100 * SUM(cws.sales)::NUMERIC / MIN(yts.yearly_total_sales), 2) AS percentage
FROM clean_weekly_sales cws
LEFT JOIN yearly_total_sales yts
ON cws.calendar_year = yts.calendar_year
GROUP BY cws.demographic, cws.calendar_year
ORDER BY cws.calendar_year, cws.demographic; 
```

#### Answer:
| demographic | calendar_year | yearly_sales | percentage |
| ----------- | ------------- | ------------ | ---------- |
| Couples     | 2018          | 3402388688   | 26.38      |
| Families    | 2018          | 4125558033   | 31.99      |
| unknown     | 2018          | 5369434106   | 41.63      |
| Couples     | 2019          | 3749251935   | 27.28      |
| Families    | 2019          | 4463918344   | 32.47      |
| unknown     | 2019          | 5532862221   | 40.25      |
| Couples     | 2020          | 4049566928   | 28.72      |
| Families    | 2020          | 4614338065   | 32.73      |
| unknown     | 2020          | 5436315907   | 38.55      |

---
#### Question 8: Which age_band and demographic values contribute the most to Retail sales?

#### Solution: 

```sql
WITH total_sales_cte AS (
  
  SELECT demographic, 
         age_band, 
         SUM(sales) as total_sales
  FROM clean_weekly_sales
  WHERE demographic != 'unknown'
  OR age_band != 'unknown'
  GROUP BY demographic, age_band
  ORDER BY SUM(sales) DESC
  
)

SELECT demographic, 
       age_band
FROM total_sales_cte
LIMIT 1;
```

#### Answer:
| demographic | age_band |
| ----------- | -------- |
| Families    | Retirees |

---
#### Question 9: Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

#### Solution: 
No, you cannot use the avg_transaction column directly, because it treats every row as having equal weight, ignoring the actual number of transactions.

```sql
SELECT calendar_year, 
  	   platform, 
  	   ROUND(SUM(sales) / SUM(transactions), 2) AS correct_avg,
  	   ROUND(AVG(avg_transaction), 2) AS incorrect_avg
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
```

#### Answer:
| calendar_year | platform | correct_avg | incorrect_avg |
| ------------- | -------- | ----------- | ------------- |
| 2018          | Retail   | 36.00       | 42.91         |
| 2018          | Shopify  | 192.00      | 188.28        |
| 2019          | Retail   | 36.00       | 41.97         |
| 2019          | Shopify  | 183.00      | 177.56        |
| 2020          | Retail   | 36.00       | 40.64         |
| 2020          | Shopify  | 179.00      | 174.87        |

---
## C. Before and After Analysis

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

#### Question 1: What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

#### Solution: 

```sql
WITH sales_bf_af_cte AS (

  SELECT SUM(
         CASE
           WHEN week_number IN (21,22,23,24) THEN sales
           ELSE 0
         END
         ) AS sales_before,
         SUM(
         CASE
           WHEN week_number IN (25,26,27,28) THEN sales
           ELSE 0
         END
         ) AS sales_after
  FROM clean_weekly_sales
  WHERE calendar_year = 2020
  
)

SELECT *, 
	   (sales_after - sales_before) AS growth_value, 
       ROUND( ( 100 * (sales_after - sales_before)::NUMERIC/sales_before), 2) AS growth_percentage
  FROM sales_bf_af_cte;
```

#### Answer:
| sales_before | sales_after | growth_value | growth_percentage |
| ------------ | ----------- | ------------ | ----------------- |
| 2345878357   | 2318994169  | -26884188    | -1.15  

---
#### Question 2: What about the entire 12 weeks before and after?

#### Solution: 

```sql
WITH sales_bf_af_cte AS (

  SELECT SUM(
         CASE
           WHEN week_number BETWEEN 13 AND 24 THEN sales
           ELSE 0
         END
         ) AS sales_before,
         SUM(
         CASE
           WHEN week_number BETWEEN 25 AND 37 THEN sales
           ELSE 0
         END
         ) AS sales_after
  FROM clean_weekly_sales
  WHERE calendar_year = 2020
  
)

SELECT *, 
	   (sales_after - sales_before) AS growth_value, 
       ROUND( ( 100 * (sales_after - sales_before)::NUMERIC/sales_before), 2) AS growth_percentage
  FROM sales_bf_af_cte;
```

#### Answer:
| sales_before | sales_after | growth_value | growth_percentage |
| ------------ | ----------- | ------------ | ----------------- |
| 7126273147   | 6973947753  | -152325394   | -2.14             |

---
#### Question 3: How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

#### Solution: 

```sql
WITH sales_bf_af_cte AS (

  SELECT calendar_year,
         SUM(
         CASE
           WHEN week_number BETWEEN 13 AND 24 THEN sales
           ELSE 0
         END
         ) AS sales_before,
         SUM(
         CASE
           WHEN week_number BETWEEN 25 AND 37 THEN sales
           ELSE 0
         END
         ) AS sales_after
  FROM clean_weekly_sales
  WHERE calendar_year = 2018
  GROUP BY calendar_year
  UNION ALL 
  SELECT calendar_year,
         SUM(
         CASE
           WHEN week_number BETWEEN 13 AND 24 THEN sales
           ELSE 0
         END
         ) AS sales_before,
         SUM(
         CASE
           WHEN week_number BETWEEN 25 AND 37 THEN sales
           ELSE 0
         END
         ) AS sales_after
  FROM clean_weekly_sales
  WHERE calendar_year = 2019
  GROUP BY calendar_year
  UNION ALL
  SELECT calendar_year,
         SUM(
         CASE
           WHEN week_number BETWEEN 13 AND 24 THEN sales
           ELSE 0
         END
         ) AS sales_before,
         SUM(
         CASE
           WHEN week_number BETWEEN 25 AND 37 THEN sales
           ELSE 0
         END
         ) AS sales_after
  FROM clean_weekly_sales
  WHERE calendar_year = 2020
  GROUP BY calendar_year
  
  
)

SELECT *, 
	   (sales_after - sales_before) AS growth_value, 
       ROUND( ( 100 * (sales_after - sales_before)::NUMERIC/sales_before), 2) AS growth_percentage
  FROM sales_bf_af_cte;
```

#### Answer:
| calendar_year | sales_before | sales_after | growth_value | growth_percentage |
| ------------- | ------------ | ----------- | ------------ | ----------------- |
| 2018          | 6396562317   | 6500818510  | 104256193    | 1.63              |
| 2019          | 6883386397   | 6862646103  | -20740294    | -0.30             |
| 2020          | 7126273147   | 6973947753  | -152325394   | -2.14             |

---
