/* Restaurant Analytics */
-- 11. Which restaurants receive the highest order volume?
SELECT r.restaurant_id , r.restaurant_name , COUNT(o.order_id) AS order_count
FROM restaurants r 
JOIN orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id , r.restaurant_name
ORDER BY order_count DESC
LIMIT 5;
/* or */

SELECT r.restaurant_id , r.restaurant_name , COUNT(o.order_id) AS order_count
FROM restaurants r 
JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id , r.restaurant_name
ORDER BY order_count DESC
LIMIT 5;

-- 12. Which cuisines perform the best by revenue?
SELECT r.cuisine_type , SUM(o.order_value - o.discount_amount) AS revenue
FROM restaurants r 
JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.cuisine_type
ORDER BY revenue DESC
LIMIT 5;

-- 13. What is the average restaurant rating across different cities?
SELECT city, AVG(rating) AS avg_rating
FROM restaurants
GROUP BY city
ORDER BY avg_rating DESC;

-- 14. Which restaurants have the highest cancellation rates?
SELECT r.restaurant_id,r.restaurant_name,
ROUND(100 * SUM(o.order_status = 'Cancelled') / COUNT(o.order_id), 2) AS cancel_percent
FROM restaurants r
JOIN orders o ON r.restaurant_id=o.restaurant_id
GROUP BY r.restaurant_id,r.restaurant_name
ORDER BY cancel_percent DESC
LIMIT 5;

/* or */
SELECT r.restaurant_id,r.restaurant_name,
ROUND(100 * SUM(o.order_status = 'Cancelled') / COUNT(o.order_id), 2) AS cancel_percent
FROM restaurants r
JOIN orders o ON r.restaurant_id=o.restaurant_id
GROUP BY r.restaurant_id,r.restaurant_name
HAVING COUNT(*) > 0
ORDER BY cancel_percent DESC
LIMIT 5;
