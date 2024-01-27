# Coffee Shop SQL Analysis
## EDA and Business Tasks

__Author__: Daniel Perez <br />
__Email__: dannypere11@gmail.com <br />
__LinkedIn__: https://www.linkedin.com/in/danielperez12/ <br />

__1.__ Find the total number of rows of data for each store location.

```sql
SELECT store_location,
COUNT(*) AS entries
FROM dbo.maven_roasters
GROUP BY store_location
ORDER BY entries DESC
```
__Results:__

store_location|	entries
|-------------|------------|
Hell's Kitchen|      50465
Astoria|          	  50337
Lower Manhattan|	  47563

__2.__ Find the percentage of total quantities purchased for each product category.

```sql
SELECT product_category,
LEFT(ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()),2),4) AS percent_of_total,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty
FROM dbo.maven_roasters
GROUP BY product_category
ORDER BY transaction_qty DESC
```
__Results:__

product_category|                                  percent_of_total| transaction_qty
|--------------------------------------------------|---------------|----------------|
Coffee|                                             39.2|             89057
Tea|                                                30.6|             69672
Bakery|                                             15.0|             22719
Drinking Chocolate|                                 7.72|             17445
Flavours|                                           4.58|             10511
Coffee beans|                                       1.18|             1828
Loose Tea|                                          0.82|             1210
Branded|                                            0.50|             776
Packaged Chocolate|                                 0.33|             487

__3.__ Find the total amount made for each location within the 6 month timeframe.

```sql
SELECT store_location,
ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt
FROM dbo.maven_roasters
GROUP BY store_location
ORDER BY trans_amt DESC
```
__Results:__

store_location|                                     trans_amt
|--------------------------------------------------|---------|
Hell's Kitchen|                                     235577.07
Astoria|                                            231294.46
Lower Manhattan|                                    229233.4

__4.__ Find the total amount made by the company over the timeframe and the percentage change by each month.

```sql
SELECT MONTH(transaction_date) AS mnth,
ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt,
ROUND((100 *(1 -(LAG((SUM(ROUND((unit_price * transaction_qty),2)))) OVER (ORDER BY MONTH(transaction_date)) /
 (SUM(ROUND((unit_price * transaction_qty),2)))))),2) AS percentage_change
FROM dbo.maven_roasters
GROUP BY MONTH(transaction_date)
ORDER BY mnth
```
__Results:__
mnth|        trans_amt|              percentage_change
|-----------|----------------------|----------------------|
1|           81405.89|               NULL
2|          75790.49|               -7.41
3|           98493.18|               23.05
4|           118519.93|              16.9
5|           156088.61|              24.07
6|           165806.83|              5.86

__5.__ Find the top 10 products based on transaction quantities.

```sql
SELECT TOP 10
product_detail,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty
FROM dbo.maven_roasters
GROUP BY product_detail
ORDER BY transaction_qty DESC
```

__Results:__

product_detail|                                     transaction_qty
|--------------------------------------------------|---------------|
Earl Grey Rg|                                       4700
Dark chocolate Lg|                                  4660
Morning Sunrise Chai Rg|                            4643
Latte|                                              4569
Peppermint Rg|                                      4558
Columbian Medium Roast Rg|                          4543
Traditional Blend Chai Rg|                          4512
Our Old Time Diner Blend Sm|                        4484
Latte Rg|                                           4481
Serenity Green Tea Rg|                              4477

__6.__ Find the bottom 10 products based on transaction quantities.

```sql
SELECT TOP 10
product_detail,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty
FROM dbo.maven_roasters
GROUP BY product_detail
ORDER BY transaction_qty ASC
```

__Results:__

product_detail|                                     transaction_qty
|--------------------------------------------------|---------------|
Dark chocolate|                                     118
Spicy Eye Opener Chai|                              122
Guatemalan Sustainably Grown|                       134
Earl Grey|                                          142
Jamacian Coffee River|                              146
Chili Mayan|                                        148
Columbian Medium Roast|                             148
Primo Espresso Roast|                               150
Lemon Grass|                                        152
Traditional Blend Chai|                             153

__7.__ What are the peak times of day based on transaction amounts and transaction quantities?

```sql
SELECT DATEPART(HOUR,transaction_time) AS hr,
ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
COUNT(DISTINCT transaction_id) AS unique_trans
FROM dbo.maven_roasters
GROUP BY DATEPART(HOUR,transaction_time)
ORDER BY hr
```

__Results:__

hr|          trans_amt|              transaction_qty| unique_trans
|-----------|----------------------|---------------|------------|
6|           21802.77|               6839|            4568
7|           63165.17|               19353|           13332
8|           82127.77|               25043|           17500
9|           84516.83|               25182|           17576
10|          87989.14|               26516|           18362
11|          46223.39|               14008|           9739
12|         40106.89|               12662|           8680
13|          40367.45|               12439|           8714
14|          41284.04|               12899|           8925
15|          41689.35|               12910|           8966
16|          41122.75|               12881|           9093
17|         40134.31|               12700|           8745
18|          34225.45|               10808|           7480
19|          28413.98|               8585|            6082
20|          2935.64|                880|             603

__8.__ What are the peak days of the week regarding transaction quantities?

```sql
SELECT DATEPART(WEEKDAY,transaction_date) AS wd,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
COUNT(DISTINCT transaction_id) AS unique_trans
FROM dbo.maven_roasters
GROUP BY DATEPART(WEEKDAY,transaction_date)
ORDER BY wd
```

__Results:__

wd|          transaction_qty| unique_trans
|-----------|---------------|------------|
1|           30089|           21005
2|           31127|           21541
3|           30332|           21089
4|           30516|           21201
5|           31036|           21534
6|           31100|           21594
7|           29505|           20401

__9.__ Which products were most popular at both the beginning of the timeframe and at the end?

```sql
WITH one AS 
(
SELECT TOP 10
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
product_detail
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 1
GROUP BY product_detail
ORDER BY transaction_qty DESC
),

six AS 
(
SELECT TOP 10
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
product_detail
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 6
GROUP BY product_detail
ORDER BY transaction_qty DESC
)

SELECT o.transaction_qty AS jan_amt,
s.transaction_qty AS jun_amt,
o.product_detail
FROM one o
LEFT JOIN six s ON o.product_detail = s.product_detail
WHERE s.transaction_qty IS NOT NULL
ORDER BY jan_amt DESC
```

__Results:__

jan_amt|     jun_amt|     product_detail
|-----------|-----------|-------------------------------|
548|         1075|        Ethiopia Sm
547|         1078|        Columbian Medium Roast Rg
546|         1078|        Morning Sunrise Chai Rg
536|         1105|        Dark chocolate Lg
533|         1084|        Latte Rg
532|         1107|        Earl Grey Rg
526|         1080|        Latte

__10.__ We're looking to remove the three least popular items from the menu. Based on the 6 months of data, which products were the least popular at both the beginning and end of the timeframe?

```sql
WITH one AS 
(
SELECT TOP 10
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
product_detail
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 1
GROUP BY product_detail
ORDER BY transaction_qty ASC
),

six AS 
(
SELECT TOP 10
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
product_detail
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 6
GROUP BY product_detail
ORDER BY transaction_qty ASC
)

SELECT o.transaction_qty AS jan_amt,
s.transaction_qty AS jun_amt,
o.product_detail
FROM one o
LEFT JOIN six s ON o.product_detail = s.product_detail
WHERE s.transaction_qty IS NOT NULL
ORDER BY jan_amt ASC, jun_amt ASC
```

__Results:__

jan_amt|     jun_amt|     product_detail
|-----------|-----------|-----------------------
8|           30|          Columbian Medium Roast
8|           34|          Spicy Eye Opener Chai
12|          29|          Dark chocolate
16|          30|         Jamacian Coffee River
18|          32|          Chili Mayan

__11.__ Do holidays have a noticeable effect on transaction quantities?

```sql
WITH jan AS 
(
SELECT COUNT(DISTINCT transaction_id) / 31 AS jan_avg
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 1
),
feb AS
(
SELECT COUNT(DISTINCT transaction_id) / 28 AS feb_avg
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 2
),
mar AS
(
SELECT COUNT(DISTINCT transaction_id) / 31 AS mar_avg
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 3
),
apr AS
(
SELECT COUNT(DISTINCT transaction_id) / 30 AS apr_avg
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 4
),
may AS
(
SELECT COUNT(DISTINCT transaction_id) / 31 AS may_avg
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 5
),
jun AS
(
SELECT COUNT(DISTINCT transaction_id) / 30 AS jun_avg
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 6
)

SELECT ja.jan_avg, f.feb_avg, m.mar_avg, a.apr_avg, ma.may_avg, j.jun_avg
FROM jan ja, feb f, mar m, apr a, may ma, jun j
```

__Results:__

jan_avg|     feb_avg|     mar_avg|     apr_avg|     may_avg|     jun_avg
|-----------|-----------|-----------|-----------|-----------| -----------|
556|         580 |        681   |      840    |     1075    |    1172

jan_holiday | feb_holiday | mar_holiday | apr_holiday |may_holiday|jun_holiday
|----------|----------|------------|---------|--------|-------|
550|        583|        693|        829|        1065|       1286

__12.__ Which store location saw the most change in monthly transactions and sales volumes?

```sql
WITH jan AS
(
SELECT store_location,
COUNT(DISTINCT transaction_id) AS num_sales,
SUM(ROUND((unit_price * transaction_qty),2)) AS trans_amt
FROM maven_roasters
WHERE MONTH(transaction_date) = 1
GROUP BY store_location
),
jun AS
(
SELECT store_location,
COUNT(DISTINCT transaction_id) AS num_sales,
SUM(ROUND((unit_price * transaction_qty),2)) AS trans_amt
FROM maven_roasters
WHERE MONTH(transaction_date) = 6
GROUP BY store_location
)
SELECT ja.store_location,
j.num_sales - ja.num_sales AS difference_in_sales_volume,
ROUND((j.trans_amt - ja.trans_amt),2) AS difference_in_revenue
FROM jan ja
JOIN jun j ON ja.store_location = j.store_location
ORDER BY difference_in_sales_volume DESC, difference_in_revenue DESC
```

__Results:__

store_location|                                     difference_in_sales_volume| difference_in_revenue
|-------------------------|------------------------|---------|
Hell's Kitchen |          6165|                       29001.03
Astoria|                  6017|                       27573.55
Lower Manhattan |         5743|                       27826.36