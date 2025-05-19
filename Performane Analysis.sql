
WITH yearlyPerformance AS(
SELECT 
YEAR(F.order_date) AS OrderTime,
P.product_name,
SUM(F.sales_amount) AS CurrentSales
FROM gold.fact_sales F
LEFT JOIN 
gold.dim_products P ON F.product_key = P.product_key
WHERE F.order_date IS NOT NULL
GROUP BY YEAR(F.order_date) ,P.product_name
)
SELECT
* ,
AVG(CurrentSales) OVER (PARTITION BY product_name) AvgSales,
CurrentSales-AVG(CurrentSales) OVER (PARTITION BY product_name) AS DiffAVG,
CASE WHEN CurrentSales-AVG(CurrentSales) OVER (PARTITION BY product_name) >  0 THEN 'ABOVE AVERAGE'
	 WHEN CurrentSales-AVG(CurrentSales) OVER (PARTITION BY product_name) <  0 THEN  'BELOW AVERAGE'
	 ELSE 'AVG'
END AvgChange,
LAG(CurrentSales) OVER (PARTITION BY product_name ORDER BY OrderTime) PreviousYear,
CurrentSales-LAG(CurrentSales) OVER (PARTITION BY product_name ORDER BY OrderTime) AS DiffPrevious,
CASE WHEN CurrentSales-LAG(CurrentSales) OVER (PARTITION BY product_name ORDER BY OrderTime) >  0 THEN 'INCREAING'
	 WHEN CurrentSales-LAG(CurrentSales) OVER (PARTITION BY product_name ORDER BY OrderTime) <  0 THEN  'DECRESING'
	 ELSE 'NO CHANGE'
END PreviosYearChange
FROM yearlyPerformance
ORDER BY product_name,OrderTime