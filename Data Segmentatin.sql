WITH ProductSegment AS (
SELECT 
category,
product_key,
cost,
CASE WHEN cost < 100 THEN 'BELOW 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'ABOVE 1000'
END CostRange
FROM gold.dim_products)


SELECT 
CostRange,
COUNT(DISTINCT(product_key)) AS ProductNum
FROM ProductSegment
GROUP BY CostRange
ORDER BY ProductNum DESC