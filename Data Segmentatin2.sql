WITH CustomerSegmentation AS (
SELECT 
C.customer_key,
SUM(sales_amount) AS TotalSpending,
MIN(order_date) AS FirstOrder,
MAX(order_date) AS LastOrder,
DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS LifeSpan
FROM gold.dim_customers C
LEFT JOIN 
gold.fact_sales	F ON F.customer_key = C.customer_key
------WHERE order_date IS NOT NULL
GROUP BY C.customer_key
)


SELECT 
COUNT(customer_key) AS CustNumber,
CustSegment
FROM(
	SELECT 
	customer_key,
	CASE WHEN TotalSpending > 5000 AND LifeSpan >= 12 THEN 'VIP'
		 WHEN TotalSpending <= 5000 AND LifeSpan >= 12 THEN 'REGULAR'
		 ELSE 'NEW'
	END CustSegment
	FROM CustomerSegmentation)t
GROUP BY CustSegment
ORDER BY CustNumber DESC






