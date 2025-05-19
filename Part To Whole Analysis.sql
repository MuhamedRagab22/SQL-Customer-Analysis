WITH CategorySales AS(
SELECT category,
SUM(sales_amount) AS TotslSales
FROM gold.dim_products P
INNER JOIN 
gold.fact_sales F ON F.product_key = P.product_key
WHERE category IS NOT NULL
GROUP BY category 


)
SELECT 
category,
TotslSales,
SUM(TotslSales) OVER() AS GrandTotals,
ROUND(CAST(TotslSales AS FLOAT)/SUM(TotslSales) OVER()*100,2) AS PercentageSales 
FROM CategorySales
ORDER BY TotslSales DESC