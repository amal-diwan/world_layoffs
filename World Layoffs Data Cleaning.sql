-- World Layoffs Data Cleaning

SELECT *
FROM layoffs;

-- Create a copy of the raw data

CREATE TABLE layoffs_v1 AS
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_v1;

-- 1) Remove Duplicates

-- Assign row numbers
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_v1;

-- If row number greater than one than it is duplicate
WITH duplicates_cte AS
(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_v1
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;

-- Check duplicate data
SELECT *
FROM layoffs_v1
WHERE company IN ('Casper', 'Hibob', 'Yahoo')
ORDER BY company;

-- Delete duplicate data
CREATE TABLE layoffs_v2 AS
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_v1;

DELETE
FROM layoffs_v2
WHERE row_num > 1;


-- Verify no more duplicate data
SELECT *
FROM layoffs_v2
WHERE row_num > 1;

SELECT *
FROM layoffs_v2
WHERE company IN ('Casper', 'Hibob', 'Yahoo')
ORDER BY company;

-- 2) Stantdardise Data

SELECT *
FROM layoffs_v2;

-- Check data in each column

-- company
SELECT DISTINCT company, TRIM(company)
FROM layoffs_v2;
-- Trimed leading or trailing spaces
UPDATE layoffs_v2
SET company = TRIM(company);

-- location
SELECT DISTINCT location
FROM layoffs_v2
ORDER BY location;

-- industry
SELECT DISTINCT industry
FROM layoffs_v2
ORDER BY industry;
-- Modified different variations of crypto
UPDATE layoffs_v2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- total_laid_off
SELECT MAX(total_laid_off), MIN(total_laid_off)
FROM layoffs_v2;

-- percentage_laid_off
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_v2;

-- date
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_v2;
## Changed date format from string to date
UPDATE layoffs_v2
SET date = STR_TO_DATE(`date`, '%m/%d/%Y');

-- stage
SELECT DISTINCT stage
FROM layoffs_v2
ORDER BY stage;

-- country
SELECT DISTINCT country
FROM layoffs_v2
ORDER BY country;
## Removed traling '.' from United States
UPDATE layoffs_v2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- funds_raised_millions
SELECT MAX(funds_raised_millions), MIN(funds_raised_millions)
FROM layoffs_v2;

-- 3) Check Null or Blank Values

SELECT *
FROM layoffs_v2;

-- Check null and blank values of industry column
SELECT *
FROM layoffs_v2
WHERE industry IS NULL OR  industry = '';

-- Changed blank values to null because easier to work with
UPDATE layoffs_v2
SET industry = NULL
WHERE industry = '';

-- Found the missing values and updated table
SELECT t1.company, t1.industry, t2.company, t2.industry
FROM layoffs_v2 AS t1
JOIN layoffs_v2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE layoffs_v2 AS t1
JOIN layoffs_v2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Other null values in total_laid_off, percentage_laid_off, date, stage and funds_raised_millions are fine for now

-- 4) Remove Irrelevant Data if any

SELECT *
FROM layoffs_v2;

-- Can't be used in analysis
SELECT *
FROM layoffs_v2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_v2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Was created for own use. Not needed for analysis
ALTER TABLE layoffs_v2
DROP COLUMN row_num;

-- Copying the clean data
CREATE TABLE layoffs_cleaned AS
SELECT *
FROM layoffs_v2;




