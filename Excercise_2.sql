SET search_path TO excercise_2;*

-- CASE 1 --
SELECT
	u.user_id,
	u.username,
	u.created_at
FROM users AS u
LEFT JOIN photos AS p
	USING(user_id)
WHERE p.created_dat IS NULL
ORDER BY 1;

-- CASE 2 -- 
SELECT
	TO_CHAR (u.created_at, 'Day') AS day,
	COUNT(TO_CHAR (u.created_at, 'Day'))
FROM users AS U
GROUP BY 1
ORDER BY 2 DESC;

-- CASE 3 --
SELECT
	u.username,
	u.created_at
FROM users AS u
ORDER BY 2
LIMIT 5;

-- CASE 4 --
SELECT
	u.username,
	COUNT(l.user_id) AS likes
FROM users AS u
JOIN likes AS l
	USING(user_id)
GROUP BY 1
ORDER BY 2 DESC;

-- CASE 5 --
SELECT
	t.tag_name,
	COUNT(pt.tag_id) AS tags
FROM tags AS t
JOIN photo_tags AS pt
	USING(tag_id)
GROUP BY 1
ORDER BY 2 DESC;

-- CASE 6 --
SELECT
	u.user_id,
	u.username,
	COUNT(p.user_id) AS photos
FROM users AS u
JOIN photos AS p
	USING(user_id)
GROUP BY 1
ORDER BY 3 DESC, 1 ASC;

-- CASE 7 --
SELECT
	COUNT(*) AS n_user_posting
FROM users AS u
WHERE u.user_id IN (SELECT DISTINCT p.user_id FROM photos AS p);

-- CASE 8 --
SELECT
	l.user_id,
	COUNT(l.user_id) photo_likes
FROM likes AS l
GROUP BY 1
HAVING COUNT(l.user_id) = (SELECT COUNT(*) FROM photos AS p)
ORDER BY 2 DESC;

-- CASE 9 --
SELECT
	DISTINCT c.user_id,
	u.username,
	c.created_at
FROM comments AS c
JOIN users AS u
	USING(user_id)
GROUP BY 1,2,3
ORDER BY 1;

-- CASE 10 --
SELECT
	(SELECT COUNT (DISTINCT c.user_id) FROM comments AS c)::float / 
	COUNT(u.user_id)::float * 100 AS percent_left_comment,
	(SELECT COUNT (u.user_id) FROM users AS u WHERE u.user_id NOT IN (SELECT DISTINCT c.user_id FROM comments AS c))::float /
	COUNT(u.user_id)::float * 100 AS percent_not_left_comment
FROM users AS u;

-- CASE 10: alternatif --
WITH comment_table AS(
SELECT
	DISTINCT u.user_id AS user_id,
	c.user_id AS id
FROM users AS u
LEFT JOIN comments AS c
	USING(user_id)
)
SELECT
	SUM(CASE WHEN ct.id IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(ct.user_id)::float * 100 AS percent_left_comment,
	SUM(CASE WHEN ct.id IS NULL THEN 1 ELSE 0 END)::float / COUNT(ct.user_id)::float * 100 AS percent_not_left_comment
FROM comment_table AS ct;