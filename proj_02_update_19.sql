-- concat dates and times into new column

SELECT *,
CONCAT(LEFT(transaction_date, 10),' ',(RIGHT(transaction_time, 16))) AS new_dt
FROM dbo.maven_roasters

-- find nulls

SELECT *
FROM dbo.maven_roasters
WHERE transaction_id IS NULL
OR transaction_date IS NULL 
OR transaction_time IS NULL
OR transaction_qty IS NULL
OR store_id IS NULL
OR store_location IS NULL
OR product_id IS NULL
OR unit_price IS NULL
OR product_category IS NULL
OR product_type IS NULL
OR product_detail IS NULL

-- find duplicates of transaction_id

SELECT transaction_id
FROM dbo.maven_roasters
GROUP BY transaction_id
HAVING COUNT(*) > 1

-- find duplicates of column subset [1:]

SELECT transaction_date,
transaction_time, 
transaction_qty,
product_id,
store_id, 
COUNT(*) AS occurrences
FROM dbo.maven_roasters
GROUP BY transaction_date,
transaction_time,
transaction_qty,
product_id,
store_id
HAVING COUNT(*) > 1

-- drop duplicates of column subset [1:0]

WITH dupes AS 
(
SELECT transaction_date,
transaction_time, 
transaction_qty,
product_id,
store_id, 
COUNT(*) AS occurrences
FROM dbo.maven_roasters
GROUP BY transaction_date,
transaction_time,
transaction_qty,
product_id,
store_id
HAVING COUNT(*) > 1
)

DELETE df
FROM dupes d
JOIN dbo.maven_roasters df ON d.transaction_date = df.transaction_date
AND d.transaction_time = df.transaction_time
AND d.transaction_qty = df.transaction_qty
AND d.product_id = df.product_id
AND d.store_id = df.store_id
WHERE occurrences > 1

-- unique store locations

SELECT DISTINCT(store_location)
FROM dbo.maven_roasters

-- creation of transaction_amount column

SELECT *,
ROUND((unit_price * transaction_qty),2) AS trans_amt
FROM dbo.maven_roasters

-- product_category unique

SELECT DISTINCT(product_category)
FROM dbo.maven_roasters

-- product_type unique

SELECT DISTINCT(product_type)
FROM dbo.maven_roasters
ORDER BY product_type ASC

-- product_detail unique

SELECT DISTINCT(product_detail)
FROM dbo.maven_roasters
ORDER BY product_detail ASC

-- store_id unique

SELECT DISTINCT(store_id)
FROM dbo.maven_roasters

-- count of rows for each store_location

SELECT store_location,
COUNT(*) AS entries
FROM dbo.maven_roasters
GROUP BY store_location
ORDER BY entries DESC

-- date min and max

SELECT MIN(transaction_date) AS first_date,
MAX(transaction_date) AS last_date
FROM dbo.maven_roasters

-- verify number of distinct dates

SELECT COUNT(DISTINCT(transaction_date)) AS dates_in_data,
DATEDIFF(d, MIN(transaction_date),MAX(transaction_date)) + 1 AS expected_dates
FROM dbo.maven_roasters

-- task 01

SELECT product_category,
LEFT(ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()),2),4) AS percent_of_total,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty
FROM dbo.maven_roasters
GROUP BY product_category
ORDER BY transaction_qty DESC

-- task 02

SELECT ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt,
product_category
FROM dbo.maven_roasters
GROUP BY product_category
ORDER BY trans_amt DESC

-- task 03

SELECT SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
store_location
FROM dbo.maven_roasters
GROUP BY store_location
ORDER BY transaction_qty DESC

-- task 04

SELECT store_location,
ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt
FROM dbo.maven_roasters
GROUP BY store_location
ORDER BY trans_amt DESC

-- task 05

SELECT ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt,
store_location,
MONTH(transaction_date) AS mnth
FROM dbo.maven_roasters
GROUP BY store_location, MONTH(transaction_date)
ORDER BY mnth

-- task 06


SELECT MONTH(transaction_date) AS mnth,
ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt,
ROUND((100 *(1 -(LAG((SUM(ROUND((unit_price * transaction_qty),2)))) OVER (ORDER BY MONTH(transaction_date)) / (SUM(ROUND((unit_price * transaction_qty),2)))))),2) AS percentage_change
FROM dbo.maven_roasters
GROUP BY MONTH(transaction_date)
ORDER BY mnth


-- task 07

SELECT TOP 10
product_detail,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty
FROM dbo.maven_roasters
GROUP BY product_detail
ORDER BY transaction_qty DESC

-- task 08 (8,9, and 10 are all desc and asc switches)

SELECT TOP 10
product_detail,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty
FROM dbo.maven_roasters
GROUP BY product_detail
ORDER BY transaction_qty ASC

-- task 09

SELECT TOP 10
ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt,
product_detail
FROM dbo.maven_roasters
GROUP BY product_detail
ORDER BY trans_amt DESC

-- task 10

SELECT TOP 10
ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt,
product_detail
FROM dbo.maven_roasters
GROUP BY product_detail
ORDER BY trans_amt ASC

-- business task 07: peak times of day

SELECT DATEPART(HOUR,transaction_time) AS hr,
ROUND((SUM(ROUND((unit_price * transaction_qty),2))),2) AS trans_amt,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
COUNT(DISTINCT transaction_id) AS unique_trans
FROM dbo.maven_roasters
GROUP BY DATEPART(HOUR,transaction_time)
ORDER BY hr

-- business task 08: peak days of week

SELECT DATEPART(WEEKDAY,transaction_date) AS wd,
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
COUNT(DISTINCT transaction_id) AS unique_trans
FROM dbo.maven_roasters
GROUP BY DATEPART(WEEKDAY,transaction_date)
ORDER BY wd

-- business task 09: most popular products at beginning and end of year

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

-- test

SELECT TOP 10
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
product_detail
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 1
GROUP BY product_detail
ORDER BY transaction_qty 

-- test

SELECT TOP 10
SUM(CONVERT(INT, transaction_qty)) AS transaction_qty,
product_detail
FROM dbo.maven_roasters
WHERE MONTH(transaction_date) = 6
GROUP BY product_detail
ORDER BY transaction_qty 

-- business task 10: removing the least popular items from the last 6 months

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

-- supplemental evidence

SELECT TOP 10
SUM(CONVERT(INT, transaction_qty)) AS six_month_qty_total,
product_detail
FROM dbo.maven_roasters
GROUP BY product_detail
ORDER BY six_month_qty_total ASC

-- test 01

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
),

total_timeframe AS
(
SELECT TOP 10
SUM(CONVERT(INT, transaction_qty)) AS six_month_qty_total,
product_detail
FROM dbo.maven_roasters
GROUP BY product_detail
ORDER BY six_month_qty_total ASC
)

SELECT o.transaction_qty AS jan_amt,
s.transaction_qty AS jun_amt,
t.six_month_qty_total AS six_month_qty_total,
o.product_detail
FROM one o
JOIN six s ON o.product_detail = s.product_detail
JOIN total_timeframe t ON o.product_detail = t.product_detail
ORDER BY jan_amt ASC

-- business task 11: do holidays have an effect on sales?

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

-- verification jan

SELECT COUNT(DISTINCT transaction_id) AS jan_holiday
FROM dbo.maven_roasters
WHERE transaction_date = '2023-01-01'

-- verification feb

SELECT COUNT(DISTINCT transaction_id) AS feb_holiday
FROM dbo.maven_roasters
WHERE transaction_date = '2023-02-14'

-- verification mar

SELECT COUNT(DISTINCT transaction_id) AS mar_holiday
FROM dbo.maven_roasters
WHERE transaction_date = '2023-03-17'

-- verification apr

SELECT COUNT(DISTINCT transaction_id) AS apr_holiday
FROM dbo.maven_roasters
WHERE transaction_date = '2023-04-09'

-- verification may

SELECT COUNT(DISTINCT transaction_id) AS may_holiday
FROM dbo.maven_roasters
WHERE transaction_date = '2023-05-14'

-- verification jun

SELECT COUNT(DISTINCT transaction_id) AS jun_holiday
FROM dbo.maven_roasters
WHERE transaction_date = '2023-06-18'

-- business task 12: which store location saw the most change in avg number of trans and avg revenue?

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