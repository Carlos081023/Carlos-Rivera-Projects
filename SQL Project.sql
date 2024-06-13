## SQL Project

## DISCLAIMER:
## In this portion of the SQL project, I will be conducting data cleaning on a dataset and then do EDA, exploratory data analysis after I have cleaned my data.

## Data Cleaning 

## After importing the dataset which contained 2361 entries, I am going to query the table to ensure it imported the data and just view it
SELECT * 
FROM layoffs;

## 1. Removing Duplicates
## 2. Standardize the data
## 3. Null values or blanks 
## 4. Remove columns or rows that are not necessary

## layoffs is our raw original dataset, from this point onward I will create another table in which the cleaning process will take place to ensure the original data isn't changed

## Creating new table
CREATE TABLE layoffs_working
LIKE layoffs;

## Inserting the data from layoffs into the working table
INSERT layoffs_working
SELECT *
FROM layoffs;

## Identifying duplicate values
SELECT *,
ROW_NUMBER()  OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_working;

## USING CTE to fitler the duplicated data
WITH duplicate_CTE AS
(
SELECT *,
ROW_NUMBER()  OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_working
)
SELECT *
FROM duplicate_CTE
WHERE row_num >1;

## From here, I am able to identify the duplicate values however, I cannot remove from this CTE as using the DELETE statement would not work. 
## I will creating another table and from there be able to delete the rows where row_num is greater than 2

CREATE TABLE `layoffs_working2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

## Now that the table has been created, I want to insert the query I used in the CTE and put into the table so I can delete row_nums where > 1
INSERT INTO layoffs_working2
SELECT *,
ROW_NUMBER()  OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_working;

## This Query will delete all values that have row_num > 1 which are all duplicate values
DELETE
FROM layoffs_working2
WHERE row_num > 1;

## Ensuring all duplicates are removed.
SELECT *
FROM layoffs_working2
WHERE row_num > 1;

## Standardizing the Data

## Viewing company column
SELECT company
FROM layoffs_working2;
## I noticed some names in this column are spaced so I am going to just trim them so all are standardized
SELECT 
	company,
	TRIM(company)
FROM layoffs_working2;
## From here I can validate the column entries have been trimmed!

## Now I'm updating the table with the trim
UPDATE layoffs_working2
set company = TRIM(company);

## Now viewing industry
SELECT DISTINCT industry
FROM layoffs_working2
ORDER BY 1;

## In this query I notice industry has some null values Crypto Currency has been repeated but because of the way it was input, it  is not technically a duplicate so we 
## will change this
SELECT *
FROM layoffs_working2
WHERE industry LIKE'Crypto%';

# I will update Crypto Currency
UPDATE layoffs_working2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

## Viewing Location
SELECT DISTINCT location
FROM layoffs_working2
ORDER BY 1;

## Just by viewing location,it looks fine

## Viewing Country
SELECT DISTINCT country
FROM layoffs_working2
ORDER BY 1;

## there is a duplicate in country, US is repeated twice so I will fix this
UPDATE layoffs_working2
SET country = 'United States'
WHERE country LIKE 'United States%';

## Now looking on date column
SELECT`date`,
STR_TO_DATE(`date` , '%m/%d/%Y')
FROM layoffs_working2;

## Updating date column
UPDATE layoffs_working2
SET `date` = STR_TO_DATE(`date` , '%m/%d/%Y');

## date column is still a text data type, I want to convert this to a date date type
ALTER TABLE layoffs_working2
MODIFY COLUMN `date` DATE;

## Working with blanks or NULL values

#Viewing total lay offs
SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_working2
WHERE industry IS NULL
OR industry = '';

## Previously, industry has some missing / NULL values so I found them. Now I am going to try to poplulate the missing entries If i can.
SELECT *
FROM layoffs_working2
WHERE company = 'Airbnb';

## this query is just me trying to see where industry is blank and where it is mentioned to see which companies belong to which industry
SELECT *
FROM layoffs_working2 as t1
JOIN layoffs_working2 as t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_working2 t1
JOIN layoffs_working2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

## This didnt work as intended so I am going to try a work around by setting blank values into NULL values

UPDATE layoffs_working2
SET industry = NULL
WHERE industry = '';

## Now try again
UPDATE layoffs_working2 t1
JOIN layoffs_working2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

## Deleting NULL values
DELETE
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

## Removing the columns we don't need.
ALTER TABLE layoffs_working2
DROP COLUMN row_num;

## Exploratory Data Analysis

## From this point onwards, I will conduct EDA on the dataset to see what trends or patterns I see in the dataset!

## Which company had the most layoffs and how many did they layoff in a single day?
SELECT *
FROM layoffs_working2
WHERE total_laid_off = (SELECT MAX(total_laid_off) FROM layoffs_working2);
## Google had the most layoffs with 12000 total people laid off but it was only 6% of their total workforce.

## Which company had the lowest number of layoffs and how many did they layoff in a single day?
SELECT *
FROM layoffs_working2
WHERE total_laid_off = (
	SELECT MIN(total_laid_off) 
	FROM layoffs_working2
    )
;
## The company was Branch and they laid off a total of 3 people but had a 27% layoff percentage meaning they laid off more than a 1/4 of their company.

## Now let's see how many layoffs each industry had
SELECT 
	industry,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_working2
GROUP BY industry
ORDER BY total_laid_off DESC
;
## This table shows the Consumer industry had the most layoffs with retail as a very close second. Manufacturing at the least total layoffs.

## Now I will look at how many layoffs each company had overall
SELECT
	company,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_working2
GROUP BY company
ORDER BY total_laid_off DESC
;
## The biggest companies in the world like Amazon, Google, Meta, etc were the ones with the MOST layoffs 

## Seeing where the data of these layoffs began and end up too.
SELECT
	MIN(`date`),
    MAX(`date`)
FROM layoffs_working2;
## The layoffs began in 2020 and this records up to 2023. 

## Looking at which countries have the most layoffs?
SELECT
	country,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_working2
GROUP BY country
ORDER BY total_laid_off DESC
;
## The USA had the most layoffs for a country recorded with India behind it but the gap is significantly large

## Looking at which year had the most layoffs
SELECT 
	YEAR(`date`),
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_working2
GROUP BY YEAR(`date`)
ORDER BY total_laid_off DESC
;
## 2022 had the most layoffs recorded with 2023 following behind. This could be from the fact that companys overhired during the pandemic and when it was over they needed to consolidate

## Looking at which stage had the highest number of layoffs
SELECT 
	stage,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_working2
GROUP BY stage
ORDER BY total_laid_off DESC
;

## Looking at total layoffs for each year and month and doing a rolling total
## I will use a CTE to accomplish since it is best
WITH rolling_total AS
(
SELECT 
	substr(`date`,1,7) AS `Month`, 
	SUM(total_laid_off) as total_laid_off
FROM layoffs_working2
WHERE substr(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month`
)
SELECT 
	`Month`,
    total_laid_off,
    SUM(total_laid_off) OVER(ORDER BY `Month`) AS rolling_total
FROM rolling_total
;

## Looking at how many layoffs happened in each industry each year
SELECT
	industry,
    YEAR(`date`) as `Year`,
    SUM(total_laid_off) as total_laid_off
FROM layoffs_working2
WHERE industry IS NOT NULL
GROUP BY industry, YEAR(`date`)
ORDER BY industry, total_laid_off DESC
;

## CTE for ranking which company had the highest layoffs
WITH company_year AS
(
SELECT 
	company, 
    YEAR(`date`) as `Year`,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_working2
GROUP BY company, YEAR(`date`)
), company_year_rank AS (
SELECT *,
	DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY total_laid_off DESC) as Ranking
FROM company_year
WHERE `Year` IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE Ranking <= 5
;