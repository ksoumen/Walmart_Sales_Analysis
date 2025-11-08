SELECT COUNT(*) FROM walmart;

SELECT
	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method;

SELECT
	COUNT(DISTINCT Branch)
FROM walmart;

SELECT 
	MAX(Quantity) AS Max,
	MIN(Quantity) AS Min
FROM walmart;

--Business Problems
--Q.1 Find different payment method and number of transactions,number of qty sold

SELECT
	payment_method,
	COUNT(*) AS no_payments,
	SUM(Quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

--Q.2 Identify the highest-rated category in each branch,displaying the branch category
--AVG rating

SELECT *
FROM
(
	SELECT
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating)DESC) AS rank
	FROM walmart
	GROUP BY 1,2
) AS t
WHERE rank = 1;

--Q.3 Identify the busiest day for each branch based on the number of transantions
SELECT *
FROM 
(
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') as day_name,
		count(*) as no_transactions,
		RANK()OVER(PARTITION BY branch ORDER BY COUNT(*) DESC )as rank
	FROM walmart
	GROUP BY 1,2
)AS t
WHERE rank = 1;

--Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity

SELECT
	payment_method,
	SUM(quantity) Total_Quantity
FROM walmart
GROUP BY payment_method;


--Q.5
-- Determine the avg,min,and max rating of products for each city.
-- List the city,average_rating,min_rating,and max_rating.

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1,2;

--Q.6
-- Calculate the total profit for each category by considering total_profit as
--(unit_price * quantity * profit_margin)
--List category and total_profit,ordered from highest to lower profit.

SELECT
	category,
	SUM(total_price) as total_revenue,
	SUM(total_price * profit_margin) as profit
FROM walmart
GROUP BY 1
ORDER BY 3 DESC

--Q.7
--Determine the most common payment method for each Branch,
--Display branch and the prefered_payment_method

WITH CTE
AS
	(SELECT
		branch,
		payment_method,
		COUNT(*)as total_trans,
		RANK()OVER(PARTITION BY branch ORDER BY COUNT(*)DESC) as rank
	FROM walmart
	GROUP BY 1,2
)
SELECT *
FROM CTE
WHERE rank = 1;

--Q.8
--Categorize sales into 3 group MORNING,AFTERNOON,EVENING
--Find out which of the shift and number of invoices

SELECT
	Branch,
	CASE 
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

--Q.9
--Identify 5 branch with highest decrease ratio in
-- revenue compare to last year(current year 2023 and last year 2022)
--rdr == last_rev - cr_rev / last_rev * 100

--2022 sales
--using CTE

WITH revenue_2022
AS
(
	SELECT
		branch,
		SUM(total_price) as revenue
	FROM walmart
	WHERE EXTRACT (YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2022
	GROUP BY 1
),
revenue_2023
AS(
	SELECT
		branch,
		SUM(total_price) as revenue
	FROM walmart
	WHERE EXTRACT (YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::NUMERIC/
		ls.revenue::numeric * 100,
		2) as revenue_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;











