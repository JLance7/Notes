SELECT * FROM codes_cancellation;

SELECT * FROM code_carrier;

SELECT * FROM performance;

CREATE schema testing;
CREATE TABLE testing.people (
	first_name VARCHAR(100),
	last_name VARCHAR(100),
	age int
);

INSERT INTO testing.people (first_name, last_name, age)
VALUES
	('Josh', 'Lanctot', 22),
	('Ronald', 'Weasley', 27),
	('Ronald', 'McDonald', 24),
	('Mike', 'Wazowski', 33),
	('Sullivan', NULL, 52);
	
select first_name, last_name, age from testing.people;
SELECT first_name, age from testing.people WHERE age BETWEEN 22 AND 27;
SELECT first_name, age FROM testing.people WHERE first_name IN ('Ronald', 'Sullivan');
select * from testing.people where first_name like '%ald';

-- Joining
-- create customers and orders tables
DROP TABLE IF EXISTS testing.customers;
CREATE TABLE IF NOT EXISTS testing.customers (
	cust_id SERIAL PRIMARY KEY,
	first_name VARCHAR,
	last_name VARCHAR
);

DROP TABLE IF EXISTS testing.orders;
CREATE TABLE IF NOT EXISTS testing.orders (
	order_id SERIAL PRIMARY KEY,
	cust_id int,
	order_name VARCHAR
);

-- insert
INSERT INTO testing.customers (first_name, last_name) VALUES 
	('Alan', 'B'),
	('John', 'Doe');
SELECT * FROM testing.customers;

INSERT INTO testing.orders (cust_id, order_name) VALUES
	(2, 'second order'),
	(1, 'first_order');

INSERT INTO testing.orders (cust_id, order_name) VALUES
	(3, 'third_order');

-- select
select * from testing.customers;
select * from testing.orders;

-- Inner join query (both must have cust_id)
SELECT
	cust.first_name AS cust_first,
	cust.last_name AS cust_last,
	orders.order_name
FROM
	testing.orders orders
INNER JOIN testing.customers cust -- JOIN is same as INNER JOIN  	
	ON orders.cust_id = cust.cust_id
WHERE
	cust.first_name = 'John';

-- LEFT JOIN (returns all left records, and matching right records, RIGHT JOIN is vise versa)
SELECT
	c.first_name,
	c.last_name,
	o.order_name
FROM 
	testing.orders o
LEFT JOIN testing.customers c -- can also do LEFT OUTER JOIN
	ON o.cust_id = c.cust_id;

-- FULL JOIN (returns all from left and right regardless if there is a match)
SELECT
	c.first_name,
	c.last_name,
	o.order_name
FROM 
	testing.orders o
FULL JOIN testing.customers c 
	ON o.cust_id = c.cust_id;
	
-- Implementing joins
SELECT * FROM performance;
SELECT * FROM codes_carrier;
SELECT * FROM codes_cancellation;

SELECT
	p.mkt_carrier,
	p.mkt_carrier_fl_num AS flight,
	p.origin_city_name,
	p.dest_city_name,
	cc.carrier_desc AS airline,
	p.cancellation_code,
	ca.cancel_desc
FROM
	performance p
INNER JOIN codes_carrier cc
	ON p.mkt_carrier = cc.carrier_code
LEFT JOIN codes_cancellation ca
	ON p.cancellation_code = ca.cancellation_code
WHERE
	ca.cancel_desc IS NOT NULL
AND
	p.mkt_carrier != 'UA';
	
-- Presenting and Aggregating results
CREATE TABLE IF NOT EXISTS testing.more_people (
	name character varying(50),
	state character varying(30)
);

INSERT INTO testing.more_people VALUES
	('John', 'Oregon'),
	('Alex', 'Missouri'),
	('Margaret', 'Iowa'),
	('Mike', 'Alabama'),
	('Jason', 'New Hampshire'),
	('Ian', 'Louisiana');
-- Sort
SELECT * FROM testing.more_people ORDER BY state, name;

-- Aggregate (if using aggregate function, must list all other fields in GROUP BY clause)
-- COUNT, SUM, AVG, MIN, MAX
DROP TABLE IF EXISTS testing.person;
CREATE TABLE IF NOT EXISTS testing.person(
	name varchar,
	grade_lvl varchar,
	age int
);
INSERT INTO testing.person VALUES 
	('Eliza', 'Junior', 17),
	('Jane', 'Junior',  17),
	('Leslie', 'Senior', 19),
	('Matt', 'Junior', 16),
	('Ned', 'Freshman', 15),
	('Susie', 'Junior', 18);
	
SELECT * FROM testing.person;

-- average age per grade_lvl
SELECT
	grade_lvl,
	AVG(age) as avg_age
FROM testing.person
GROUP BY grade_lvl;

-- Average departure delay and carrier description per mkt_carrier
SELECT 
	p.mkt_carrier,
	AVG(p.dep_delay_new) AS avg_departure_delay,
	cc.carrier_desc,
	AVG(p.arr_delay_new) AS avg_arrival_delay
FROM performance p
INNER JOIN codes_carrier cc
	ON p.mkt_carrier = cc.carrier_code
GROUP BY 
	p.mkt_carrier, cc.carrier_desc
ORDER BY -- to sort group by
	AVG(p.dep_delay_new) DESC;
	
-- Filter aggregate functions with HAVING keyword
SELECT * FROM testing.person;
SELECT
	grade_lvl,
	AVG(age) AS avg_age
FROM testing.person
GROUP BY 
	grade_lvl
HAVING
	AVG(age) > 17;
	
-- Putting it all together
-- Data for flights from Omaha
SELECT
	p.fl_date,
	p.mkt_carrier,
	c.carrier_desc,
	p.mkt_carrier_fl_num,
	p.origin,
	p.origin_city_name,
	p.dep_delay_new
FROM
	performance p
INNER JOIN codes_carrier c
	ON p.mkt_carrier = c.carrier_code
WHERE origin = 'OMA';

-- Average departure delay for Omaha when there is a delay
SELECT 
	AVG(dep_delay_new) AS avg_delay
FROM performance
WHERE origin = 'OMA'
	AND dep_delay_new <> 0; 
	
-- Average departure delay for each carrier
SELECT
	p.mkt_carrier,
	c.carrier_desc,
	AVG(p.dep_delay_new) AS departure_delay
FROM
	performance p
JOIN codes_carrier c 
	ON p.mkt_carrier = c.carrier_code
WHERE
	origin = 'OMA'
AND dep_delay_new <> 0
GROUP BY
	p.mkt_carrier, c.carrier_desc
HAVING -- filter aggregate function
	AVG(p.dep_delay_new) > 49 
ORDER BY
	AVG(p.dep_delay_new); -- Ascending sort

