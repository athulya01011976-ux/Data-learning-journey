CREATE DATABASE sales;
USE sales;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    country VARCHAR(30));

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    price INT);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE);

INSERT INTO customers VALUES
(1,'Alice','USA'),
(2,'Bob','India'),
(3,'Charlie','USA'),
(4,'Diana','UK'),
(5,'Evan','India');

INSERT INTO products VALUES
(101,'Laptop','Electronics',1000),
(102,'Phone','Electronics',700),
(103,'Chair','Furniture',150),
(104,'Desk','Furniture',300),
(105,'Headphones','Electronics',200);

INSERT INTO orders VALUES
(1001,1,101,1,'2024-01-05'),
(1002,1,102,2,'2024-01-10'),
(1003,2,103,4,'2024-01-15'),
(1004,3,104,1,'2024-02-01'),
(1005,3,101,1,'2024-02-05'),
(1006,4,105,3,'2024-02-10');

-- List all orders along with customer name and country
SELECT o.order_id,o.customer_id,o.product_id,o.quantity,o.order_date, 
c.customer_name , c.country
FROM orders o 
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- Show all customers who have placed at least one order
SELECT DISTINCT(c.customer_id) , c.customer_name 
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- Find customers who have never placed any order
SELECT c.customer_id , c.customer_name
FROM customers c 
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL;

-- Display order details including product name, category, and total order value
SELECT o.order_id , p.product_name , p.category , o.quantity*p.price AS total_order_value 
FROM orders o
JOIN products p ON o.product_id = p.product_id;

-- Show total quantity sold for each product category
SELECT  p.category , SUM(o.quantity) AS total_quantity 
FROM orders o 
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category;

-- Find customers who purchased products from more than one category
SELECT c.customer_id, c.customer_name
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id,c.customer_name
HAVING COUNT(distinct(p.category)) > 1;

-- Show total spending per customer, including customers with zero orders
SELECT c.customer_id , c.customer_name , COALESCE(SUM(o.quantity*p.price),0) AS total_spending
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id , c.customer_name;

-- For each country, show total revenue generated
SELECT c.country, SUM(o.quantity*p.price) AS total_revenue
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.country;

-- Identify products that were ordered by customers from more than one country
SELECT p.product_name 
FROM products p 
JOIN orders o ON p.product_id = o.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.product_name
HAVING COUNT(DISTINCT(c.country)) > 1;

-- Find customers whose total spending is higher than the average spending of all customers
WITH customers_spending AS (
SELECT c.customer_id, SUM(o.quantity*p.price) AS total_spent
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id)
SELECT c.customer_id, c.total_spent
FROM customers_spending c
WHERE c.total_spent > (SELECT AVG(total_spent) FROM customers_spending);