-- Setup
CREATE TABLE public.codes_cancellation (
    cancellation_code character varying(2),
    cancel_desc character varying(45)
);

CREATE TABLE public.codes_carrier (
    carrier_code character varying(2),
    carrier_desc character varying(45)
);

CREATE TABLE public.perform_feb (
    fl_date date,
    mkt_carrier character varying(2),
    mkt_carrier_fl_num character varying(4),
    origin character varying(3),
    origin_city_name character varying(45),
    origin_state_abr character varying(2),
    dest character varying(3),
    dest_city_name character varying(45),
    dest_state_abr character varying(2),
    dep_delay_new numeric,
    arr_delay_new numeric,
    cancelled numeric,
    cancellation_code character varying(2),
    diverted numeric,
    carrier_delay numeric,
    weather_delay numeric,
    nas_delay numeric,
    security_delay numeric,
    late_aircraft_delay numeric
);

CREATE TABLE public.performance (
    fl_date date,
    mkt_carrier character varying(2),
    mkt_carrier_fl_num character varying(4),
    origin character varying(3),
    origin_city_name character varying(45),
    origin_state_abr character varying(2),
    dest character varying(3),
    dest_city_name character varying(45),
    dest_state_abr character varying(2),
    dep_delay_new numeric,
    arr_delay_new numeric,
    cancelled numeric,
    cancellation_code character varying(2),
    diverted numeric,
    carrier_delay numeric,
    weather_delay numeric,
    nas_delay numeric,
    security_delay numeric,
    late_aircraft_delay numeric
);

CREATE SCHEMA IF NOT EXISTS testing;

SELECT * FROM codes_cancellation;
SELECT * FROM codes_carrier;
SELECT * FROM perform_feb;
SELECT * FROM performance;

-- String data types
-- CHAR, VARCHAR (use), TEXT

-- String manipulation
-- Concatenation
CREATE TABLE IF NOT EXISTS testing.population(
	city TEXT,
	location TEXT,
	state TEXT,
	population TEXT
);
INSERT INTO testing.population (city, location, state, population)
	VALUES ('Louisville', 'somewhere', 'KY', '3000');

SELECT
	CONCAT(city, '-', state) AS city_state,
	location,
	population,
	CONCAT_WS(', ', city, state)
FROM 
	testing.population
WHERE
	city = 'Louisville';
	
-- more string functions
SELECT TRIM(' word ');
SELECT TRIM('w' FROM 'word');
SELECT TRIM(TRAILING ' ' FROM ' word  ');

SELECT LEFT('LongString', 4);
SELECT SPLIT_PART('USA/DC/02', '/', 2);
SELECT SUBSTRING('HelloWorld', 1, 5);

SELECT DISTINCT LOWER(mkt_carrier) AS mkt_carrier FROM performance ORDER BY mkt_carrier ASC;
SELECT
	REPLACE(origin_city_name, 'Newark', 'Replaced') AS origin_city_name
FROM 
	performance;
	
SELECT carrier_code || ': ' || carrier_desc AS my_col
	FROM codes_carrier;
	
SELECT 13/2::FLOAT;

-- More Aggregate functions
SELECT AVG(dep_delay_new) FROM performance;
SELECT COUNT(DISTINCT origin) FROM performance;

-- Aggregate functions usage finds average departure delay per airline
SELECT
	AVG(p.dep_delay_new) AS average_delay,
	c.carrier_desc
FROM performance p
JOIN codes_carrier c
	ON p.mkt_carrier = c.carrier_code
GROUP BY c.carrier_desc
HAVING AVG(p.dep_delay_new) > 12
ORDER BY c.carrier_desc;

-- Set operations (Unions, Intersections, Exceptions) combine data from multiple queries
CREATE TABLE IF NOT EXISTS testing.customers (
	cust_id SERIAL PRIMARY KEY,
	first_name VARCHAR,
	last_name VARCHAR
);
INSERT INTO testing.customers (first_name, last_name) VALUES 
	('Alan', 'B'),
	('John', 'Doe');
SELECT * FROM testing.customers;

CREATE TABLE IF NOT EXISTS testing.customers2 (
	cust_id SERIAL PRIMARY KEY,
	first_name VARCHAR,
	last_name VARCHAR
);
INSERT INTO testing.customers2 (first_name, last_name) VALUES 
	('Mike', 'Bower'),
	('Alex', 'Honnold');
SELECT * FROM testing.customers2;

-- Union (returns records from both queries)
SELECT cust.* FROM testing.customers cust
UNION
SELECT cust2.* FROM testing.customers2 cust2;

-- Exception (returns records that exist only in first query)
SELECT
	cust.*
FROM 
	testing.customers cust
EXCEPT
SELECT 
	cust2.*
FROM testing.customers2 cust2;

-- Intersect (returns records that exist in both queries)
SELECT
	cust.*
FROM 
	testing.customers cust
INTERSECT
SELECT 
	cust2.*
FROM testing.customers2 cust2;

-- Use case
SELECT * FROM performance 
WHERE origin = 'BIL' AND dest = 'SEA' AND fl_date = '2018-01-01'
UNION
SELECT * FROM performance
WHERE origin = 'BZN' AND dest = 'SEA' AND fl_date = '2018-01-01';


-- Subqueries
DROP TABLE IF EXISTS testing.stores;
CREATE TABLE IF NOT EXISTS testing.stores(
	stored_id SERIAL PRIMARY KEY,
	store_name VARCHAR(100) NOT NULL,
	store_location VARCHAR(100) NOT NULL
);
INSERT INTO testing.stores (store_name, store_location) VALUES
	('Wal-Mart', 'AR'),
	('Target', 'MN'),
	('Valu-Mart', 'MI'),
	('Grocer', 'UT');
SELECT * FROM testing.stores;

CREATE TABLE IF NOT EXISTS testing.orders(
	order_id SERIAL PRIMARY KEY,
	store_name VARCHAR(100) NOT NULL,
	order_value INTEGER NOT NULL
);
INSERT INTO testing.orders (store_name, order_value) VALUES
	('Grocer', 120),
	('Target', 550),
	('Target', 420),
	('Wal-Mart', 590);
SELECT * FROM testing.orders;

-- Subquery (inner query executes first)
SELECT a.store_name, a.store_location FROM testing.stores a 
WHERE a.store_name IN (
	SELECT store_name FROM testing.orders WHERE order_value > 500
);

SELECT fl_date,
	CONCAT(mkt_carrier, ' ', mkt_carrier_fl_num) AS flight,
	origin,
	dest,
	cancellation_code
FROM performance
WHERE cancelled = 1
	AND cancellation_code = (
		SELECT cancellation_code FROM codes_cancellation WHERE cancel_desc = 'Weather'
	);
	
SELECT a.store_name, a.order_id
FROM testing.orders a
WHERE a.order_value >= (
	SELECT AVG(order_value) FROM testing.orders
);

-- Correlated subquery (subquery kinda of relies on outer query)
-- Get data from performance on flights where the departure delay is greater than the average dep_delay for destinations SFO and ORD with given params
SELECT
	a.fl_date,
	a.mkt_carrier,
	a.mkt_carrier_fl_num,
	a.origin,
	a.dest,
	a.dep_delay_new
FROM
	performance a
WHERE
	a.fl_date = '2018-01-02'
	AND a.mkt_carrier = 'UA'
	AND a.origin = 'DEN'
	AND a.dest IN ('ORD', 'SFO')
	AND a.dep_delay_new > (
		SELECT AVG(dep_delay_new)
		FROM performance
		WHERE dep_delay_new > 0
			AND a.origin = origin
			AND a.dest = dest
			AND a.mkt_carrier = mkt_carrier
	);


-- Common table expressions
SELECT -- correlated subquery (select data where amount is greater than average amount for each customer_id)
	a.trans_id
	b.first_name, b.last_name
	a.amount
FROM
	transactions a
INNER JOIN customers b
	ON a.cust_id = b.cust_id
WHERE
	a.amount > 
		(SELECT AVG(amount)
		 FROM transactions aa
		 WHERE a.cust_id == aa.cust_id)
ORDER BY a.trans_id;

-- same thing using CTE
WITH AvgAmount AS (
	SELECT cust_id,
		AVG(amount) as avg_amount
	FROM transactions
	GROUP BY cust_id
)
SELECT
	a.trans_id
	b.first_name, b.last_name
	a.amount
FROM
	transactions a
INNER JOIN customers b
	ON a.cust_id = b.cust_id
INNER JOIN AvgAmount c
	ON a.cust_id = c.cust_id
WHERE
	a.amount > c.avg_amount;

-- Real world
WITH delays AS (
	SELECT
		origin, 
		dest, 
		AVG(dep_delay_new) AS avg_dep
	FROM performance
	WHERE mkt_carrier = 'UA'
		AND dep_delay_new > 0
	GROUP BY origin, dest
)
SELECT
	a.fl_date,
	a.mkt_carrier,
	a.mkt_carrier_fl_num,
	a.origin,
	a.dest,
	a.dep_delay_new
FROM
	performance a
INNER JOIN delays b
	ON a.origin = b.origin
	AND a.dest = b.dest
WHERE
	a.mkt_carrier = 'UA'
	AND a.dep_delay_new > b.avg_dep;
	
-- Recursive CTE
WITH RECURSIVE series (list_num) AS (
	SELECT 5
	UNION ALL
	SELECT list_num + 5
	FROM series
	WHERE list_num + 5 >= 50
)
SELECT list_num FROM series;


-- Window functions (set of table rows over which function is applied)
SELECT
	name,
	course,
	ROW_NUMBER() OVER () AS rn
FROM enrollees;

SELECT
	name,
	course,
	ROW_NUMBER() OVER (
		PARTITION BY name -- number name by each course 
		ORDER BY course
	) AS rn
FROM 
	enrollees;
	
-- RANK() is same as ROW_NUMBER() except matching rows are ranked, DENSE_RANK() avoids gaps
SELECT
	name, RANK() OVER (
		ORDER BY name -- for each matching name, give it the same number
	) AS rank
FROM enrollees;

-- DENSE_RANK() if rows tie (both have 2), it assigned one column the differentiator
SELECT
	name,
	RANK() OVER ( -- skips 2, 4, etc.
		ORDER BY name) AS rank,
	DENSE_RANK() OVER ( -- each name has same number
		ORDER BY name) AS d_rank,
	ROW_NUMBER() OVER ( -- row numbers each name/row
		ORDER BY name) AS rn
FROM enrollees;

-- applying rank functions
SELECT
	mkt_carrier,
	mkt_carrier_fl_num,
	origin,
	dest,
	arr_delay_new
FROM
	performance
WHERE fl_date = '2018-01-16'
	AND mkt_carrier = 'AA'
	AND ORIGIN = 'MCI';

SELECT
	mkt_carrier,
	mkt_carrier_fl_num,
	origin,
	dest,
	arr_delay_new,
	ROW_NUMBER() OVER (ORDER BY CAST(mkt_carrier_fl_num AS int)) AS rn, -- look at flight data for the day, and sequentially number them based on flight number
	DENSE_RANK() OVER (ORDER BY arr_delay_new DESC) AS delay_rank, -- rank numerically based on lowest to highest arrival time (DENSE_RANK fixes skipping issue with rank, use rank when you want same rank on duplicates)
	DENSE_RANK() OVER (PARTITION BY dest ORDER BY arr_delay_new DESC) AS delay_rank -- in addition to delay time, airport is important consideration. Rank arrival delay for each destination airport
FROM -- numbers all rows based on flight num
	performance
WHERE fl_date = '2018-01-16'
	AND mkt_carrier = 'AA'
	AND origin = 'MCI';
	
-- special values
SELECT
	FIRST_VALUE(name) OVER ( -- rank salary by department, highest value's name is given in col high_pay (LAST_VALUE for last val)
			PARTITION BY dept
			ORDER BY salary DESC
	) AS high_pay
FROM salaries;

-- reuse window functions
SELECT dept, 
	LAST_VALUE(name) OVER w AS low_pay,
	LAST_VALUE(salary) OVER w AS low_amt
FROM salaries
WINDOW w AS (
	PARTITION BY dept
	ORDER BY salary DESC -- rank salary from lowest to highest by department
);

-- lag and lead (lagging occurs before current row, leading occurs after)
SELECT
	sales as curr_month,
	LAG(monthly_sales, 1) OVER ( -- show current record sales, then in prev_month column it is the previous month's sales
		ORDER BY month
	) AS prev_month
FROM sales_record
ORDER BY month;

-- Aggregate functions
-- average age per group
SELECT
	grade_lvl,
	AVG(age) AS avg_age
FROM students
GROUP BY grade_lvl;

-- average age per group but also retain rows
SELECT
	grade_lvl
	AVG(age) OVER(
		PARTITION BY grade_lvl
	) AS avg_age
FROM students;

-- order of evaluation
SELECT
	a.first_name, a.last_name
FROM (SELECT first_name,
	 	last_name,
	  ROW_NUMBER() OVER (
	  	PARTITION BY dept
		ORDER BY last_name
	  ) AS rn
	FROM students) a
WHERE rn = 1; -- selects student with first last name in dept

-- LAG function 
SELECT
	fl_date,
	SUM(dep_delay_new) AS dep_delay
FROM performance
WHERE origin = 'DTW'
GROUP BY fl_date;

WITH daily_delays AS (
	SELECT
		fl_date,
		SUM(dep_delay_new) AS dep_delay
	FROM performance
	WHERE origin = 'DTW'
	GROUP BY fl_date
)
SELECT -- use lag function to compare a day to the previous day
	fl_date,
	dep_delay,
	LAG(dep_delay, 1) OVER (ORDER BY fl_date) AS prior_day_delay,
	dep_delay - LAG(dep_delay, 1) OVER (ORDER BY fl_date) AS change_delay
FROM daily_delays;

-- wrap up
SELECT fl_date,
	p.mkt_carrier,
	c.carrier_desc,
	p.mkt_carrier_fl_num,
	p.origin,
	p.origin_city_name,
	p.dest,
	p.dest_city_name,
	p.dep_delay_new,
	p.arr_delay_new
FROM performance p
JOIN codes_carrier c
	ON p.mkt_carrier = c.carrier_code
WHERE dest = 'ICT';

-- Join
SELECT 
	CAST(AVG(performance.arr_delay_new) AS int) AS avg_delay_per_carrier, 
	codes_carrier.carrier_desc
FROM performance
JOIN codes_carrier 
	ON codes_carrier.carrier_code = performance.mkt_carrier
GROUP BY codes_carrier.carrier_desc
ORDER BY avg_delay_per_carrier;

-- Union, subquery
SELECT AVG(p.arr_delay_new) AS avg_arr_delay, dest_city_name
FROM
	(SELECT fl_date,
		mkt_carrier,
		mkt_carrier_fl_num,
		origin,
		origin_city_name,
		dest,
		dest_city_name,
		dep_delay_new,
		arr_delay_new
	FROM performance 
	UNION
	SELECT fl_date,
		mkt_carrier,
		mkt_carrier_fl_num,
		origin,
		origin_city_name,
		dest,
		dest_city_name,
		dep_delay_new,
		arr_delay_new
	FROM perform_feb 
	WHERE dest = 'ICT') p
WHERE p.arr_delay_new <> 0
GROUP BY dest_city_name
ORDER BY avg_arr_delay;

-- CTE
WITH flight_info AS (
	SELECT * FROM performance
	UNION
	SELECT * FROM perform_feb
)
SELECT 
	AVG(arr_delay_new) AS avg_arr_delay
FROM flight_info;

-- correlated subquery
WITH flight_info AS (
	SELECT *, 'Jan' AS fl_month FROM performance a WHERE a.dest = 'ICT'
	UNION
	SELECT *, 'Feb as fl_month' FROM perform_feb b WHERE b.dest = 'ICT'
)
SELECT 
	p.fl_month,
	p.fl_date,
	p.mkt_carrier,
	p.arr_delay_new
FROM flight_info p
WHERE p.arr_delay_new > (
	SELECT AVG(arr_delay_new)
	FROM flight_info p
	WHERE p.mkt_carrier = mkt_carrier
);


WITH flight_info AS (
	SELECT *, 'Jan' AS fl_month FROM performance a WHERE a.dest = 'ICT'
	UNION
	SELECT *, 'Feb as fl_month' FROM perform_feb b WHERE b.dest = 'ICT'
)
SELECT
	pp.fl_month,
	pp.fl_date,
	pp.mkt_carrier,
	pp.arr_delay_new,
	REPLACE( (pp.origin_city_name || ' to ' || pp.dest_city_name), ',', '') AS route
FROM
	(SELECT 
		p.fl_month,
		p.fl_date,
		p.mkt_carrier,
		p.arr_delay_new,
	 	p.origin_city_name,
	 	p.dest_city_name,
		DENSE_RANK() OVER (PARTITION BY fl_month ORDER BY arr_delay_new DESC) AS ranking
	FROM flight_info p
	WHERE p.arr_delay_new > (
		SELECT AVG(arr_delay_new)
		FROM flight_info p
		WHERE p.mkt_carrier = mkt_carrier
	)
) pp
WHERE pp.ranking < 4; -- window function to get top 3 longest arrival delays per month

