10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

select m.name as museum_name, m.city
from museum_hours mh1
	join museum m on m.museum_id = mh1.museum_id
where day = 'Sunday' 
and exists (select 1 from museum_hours mh2
			where mh2.museum_id = mh1.museum_id
			and mh2.day = 'Monday');

15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

select m.name as museum_name, m.state, mh.day,
	to_timestamp(open, 'HH:MI AM') as open_time,
	to_timestamp(close, 'HH:MI AM') as close_time,
	to_timestamp(close, 'HH:MI AM') - to_timestamp(open, 'HH:MI AM') as duration,
	rank() over(order by (to_timestamp(close, 'HH:MI AM') - to_timestamp(open, 'HH:MI AM')) desc) as rnk
	from museum_hours mh
join museum m on m.museum_id = mh.museum_id
limit 1;


18) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

with cte_country as 
		(select country, count(1), rank() over(order by count(1) desc) as rnk
		from museum
		group by country),

	cte_city as 
		(select city, count(1), rank() over(order by count(1) desc) as rnk
		from museum
		group by city)

select string_agg(distinct country, ', ') as country, string_agg(city, ', ') as city
from cte_country
cross join cte_city
where cte_country.rnk = 1
and cte_city.rnk = 1; 



1) Fetch all the paintings which are not displayed on any museums?

SELECT w.name
FROM work w
LEFT JOIN museum m ON w.museum_id = m.museum_id
WHERE m.museum_id IS NULL;


2)Are there museums without any paintings?


SELECT COUNT(*) FROM museum;
SELECT COUNT(*) FROM work;

SELECT m.museum_id, m.name, COUNT(w.work_id) as painting_count 
FROM museum m
LEFT JOIN work w ON m.museum_id = w.museum_id
GROUP BY m.museum_id, m.name;


3) How many paintings have an asking price of more than their regular price? 

SELECT * FROM product_size
WHERE sale_price > regular_price;


4) Identify the paintings whose asking price is less than 50% of its regular price

SELECT * FROM product_size
WHERE sale_price < 0.5 * regular_price;

5) Which canva size costs the most?

-- Check the type of size_id in canvas_size table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'canvas_size' AND column_name = 'size_id';

-- Check the type of size_id in product_size table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'product_size' AND column_name = 'size_id';



SELECT cs.label, MAX(ps.sale_price) as max_price
FROM canvas_size cs
JOIN product_size ps ON cs.size_id::text = ps.size_id::text
GROUP BY cs.label
ORDER BY max_price DESC
LIMIT 1;



6) Delete duplicate records from work, product_size, subject and image_link tables

DELETE FROM WORK
WHERE work_id NOT IN (
    SELECT MIN(work_id)
    FROM WORK
    GROUP BY name, artist_id, style, museum_id
);

DELETE FROM product_size
WHERE size_id NOT IN (
    SELECT MIN(size_id)
    FROM product_size
    GROUP BY work_id, size_id, sale_price, regular_price);



DELETE FROM subject
WHERE subject NOT IN (
    SELECT MIN(subject)
    FROM subject
    GROUP BY work_id, subject
);

select * from image_link;

DELETE FROM image_link
WHERE work_id NOT IN (
    SELECT MIN(work_id)
    FROM image_link
    GROUP BY work_id, url, thumbnail_small_url, thumbnail_large_url
);


7) Identify the museums with invalid city information in the given dataset

SELECT museum_id, name, city
FROM museum
WHERE city ~ '[0-9]';


	
8) Museum_Hours table has 1 invalid entry. Identify it and remove it.

SELECT * FROM museum_hours
	
SELECT *
FROM museum_hours
WHERE day NOT IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

UPDATE museum_hours
SET day = 'Thursday'
WHERE day = 'Thusday';


9) Fetch the top 10 most famous painting subject

select * from subject
	
SELECT subject, COUNT(*) as painting_count
	FROM subject 
GROUP by subject
	ORDER BY painting_count DESC
	LIMIT 10;


10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT m.name AS museum_name, m.city
FROM museum m
JOIN museum_hours mh1 ON m.museum_id = mh1.museum_id AND mh1.day = 'Sunday'
JOIN museum_hours mh2 ON m.museum_id = mh2.museum_id AND mh2.day = 'Monday';


11) How many museums are open every single day?

SELECT m.name AS museum_name
FROM museum m
JOIN (
    SELECT museum_id
    FROM museum_hours
    GROUP BY museum_id
    HAVING COUNT(DISTINCT day) = 7
) AS open_every_day ON m.museum_id = open_every_day.museum_id;

 SELECT m.name AS museum_name, m.museum_id, MIN(mh.open) AS open_time, MAX(mh.close) AS close_time
FROM museum m
JOIN museum_hours mh ON m.museum_id = mh.museum_id
WHERE m.museum_id IN (
    SELECT museum_id
    FROM museum_hours
    GROUP BY museum_id
    HAVING COUNT(DISTINCT day) = 7
)
GROUP BY m.name, m.museum_id
ORDER BY m.name;


12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

SELECT m.name as museum_name, COUNT(w.work_id) as painting_count 
	FROM museum m
	JOIN work w on m.museum_id = w.museum_id
	GROUP BY m.name
	ORDER BY painting_count DESC
	LIMIT 5;



13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

SELECT a.full_name as artist_name, COUNT(w.work_id) as painting_count 
	FROM artist a
	JOIN work w on a.artist_id = w.artist_id
	GROUP BY a.full_name
	ORDER BY painting_count DESC
	LIMIT 5;
	

14) Display the 3 least popular canva sizes

SELECT cs.label AS canvas_size, COUNT(ps.work_id) AS usage_count
FROM canvas_size cs
JOIN product_size ps ON cs.size_id::text = ps.size_id::text
GROUP BY cs.label
ORDER BY usage_count ASC
LIMIT 3;


15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
	


SELECT m.name AS museum_name, m.state, mh.day,
       to_timestamp(open, 'HH:MI AM') as open_time,
	to_timestamp(close, 'HH:MI AM') as close_time,
	to_timestamp(close, 'HH:MI AM') - to_timestamp(open, 'HH:MI AM') as duration
FROM museum m
JOIN museum_hours mh ON m.museum_id = mh.museum_id
ORDER BY duration DESC
LIMIT 1;


16) Which museum has the most no of most popular painting style?

WITH cte AS 
	(SELECT style
    FROM work
    GROUP BY style
    ORDER BY COUNT(*) DESC
    LIMIT 1)

SELECT m.name AS museum_name, COUNT(w.work_id) AS painting_count
FROM museum m
JOIN work w ON m.museum_id = w.museum_id
WHERE w.style = (SELECT style FROM cte)
GROUP BY m.name
ORDER BY painting_count DESC
LIMIT 1;	

17) Identify the artists whose paintings are displayed in multiple countries

SELECT a.artist_id, a.full_name, COUNT(distinct m.country) as country_count 
	FROM artist a
	JOIN work w ON a.artist_id = w.artist_id
	JOIN museum m ON w.museum_id = m.museum_id
	GROUP BY a.artist_id, a.full_name
	HAVING COUNT(distinct m.country) > 1
	ORDER BY country_count DESC
	;

18) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.


WITH cte_country AS 
		(SELECT country, COUNT(1), RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
		FROM museum
		GROUP BY country),

	cte_city as 
		(SELECT city, COUNT(1), RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
		FROM museum
		GROUP BY city)

select string_agg(distinct country, ', ') as country, string_agg(city, ', ') as city
from cte_country
cross join cte_city
where cte_country.rnk = 1
and cte_city.rnk = 1; 



	
19) Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label


SELECT a.full_name AS artist_name, ps.sale_price, w.name AS painting_name, 
       m.name AS museum_name, m.city AS museum_city, cs.label AS canvas_label
FROM product_size ps
JOIN work w ON ps.work_id = w.work_id
JOIN artist a ON w.artist_id = a.artist_id
JOIN museum m ON w.museum_id = m.museum_id
JOIN canvas_size cs ON ps.size_id::text = cs.size_id::text
WHERE ps.sale_price = (SELECT MAX(sale_price) FROM product_size)
   OR ps.sale_price = (SELECT MIN(sale_price) FROM product_size);



	
20) Which country has the 5th highest no of paintings?

SELECT country
FROM(
	SELECT country, COUNT(*) AS painting_count
	FROM museum m
	JOIN work w ON m.museum_id = w.museum_id
	GROUP BY country
	ORDER BY painting_count DESC
	LIMIT 5
) AS fifth_highest_country
ORDER BY painting_count ASC
LIMIT 1;


21) Which are the 3 most popular and 3 least popular painting styles?

(
    SELECT style, COUNT(*) AS style_count
    FROM work
    GROUP BY style
    ORDER BY style_count DESC
    LIMIT 4
)
UNION ALL
(
    SELECT style, COUNT(*) AS style_count
    FROM work
    GROUP BY style
    ORDER BY style_count ASC
    LIMIT 3
);

	

22) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

SELECT a.full_name AS artist_name, COUNT(w.work_id) AS num_paintings, a.nationality
FROM artist a
JOIN work w ON a.artist_id = w.artist_id
JOIN subject s ON w.work_id = s.work_id
JOIN museum m ON w.museum_id = m.museum_id
WHERE s.subject = 'Portraits' AND m.country != 'USA'
GROUP BY a.artist_id, a.full_name, a.nationality
ORDER BY num_paintings DESC
LIMIT 5;




