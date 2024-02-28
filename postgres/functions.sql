SELECT * FROM customers;
SELECT * FROM orders;

-- join tables
SELECT 
  c.firstname,
  c.lastname,
  o.orderid,
  o.netamount
FROM customers c
JOIN orders o
  ON c.customerid = o.customerid;

-- View
CREATE OR REPLACE VIEW cust_orders AS (
  SELECT 
    c.firstname,
    c.lastname,
    o.orderid,
    o.netamount
  FROM customers c
  JOIN orders o
    ON c.customerid = o.customerid
);
SELECT * FROM cust_orders;

-- function
CREATE OR REPLACE FUNCTION cust_orders()
  RETURNS TABLE (firstname VARCHAR, lastname VARCHAR, orderid INT, netamount NUMERIC)
AS $$
  SELECT 
    c.firstname,
    c.lastname,
    o.orderid,
    o.netamount
  FROM customers c
  JOIN orders o
    ON c.customerid = o.customerid
$$ LANGUAGE SQL;
SELECT * FROM cust_orders();
SELECT * FROM cust_orders();

-- input arg
CREATE OR REPLACE FUNCTION cust_order(customerid INT)
  RETURNS TABLE (firstname VARCHAR, lastname VARCHAR, orderid INT, netamount NUMERIC)
AS $$
  SELECT 
    c.firstname,
    c.lastname,
    o.orderid,
    o.netamount
  FROM customers c
  JOIN orders o
    ON c.customerid = o.customerid
  WHERE c.customerid = cust_order.customerid
$$ LANGUAGE SQL;
SELECT * FROM cust_order(42);

-- DROP FUNCTION IF EXISTS cust_orders();
-- DROP FUNCTION IF EXISTS cust_order(INT);


CREATE OR REPLACE FUNCTION my_pow(x DOUBLE PRECISION, y DOUBLE PRECISION)
  RETURNS DOUBLE PRECISION 
AS $$
  SELECT POWER(x, y);
$$ LANGUAGE SQL;
SELECT my_pow(2, 3);

-- default input parameter value
CREATE OR REPLACE FUNCTION my_default(x INT = 42)
  RETURNS DOUBLE PRECISION 
AS $$
  SELECT x;
$$ LANGUAGE SQL;
SELECT my_default();

CREATE OR REPLACE FUNCTION array_sum(int_array INT[])
  RETURNS BIGINT
AS $$
  SELECT SUM(el)
  FROM UNNEST(int_array) AS arr(el);
$$ LANGUAGE SQL;
SELECT array_sum(ARRAY[41, 42, 43]);


CREATE OR REPLACE FUNCTION array_sum_avg(int_array INT[])
  RETURNS TABLE (array_sum BIGINT, array_avg NUMERIC)
AS $$
  SELECT SUM(el), AVG(el)::NUMERIC(5, 2)
  FROM UNNEST(int_array) AS arr(el);
$$ LANGUAGE SQL;
SELECT array_sum_avg(ARRAY[41, 42, 42]) AS "Record Types";
SELECT * FROM array_sum_avg(ARRAY[41, 42, 42]);


-- output arguments (don't need RETURNS statement)
CREATE OR REPLACE FUNCTION get_cust_name(
  IN id INT,
  OUT firstname VARCHAR,
  OUT lastname VARCHAR
)
AS $$
  SELECT c.firstname, c.lastname FROM customers c
  WHERE c.customerid = id;
$$ LANGUAGE SQL;
SELECT * FROM get_cust_name(1);

-- get all customers between range inclusive by id
DROP FUNCTION IF EXISTS get_cust_by_id(INT, INT);
CREATE OR REPLACE FUNCTION get_cust_by_id(
  IN id INT,
  IN id2 INT,
  OUT customerid INT,
  OUT firstname VARCHAR,
  OUT lastname VARCHAR
)
AS $$
  SELECT customerid, firstname, lastname 
  FROM customers WHERE customerid BETWEEN id AND id2
  ORDER BY customerid ASC;
$$ LANGUAGE SQL;
SELECT * FROM get_cust_by_id(1, 10); -- only returns one (better use RETUNS TABLE instead to get all rows)


-- more functions calling
CREATE OR REPLACE FUNCTION call_me(x INT, y INT, sw BOOLEAN = TRUE)
  RETURNS INT
AS $$
  SELECT x + y WHERE sw
  UNION ALL 
  SELECT x - y WHERE NOT sw;
$$ LANGUAGE SQL;

SELECT 
  call_me(41, 42),
  call_me(x := 41, y := 42),
  call_me(41, 42, FALSE),
  call_me(41, 42, TRUE);
  




-- PL/pgsql program
DROP FUNCTION IF EXISTS get_cust_names(INT, INT);
CREATE OR REPLACE FUNCTION get_cust_names(id INT, id2 INT)
  RETURNS TABLE (firstname VARCHAR, lastname VARCHAR)
AS $$
  BEGIN
    RETURN QUERY
      SELECT c.firstname, c.lastname FROM customers c
      WHERE c.customerid BETWEEN id AND id2;
  END;
$$ LANGUAGE plpgsql;
SELECT * FROM get_cust_names(1, 5);