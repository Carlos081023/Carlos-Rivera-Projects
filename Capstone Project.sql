## Capstone Project

## Data import

## I have 12 tables i need to import of divvy bike data. Because the import wizard is slow, I did a LOAD DATA INFILE statement to expedite the process.
## In doing so, I had to then create a table and the load the contents of file into the table created
CREATE TABLE divvy_202312(
ride_id varchar(100),
rideable_type text,
started_at char(20),
ended_at char(20),
start_station_name text,
start_station_id char(50),
end_station_name text,
end_station_id char(50),
member_casual text,
ride_length time,
day_of_week int
);	

LOAD DATA INFILE '202312-divvy-tripdata_clean.csv'
INTO TABLE divvy_202312
FIELDS TERMINATED BY ','
IGNORE 1 LINES  # This just means that when SQL imports the rows, it skips the first row because that row is just the headers of each column
;

## Data Cleaning

## I ran into the limitations of excel when working with big datasets. Because of the large size, I felt it was better to clean my data in SQL

## I have already cleaned the first two tables so I will clean the last 10. 
## The following code is just the removal of docked_bikes because in my analysis, I want to include only actual rideable types classic and electric. Docked bikes are just a bike
## that has not moved. This is not important to my analysis and even 
SELECT *
FROM divvy_202303
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202303
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202301

WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202304
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202305
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202305
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202306
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202306
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202307
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202307
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202308
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202308
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202309
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202309
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202310
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202310
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202311
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202311
WHERE rideable_type = 'docked_bike';

SELECT *
FROM divvy_202312
WHERE rideable_type = 'docked_bike';

DELETE FROM divvy_202312
WHERE rideable_type = 'docked_bike';

## Exploratory Data Analysis

## After cleaning the datasets I will begin exploring the dataset to identify trends and patterns. I will combine the tables into a full year view.
## To accomplish, I want to do this by using a UNION and not a JOIN statement since I want all the rows from each table and not the columns since they're all the same

CREATE TEMPORARY TABLE Divvy_Full
SELECT *
FROM divvy_202301
UNION ALL
SELECT *
FROM divvy_202302
UNION ALL
SELECT *
FROM divvy_202303
UNION ALL
SELECT *
FROM divvy_202304
UNION ALL
SELECT *
FROM divvy_202305
UNION ALL
SELECT *
FROM divvy_202306
UNION ALL
SELECT *
FROM divvy_202307
UNION ALL
SELECT *
FROM divvy_202308
UNION ALL
SELECT *
FROM divvy_202309
UNION ALL
SELECT *
FROM divvy_202310
UNION ALL
SELECT *
FROM divvy_202311
UNION ALL
SELECT *
FROM divvy_202312
;

## This code would work but unfortunately the connection to mySQL server gets lost probably due to this being a very big query. 
## I will now do this by breaking up the query into chunks to accomplish the same thing. This will take more code but be less computationally intensive.

## First I will create the temp table from which I want to work with
CREATE TEMPORARY TABLE	divvy_full
SELECT * 
FROM divvy_202301;

## From here onward I'll add each month into the table
INSERT INTO divvy_full
SELECT *
FROM divvy_202302;
INSERT INTO divvy_full
SELECT *
FROM divvy_202303;
INSERT INTO divvy_full
SELECT *
FROM divvy_202304;
INSERT INTO divvy_full
SELECT *
FROM divvy_202305;
INSERT INTO divvy_full
SELECT *
FROM divvy_202306;
INSERT INTO divvy_full
SELECT *
FROM divvy_202307;
INSERT INTO divvy_full
SELECT *
FROM divvy_202308;
INSERT INTO divvy_full
SELECT *
FROM divvy_202309;
INSERT INTO divvy_full
SELECT *
FROM divvy_202310;
INSERT INTO divvy_full
SELECT *
FROM divvy_202311;
INSERT INTO divvy_full
SELECT *
FROM divvy_202312;


## Now that the temp table has been created I can begin the EDA
WITH CTE_per_month AS(
	SELECT
		count(ride_id) as riders,
		substr(`started_at`,1,2) as Per_month
	FROM divvy_full
	GROUP BY Per_month
)
SELECT 
	riders,
	TRIM(TRAILING '/' from Per_month) as Per_Month
FROM CTE_per_month
ORDER BY CAST(Per_month AS unsigned);
## I wanted to see how many riders there were broken down by each month. However because there was a '/' I wanted to remove that so I made the original
## query into a CTE and then trimmed the table. it is not in order of date but it works. I then did a order by riders because I want to see how each month performs
## from lowest riders to most riders. From this Feb is the lowest ridership and the highest ridership happens in August.

## Now I want to see how many casual and members are in each month
SELECT 
	COUNT(ride_id) as riders,
    member_casual,
    REPLACE(substr(`started_at`,1,2), '/'," ") as per_month
FROM divvy_full
GROUP BY member_casual, per_month;


## Now I want to see the average time each membertype takes per month
SELECT * 
FROM divvy_full; ## Just seeing the ride_length column
ALTER TABLE divvy_full ADD COLUMN ride_length2 TIME; ## Here I am creating a new column to change the data type for ride_length
UPDATE divvy_full
SET ride_length2 = str_to_date(ride_length, '%H:%i:%s'); ## Changing the data type from text to time into HH:MM:SS format
ALTER TABLE divvy_full DROP COLUMN ride_length; ## Here I am dropping the ride_length column now that I know the new column works as intended.
SELECT *
FROM divvy_full
limit 10; ##  This is just a check
SELECT 
	REPLACE(substr(`started_at`,1,2),'/', '') as per_month,
    member_casual,
    sec_to_time(ROUND(AVG(time_to_sec(ride_length2)))) as Average_ride_length 
FROM divvy_full
GROUP BY member_casual, per_month;
## Originally the query had the average length in seconds so I had to use sec_to_time  and time_to_sec to fix it. However there was
## fractional seconds so I used the round function to remove that so its in HH:MM:SS format.
## From this table I can gather that casual riders in each month always ride longer. This means that casual members on average have longer rides than members do in any given month

## Now I want to see the number of riders in each membership each day of the week of each month WHERE 1 is sunday and 7 is saturday
SELECT
	member_casual,
    COUNT(ride_id) as riders,
	day_of_week,
    REPLACE(substr(`started_at`,1,2),'/', '') as per_month
FROM divvy_full
GROUP BY day_of_week, member_casual, per_month
ORDER BY CAST(per_month AS unsigned) ,day_of_week;
## It seems for all riders, most riders use the divvy bikes in the beginning of the week, likely they may ride bikes to work and then when the end of the week comes they use it less

## Now I want to see the average time it takes a rider of each category in each day of the week in each month
SELECT
	member_casual,
    sec_to_time(ROUND(AVG(time_to_sec(ride_length2)))) as Average_ride_length, 
	day_of_week,
    REPLACE(substr(`started_at`,1,2),'/', '') as per_month
FROM divvy_full
GROUP BY day_of_week, member_casual, per_month
ORDER BY CAST(per_month as unsigned),day_of_week;
## On  average, in each day of the week in each month, casuals ride more in the beginning of the week as previously mentioned in the above query. 

## Now let's see the top 10 stations that are being started from and ranking them
SELECT 
	count(ride_id) as num_riders,
	start_station_name,
    DENSE_RANK() OVER(ORDER BY COUNT(ride_id) DESC) as Ranking
FROM divvy_full
WHERE start_station_name <> ''
GROUP BY start_station_name
LIMIT 10;
## From this query, most of the start names are places in Chicago that are popular tourist locations like Navy Pier and Lake Michigan

## I want to this broken down by month
WITH cte_ranking AS (
	SELECT 
		REPLACE(substr(`started_at`,1,2),'/', '') as per_month,
		count(ride_id) as num_riders,
		start_station_name,
		DENSE_RANK() OVER(PARTITION BY REPLACE(substr(`started_at`,1,2),'/', '') ORDER BY COUNT(ride_id) DESC) as Ranking
	FROM divvy_full
	WHERE start_station_name <> ''
	GROUP BY per_month, start_station_name
)
SELECT *
FROM cte_ranking
WHERE Ranking = 1
ORDER BY CAST(per_month as unsigned);
## This query shows the top start_station for each month of the year. From this table it shows that the area near navy pier is a popular location along with the university of chicago and train stations like '
## OTC and UNion station. so it seems the demographic of riders are locals and tourists riding to Navy pier area, possible locals like students to the U of C campus, and commuters 
## going to OTC or Union station. 

## Im going to query this further can get the percentage
WITH cte_rank AS (
	SELECT 
		REPLACE(substr(`started_at`,1,2),'/', '') as per_month,
		count(ride_id) as num_riders,
		start_station_name,
		DENSE_RANK() OVER(PARTITION BY REPLACE(substr(`started_at`,1,2),'/', '') ORDER BY COUNT(ride_id) DESC) as Ranking
	FROM divvy_full
	WHERE start_station_name <> ''
	GROUP BY per_month, start_station_name
), 
cte_percent AS(
	SELECT *
	FROM cte_rank
	WHERE Ranking = 1
	ORDER BY per_month
)
SELECT 	
	DISTINCT start_station_name,
    COUNT(start_station_name) as num_of_months,
	ROUND((COUNT(start_station_name)/12) * 100, 2) as Percentage
FROM cte_percent
GROUP BY start_station_name
ORDER BY Percentage DESC;

## Now I will how each member type differs when it comes to their favorite start_station
SELECT 
	count(ride_id) as num_riders,
	start_station_name,
    member_casual
FROM divvy_full
WHERE start_station_name <> ''
AND member_casual = 'Casual'
GROUP BY start_station_name
ORDER BY num_riders DESC
Limit 10;
;
## Top location are near or at tourist locations for casuals, my hypothesis is that members will be similar
SELECT 
	count(ride_id) as num_riders,
	start_station_name,
    member_casual
FROM divvy_full
WHERE start_station_name <> ''
AND member_casual = 'Member'
GROUP BY start_station_name
ORDER BY num_riders DESC
Limit 10
;

## My intial hypothesis was that members will be similar to casual stations but theyre very different. These top 10 station for members are 
## places in like residental areas or commuter hubs. It seems that people who have divvy are frequent commuters and people who live in Chicago and use the bikes as a means of 
## transportation.

## Now I'll look at the end_station_name 
SELECT 
	count(ride_id) as num_riders,
	end_station_name,
    DENSE_RANK() OVER(ORDER BY COUNT(ride_id) DESC) as Ranking
FROM divvy_full
WHERE end_station_name <> ''
GROUP BY end_station_name
LIMIT 10;

WITH cte_ranking AS (
SELECT 
	REPLACE(substr(`started_at`,1,2),'/', '') as per_month,
	count(ride_id) as num_riders,
	end_station_name,
    DENSE_RANK() OVER(PARTITION BY REPLACE(substr(`started_at`,1,2),'/', '') ORDER BY COUNT(ride_id) DESC) as Ranking
FROM divvy_full
WHERE end_station_name <> ''
GROUP BY per_month, end_station_name
)
SELECT *
FROM cte_ranking
WHERE Ranking = 1
ORDER BY CAST(per_month AS UNSIGNED);
## This query shows the top end_station for each month of the year. From this table it shows that the area near navy pier is a popular location along with the university of chicago and train stations like '
## OTC and UNion station. so it seems the demographic of riders are locals and tourists riding to Navy pier area, possible locals like students to the U of C campus, and commuters 
## going to OTC or Union station. 

## Im going to query this further can get the percentage
WITH cte_ranking AS (
SELECT 
	REPLACE(substr(`started_at`,1,2),'/', '') as per_month,
	count(ride_id) as num_riders,
	end_station_name,
    DENSE_RANK() OVER(PARTITION BY REPLACE(substr(`started_at`,1,2),'/', '') ORDER BY COUNT(ride_id) DESC) as Ranking
FROM divvy_full
WHERE end_station_name <> ''
GROUP BY per_month, end_station_name
), 
cte_percent As(
	SELECT *
	FROM cte_ranking
	WHERE Ranking = 1
	ORDER BY per_month
)
SELECT 	
	DISTINCT end_station_name,
    COUNT(end_station_name) as num_of_months,
	ROUND((COUNT(end_station_name)/12) * 100, 2) as Percentage
FROM cte_percent
GROUP BY end_station_name
ORDER BY Percentage DESC;

## Top end stations for members
SELECT 
	count(ride_id) as num_riders,
	end_station_name,
    member_casual
FROM divvy_full
WHERE end_station_name <> ''
AND member_casual = 'Member'
GROUP BY end_station_name
ORDER BY num_riders DESC
Limit 10
;

## top end for casuals
SELECT 
	count(ride_id) as num_riders,
	end_station_name,
    member_casual
FROM divvy_full
WHERE end_station_name <> ''
AND member_casual = 'Casual'
GROUP BY end_station_name
ORDER BY num_riders DESC
Limit 10
;

## Exporting the temp file 
SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/divvybikes/DivvyData_capstone.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM divvy_full;

