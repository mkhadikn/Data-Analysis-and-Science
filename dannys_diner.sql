-- case study: https://8weeksqlchallenge.com/case-study-1/

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
SELECT * FROM sales;

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
SELECT * FROM menu;

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
SELECT * FROM members;

-- 1. What is the total amount each customer spent at the restaurant?

WITH price_sales AS (
	SELECT customer_id, price FROM sales JOIN menu ON sales.product_id = menu.product_id
)
SELECT customer_id, SUM(price) total_spent FROM price_sales GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT(order_date)) visit_days FROM sales GROUP BY customer_id;

-- additional answer for diff questions:

WITH datediff AS (
SELECT customer_id, min(order_date) first_order, max(order_date) last_order FROM sales GROUP BY customer_id
)
SELECT customer_id, DATEDIFF(last_order, first_order) duration FROM datediff;

-- 3. What was the first item from the menu purchased by each customer?

WITH add_row AS (
	SELECT customer_id, order_date, product_id, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) num_of_row FROM sales
), 
first_item AS (
SELECT customer_id, product_name, order_date FROM add_row 
JOIN menu ON add_row.product_id = menu.product_id 
WHERE num_of_row = 1
)
SELECT * FROM first_item;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT COUNT(customer_id) times_purchased, product_name FROM sales 
JOIN menu ON sales.product_id = menu.product_id 
GROUP BY product_name ORDER BY times_purchased DESC;

-- 5. Which item was the most popular for each customer?

SELECT customer_id, COUNT(product_name) times_purchased, product_name FROM sales 
JOIN menu ON sales.product_id = menu.product_id 
GROUP BY customer_id, product_name ORDER BY customer_id, times_purchased DESC;

-- 6. Which item was purchased first by the customer after they became a member?

WITH join_member AS (
SELECT S.customer_id, S.order_date, MN.product_name, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date DESC) row_ FROM sales S 
JOIN menu MN ON S.product_id = MN.product_id
JOIN members M ON S.customer_id = M.customer_id 
WHERE S.order_date >= M.join_date
)
SELECT customer_id, product_name FROM join_member WHERE row_ = 1;

-- 7. Which item was purchased just before the customer became a member?

WITH join_member AS (
SELECT S.customer_id, S.order_date, MN.product_name, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date DESC) row_ FROM sales S 
JOIN menu MN ON S.product_id = MN.product_id
JOIN members M ON S.customer_id = M.customer_id 
WHERE S.order_date < M.join_date
)
SELECT customer_id, product_name FROM join_member WHERE row_ = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

WITH join_member AS (
SELECT S.customer_id, S.order_date, MN.price FROM sales S 
JOIN menu MN ON S.product_id = MN.product_id
JOIN members M ON S.customer_id = M.customer_id 
WHERE S.order_date < M.join_date

)
SELECT customer_id, COUNT(customer_id) total_item, SUM(price) amount_spent FROM join_member GROUP BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH spent AS (
SELECT customer_id, S.product_id, price FROM sales S JOIN menu M ON S.product_id = M.product_id
)
SELECT customer_id,
SUM(CASE 
	WHEN product_id = 1 THEN price*20
	ELSE price*10
END) points
FROM spent GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--     not just sushi - how many points do customer A and B have at the end of January?

SELECT S.customer_id,
SUM(CASE 
	WHEN (DATEDIFF(order_date, join_date) BETWEEN 0 AND 7) OR S.product_id = 1 THEN price*20
    ELSE price*10
END) points
FROM sales S 
JOIN menu M ON S.product_id = M.product_id
JOIN members MM ON S.customer_id = MM.customer_id
WHERE order_date < '2021-02-01'
GROUP BY customer_id;

-- By : mkhadikn
