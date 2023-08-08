-- Creating Table

DROP TABLE IF EXISTS OLYMPICS_HISTORY;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR,
    sex         VARCHAR,
    age         VARCHAR,
    height      VARCHAR,
    weight      VARCHAR,
    team        VARCHAR,
    noc         VARCHAR,
    games       VARCHAR,
    year        INT,
    season      VARCHAR,
    city        VARCHAR,
    sport       VARCHAR,
    event       VARCHAR,
    medal       VARCHAR
);

SELECT * FROM OLYMPICS_HISTORY;

DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR,
    region      VARCHAR,
    notes       VARCHAR
);

SELECT * FROM OLYMPICS_HISTORY_NOC_REGIONS;

-- Queries

-- How many olympics games have been held?

SELECT COUNT(DISTINCT games) AS total_olympics_games
FROM OLYMPICS_HISTORY;

--  List down all Olympics games held so far.

SELECT DISTINCT year, season, city
FROM OLYMPICS_HISTORY
ORDER BY year;

-- Mention the total no of nations who participated in each olympics game.

WITH all_countries AS
(SELECT oh.games, nr.region
 FROM OLYMPICS_HISTORY oh
 JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
 ON oh.noc = nr.noc
 GROUP BY oh.games, nr.region
)
SELECT games, COUNT(*) AS "total_no_of_countries"
FROM
all_countries
GROUP BY games
ORDER BY games;

-- Which year saw the highest and lowest no of countries participating in olympics?

WITH all_countries AS
(SELECT oh.games, nr.region
 FROM OLYMPICS_HISTORY oh
 JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
 ON oh.noc = nr.noc
 GROUP BY oh.games, nr.region
),
a AS
(SELECT games, COUNT(*) AS "total_no_of_countries"
FROM
all_countries
GROUP BY games
ORDER BY total_no_of_countries
)
SELECT DISTINCT
CONCAT(first_value(games) OVER(ORDER BY total_no_of_countries) , ' - ' , first_value(total_no_of_countries) OVER(ORDER BY total_no_of_countries)) AS lowest_countries, 
CONCAT(first_value(games) OVER(ORDER BY total_no_of_countries DESC) , ' - ' , first_value(total_no_of_countries) OVER(ORDER BY total_no_of_countries DESC)) AS highest_countries 
FROM a
;

-- Which nation has participated in all of the olympic games?

WITH all_games as
(
SELECT nr.region , COUNT(DISTINCT oh.games) AS freq
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
ON oh.noc = nr.noc   
GROUP BY nr.region , oh.games)
SELECT all_games.region AS country, SUM(all_games.freq) AS "total_participated_countries"
FROM all_games
GROUP BY all_games.region
HAVING SUM(all_games.freq) = (SELECT COUNT(DISTINCT games) AS total_olympics_games
FROM OLYMPICS_HISTORY);

-- Identify the sport which was played in all summer olympics.

SELECT sport, COUNT(DISTINCT games) AS no_of_games
FROM OLYMPICS_HISTORY
WHERE season = 'Summer'
GROUP BY sport
HAVING COUNT(DISTINCT games) = (SELECT COUNT(DISTINCT games) AS total_summer_games
FROM OLYMPICS_HISTORY
WHERE season = 'Summer') ;

-- Which Sports were just played only once in the olympics.

WITH t1 AS
(SELECT DISTINCT games, sport
FROM olympics_history),
t2 AS
(SELECT sport, COUNT(1) as no_of_games
FROM t1
GROUP by sport)
SELECT t2.*, t1.games
FROM t2
JOIN t1 ON t1.sport = t2.sport
WHERE t2.no_of_games = 1
ORDER BY  t1.sport;

-- Fetch the total no of sports played in each olympic games.

WITH t1 AS(SELECT DISTINCT games, sport
FROM olympics_history )
SELECT t1.games, COUNT(1) AS no_of_sports
FROM t1
GROUP BY t1.games
ORDER BY games DESC;

-- Fetch oldest athletes to win a gold medal.

WITH t1 as 
(SELECT name, sex, 
 CAST(CASE 
 	WHEN AGE = 'NA' THEN '0'
    ELSE AGE 
 END AS INT) AS age,team,games,city,sport, event, medal
FROM OLYMPICS_HISTORY),
ranking AS
(SELECT t1.*,
 RANK() OVER(ORDER BY AGE DESC) AS rnk
 FROM t1
 WHERE medal = 'Gold'
)
SELECT *
FROM ranking
WHERE rnk=1;

-- Find the Ratio of male and female athletes participated in all olympic games.

WITH male AS
(SELECT COUNT(DISTINCT name) AS m_count
 FROM OLYMPICS_HISTORY
 WHERE sex = 'M'
),
female AS
(SELECT COUNT(DISTINCT name) AS f_count
 FROM OLYMPICS_HISTORY
 WHERE sex = 'F')
SELECT concat('1 : ', ROUND(male.m_count::decimal/female.f_count, 2)) as ratio
FROM male, female;

-- Fetch the top 5 athletes who have won the most gold medals.

WITH t1 AS
(SELECT name , team, COUNT(1) AS total_gold_medals
FROM OLYMPICS_HISTORY
WHERE medal = 'Gold'
GROUP BY name , team
),
t2 AS
(SELECT name,team, total_gold_medals,
 DENSE_RANK() OVER(ORDER BY total_gold_medals DESC) AS rnk
 FROM t1
)
SELECT name,team, total_gold_medals
FROM t2
WHERE rnk > 0 AND rnk < 6;


-- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH t1 AS
(SELECT name , team, COUNT(1) AS most_medals
FROM OLYMPICS_HISTORY
WHERE medal IN ('Gold' , 'Silver' , 'Bronze')
GROUP BY name , team
),
t2 AS
(SELECT name,team, most_medals,
 DENSE_RANK() OVER(ORDER BY most_medals DESC) AS rnk
 FROM t1
)
SELECT name,team, most_medals
FROM t2
WHERE rnk > 0 AND rnk < 6;

-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

WITH t1 AS
(SELECT nr.region , COUNT(*) AS total_medals
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
ON oh.noc = nr.noc
WHERE medal IN ('Gold' , 'Silver' , 'Bronze')
GROUP BY nr.region
ORDER BY total_medals DESC
),
t2 AS (SELECT region, total_medals,
DENSE_RANK() OVER(ORDER BY total_medals DESC) AS rnk
FROM t1
)
SELECT * 
FROM t2
WHERE rnk <= 5;

-- List down total gold, silver and bronze medals won by each country.

WITH 
g AS
(SELECT nr.region , COUNT(*) AS gold
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
ON oh.noc = nr.noc
WHERE medal = 'Gold'
GROUP BY nr.region),
s AS 
(SELECT nr.region , COUNT(*) AS silver
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
ON oh.noc = nr.noc
WHERE medal = 'Silver'
GROUP BY nr.region),
b AS
(SELECT nr.region , COUNT(*) AS bronze
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
ON oh.noc = nr.noc
WHERE medal = 'Bronze'
GROUP BY nr.region)
SELECT g.region , g.gold , s.silver, b.bronze
FROM g
JOIN s
ON g.region = s.region
JOIN b 
ON s.region = b.region
ORDER BY (gold + silver + bronze) DESC;

-- List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

CREATE EXTENSION TABLEFUNC;

SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
                , medal
                , count(1) as total_medals
                FROM olympics_history oh
                JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
                where medal <> ''NA''
                GROUP BY games,nr.region,medal
                order BY games,medal',
            'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);
	
-- Break down all olympic games where india won medal for Hockey and how many medals in each olympic games

SELECT team, sport, games, count(1) as total_medals
FROM olympics_history
WHERE medal <> 'NA'
AND team = 'India' and sport = 'Hockey'
GROUP BY team, sport, games
ORDER BY total_medals DESC;

-- In which Sport/event, India has won highest medals.

SELECT sport, count(1) as total_medals
FROM OLYMPICS_HISTORY
WHERE medal <> 'NA'
AND team = 'India'
GROUP BY sport
ORDER BY total_medals DESC
LIMIT 1;