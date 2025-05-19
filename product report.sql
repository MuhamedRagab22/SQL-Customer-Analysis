CREATE VIEW gold.report_product AS
WITH Porduct_Base AS (
SELECT 
order_number,
customer_key,
F.product_key,
order_date,
sales_amount,
quantity,
product_name,
category,
subcategory,
maintenance,
cost,
product_line
FROM gold.fact_sales F
LEFT JOIN gold.dim_products P
ON P.product_key = F.product_key
WHERE order_date IS NOT NULL)

,Product_Aggregation AS(
	SELECT
	product_name,
	category,
	subcategory,
	maintenance,
	product_line,
	MAX(order_date) AS Last_Order_Date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS LifeSpan,
	SUM(sales_amount) AS Total_Sales,
	SUM(quantity) AS Total_Quantity,
	SUM(cost) AS Total_Cost,
	COUNT(DISTINCT(customer_key)) AS Total_Customers,
	COUNT(DISTINCT(order_number)) AS Total_Orders ,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),1) AS Avg_Selling_Price
	FROM Porduct_Base
	GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	maintenance,
	product_line)

SELECT 
product_name,
category,
subcategory,
maintenance,
product_line,
DATEDIFF(MONTH, Last_Order_Date , GETDATE()) AS Recency,
CASE WHEN Total_Sales >50000 THEN 'HIGH PERFORMER'
	 WHEN Total_Sales >10000 THEN 'MID PERFORMER'
	 ELSE 'LOW PERFORMER'
END AS Product_Performance,
LifeSpan,
Total_Sales,
Total_Quantity,
Total_Cost,
Total_Customers,
Total_Orders ,
Avg_Selling_Price,
CASE WHEN Total_Orders =0  THEN 0
     ELSE Total_Sales/Total_Orders 
END	AS Average_Order_Value,
CASE WHEN LifeSpan =0 THEN 0
	 ELSE Total_Sales/LifeSpan
END AS Average_Monthly_Spending
FROM Product_Aggregation