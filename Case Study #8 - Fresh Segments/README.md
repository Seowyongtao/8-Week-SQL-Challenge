# Case Study #8 - Fresh Segments

<img alt="Case Study 8" src="https://8weeksqlchallenge.com/images/case-study-designs/8.png" width="60%" height="60%" />

## 📚 Table of Contents
- [Introduction](#introduction)
- [A. Data Exploration and Cleansing](#a-data-exploration-and-cleansing)

## Introduction 

Danny created Fresh Segments, a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.

Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.

In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.

Danny has asked for your assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.

## A. Data Exploration and Cleansing

#### Question 1: Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

#### Solution: 

```sql
ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN month_year TYPE DATE USING TO_DATE(month_year, 'MM-YYYY');
```
---
#### Question 2: What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

#### Solution: 

```sql
SELECT month_year, 
	   COUNT(*) AS cnt
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year NULLS FIRST;
```

#### Answer:
| month_year | cnt  |
| ---------- | ---- |
|            | 1194 |
| 2018-07-01 | 729  |
| 2018-08-01 | 767  |
| 2018-09-01 | 780  |
| 2018-10-01 | 857  |
| 2018-11-01 | 928  |
| 2018-12-01 | 995  |
| 2019-01-01 | 973  |
| 2019-02-01 | 1121 |
| 2019-03-01 | 1136 |
| 2019-04-01 | 1099 |
| 2019-05-01 | 857  |
| 2019-06-01 | 824  |
| 2019-07-01 | 864  |
| 2019-08-01 | 1149 |

---
#### Question 3: What do you think we should do with these null values in the fresh_segments.interest_metrics

#### Solution: 
We should remove those records. Without the interest_id and month_year information, the analysis is meaningless because we won't be able to analyze the data from those perspectives.

```sql
DELETE FROM fresh_segments.interest_metrics WHERE interest_id IS NULL;
```

---
#### Question 4: How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

#### Solution: 

```sql
SELECT COUNT(CASE WHEN id IS NULL THEN 1 ELSE NULL END) AS not_in_interest_map, 
	   COUNT(CASE WHEN interest_id IS NULL THEN 1 ELSE NULL END) AS not_in_interest_metrics
FROM fresh_segments.interest_metrics a 
FULL JOIN fresh_segments.interest_map b 
ON a.interest_id = b.id;
```

#### Answer:
| not_in_interest_map | not_in_interest_metrics |
| ------------------- | ----------------------- |
| 0                   | 7                       |

---
#### Question 5: Summarise the id values in the fresh_segments.interest_map by its total record count in this table

#### Solution: 

```sql
SELECT id, 
       interest_name, 
       COUNT(*) AS cnt
FROM fresh_segments.interest_map a
JOIN fresh_segments.interest_metrics b
  ON a.id = b.interest_id
GROUP BY id, interest_name
ORDER BY cnt DESC;
```

#### Answer:
| id    | interest_name                                        | cnt |
| ----- | ---------------------------------------------------- | --- |
| 78    | Contractors & Construction Professionals             | 14  |
| 18490 | Professional Sound Products Researchers              | 14  |
| 19613 | Land Rover Shoppers                                  | 14  |
| 10351 | Military Personal Finance Researchers                | 14  |
| 6081  | Hawaii Trip Planners                                 | 14  |
| 4927  | Immigration Rights Advocates                         | 14  |
| 4910  | Cholesterol Researchers                              | 14  |
| 6133  | Fantasy Football Enthusiasts                         | 14  |
| 6328  | Mattress Researchers                                 | 14  |
| ...  | ...                             | ...  |

---
#### Question 6: What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

---
#### Question 7: Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

#### Solution: 

Yes, there are records having value “month_year” value that is before the “created_at” value: 

```sql
SELECT a.month_year, b.created_at
FROM fresh_segments.interest_metrics a
JOIN fresh_segments.interest_map b
  ON a.interest_id = b.id
WHERE a.month_year < b.created_at; 
```

| month_year | created_at          |
| ---------- | ------------------- |
| 2018-07-01 | 2018-07-06 14:35:03 |
| 2018-07-01 | 2018-07-06 14:35:04 |
| 2018-07-01 | 2018-07-06 14:35:04 |
| 2018-07-01 | 2018-07-06 14:35:04 |
| 2018-07-01 | 2018-07-06 14:35:04 |
| 2018-07-01 | 2018-07-17 10:40:03 |
| 2018-08-01 | 2018-08-02 16:05:03 |
| 2018-08-01 | 2018-08-02 16:05:03 |
| 2018-08-01 | 2018-08-02 16:05:03 |
| 2018-08-01 | 2018-08-02 16:05:03 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:04 |
| 2018-08-01 | 2018-08-02 16:05:05 |
| 2018-08-01 | 2018-08-02 16:05:05 |
| 2018-08-01 | 2018-08-07 17:10:03 |
| 2018-08-01 | 2018-08-07 17:10:03 |
| 2018-08-01 | 2018-08-07 17:10:03 |
| 2018-08-01 | 2018-08-07 17:10:03 |
| 2018-08-01 | 2018-08-07 17:10:04 |
| 2018-08-01 | 2018-08-07 17:10:04 |
| 2018-08-01 | 2018-08-07 17:10:04 |
| 2018-08-01 | 2018-08-07 17:10:04 |
| 2018-08-01 | 2018-08-07 17:10:04 |
| 2018-08-01 | 2018-08-07 17:10:04 |
| 2018-08-01 | 2018-08-07 17:10:04 |
| 2018-08-01 | 2018-08-13 13:35:02 |
| 2018-08-01 | 2018-08-15 18:00:03 |
| 2018-08-01 | 2018-08-15 18:00:03 |
| 2018-08-01 | 2018-08-15 18:00:03 |
| 2018-08-01 | 2018-08-15 18:00:03 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-15 18:00:04 |
| 2018-08-01 | 2018-08-17 10:50:03 |
| 2018-09-01 | 2018-09-05 18:10:03 |
| 2018-09-01 | 2018-09-05 18:10:04 |
| 2018-09-01 | 2018-09-05 18:10:04 |
| 2018-09-01 | 2018-09-05 18:15:03 |
| 2018-09-01 | 2018-09-06 11:40:04 |
| 2018-09-01 | 2018-09-06 16:55:03 |
| 2018-09-01 | 2018-09-07 15:00:03 |
| 2018-09-01 | 2018-09-14 14:35:03 |
| 2018-10-01 | 2018-10-03 14:15:03 |
| 2018-10-01 | 2018-10-03 14:15:03 |
| 2018-10-01 | 2018-10-03 14:15:03 |
| 2018-10-01 | 2018-10-03 14:15:03 |
| 2018-10-01 | 2018-10-03 14:15:03 |
| 2018-10-01 | 2018-10-03 14:15:04 |
| 2018-10-01 | 2018-10-03 14:15:04 |
| 2018-10-01 | 2018-10-03 14:15:04 |
| 2018-10-01 | 2018-10-03 14:15:04 |
| 2018-10-01 | 2018-10-03 14:15:04 |
| 2018-10-01 | 2018-10-03 14:45:03 |
| 2018-10-01 | 2018-10-10 15:20:04 |
| 2018-10-01 | 2018-10-10 15:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:04 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:20:05 |
| 2018-10-01 | 2018-10-11 12:30:03 |
| 2018-11-01 | 2018-11-02 17:10:04 |
| 2018-11-01 | 2018-11-02 17:10:04 |
| 2018-11-01 | 2018-11-02 17:10:04 |
| 2018-11-01 | 2018-11-02 17:10:04 |
| 2018-11-01 | 2018-11-02 17:10:04 |
| 2018-11-01 | 2018-11-02 17:10:05 |
| 2018-11-01 | 2018-11-02 17:10:05 |
| 2018-11-01 | 2018-11-02 17:10:05 |
| 2018-11-01 | 2018-11-02 17:10:05 |
| 2018-11-01 | 2018-11-02 17:10:05 |
| 2018-11-01 | 2018-11-02 17:10:05 |
| 2018-11-01 | 2018-11-09 15:40:04 |
| 2018-11-01 | 2018-11-09 15:40:05 |
| 2018-11-01 | 2018-11-09 15:40:05 |
| 2018-11-01 | 2018-11-09 15:40:05 |
| 2018-11-01 | 2018-11-09 15:40:05 |
| 2018-11-01 | 2018-11-09 15:45:04 |
| 2018-11-01 | 2018-11-12 17:30:04 |
| 2018-11-01 | 2018-11-14 12:30:04 |
| 2018-11-01 | 2018-11-14 12:30:04 |
| 2018-11-01 | 2018-11-14 12:30:04 |
| 2018-11-01 | 2018-11-14 12:30:04 |
| 2018-11-01 | 2018-11-14 12:30:04 |
| 2018-11-01 | 2018-11-14 12:30:05 |
| 2018-11-01 | 2018-11-14 12:30:05 |
| 2018-11-01 | 2018-11-14 12:30:05 |
| 2018-11-01 | 2018-11-14 12:30:06 |
| 2018-12-01 | 2018-12-03 11:10:04 |
| 2018-12-01 | 2018-12-03 11:10:04 |
| 2018-12-01 | 2018-12-03 11:10:04 |
| 2018-12-01 | 2018-12-03 11:10:05 |
| 2018-12-01 | 2018-12-03 11:10:05 |
| 2018-12-01 | 2018-12-03 11:10:05 |
| 2018-12-01 | 2018-12-03 11:10:05 |
| 2018-12-01 | 2018-12-03 11:10:05 |
| 2018-12-01 | 2018-12-03 11:10:05 |
| 2018-12-01 | 2018-12-07 11:50:03 |
| 2018-12-01 | 2018-12-07 11:50:04 |
| 2018-12-01 | 2018-12-07 11:50:04 |
| 2018-12-01 | 2018-12-07 11:50:04 |
| 2018-12-01 | 2018-12-07 11:50:04 |
| 2018-12-01 | 2018-12-11 10:35:05 |
| 2018-12-01 | 2018-12-11 14:15:05 |
| 2018-12-01 | 2018-12-13 20:00:00 |
| 2018-12-01 | 2018-12-14 21:00:00 |
| 2018-12-01 | 2018-12-14 21:00:00 |
| 2018-12-01 | 2018-12-14 21:00:00 |
| 2019-01-01 | 2019-01-07 12:00:03 |
| 2019-01-01 | 2019-01-10 11:10:03 |
| 2019-01-01 | 2019-01-10 11:10:04 |
| 2019-01-01 | 2019-01-10 11:10:04 |
| 2019-01-01 | 2019-01-10 11:10:04 |
| 2019-01-01 | 2019-01-10 11:10:04 |
| 2019-01-01 | 2019-01-10 11:10:04 |
| 2019-01-01 | 2019-01-10 11:10:04 |
| 2019-01-01 | 2019-01-10 11:10:04 |
| 2019-01-01 | 2019-01-10 11:10:05 |
| 2019-01-01 | 2019-01-10 11:10:05 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-04 22:00:00 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:01 |
| 2019-02-01 | 2019-02-06 21:00:02 |
| 2019-02-01 | 2019-02-06 21:00:02 |
| 2019-02-01 | 2019-02-06 21:00:02 |
| 2019-02-01 | 2019-02-07 21:00:00 |
| 2019-03-01 | 2019-03-05 18:00:00 |
| 2019-03-01 | 2019-03-05 22:00:00 |
| 2019-03-01 | 2019-03-15 22:00:02 |
| 2019-04-01 | 2019-04-08 18:00:05 |
| 2019-04-01 | 2019-04-15 18:00:00 |
| 2019-04-01 | 2019-04-15 18:00:00 |
| 2019-04-01 | 2019-04-15 18:00:00 |
| 2019-04-01 | 2019-04-15 18:00:00 |
| 2019-04-01 | 2019-04-15 18:00:00 |
| 2019-04-01 | 2019-04-15 18:00:00 |
| 2019-04-01 | 2019-04-15 18:00:00 |
| 2019-05-01 | 2019-05-06 22:00:00 |

But, it seems like those records are created in the same month. 

Running another query to check by converting “created_at” to first day of the month instead: 

```sql
SELECT a.month_year, DATE_TRUNC('mon', b.created_at)
FROM fresh_segments.interest_metrics a
JOIN fresh_segments.interest_map b
  ON a.interest_id = b.id
WHERE a.month_year < DATE_TRUNC('mon', b.created_at); 
```
There are no records shown if compared using DATE_TRUNC('mon', b.created_at). Hence, it is safe to assume those are valid records. 

---
