-- CASE WHEN (add if/else login to select query)
CREATE TABLE testing.films (
	film_id TEXT PRIMARY KEY,
	title TEXT,
	description TEXT,
	release_year TEXT,
	language_id TEXT,
	rental_duration TEXT,
	rental_rate TEXT,
	length TEXT,
	replacement_cost TEXT,
	rating TEXT,
	last_update TEXT,
	special_features TEXT,
	fulltext TEXT
);
INSERT INTO testing.films (film_id, length, title) VALUES 
	('1', '50', 'Cool title'),
	('2', '60', 'nice'),
	('3', '120', 'awesome'),
	('4', '150', 'rad');
SELECT film_id, length, title 
FROM testing.films;

SELECT film_id, length, title,
	CASE WHEN length::int <= 50 THEN 'SHORT'
		WHEN length::int > 50 AND length::int <= 120 THEN 'MEDIUM'
		WHEN length::int > 120 THEN 'LONG' END how_long
FROM testing.films;