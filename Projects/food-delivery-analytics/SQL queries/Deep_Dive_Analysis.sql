/* Deep-Dive */
-- 21. What is the reorder rate for customers? (How many days between first and second order?)
WITH ordered_customers AS(
SELECT customer_id , order_timestamp,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_timestamp) AS rn
FROM orders),

reorder AS(
SELECT customer_id ,
       MAX(CASE WHEN rn = 1 THEN order_timestamp END) AS first_order,
       MAX(CASE WHEN rn = 2 THEN order_timestamp END) AS second_order
FROM ordered_customers
GROUP BY customer_id
HAVING second_order IS NOT NULL)

SELECT customer_id,
       DATEDIFF(second_order, first_order) AS days_between_first_second
FROM reorder
ORDER BY days_between_first_second;

-- 22. What are the top reasons for order failures? (We will infer based on patterns.)
SELECT order_status , COUNT(*) AS failure_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS failure_percentage
FROM orders
WHERE order_status <> 'Delivered'
GROUP BY order_status
ORDER BY failure_count DESC;

/* OR */
WITH failed AS (
    SELECT *
    FROM orders
    WHERE order_status <> 'Delivered')

SELECT 
    order_status AS failure_reason,
    COUNT(*) AS failure_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM failed), 2) AS failure_percentage
FROM failed
GROUP BY order_status
ORDER BY failure_count DESC;

-- 23. How does discount size impact order value? (More discount → more order?)
WITH DiscountedOrders AS (
SELECT order_id, order_value , discount_amount,
CASE 
    WHEN discount_amount = 0 THEN 'NO discount'
    WHEN discount_amount > 0 AND discount_amount <= 20 THEN 'category 1'
    WHEN discount_amount > 20 AND discount_amount <= 50 THEN 'category 2'
    ELSE 'category 3'
    END AS DISCOUNT
FROM orders )

SELECT DISCOUNT ,
       COUNT(order_id) AS Number_of_orders,
       AVG(order_value) AS AOV,
       SUM(order_value) AS total
FROM DiscountedOrders
GROUP BY DISCOUNT
ORDER BY AOV DESC;

-- 24. What is the Month-over-Month revenue trend?
WITH month_on_month AS(
SELECT DATE_FORMAT(order_timestamp, '%Y-%m') AS month,
	   SUM(order_value - discount_amount) AS revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY month),

growth AS(
SELECT month, revenue,
LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue
FROM month_on_month)

SELECT month, revenue , prev_month_revenue,
ROUND(((revenue - prev_month_revenue) / prev_month_revenue) * 100,2) AS mom_growth_percent
FROM growth;

-- 25. Which restaurants are growing vs declining?
WITH yearly AS (
SELECT r.restaurant_id, r.restaurant_name,
        DATE_FORMAT(o.order_timestamp, '%Y') AS year,
        SUM(o.order_value - o.discount_amount) AS revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id, r.restaurant_name, year),

growth AS (
SELECT restaurant_id, restaurant_name, year, revenue,
LAG(revenue) OVER (PARTITION BY restaurant_id 
                   ORDER BY year) AS prev_year_revenue
    FROM yearly)
    
SELECT restaurant_id, restaurant_name, year, revenue,prev_year_revenue,
ROUND((revenue - prev_year_revenue) / NULLIF(prev_year_revenue,0) * 100,2) AS yoy_growth_percent
FROM growth
ORDER BY restaurant_id, year;

