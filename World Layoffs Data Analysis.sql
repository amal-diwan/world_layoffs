-- World Layoffs Data Analysis

SELECT *
FROM layoffs_cleaned;

-- What were the total layoffs
SELECT SUM(total_laid_off) as total_layoffs
FROM layoffs_cleaned;

-- What is the average layoffs in a month
WITH layoffs_per_month AS
(
	SELECT DATE_FORMAT(`date`, '%Y-%m') as dates, SUM(total_laid_off) as total_layoffs
	FROM layoffs_cleaned
	GROUP BY dates
)
SELECT ROUND(AVG(total_layoffs), 2) as avg_layoffs_per_month
FROM layoffs_per_month;

-- What are the total funds raised
SELECT SUM(funds_raised_millions) as total_funds_raised
FROM layoffs_cleaned;

-- Which year had the highest layoffs
SELECT YEAR(`date`) AS years, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_cleaned
WHERE `date` IS NOT NULL
GROUP BY years
ORDER BY sum_laid_off DESC
LIMIT 1;

-- Which company has the highest layoffs
SELECT company, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_cleaned
WHERE company IS NOT NULL
GROUP BY company
ORDER BY sum_laid_off DESC
LIMIT 1;

-- Which industries were the most impacted
SELECT industry, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_cleaned
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY sum_laid_off DESC
LIMIT 10;

-- What is the average layoff per industry
SELECT industry, ROUND(AVG(total_laid_off),2) AS avg_laid_off
FROM layoffs_cleaned
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY avg_laid_off DESC;

-- Which countires were the most impacted
SELECT country, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_cleaned
WHERE country IS NOT NULL
GROUP BY country
ORDER BY sum_laid_off DESC
LIMIT 10;


-- What is the trend in layoffs overtime
SELECT DATE_FORMAT(`date`, '%Y-%m') AS dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned
WHERE `date` IS NOT NULL
GROUP BY dates
ORDER BY dates ASC;

-- What is the relationship between company size and layoffs
WITH company_size AS
(
	SELECT total_laid_off,
		ROUND(total_laid_off / percentage_laid_off) AS estimated_employees
	FROM layoffs_cleaned
	WHERE percentage_laid_off > 0 AND total_laid_off IS NOT NULL
)
SELECT
	CASE
		WHEN estimated_employees BETWEEN 200000 AND 500000 THEN 'Enterprise'
		WHEN estimated_employees BETWEEN 50000 AND 199999 THEN 'Large'
		WHEN estimated_employees BETWEEN 10000 AND 49999 THEN 'Medium'
		WHEN estimated_employees BETWEEN 1000 AND 9999 THEN 'Small'
		WHEN estimated_employees BETWEEN 0 AND 999 THEN 'Startup'
		ELSE 'Other'
	END AS size_category,
    SUM(total_laid_off) AS sum_laid_off
FROM company_size
GROUP BY size_category
ORDER BY sum_laid_off DESC;

-- What is the relationship between funds raised and layoffs
SELECT
	CASE
		WHEN funds_raised_millions BETWEEN 75000 AND 125000 THEN 'Very High'
		WHEN funds_raised_millions BETWEEN 15000 AND 74999 THEN 'High'
		WHEN funds_raised_millions BETWEEN 1000 AND 14999 THEN 'Meduim'
		WHEN funds_raised_millions BETWEEN 100 AND 999 THEN 'Low'
		WHEN funds_raised_millions BETWEEN 0 AND 99 THEN 'Very Low'
		ELSE 'Other'
	END AS funds_category,
    SUM(total_laid_off) AS sum_laid_off
FROM layoffs_cleaned
WHERE funds_raised_millions IS NOT NULL
GROUP BY funds_category
ORDER BY sum_laid_off DESC;