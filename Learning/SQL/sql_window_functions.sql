
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

-- Ranking orders by value
-- For each customer, assign a unique sequential number to their orders based on order value (quantity × price) in descending order.
WITH order_value AS(
	SELECT c.customer_id , o.order_id , SUM(o.quantity*p.price) AS ordervalue,
    ROW_NUMBER() OVER(PARTITION BY o.customer_id 
				ORDER BY SUM(o.quantity * p.price) DESC) AS order_number
	FROM products p
	JOIN orders o ON p.product_id = o.product_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, o.order_id)
SELECT customer_id , order_id , ordervalue , order_number
FROM order_value;

-- Rank all customers based on their total spending, with the highest spender ranked first.
WITH highest_spender AS (
    SELECT c.customer_id, SUM(o.quantity * p.price) AS total_spending,
	RANK() OVER(ORDER BY SUM(o.quantity * p.price) DESC) AS spending_rank
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN products p ON o.product_id = p.product_id  
    GROUP BY c.customer_id)
SELECT customer_id, total_spending, spending_rank
FROM highest_spender;

-- Within each product category, assign a rank to products based on price (highest first) such that there are no gaps in ranking.
SELECT category,product_name,price,
DENSE_RANK() OVER(PARTITION BY category
				  ORDER BY price DESC) AS price_rank
FROM products;

-- Compute a running total of revenue across all orders ordered by order_date.
WITH order_details AS (
    SELECT o.order_date,o.order_id,
	(o.quantity * p.price) AS order_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id)
SELECT order_date, order_id, order_revenue,
SUM(order_revenue) OVER (ORDER BY order_date, order_id) AS cumulative_revenue
FROM order_details
ORDER BY order_date, order_id;

-- For each product category, return only the top 2 most expensive products.
WITH expensive_products AS(
	SELECT category , product_name ,
	DENSE_RANK() OVER(PARTITION BY category
					  ORDER BY price DESC) AS price
	FROM products)
SELECT category , product_name , price
FROM expensive_products 
WHERE price<=2;

-- For each customer, identify their first order based on order_date.
WITH first_order AS(
	SELECT c.customer_id, o.order_id , order_date,
	ROW_NUMBER() OVER(PARTITION BY o.customer_id
				  ORDER BY o.order_date ASC) AS date
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id)
SELECT  customer_id, order_id , order_date
FROM first_order
WHERE date <=1;

-- For each order, show the difference between that order’s value and the customer’s average order value.
WITH base_values AS(
	SELECT o.customer_id , o.order_id ,
	(o.quantity*p.price) AS order_value
	FROM orders o
    JOIN products p ON o.product_id = p.product_id),
    
averages as(
	SELECT customer_id, order_id, order_value,
	AVG(order_value) OVER(PARTITION BY customer_id) AS customer_avg_value
	FROM base_values)
    
SELECT customer_id , order_id , order_value, customer_avg_value,
(order_value - customer_avg_value) AS difference
FROM averages;
