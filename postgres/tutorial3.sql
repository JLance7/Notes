-- DDL (data definition lang)
CREATE DATABASE testing;

-- DCL (data control lang)
GRANT SELECT ON customers to postgres;
GRANT ALL ON customers to PUBLIC;
REVOKE ALL on customers FROM PUBLIC;

-- DML (data manipulation lang)
-- insert, update, delete
-- insert into table _ VALUES _
-- update table set col = val 
-- delete from table
INSERT INTO customers (_id, name) VALUES (1, 'Josh');

-- DQL (data query lang)
SELECT * FROM customers;

-- DTL (data transaction lang)
-- BEGIN or START, savepoint, rollback
BEGIN TRANSACTION;
UPDATE something	
IF condition
	rollback
end if;

-- imperative constructs
IF, LOOP, WHILE, EXIT, GOTO


-- Concurrency challenges
BEGIN TRANSACTION;

UPDATE employees



-- TCL (BEGIN/START COMMIT/ROLLBACK)

-- Starting transaciton: BEGIN, BEGIN WORK, BEGIN TRANSACTION, START TRANSACTION
-- Terminating transaction: COMMIT, COMMIT WORK, COMMIT TRANSACTION
-- Revert transaction: ROLLBACK, ROLLBACK WORK, ROLLBACK TRANSACTION

-- CREATE DATABASE DML;
CREATE TABLE Employees 
(
	Employee 	VARCHAR(10) PRIMARY KEY,
	Salary 		INT 		NOT NULL
);
INSERT INTO Employees
(
	Employee, Salary
)
VALUES 	('Chris', 45000),
		('Sally', 58000),
		('Jack', 49000);

CREATE TABLE Orders
(
	OrderID 	INT 		PRIMARY KEY 
							GENERATED ALWAYS AS IDENTITY,
	Employee 	CHAR(10)	REFERENCES Employees(Employee)
							ON DELETE CASCADE
							ON UPDATE CASCADE,
	OrderDate	DATE 		NOT NULL
							DEFAULT NOW()
);
INSERT INTO Orders (Employee, OrderDate)
VALUES 	('Sally', '2018-01-01'),
		('Jack', '2018-01-01'),
		('Sally', '2018-01-02'),
		('Chris', '2018-01-03');
SELECT * FROM employees;
SELECT * FROM Orders;

BEGIN TRANSACTION;

UPDATE employees
SET salary = 57000
WHERE employee = 'Jack';

SAVEPOINT JackUpdated

DELETE FROM employees
WHERE salary > 50000;

SELECT * FROM employees;

ROLLBACK TRANSACTION TO SAVEPOINT JackUpdated;

SELECT * FROM employees;

COMMIT;

SELECT * FROM employees;

BEGIN;
CREATE TABLE t(id int);
SELECT * FROM t;
ROLLBACK;

SELECT * FROM t; -- not created because no commit of transaction, it rolled back


--- insert statement ---
DROP TABLE IF EXISTS t;

CREATE TABLE t (
	Identity_Column_ALWS	INT		NOT NULL	GENERATED ALWAYS AS IDENTITY,
	Identity_Column_DFLT	INT 	NOT NULL	GENERATED BY DEFAULT AS IDENTITY,
	Default_Column			INT		NOT NULL	DEFAULT(0),
	Unique_Column			INT		NULL		UNIQUE,
	Constraint_Column		INT		NULL		CHECK (Constraint_Column > 0)
);

INSERT INTO t (Default_column, Unique_Column, Constraint_Column) VALUES
	(1, 1, 1),
	(2, 2, 2);
	
SELECT * FROM t;

INSERT INTO t (Default_column, Unique_Column, Constraint_Column)
SELECT 3, 3, 3;

INSERT INTO t (Unique_Column, Constraint_Column) VALUES
	(4,4);
INSERT INTO t (Default_Column, Unique_Column, Constraint_Column) VALUES
	(DEFAULT, 5, 5);

-- insert query result set
INSERT INTO t (Default_Column, Unique_Column, Constraint_Column) 
SELECT Default_Column * 5, Unique_Column * 6, Constraint_Column + 10
FROM t;

-- view  (modifiable view)
CREATE VIEW tview AS
SELECT Unique_Column,
	Constraint_Column
FROM t;

SELECT * FROM tview;
SELECT * FROM t;

INSERT INTO tview (Unique_Column) VALUES
(300) ON CONFLICT DO NOTHING;

INSERT INTO tview (Unique_Column) VALUES
(300) 
ON CONFLICT (Unique_Column)
DO UPDATE SET Constraint_Column = EXCLUDED.Constraint_Column
RETURNING *;

WITH insert_cte AS (
  INSERT INTO tview (Unique_Column) VALUES
  (300) 
  ON CONFLICT (Unique_Column)
  DO UPDATE SET Constraint_Column = EXCLUDED.Constraint_Column
  RETURNING *
)
SELECT *, NOW() AS ts, current_user AS SysUser
INTO  New_Table
FROM insert_cte;

SELECT * from New_table;

-- updating
SELECT * FROM orders ;

UPDATE orders 
SET orderdate = '2018-01-04'
WHERE orderid = 4;

UPDATE orders 
SET orderdate = (
  SELECT MAX(orderdate)
  FROM orders
)
WHERE orderid = 1;

-- update, advance all order dates for employees who make 50k or more
SELECT * FROM orders;
SELECT * FROM employees ;

UPDATE orders AS o
SET orderdate = orderdate + 1
WHERE EXISTS (
  SELECT NULL 
  FROM employees AS e
  WHERE e.employee = o.employee
  AND e.salary > 50000
);

UPDATE orders AS o
SET orderdate = CASE 
                  WHEN e.salary > 50000 THEN orderdate + 1
                  WHEN e.salary < 49000 THEN orderdate - 1
                END
FROM employees AS e
WHERE e.employee = o.employee
AND (e.salary > 50000 or e.salary < 49000)
RETURNING *;

WITH order_update AS (
  UPDATE orders AS o
  SET orderdate = CASE 
                    WHEN e.salary > 50000 THEN orderdate + 1
                    WHEN e.salary < 49000 THEN orderdate - 1
                  END
  FROM employees AS e
  WHERE e.employee = o.employee
  AND (e.salary > 50000 or e.salary < 49000)
  RETURNING o.*
)
SELECT *,
  NOW() as ts,
  CURRENT_USER as user
INTO log_table
FROM order_update;

SELECT * FROM log_table;


-- delete
select * from orders;
DELETE from orders where orderid = 1;

BEGIN;

DELETE FROM orders 
WHERE employee IN (
  SELECT employee
  FROM employees 
  WHERE salary < 60000
);
SELECT * from orders;
TRUNCATE orders;
ROLLBACK;

-- joining
DELETE FROM orders AS o
USING employees e
WHERE o.employee = e.employee
AND e.salary < 50000;

rollback;
SELECT o.*, e.salary from orders o join employees e on o.employee = e.employee order by orderid;

-- cursor example
BEGIN;
ROLLBACK;

DECLARE my_cursor CURSOR
FOR
SELECT *
FROM orders
where employee IN (
  SELECT employee
  from employees 
  WHERE salary < 50000
)
FOR UPDATE;

FETCH FIRST FROM my_cursor;

DELETE FROM orders 
WHERE CURRENT OF my_cursor;

FETCH NEXT FROM my_cursor;

-- view
CREATE VIEW vemployees AS
SELECT * FROM employees
WHERE employee <> 'Sally';

SELECT * FROM vemployees;
DELETE FROM vemployees WHERE employee = 'Jack' RETURNING *;
SELECT * FROM employees ;


-- bulk delete
BEGIN TRANSACTION;
TRUNCATE orders;
SELECT * from orders;
ROLLBACK;

DROP TABLE orders;


CREATE TABLE large_delete (
  key_column INT 
             PRIMARY KEY 
             GENERATED ALWAYS AS IDENTITY,
  filler CHAR(500) NOT NULL
);
-- get table size in GB
SELECT CAST(pg_table_size('large_delete') / POWER(1024, 3) AS float) AS size_in_gb;

-- dummy data insert
INSERT INTO large_delete (filler)
SELECT REPEAT('x', 500)
FROM GENERATE_SERIES(1,1000000);

SELECT * FROM large_delete;
SELECT count(*) from large_delete;

-- Truncate is much better than delete
TRUNCATE large_delete;