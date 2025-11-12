-- 1 --
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	c.active
FROM customer AS c
WHERE c.active = 1;

-- 2 --
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	c.active
FROM customer AS c
WHERE c.first_name LIKE 'Y%';

-- 3 --
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	C.store_id,
	c.active
FROM customer AS c
WHERE c.store_id = 2
ORDER BY c.first_name ASC;

-- 4 --
SELECT
	p.staff_id,
	COUNT (p.amount) AS freq
FROM payment AS p
GROUP BY p.staff_id
ORDER BY freq DESC;

-- 5 --
SELECT
	p.customer_id,
	SUM(p.amount) AS ttlpayment
FROM payment AS p
GROUP BY p.customer_id
HAVING SUM(p.amount) > 175
ORDER BY ttlpayment ASC;

-- 6 --
SELECT
	f.title,
	f.length,
	f.rating,
	DENSE_RANK () OVER(PARTITION BY f.rating ORDER BY f.length DESC) AS rangking
FROM film AS f
WHERE f.rating = 'PG';

-- 7 --
SELECT
	f.film_id,
	f.title,
	COUNT(i.film_id) AS stock
FROM film AS f
JOIN inventory AS i
	ON f.film_id = i.film_id
WHERE f.film_id = 17
GROUP BY f.film_id, f.title;

-- 8 --
CREATE TEMPORARY TABLE academy_dinosaur AS
SELECT
	a.actor_id,
	a.first_name,
	a.last_name,
	fa.film_id
FROM actor AS a
JOIN film_actor AS fa
	ON a.actor_id = fa.actor_id
WHERE fa.film_id = 1;

SELECT
	aa.actor_id,
	aa.first_name,
	aa.last_name,
	f.title
FROM academy_dinosaur AS aa
JOIN film AS f
	ON aa.film_id = f.film_id;

-- 9 --
CREATE TEMPORARY TABLE film_id AS
SELECT
	r.inventory_id,
	i.film_id
FROM rental AS r
JOIN inventory AS i
	ON r.inventory_id = i.inventory_id;

CREATE TEMPORARY TABLE category_id AS
SELECT
	fi.film_id,
	fc.category_id
FROM film_id AS fi
JOIN film_category AS fc
	ON fi.film_id = fc.film_id;

SELECT
	ci.category_id,
	c.name,
	COUNT(c.name) AS freq
FROM category_id AS ci
JOIN category AS c
	ON ci.category_id = c.category_id
GROUP BY ci.category_id, c.name
ORDER BY freq DESC
LIMIT 10;

-- 9 coba simple --
SELECT
	category_id,
	name,
	COUNT (category_id) AS freq
FROM rental
JOIN inventory
	USING (inventory_id)
JOIN film_category
	USING (film_id)
JOIN category
	USING (category_id)
GROUP BY category_id, name
ORDER BY freq DESC
LIMIT 10;

-- 10 --
SELECT
	c.category_id,
	c.name,
	SUM (p.amount) AS totalamount
FROM payment AS p
JOIN rental AS r
	USING (rental_id)
JOIN inventory AS i
	USING (inventory_id)
JOIN film_category AS fc
	USING (film_id)
JOIN category AS c
	USING (category_id)
GROUP BY c.category_id,c.name
ORDER BY totalamount DESC
LIMIT 10;

-- 11 --
SELECT
	p.customer_id,
	CONCAT (c.first_name, ' ', c.last_name) AS full_name,
	SUM (p.amount) AS totalamount
FROM payment AS p
JOIN customer AS c
	ON p.customer_id = c.customer_id
GROUP BY p.customer_id, c.first_name, c.last_name
ORDER BY totalamount DESC
LIMIT 5;

-- 12 --
CREATE TEMPORARY TABLE customer_first_rent AS
SELECT
	p.customer_id,
	CONCAT (c.first_name, ' ', c.last_name) AS full_name,
	a.district,
	FIRST_VALUE(p.payment_date) OVER(PARTITION BY CONCAT (c.first_name, ' ', c.last_name) ORDER BY p.payment_date) AS first_date,
	FIRST_VALUE(p.amount) OVER(PARTITION BY CONCAT (c.first_name, ' ', c.last_name) ORDER BY p.payment_date) AS first_amount
FROM payment AS p
JOIN customer AS c
	USING (customer_id)
JOIN address AS a
	USING (address_id)
WHERE a.district IN ('Sulawesi Utara', 'West Java', 'Central Java', 'Jakarta Raya');

SELECT * FROM customer_first_rent
GROUP BY 1,2,3,4,5
ORDER BY 4;

-- 13 --
SELECT
	EXTRACT (DAY FROM r.rental_date) AS tanggal,
	COUNT(r.rental_id) AS n_rental
FROM rental AS r
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 14 --
CREATE TEMPORARY TABLE freq_rent AS
SELECT+++=
	CONCAT (c.first_name, ' ', c.last_name) AS full_name,
	COUNT(r.rental_id) AS freq
FROM customer AS c
JOIN rental AS r
	ON c.customer_id = r.customer_id
GROUP BY full_name
ORDER BY freq DESC;

SELECT
	*,
	CASE
	WHEN freq > 30 then 0.2
	WHEN freq > 20 then 0.15
	WHEN freq > 15 then 0.1
	ELSE 0=+++=
	END AS discount
FROM freq_rent;

-- 15 --
CREATE TEMPORARY TABLE temp_table AS
SELECT
	CONCAT (c.first_name, ' ', c.last_name) AS full_name,
	r.rental_date,
	f.title,
	LAST_VALUE (title) OVER (PARTITION BY CONCAT (c.first_name, ' ', c.last_name) ORDER BY r.rental_date
							RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_rent
FROM customer AS c
JOIN rental AS r
	USING (customer_id)
JOIN inventory AS i
	USING (inventory_id)
JOIN film AS f
	USING (film_id)

SELECT
	last_rent,
	COUNT (last_rent) AS freq
FROM temp_table
GROUP BY 1
ORDER BY freq DESC;