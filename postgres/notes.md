## Relationships
-- 1 to 1 (one username in one table, corresponds to adress and description data in another table joined on username)
-- 1 to many (one username in one table, corresponds to multiple blog posts in antoher table joined on username. Use when you don't know how many data items you will have)
-- many to many (one customer_name in one table, coreesponds to entry in another table with customer_name, that entry index links to linking table which has the product_id)


## Normalization
1. each row must be unique (primary keys), each col only has one value (might need a linking table)
2. for composite key, if one col for that key is not releated, split up into linking table (remove dependencies on composite key) 
3. if two columns are really similar (rating # and rating name), create new table. If col depends upon col, which depends upone primary key, then remove that col and make table connected by id

4. multiple combinations on primary key work best if they are split up into their own tables
5. with multiple combinations, use multiple tables and join them together

### Other db objects than table
* aggregates
* functions
* views
* materialized views
* operators
* procedures
* sequences
* trigger functions
* subscriptions

Using indexes when you have a large dataset and frequently query it with specific col in where statement, or col is very unique
```sql
CREATE INDEX idx_user_email
ON users (email);
```

