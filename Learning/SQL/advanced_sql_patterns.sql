CREATE DATABASE Employee_detail;
USE Employee_detail;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    job_title VARCHAR(50),
    dept_id INT,
    salary INT);
INSERT INTO employees VALUES
(1, 'Alice', 'Data Scientist', 1, 90000),
(2, 'Bob', 'Data Analyst', 1, 60000),
(3, 'Charlie', 'ML Engineer', 2, 110000),
(4, 'David', 'Data Engineer', 2, 95000),
(5, 'Eva', 'Data Analyst', 3, 58000),
(6, 'Frank', 'AI Researcher', NULL, 130000),
(7, 'Grace', 'ML Engineer', 2, 105000);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50));

INSERT INTO departments VALUES
(1, 'Analytics'),
(2, 'Engineering'),
(3, 'HR');

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_amount INT,
    order_date DATE);

INSERT INTO orders VALUES
(101, 1, 150, '2024-01-01'),
(102, 1, 200, '2024-01-05'),
(103, 2, 300, '2024-01-03'),
(104, 1, 100, '2024-01-10'),
(105, 3, 500, '2024-01-06');

-- (1) Return the department name and total salary paid in that department.
-- Include departments even if they have no employees.
SELECT d.dept_name , COALESCE(SUM(e.salary)) AS total_salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- (2) Return departments that have at least 2 employees, along with employee count.
SELECT d.dept_id , COUNT(e.dept_id) AS employee_count
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_id
HAVING employee_count >= 2;

-- (3) List employees whose salary is greater than the average salary of their department.
SELECT e.emp_name ,e.dept_id , e.salary 
FROM employees e
WHERE e.salary > (SELECT AVG(salary) 
				  FROM employees
                  WHERE dept_id = e.dept_id);
                
-- (4) For each department, return the top 2 highest-paid employees. Keep ties separate
WITH highest_paid AS(
SELECT dept_id,emp_name , salary,
ROW_NUMBER() OVER(PARTITION BY dept_id
				  ORDER BY salary DESC) AS rn
FROM employees)
SELECT dept_id,emp_name,salary 
FROM highest_paid 
WHERE rn <=2;

-- (5) Show each employee’s salary and the running total of salaries within their department,ordered by salary descending.
SELECT emp_name , dept_id , salary,
SUM(salary) OVER(PARTITION BY dept_id 
		         ORDER BY salary DESC) AS running_total
FROM employees
WHERE dept_id IS NOT NULL;

-- (6) Return customers who have placed more than one order, along with total order amount.
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50));
    
INSERT INTO customers VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David');  

SELECT c.customer_id , c.name ,SUM(o.order_amount) AS total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(order_id) >1;

-- (7) For each customer, rank their orders by order amount (highest first)
-- and show the difference from the previous order amount.
WITH highest_rank AS(
SELECT c.customer_id , o.order_id,o.order_amount,
LAG(o.order_amount) OVER(PARTITION BY c.customer_id 
						 ORDER BY o.order_amount DESC) AS prev_month
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id)

SELECT customer_id, order_id,order_amount,
(order_amount-prev_month) AS difference
FROM highest_rank;

-- (8) Return the 2nd highest DISTINCT salary in the company.
-- If multiple employees have it, return all of them.
WITH second_highest AS(
SELECT emp_name , salary , 
DENSE_RANK() OVER(ORDER BY salary DESC) AS en
FROM employees)
SELECT emp_name, salary 
FROM second_highest
WHERE en =2;
