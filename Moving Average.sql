CREATE VIEW Change_Over_Time as
SELECT
Order_Date,
Total_Sales,
SUM(Total_Sales) OVER (PARTITION BY YEAR(Order_Date) ORDER BY Order_Date) AS Running_Total,
AVG(avg_price) OVER (PARTITION BY YEAR(Order_Date) ORDER BY Order_Date) AS Moving_Average
FROM
(
SELECT
DATETRUNC(MONTH,order_date) AS Order_Date
,SUM(sales_amount) As Total_Sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY DATETRUNC(MONTH,order_date)
)T


