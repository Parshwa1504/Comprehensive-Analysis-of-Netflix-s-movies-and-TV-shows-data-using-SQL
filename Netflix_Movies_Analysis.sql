-- DATABASE SETUP : 

DROP TABLE IF EXISTS Netflix ;

CREATE TABLE Netflix (
    show_id VARCHAR(10),
    show_type VARCHAR(15),
    title VARCHAR(150),
    director VARCHAR(250),
    show_cast VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(50),
    duration VARCHAR(20),
    listed_in VARCHAR(100),
    description VARCHAR(300)
);

SELECT 
    *
FROM
    Netflix;

SELECT 
    COUNT(*)
FROM
    Netflix;

-- [1] Generating Different output tables for Analysis : 

SELECT DISTINCT
    show_type, COUNT(*) AS Total_Content
FROM
    Netflix
GROUP BY show_type;

-- [2] Finding Most Common Ratings For Movies And Tv Shows :

SELECT show_type , rating AS Most_Common_Rating FROM (
SELECT 
    show_type, rating , COUNT(*) Total_Content , RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) AS Ranking
FROM
    Netflix
GROUP BY show_type , rating
)
WHERE ranking = 1 ;

-- [3] LIST ALL MOVIES RELEASED IN 2020 YEAR : 

SELECT 
    *
FROM
    Netflix
WHERE
    show_type = 'Movie'
    	AND release_year = 2020
;

-- [4] Find the Top 5 countries with the most content on Netflix : 

SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')), COUNT(show_id)
FROM
    Netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- [5] IDENTIFY THE LONGEST MOVIE 

SELECT 
    title, duration
FROM
    Netflix
WHERE
    show_type = 'Movie'
        AND duration = (SELECT 
            MAX(duration)
        FROM
            Netflix); 	
       ; 			

-- [6] FIND THE CONTENT ADDED IN LAST 5 YEARS 

SELECT show_type , title , date_added FROM (
SELECT
	* , 
	TO_DATE(date_added , 'Month DD, YYYY') 
FROM 
	Netflix)
	
WHERE to_date >= CURRENT_DATE - INTERVAL '5 years'
ORDER BY to_date DESC;


--[7] FIND ALL THE MOVIES / TV SHOWS BY director 'Rajiv Chilaka' : 

Select 
	*
FROM 
	(SELECT 
		* ,
		UNNEST(STRING_TO_ARRAY(director,',')) AS Different FROM Netflix
		)
WHERE Different = 'Rajiv Chilaka' ;
 
-- OR WE CAN DO THIS QUERY BY THIS ALSO :

SELECT 
    show_type, title, director
FROM
    Netflix
WHERE
    director LIKE '%Rajiv Chilaka%';

--[8] List All the shows with more than 5 seasons : 

SELECT 
	* 
FROM
	Netflix 
WHERE 
	show_type='TV Show'
	AND CAST(SPLIT_PART(duration,' ',1) AS INTEGER) > 5;

-- [9] Count the number of content items in each genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS No_Of_Content
FROM
    Netflix
GROUP BY genre
ORDER BY COUNT(*) DESC;

-- [10]Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release! 

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS Netflix_Release, 
	COUNT(*) AS Total_Content ,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM Netflix WHERE country = 'India')::numeric * 100,2) AS Average_Content
FROM 
	Netflix
WHERE
	country = 'India' 
GROUP BY Netflix_Release
ORDER BY COUNT(show_id) DESC
LIMIT 5 ;

-- [11] List all movies that are documentaries : 

SELECT 
	* 
FROM 
	(SELECT 
		* ,
		TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre FROM Netflix 
	)
WHERE genre = 'Documentaries' AND show_type = 'Movie' ;

-- OR WE CAN DO THIS QUERY AS BELOW : 

SELECT 
	* 
FROM 
	Netflix
WHERE listed_in ILIKE '%Documentaries%'; 


-- [12] Find all content without a director

SELECT 
	* 
FROM 
	Netflix
WHERE director IS NULL;

-- [13] Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
	* 
FROM 
	Netflix 
WHERE show_cast ILIKE '%Salman Khan%' 
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10  ;

-- [14] Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(show_cast,','))) AS Actors ,
	COUNT(*) AS No_Of_Movies 
FROM
	Netflix 
WHERE country ILIKE '%India%'
GROUP BY Actors 
ORDER BY COUNT(show_id) DESC
LIMIT 10;

-- [15]
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT 
	Category ,
	Count(*) AS No_Of_Content 
FROM
	(SELECT 
		* ,
		CASE 
			WHEN description ILIKE '%kill%' OR description ILIKE '%violence' THEN 'Bad_Content' 
			ELSE 'Good_Content'
			END AS Category 
		FROM
			Netflix
	)
Group BY Category ;
