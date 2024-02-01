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


-- Window functions