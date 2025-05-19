CREATE VIEW gold.report_customer AS
WITH Customer_Base AS ( -- BASE QUERY (RETRIEVES CORE COLUMNS FROM TABLES) 
	 SELECT  
	 order_number,
	 product_key,
	 F.customer_key,
	 order_date,
	 CONCAT(first_name, ' ',last_name) AS Whole_Name,
	 country,
	 marital_status,
	 gender,
	 DATEDIFF(YEAR ,birthdate ,GETDATE()) AS Age,
	 sales_amount,
	 quantity

	 FROM gold.fact_sales F
	 LEFT JOIN gold.dim_customers C
	 ON F.customer_key = C.customer_key
),
Customer_Aggregation AS (-- Customer Aggregation (Summerize Key Metrics at Customer Level) 
	SELECT 
	customer_key,
	Whole_Name,
	country,
	marital_status,
	gender,
	Age,
	COUNT(DISTINCT(product_key)) AS Total_Products,
	COUNT(DISTINCT(order_number)) AS Total_Orders ,
	SUM(sales_amount)AS Total_Sales,
	SUM(quantity) AS Total_Quantity,
	MAX(order_date) AS Last_Order_Date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS LifeSpan
FROM Customer_Base
GROUP BY 
	customer_key,
	Whole_Name,
	country,
	marital_status,
	gender,
	Age
)

SELECT 
customer_key,
Whole_Name,
CASE WHEN Total_Sales > 5000 AND LifeSpan >= 12 THEN 'VIP'
	 WHEN Total_Sales <= 5000 AND LifeSpan >= 12 THEN 'REGULAR'
	 ELSE 'NEW'
END CustSegment,
country,
marital_status,
gender,
Age,
CASE WHEN Age <30 THEN 'BELOW 30'
	 WHEN Age BETWEEN 30 AND 40 THEN '30-40'
	 WHEN Age BETWEEN 40 AND 50 THEN '40-50'
	 ELSE 'ABOVE 50'
END AgeSegmentation,
Total_Products,
Total_Orders ,
Total_Sales,
CASE WHEN Total_Orders =0  THEN 0
     ELSE Total_Sales/Total_Orders 
END	AS Average_Order_Value,
CASE WHEN LifeSpan =0 THEN 0
	 ELSE Total_Sales/LifeSpan
END AS Average_Monthly_Spending,
Total_Quantity,
Last_Order_Date,
DATEDIFF(MONTH, Last_Order_Date , GETDATE()) AS Recency,
LifeSpan
FROM Customer_Aggregation