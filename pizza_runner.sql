-- Challenge: https://8weeksqlchallenge.com/case-study-2/
-- Solved by khadik

-- DATASET:

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
SELECT * FROM runners;

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);
INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
  SELECT * FROM customer_orders;

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);
INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
SELECT* FROM runner_orders;

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');
SELECT * FROM pizza_names;

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');
SELECT * FROM pizza_recipes;


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  SELECT * FROM pizza_toppings;
  
-- DATA CLEANING:

-- customer_orders:

DROP TABLE IF EXISTS co_fix;
CREATE TEMPORARY TABLE co_fix SELECT order_id, customer_id, pizza_id, order_time,
CASE WHEN 
		exclusions = '' THEN '0'
	 WHEN
		exclusions = 'null' THEN '0'
	 WHEN 
		exclusions IS NULL THEN '0'
	 ELSE exclusions
	 END AS exclusions_fix,
CASE WHEN 
		extras = '' THEN '0'
	 WHEN 
		extras = 'null' THEN '0'
	 WHEN
		extras IS NULL THEN '0'
	 ELSE extras
	 END AS extras_fix
FROM customer_orders;
ALTER TABLE co_fix ADD index_ INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
SELECT * FROM co_fix;

-- runner_orders:

DROP TABLE IF EXISTS ro_fix;
CREATE TEMPORARY TABLE ro_fix SELECT order_id, runner_id,
CASE WHEN 
		pickup_time = '' THEN NULL
	 WHEN
		pickup_time = 'null' THEN NULL
	 ELSE pickup_time
	 END AS pickup_time_fix,
CASE WHEN 
		distance = '' THEN 0
	 WHEN 
		distance = 'null' THEN 0
	 WHEN
		distance IS NULL THEN 0
	 WHEN 
		distance like '%km' THEN TRIM('km' FROM distance)
	 ELSE distance
	 END AS distance_fix,
CASE WHEN 
		duration = '' THEN 0
	 WHEN 
		duration = 'null' THEN 0
	 WHEN
		duration IS NULL THEN 0
	 WHEN
		duration like '%mins' THEN TRIM('mins' FROM duration)
	 WHEN
		duration like '%minutes' THEN TRIM('minutes' FROM duration)
	 WHEN
		duration like '%minute' THEN TRIM('minute' FROM duration)
	 ELSE duration
	 END AS duration_fix,
CASE WHEN 
		cancellation = '' THEN 'None'
	 WHEN 
		cancellation = 'null' THEN 'None'
	 WHEN
		cancellation IS NULL THEN 'None'
	 ELSE cancellation
	 END AS cancellation_fix
FROM runner_orders;
DESCRIBE ro_fix;
ALTER TABLE ro_fix
 MODIFY COLUMN pickup_time_fix timestamp,
 MODIFY COLUMN distance_fix decimal null,
 MODIFY COLUMN duration_fix int null;
SELECT * FROM ro_fix;

-- pizza_recipes:
 
-- Splitting the data from a cell into multiple rows is too complicated in mysql. 
-- To make it easier, use jupyter notebook as follows:

-- import numpy as np
-- import pandas as pd
-- recipes = pd.read_csv('pizza_recipes.csv')
-- recipes_fix=(recipes.set_index(['pizza_id'])
-- .apply(lambda x: x.str.split(',').explode())
-- .reset_index())
-- recipes_fix.to_csv("recipes_fix.csv", index=False)

SELECT * FROM recipes_fix;

--  A. Pizza Metrics Analysis

-- 1. How many pizzas were ordered?

SELECT COUNT(order_id) pizzas_ordered FROM co_fix;

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) uniqe_orders FROM co_fix;

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(pickup_time_fix) successful_orders FROM ro_fix GROUP BY runner_id;

-- 4. How many of each type of pizza was delivere?

WITH pizza AS (
	SELECT C.pizza_id, R.pickup_time_fix FROM co_fix C
    JOIN ro_fix R ON C.order_id = R.order_id
) 
SELECT pizza_id, COUNT(pickup_time_fix) pizzas_delivered FROM pizza GROUP BY pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

WITH pizza AS (
	SELECT C.customer_id, N.pizza_name FROM co_fix C
    JOIN pizza_names N ON C.pizza_id = N.pizza_id
) 
SELECT customer_id, pizza_name, COUNT(pizza_name) pizzas_ordered FROM pizza 
GROUP BY customer_id, pizza_name ORDER BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

WITH pizza AS (
	SElECT COUNT(C.order_id) order_count FROM co_fix C
	JOIN ro_fix R ON C.order_id = R.order_id 
    WHERE R.pickup_time_fix IS NOT NULL GROUP BY C.order_id  
)
SELECT MAX(order_count) max_order FROM pizza;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT C.customer_id, 
SUM(CASE WHEN C.exclusions_fix > 0 OR C.extras_fix > 0 THEN 1 
	ELSE 0 END) atleast_1change,
SUM(CASE WHEN C.exclusions_fix = 0 AND C.extras_fix = 0 THEN 1
	ELSE 0 END) no_changes
FROM co_fix C JOIN ro_fix R ON C.order_id = R.order_id
WHERE R.pickup_time_fix IS NOT NULL
GROUP BY C.customer_id;
    
-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT
SUM(CASE WHEN C.exclusions_fix > 0 AND C.extras_fix > 0 THEN 1 
	ELSE 0 END) pizza_count_exclandext
FROM co_fix C JOIN ro_fix R ON C.order_id = R.order_id
WHERE R.pickup_time_fix IS NOT NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT HOUR(order_time) hour, COUNT(order_id) pizza_count 
FROM co_fix GROUP BY hour ORDER BY hour;

-- 10. What was the volume of orders for each day of the week?

SELECT DAYNAME(order_time) day, COUNT(order_id) pizza_count 
FROM co_fix GROUP BY day;

-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT WEEK(registration_date) week, COUNT(runner_id) runner_count FROM runners GROUP BY week;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id, AVG(MINUTE(pickup_time_fix)) avg_time FROM ro_fix GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH pizza AS (
	SELECT C.order_id, COUNT(C.order_id) pizza_count, 
	TIMESTAMPDIFF(MINUTE, C.order_time, R.pickup_time_fix) time
	FROM co_fix C JOIN ro_fix R ON C.order_id = R.order_id 
    WHERE R.pickup_time_fix IS NOT NULL GROUP BY C.order_id, C.order_time, R.pickup_time_fix
)
SELECT pizza_count, AVG(time) avg_time FROM pizza GROUP BY pizza_count;

-- Answer: Yes there is

-- 4. What was the average distance travelled for each customer?

SELECT C.customer_id, AVG(R.distance_fix) avg_dist FROM co_fix C 
JOIN ro_fix R ON C.order_id = R.order_id WHERE R.distance_fix > 0 GROUP BY C.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration_fix) - MIN(duration_fix) diff FROM ro_fix WHERE duration_fix > 0;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT order_id, runner_id, distance_fix * 60 / duration_fix speed_hour FROM ro_fix WHERE duration_fix > 0;

-- Answer: Runner 2 has an oddity in its delivery because the difference in speed between the fastest and the slowest is too big

-- 7. What is the successful delivery percentage for each runner?

WITH pizza AS (
SELECT runner_id, 
    SUM(CASE WHEN distance_fix > 0 THEN 1 ELSE 0 END) success_count,
    COUNT(order_id) order_count
    FROM ro_fix GROUP BY runner_id
)
SELECT *, success_count*100/order_count success_perc FROM pizza;

-- C. Ingredient Optimisation

-- 1. What are the standard ingredients for each pizza?

SELECT R.pizza_id, T.topping_name ingredients FROM recipes_fix R JOIN pizza_toppings T ON T.topping_id = R.toppings;

-- 2. What was the most commonly added extra?

SElECT 
	SUM(CASE WHEN extras_fix LIKE '%1%' THEN 1 ELSE 0 END) "1",
    SUM(CASE WHEN extras_fix LIKE '%2%' THEN 1 ELSE 0 END) "2",
    SUM(CASE WHEN extras_fix LIKE '%3%' THEN 1 ELSE 0 END) "3",
    SUM(CASE WHEN extras_fix LIKE '%4%' THEN 1 ELSE 0 END) "4",
    SUM(CASE WHEN extras_fix LIKE '%5%' THEN 1 ELSE 0 END) "5",
    SUM(CASE WHEN extras_fix LIKE '%6%' THEN 1 ELSE 0 END) "6",
    SUM(CASE WHEN extras_fix LIKE '%7%' THEN 1 ELSE 0 END) "7",
    SUM(CASE WHEN extras_fix LIKE '%8%' THEN 1 ELSE 0 END) "8",
    SUM(CASE WHEN extras_fix LIKE '%9%' THEN 1 ELSE 0 END) "9",
    SUM(CASE WHEN extras_fix LIKE '%10%' THEN 1 ELSE 0 END) "10",
    SUM(CASE WHEN extras_fix LIKE '%11%' THEN 1 ELSE 0 END) "11",
    SUM(CASE WHEN extras_fix LIKE '%12%' THEN 1 ELSE 0 END) "12"
FROM co_fix;

-- OR

DROP PROCEDURE IF EXISTS extras_count;
DELIMITER //
CREATE PROCEDURE extras_count()
BEGIN
	DECLARE num INT default 1;
	DROP TABLE IF EXISTS table_1;
	CREATE TABLE table_1 (extras INT, extras_count INT);
WHILE num <= 12 DO
    INSERT INTO table_1(extras, extras_count)
    SELECT CASE WHEN extras_fix LIKE concat("%",num,"%") THEN num ELSE num END extras,
	SUM(CASE WHEN extras_fix LIKE concat("%",num,"%") THEN 1 ELSE 0 END) FROM co_fix GROUP BY extras;
    SET num = num + 1;
END WHILE;
	SELECT * FROM table_1;
END //
DELIMITER ;

CALL extras_count;

-- 3. What was the most common exclusion?

SElECT 
	SUM(CASE WHEN exclusions_fix LIKE '%1%' THEN 1 ELSE 0 END) "1",
    SUM(CASE WHEN exclusions_fix LIKE '%2%' THEN 1 ELSE 0 END) "2",
    SUM(CASE WHEN exclusions_fix LIKE '%3%' THEN 1 ELSE 0 END) "3",
    SUM(CASE WHEN exclusions_fix LIKE '%4%' THEN 1 ELSE 0 END) "4",
    SUM(CASE WHEN exclusions_fix LIKE '%5%' THEN 1 ELSE 0 END) "5",
    SUM(CASE WHEN exclusions_fix LIKE '%6%' THEN 1 ELSE 0 END) "6",
    SUM(CASE WHEN exclusions_fix LIKE '%7%' THEN 1 ELSE 0 END) "7",
    SUM(CASE WHEN exclusions_fix LIKE '%8%' THEN 1 ELSE 0 END) "8",
    SUM(CASE WHEN exclusions_fix LIKE '%9%' THEN 1 ELSE 0 END) "9",
    SUM(CASE WHEN exclusions_fix LIKE '%10%' THEN 1 ELSE 0 END) "10",
    SUM(CASE WHEN exclusions_fix LIKE '%11%' THEN 1 ELSE 0 END) "11",
    SUM(CASE WHEN exclusions_fix LIKE '%12%' THEN 1 ELSE 0 END) "12"
FROM co_fix;

-- OR

DROP PROCEDURE IF EXISTS exclusions_count;
DELIMITER //
CREATE PROCEDURE exclusions_count()
BEGIN
	DECLARE num INT default 1;
	DROP TABLE IF EXISTS table_1;
	CREATE TABLE table_1 (exclusions INT, exclusions_count INT);
WHILE num <= 12 DO
    INSERT INTO table_1(exclusions, exclusions_count)
    SELECT CASE WHEN exclusions_fix LIKE concat("%",num,"%") THEN num ELSE num END exclusions,
	SUM(CASE WHEN exclusions_fix LIKE concat("%",num,"%") THEN 1 ELSE 0 END) FROM co_fix GROUP BY exclusions;
    SET num = num + 1;
END WHILE;
	SELECT * FROM table_1;
END //
DELIMITER ;

CALL exclusions_count;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--		Meat Lovers
--		Meat Lovers - Exclude BBQ Sauce
--		Meat Lovers - Extra Bacon
--		Meat Lovers - Exclude Cheese - Extra Bacon, Chicken

SET SQL_SAFE_UPDATES = 0;

DROP PROCEDURE IF EXISTS record;
DELIMITER //
CREATE PROCEDURE record()
BEGIN
	DECLARE num INT default 1;
	DROP TABLE IF EXISTS table_1;
	CREATE TABLE table_1 (order_item VARCHAR(100));
WHILE num <= (SELECT COUNT(order_id) FROM co_fix) DO
	DROP TABLE IF EXISTS table_2;
    CREATE TABLE table_2 (exclusions_fix VARCHAR(10), extras_fix VARCHAR(10), value VARCHAR(100));
	INSERT INTO table_2 (exclusions_fix, extras_fix, value) 
		SELECT exclusions_fix, extras_fix, CASE WHEN pizza_id = 1 THEN 'Meat Lovers ' ELSE 'Vegetarian ' END FROM co_fix WHERE index_ = num;
-- exclude
		UPDATE table_2 SET value = CONCAT(value,'- Exclude ') WHERE exclusions_fix NOT LIKE '%0%';
		UPDATE table_2 SET value = CONCAT(value,'Bacon ') WHERE exclusions_fix LIKE '%1%';
		UPDATE table_2 SET value = CONCAT(value,'BBQ Sauce ') WHERE exclusions_fix LIKE '%2%';
		UPDATE table_2 SET value = CONCAT(value,'Beef ') WHERE exclusions_fix LIKE '%3%';
		UPDATE table_2 SET value = CONCAT(value,'Cheese ') WHERE exclusions_fix LIKE '%4%';
		UPDATE table_2 SET value = CONCAT(value,'Chicken ') WHERE exclusions_fix LIKE '%5%';
        UPDATE table_2 SET value = CONCAT(value,'Mushrooms ') WHERE exclusions_fix LIKE '%6%';
        UPDATE table_2 SET value = CONCAT(value,'Onions ') WHERE exclusions_fix LIKE '%7%';
        UPDATE table_2 SET value = CONCAT(value,'Pepperoni ') WHERE exclusions_fix LIKE '%8%';
        UPDATE table_2 SET value = CONCAT(value,'Peppers ') WHERE exclusions_fix LIKE '%9%';
        UPDATE table_2 SET value = CONCAT(value,'Salami ') WHERE exclusions_fix LIKE '%10%';
        UPDATE table_2 SET value = CONCAT(value,'Tomatoes ') WHERE exclusions_fix LIKE '%11%';
        UPDATE table_2 SET value = CONCAT(value,'Tomato Sauce ') WHERE exclusions_fix LIKE '%12%';
-- extra
		UPDATE table_2 SET value = CONCAT(value,'- Extra ') WHERE extras_fix NOT LIKE '%0%';
		UPDATE table_2 SET value = CONCAT(value,'Bacon ') WHERE extras_fix LIKE '%1%';
		UPDATE table_2 SET value = CONCAT(value,'BBQ Sauce ') WHERE extras_fix LIKE '%2%';
		UPDATE table_2 SET value = CONCAT(value,'Beef ') WHERE extras_fix LIKE '%3%';
		UPDATE table_2 SET value = CONCAT(value,'Cheese ') WHERE extras_fix LIKE '%4%';
		UPDATE table_2 SET value = CONCAT(value,'Chicken ') WHERE extras_fix LIKE '%5%';
        UPDATE table_2 SET value = CONCAT(value,'Mushrooms ') WHERE extras_fix LIKE '%6%';
        UPDATE table_2 SET value = CONCAT(value,'Onions ') WHERE extras_fix LIKE '%7%';
        UPDATE table_2 SET value = CONCAT(value,'Pepperoni ') WHERE extras_fix LIKE '%8%';
        UPDATE table_2 SET value = CONCAT(value,'Peppers ') WHERE extras_fix LIKE '%9%';
        UPDATE table_2 SET value = CONCAT(value,'Salami ') WHERE extras_fix LIKE '%10%';
        UPDATE table_2 SET value = CONCAT(value,'Tomatoes ') WHERE extras_fix LIKE '%11%';
        UPDATE table_2 SET value = CONCAT(value,'Tomato Sauce ') WHERE extras_fix LIKE '%12%';
    INSERT INTO table_1 (order_item) SELECT value FROM table_2;
    SET num = num + 1;
END WHILE;
	SELECT * FROM table_1;
END //
DELIMITER ;

CALL record;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order 
--    from the customer_orders table and add a 2x in front of any relevant ingredients
--    For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

SET SQL_SAFE_UPDATES = 0;

DROP PROCEDURE IF EXISTS recipe;
DELIMITER //
CREATE PROCEDURE recipe()
BEGIN
	DECLARE i INT default 1;
	DROP TABLE IF EXISTS table_1;
	CREATE TABLE table_1 (order_id INT, ingredients VARCHAR(200));
WHILE i <= (SELECT COUNT(order_id) FROM co_fix) DO
	DROP TABLE IF EXISTS table_2;
    CREATE TABLE table_2 (order_id INT, pizza_id INT, exclusions_fix VARCHAR(10), extras_fix VARCHAR(10), value VARCHAR(200));
	INSERT INTO table_2 (order_id, pizza_id, exclusions_fix, extras_fix, value) 
		SELECT order_id, pizza_id, exclusions_fix, extras_fix, 
        CASE WHEN pizza_id = 1 THEN 'Meat Lovers : ' 
        ELSE 'Vegetarian : ' END FROM co_fix WHERE index_ = i;
-- Meat Lovers
		UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%1%' AND pizza_id = 1 THEN CONCAT(value,'2xBacon') 
										WHEN pizza_id = 1 AND exclusions_fix NOT LIKE '%1%' THEN CONCAT(value,'Bacon') 
                                        ELSE value END;
		UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%2%' AND pizza_id = 1 THEN CONCAT(value,', 2xBBQ Sauce') 
										WHEN pizza_id = 1 AND exclusions_fix NOT LIKE '%2%' THEN CONCAT(value,', BBQ Sauce') 
                                        ELSE value END;
		UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%3%' AND pizza_id = 1 THEN CONCAT(value,', 2xBeef') 
										WHEN pizza_id = 1 AND exclusions_fix NOT LIKE '%3%' THEN CONCAT(value,', Beef') 
                                        ELSE value END;
		UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%4%' AND pizza_id = 1 THEN CONCAT(value,', 2xCheese') 
										WHEN pizza_id = 1 AND exclusions_fix NOT LIKE '%4%' THEN CONCAT(value,', Cheese') 
                                        ELSE value END;
		UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%5%' AND pizza_id = 1 THEN CONCAT(value,', 2xChicken') 
										WHEN pizza_id = 1 AND exclusions_fix NOT LIKE '%5%' THEN CONCAT(value,', Chicken') 
                                        ELSE value END;
        UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%6%' AND pizza_id = 1 THEN CONCAT(value,', 2xMushrooms') 
										WHEN pizza_id = 1 AND exclusions_fix NOT LIKE '%6%' THEN CONCAT(value,', Mushrooms') 
                                        ELSE value END;
        UPDATE table_2 SET value = CONCAT(value,', Onions') WHERE extras_fix LIKE '%7%' AND pizza_id = 1;
        UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%8%' AND pizza_id = 1 THEN CONCAT(value,', 2xPepperoni') 
										WHEN pizza_id = 1 AND exclusions_fix NOT LIKE '%8%' THEN CONCAT(value,', Pepperoni') 
                                        ELSE value END;
        UPDATE table_2 SET value = CONCAT(value,', Peppers') WHERE extras_fix LIKE '%9%' AND pizza_id = 1;
        UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%10%' AND pizza_id = 1 THEN CONCAT(value,', 2xSalami') 
										WHEN pizza_id = 1 AND exclusions_fix NOT LIKE '%10%' THEN  CONCAT(value,', Salami ') 
                                        ELSE value END;
		UPDATE table_2 SET value = CONCAT(value,', Tomatoes') WHERE extras_fix LIKE '%11%' AND pizza_id = 1;
        UPDATE table_2 SET value = CONCAT(value,', Tomato Sauce') WHERE extras_fix LIKE '%12%' AND pizza_id = 1;
-- Vegetarian
		UPDATE table_2 SET value = CONCAT(value,'Bacon, ') WHERE extras_fix LIKE '%1%' AND pizza_id = 2;
		UPDATE table_2 SET value = CONCAT(value,'BBQ Sauce, ') WHERE extras_fix LIKE '%2%' AND pizza_id = 2;
		UPDATE table_2 SET value = CONCAT(value,'Beef, ') WHERE extras_fix LIKE '%3%' AND pizza_id = 2;
		UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%4%' AND pizza_id = 2 THEN CONCAT(value,'2xCheese, ') 
										WHEN pizza_id = 2 AND exclusions_fix NOT LIKE '%4%' THEN CONCAT(value,'Cheese, ') 
                                        ELSE value END;
		UPDATE table_2 SET value = CONCAT(value,'Chicken, ') WHERE extras_fix LIKE '%5%' AND pizza_id = 2;
        UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%6%' AND pizza_id = 2 THEN CONCAT(value,'2xMushrooms, ') 
										WHEN pizza_id = 2 AND exclusions_fix NOT LIKE '%6%' THEN CONCAT(value,'Mushrooms, ') 
                                        ELSE value END;
        UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%7%' AND pizza_id = 2 THEN CONCAT(value,'2xOnions, ') 
										WHEN pizza_id = 2 AND exclusions_fix NOT LIKE '%7%' THEN CONCAT(value,'Onions, ') 
                                        ELSE value END;
        UPDATE table_2 SET value = CONCAT(value,'Pepperoni, ') WHERE extras_fix LIKE '%8%' AND pizza_id = 2;
        UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%9%' AND pizza_id = 2 THEN CONCAT(value,'2xPeppers, ') 
										WHEN pizza_id = 2 AND exclusions_fix NOT LIKE '%9%' THEN CONCAT(value,'Peppers, ') 
                                        ELSE value END;
        UPDATE table_2 SET value = CONCAT(value,'Salami, ') WHERE extras_fix LIKE '%10%' AND pizza_id = 2;
        UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%11%' AND pizza_id = 2 THEN CONCAT(value,'2xTomatoes, ') 
										WHEN pizza_id = 2 AND exclusions_fix NOT LIKE '%11%' THEN CONCAT(value,'Tomatoes, ') 
                                        ELSE value END;
        UPDATE table_2 SET value = CASE WHEN extras_fix LIKE '%12%' AND pizza_id = 2 THEN CONCAT(value,'2xTomato Sauce') 
										WHEN pizza_id = 2 AND exclusions_fix NOT LIKE '%12%' THEN CONCAT(value,'Tomato Sauce') 
                                        ELSE value END;
    INSERT INTO table_1 (order_id, ingredients) SELECT order_id, value FROM table_2;
    SET i = i + 1;
END WHILE;
	SELECT * FROM table_1;
END //
DELIMITER ;

CALL recipe;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH quantity AS (
SELECT C.index_, T.topping_name, R.toppings, C.exclusions_fix, C.extras_fix FROM co_fix C 
JOIN recipes_fix R ON C.pizza_id = R.pizza_id 
JOIN pizza_toppings T ON R.toppings = T.topping_id
JOIN ro_fix RO ON C.order_id = RO.order_id
WHERE RO.duration_fix != 0
)
SELECT topping_name, 
SUM(CASE WHEN exclusions_fix LIKE CONCAT('%',toppings,'%') THEN 0 
WHEN extras_fix LIKE CONCAT('%',toppings,'%') THEN 2 ELSE 1 END) quantity 
FROM quantity GROUP BY topping_name ORDER BY quantity DESC;

-- D. Pricing and Ratings

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes
--    how much money has Pizza Runner made so far if there are no delivery fees?

WITH revenue AS (
SELECT C.pizza_id FROM co_fix C JOIN ro_fix R ON C.order_id = R.order_id WHERE distance_fix != 0
)
SELECT SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) total FROM revenue;

-- 2. What if there was an additional $1 charge for any pizza extras? (Add cheese is $1 extra)

WITH revenue AS (
SELECT (CASE WHEN C.pizza_id = 1 THEN 12 ELSE 10 END) pizza, extras_fix 
FROM co_fix C JOIN ro_fix R ON C.order_id = R.order_id WHERE distance_fix != 0
)
SELECT SUM(CASE WHEN extras_fix NOT LIKE CONCAT('%',0,'%') THEN pizza + 1 
				WHEN extras_fix LIKE CONCAT('%',1,'%') THEN pizza + 2 ELSE pizza END) total
FROM revenue;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
--    how would you design an additional table for this new dataset - generate a schema for this new table and insert 
--    your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (order_id INTEGER, rating INTEGER);
INSERT INTO ratings (order_id ,rating) VALUES 
(1,1),
(2,3),
(3,5),
(4,2),
(5,4),
(6,1),
(7,3),
(8,5),
(9,2),
(10,4); 
SELECT * FROM ratings;

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--    customer_id
--    order_id
--    runner_id
--    rating
--    order_time
--    pickup_time
--    Time between order and pickup
--    Delivery duration
--    Average speed
--    Total number of pizzas

SELECT C.customer_id, C.order_id, RO.runner_id, R.rating, C.order_time, RO.pickup_time_fix pickup_time, 
	   TIMESTAMPDIFF(MINUTE, C.order_time, RO.pickup_time_fix) pickup_duration, RO.duration_fix delivery_duration, 
       ROUND(RO.distance_fix/RO.duration_fix*60) avg_speed, COUNT(pizza_id) total_pizzas
FROM co_fix C LEFT JOIN ro_fix RO ON C.order_id = RO.order_id
			  LEFT JOIN ratings R ON C.order_id = R.order_id
WHERE RO.pickup_time_fix IS NOT NULL 
GROUP BY customer_id, C.order_id, runner_id, rating, order_time, pickup_time, delivery_duration, ROUND(distance_fix/duration_fix*60);

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with 
--    no cost for extras and each runner is paid $0.30 per kilometre traveled
--    how much money does Pizza Runner have left over after these deliveries?

WITH revenue AS (
SELECT (CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) pizza, distance_fix
FROM co_fix C JOIN ro_fix R ON C.order_id = R.order_id WHERE distance_fix != 0
)
SELECT SUM(pizza - distance_fix * 0.3) total FROM revenue;