/* Delivery Partner Analytics */
-- 15. Which delivery partners completed the most deliveries?
SELECT d.partner_id , d.partner_name , COUNT(*) AS counts
FROM delivery_partners d
JOIN orders o ON d.partner_id = o.delivery_partner_id
WHERE o.order_status = 'Delivered'
GROUP BY d.partner_id , d.partner_name 
ORDER BY counts DESC
LIMIT 10;

-- 16. Which delivery zones have the slowest delivery times?
ALTER TABLE orders
ADD COLUMN delivery_timestamp DATETIME;

SET SQL_SAFE_UPDATES = 0;

UPDATE orders 
SET delivery_timestamp = DATE_ADD(order_timestamp, INTERVAL FLOOR(20 + RAND()*20) MINUTE);

SELECT d.delivery_zone , 
AVG(TIMESTAMPDIFF(MINUTE, o.order_timestamp, o.delivery_timestamp)) AS avg_delivery_time
FROM delivery_partners d
JOIN orders o ON d.partner_id = o.delivery_partner_id
WHERE o.order_status = 'Delivered'
GROUP BY d.delivery_zone
ORDER BY avg_delivery_time DESC;

-- 17. Do low-rated delivery partners have higher cancellation rates?
SELECT d.partner_id , d.partner_name , d.rating AS partner_rating,
ROUND(SUM(o.order_status = 'Cancelled') * 100 /
	  COUNT(o.delivery_partner_id),2) AS cancellation_rate
FROM delivery_partners d 
JOIN orders o ON d.partner_id = o.delivery_partner_id
GROUP BY d.partner_id, d.partner_name, d.rating
ORDER BY cancellation_rate DESC 
LIMIT 10;

-- 18. Which delivery partners bring the highest revenue?
SELECT d.partner_id , d.partner_name , SUM(o.order_value - o.discount_amount) AS revenue
FROM delivery_partners d 
JOIN orders o ON d.partner_id = o.delivery_partner_id
WHERE o.order_status = 'Delivered'
GROUP BY d.partner_id , d.partner_name
ORDER BY revenue DESC
LIMIT 10;
