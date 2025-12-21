/* Order & Revenue Analytics */
-- 6. What are the peak order days and peak order hours?
SELECT DAYNAME(order_timestamp) AS peak_days ,
       HOUR(order_timestamp) AS peak_hours,
       COUNT(order_id) AS order_count
FROM orders
GROUP BY peak_days, peak_hours
ORDER BY order_count DESC
LIMIT 10;

-- 7. What percentage of orders were cancelled?
WITH cancelled AS(
SELECT COUNT(order_id) AS cancelled
FROM orders
WHERE order_status = 'Cancelled'),

total_count AS(
SELECT COUNT(order_id) AS total_orders_placed
FROM orders)

SELECT 
ROUND((c.cancelled / t.total_orders_placed)*100,2) AS cancel_percent
FROM cancelled c 
JOIN total_count t;

--- OR ---
SELECT 
ROUND(100 * SUM(order_status = 'Cancelled') / COUNT(order_id), 2) AS cancel_percent
FROM orders;

-- OR (the count of order:cancelled) --

SELECT COUNT(*) AS cancelled
FROM orders
WHERE LOWER(order_status) LIKE '%cancel%';

-- 8. Calculate revenue loss due to cancellations and returns.
SELECT SUM(order_value) AS total_revenue_loss
FROM orders
WHERE order_status IN ('Cancelled','Returned');

-- OR --

SELECT 
    SUM(order_value - discount_amount) AS net_loss,
    SUM(order_value) AS gross_loss
FROM orders
WHERE LOWER(order_status) IN ('cancelled','returned');


-- 9. What is the total revenue after discount?
SELECT SUM(order_value - discount_amount) AS total_revenue
FROM orders
WHERE LOWER(order_status) = 'delivered';

-- 10. What is the average discount given per order?
SELECT AVG(discount_amount) AS average_discount
FROM orders;
