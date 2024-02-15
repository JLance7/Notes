## Relationships
-- 1 to 1 (one username in one table, corresponds to adress and description data in another table joined on username)
-- 1 to many (one username in one table, corresponds to multiple blog posts in antoher table joined on username. Use when you don't know how many data items you will have)
-- many to many (one customer_name in one table, coreesponds to entry in another table with customer_name, that entry index links to linking table which has the product_id)


## Normalization
-- each row must be unique (primary keys), each col only has one value (might need a linking table)
-- for composite key, if one col for that key is not releated, split up into linking table (remove dependencies on composite key) 
-- if two columns are really similar (rating # and rating name), create new table