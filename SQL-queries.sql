DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
	show_id VARCHAR(7),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(20),
	listed_in VARCHAR(100),
	description VARCHAR(300)
);

SELECT * FROM netflix;

SELECT COUNT(*) as total_count
FROM netflix;

SELECT DISTINCT type
FROM netflix;

-- 1. find the count of number of movies and TV Shows

SELECT type,COUNT(*) as total_count 
FROM netflix
GROUP BY type

-- 2. find the most common rating for movies and TV Shows
SELECT type, rating
FROM
(
	SELECT type, rating, COUNT(*), RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking 
	FROM netflix
	GROUP BY 1,2 )
WHERE ranking = 1

-- 3. list all movies released in a specific year
SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = '2020'

-- 4. Find the top 5 countries with the most content on Netflix
SELECT UNNEST(STRING_TO_ARRAY(country,',')) as new_country ,COUNT(show_id) as total_count 
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. movie with longest hour
SELECT * FROM netflix
WHERE type = 'Movie' AND duration = (SELECT MAX(duration) FROM netflix)

-- 6. find content added in last five years
SELECT * FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

-- 7. find all the content by director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

-- 8. all the TV shows with  more than 5 seasons
SELECT * FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration,' ',1)::numeric > 5 

-- 9. count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,COUNT(show_id) as total_count 
FROM netflix
GROUP BY 1

-- 10. Find each year and the average numbers of content released by India on Netflix
-- return top 5 year with highest average content release
SELECT 
	SPLIT_PART(date_added,', ',2) as year, 
	COUNT(*),
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100) as avg_content_per_year

FROM netflix
-- EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year
WHERE country = 'India'
GROUP BY 1
LIMIT 5

-- 11. List all the documentries
SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries'

-- 12. find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

-- 13. find how many movies actor 'Salman Khan ' appeared in last 10 years
SELECT * FROM netflix
WHERE casts ILIKE '%Salman Khan%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. find the top 10 actors who have appeared in the highest number of movies
SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT(*) as total_content
FROM netflix

WHERE country ILIKE 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- Question 15: Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH new_table
AS (SELECT *, 
			CASE WHEN
				description ILIKE '%kill%' OR
				description ILIKE '%violence%' THEN 'Bad_conetnt'
				ELSE 'Good_content'
			END category
FROM netflix)
SELECT 
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1




