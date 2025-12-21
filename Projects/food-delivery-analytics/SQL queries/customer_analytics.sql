CREATE DATABASE food_delivery;
USE food_delivery;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    signup_date DATE,
    city VARCHAR(50),
    age INT,
    gender VARCHAR(10));

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    cuisine_type VARCHAR(50),
    city VARCHAR(50),
    average_preparation_time INT,
    rating DECIMAL(3,2));

CREATE TABLE delivery_partners (
    partner_id INT PRIMARY KEY,
    partner_name VARCHAR(100),
    join_date DATE,
    rating DECIMAL(3,2),
    delivery_zone VARCHAR(50));

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_timestamp DATETIME,
    order_value DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    delivery_partner_id INT,
    order_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (delivery_partner_id) REFERENCES delivery_partners(partner_id));

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    item_name VARCHAR(100),
    item_price DECIMAL(10,2),
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id));
    

/* Customer Analytics */
-- (1) Who are the top 10 most valuable customers (based on total spending)?
SELECT c.customer_id , c.customer_name, SUM(o.order_value - o.discount_amount) AS total_spending
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id , c.customer_name 
ORDER BY total_spending DESC
LIMIT 10;

-- (2) What is the month-on-month customer growth?
WITH monthly_customers AS (
SELECT DATE_FORMAT(signup_date, '%Y-%m') AS month,
	   COUNT(*) AS new_customers
FROM customers
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')),

growth_calc AS (
SELECT month, new_customers,
LAG(new_customers) OVER (ORDER BY month) AS prev_month_customers
FROM monthly_customers)

SELECT month, new_customers, prev_month_customers,
ROUND(((new_customers - prev_month_customers) / prev_month_customers) * 100,2) AS growth_percentage
FROM growth_calc;

-- (3) What percentage of customers ordered more than once? (Repeat rate)
WITH ordered_customers AS(
SELECT customer_id , COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id),

repeated_customers AS(
SELECT COUNT(customer_id) AS repeat_customer_count
FROM ordered_customers
WHERE order_count > 1),

total_customer AS(
SELECT COUNT(*) AS total_count
FROM orders)

SELECT 
ROUND((r.repeat_customer_count / t.total_count)*100,2) AS percent_rate
FROM repeated_customers r
JOIN total_customer t;

-- (4) Which city has the highest customer activity? 
SELECT c.city, COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_orders DESC;

-- (5) What is the average order value by age group?
SELECT 
	  CASE 
          WHEN (c.age) BETWEEN 18 AND 25 THEN '18-25'
          WHEN (c.age) BETWEEN 26 AND 35 THEN '26-35'
          WHEN (c.age) BETWEEN 36 AND 45 THEN '36-45'
          WHEN (c.age) > 45 THEN '45+'
          ELSE 'unknown'
	  END AS age,
      AVG(o.order_value) AS avg_oredr_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY age
ORDER BY
    CASE
        WHEN age = '18-25' THEN 1
        WHEN age = '26-35' THEN 2
        WHEN age = '36-45' THEN 3
        WHEN age = '45+' THEN 4
        ELSE 5
    END;
