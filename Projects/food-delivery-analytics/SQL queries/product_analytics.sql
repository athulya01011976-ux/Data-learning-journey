/* Product or Item Analytics */
-- 19. What are the top 10 most ordered items?
SELECT i.item_name, COUNT(*) AS order_count
FROM order_items i
JOIN orders o ON i.order_id = o.order_id
GROUP BY i.item_name
ORDER BY order_count DESC
LIMIT 10;

/* OR */
SELECT i.item_name,SUM(i.quantity) AS total_ordered
FROM order_items i
JOIN orders o ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY i.item_name
ORDER BY total_ordered DESC
LIMIT 10;

-- 20. What is the contribution of each item to total revenue?
SELECT i.item_name , SUM(i.quantity * i.item_price) AS total_revenue
FROM order_items i
JOIN orders o ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY i.item_name
ORDER BY total_revenue DESC
LIMIT 10;
