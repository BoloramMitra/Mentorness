
-- To avoid any errors, check missing value / null value 

use CovidData;

-- Q1. Write a code to check NULL value

SELECT *
FROM Corona
WHERE Province IS NULL OR
Country IS NULL OR
Latitude IS NULL OR
Longitude IS NULL OR
Date IS NULL OR
Confirmed IS NULL OR
Deaths IS NULL OR
Recovered IS NULL;

-- Q2. If NULL values are present, update them with zeros for all columns. 

SELECT 
    COALESCE(Province, 0) AS Province,
    COALESCE(Country, 0) AS Country,
    COALESCE(Latitude, 0) AS Latitude,
    COALESCE(Longitude, 0) AS Longitude,
    COALESCE(Date, 0) AS Date,
    COALESCE(Confirmed, 0) AS Confirmed,
    COALESCE(Deaths, 0) AS Deaths,
    COALESCE(Recovered, 0) AS Recovered
FROM Corona;

-- Q3. check total number of rows

Select count(*) as total_number_of_rows
from corona;

-- Q4. Check what is start_date and end_date

Select Min(Date) as Start_date,
       Max(Date) as End_date
from corona;

-- Q5. Number of month present in dataset

Select count(distinct(Month(date))) as count_of_month
from corona;
-- ---------------------------------------------------------OR
Select distinct(Month(date)) as No_of_Mon
from corona;

-- Q6. Find monthly average for confirmed, deaths, recovered

Select Monthname(Date) as Name_of_the_Month,  /*Month wise avg*/
       Round(Avg(Confirmed),2) as Avg_confirmed,
	   Round(Avg(Deaths),2) as Avg_Deaths,
       Round(Avg(Recovered),2) as Avg_Recovered
From corona
Group by Monthname(Date);
-- ---------------------------------------------------------OR
SELECT 
    YEAR(Date) AS Years,  /*Yearwise Monthly avg*/
    Month(Date) AS Months,
    Round(AVG(Confirmed),2) AS AvgConfirmed,
    Round(AVG(Deaths),2) AS AvgDeaths,
    Round(AVG(Recovered),2) AS AvgRecovered
FROM Corona
GROUP BY YEAR(Date), Month(Date)
ORDER BY Years,Months;

-- Q7. Find most frequent value for confirmed, deaths, recovered each month 

SELECT ConfirmedCount, Confirmed, DeathsCount, Deaths, RecoveredCount, Recovered, Months, Years
FROM (SELECT 
	COUNT(Confirmed) AS ConfirmedCount, Confirmed, 
	COUNT(Deaths) AS DeathsCount, Deaths, 
	COUNT(Recovered) AS RecoveredCount, Recovered,
	MONTH(Date) AS Months, YEAR(Date) AS Years,
	DENSE_RANK() OVER (PARTITION BY MONTH(Date), YEAR(Date) ORDER BY COUNT(Confirmed) DESC) AS RankedConfirmed,
	DENSE_RANK() OVER (PARTITION BY MONTH(Date), YEAR(Date) ORDER BY COUNT(Deaths) DESC) AS RankedDeaths,
	DENSE_RANK() OVER (PARTITION BY MONTH(Date), YEAR(Date) ORDER BY COUNT(Recovered) DESC) AS RankedRecovered
    FROM Corona
    GROUP BY Confirmed, Deaths, Recovered, MONTH(Date), YEAR(Date)
) AS subquery
WHERE RankedConfirmed = 1 AND RankedDeaths = 1 AND RankedRecovered = 1
ORDER BY Years, Months;

-- Q8. Find minimum values for confirmed, deaths, recovered per year

Select Min(confirmed), Min(deaths), Min(recovered), Year(date) as years
from corona
group by Year(date);

-- Q9. Find maximum values of confirmed, deaths, recovered per year

Select Max(confirmed), Max(deaths), Max(recovered), Year(date) as years
from corona
group by Year(date);

-- Q10. The total number of case of confirmed, deaths, recovered each month

Select Sum(confirmed) as total_confirmed_cases,
	   Sum(deaths) as total_deaths,
       Sum(Recovered) as total_recovered,
       Year(date) as Years, Month(Date) as Months
From Corona
group by Year(date),Month(Date)
order by Years;

-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT Round(SUM(Confirmed),2) AS TotalConfirmedCases,
       Round(AVG(Confirmed),2) AS AverageConfirmedCases,
       Round(VARIANCE(Confirmed),2) AS VarianceConfirmedCases,
       Round(STDDEV(Confirmed),2) AS StdDevConfirmedCases
FROM Corona;

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT 
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    Round(SUM(Deaths),2) AS TotalDeathCases,
    Round(AVG(Deaths),2) AS AverageDeathCases,
    Round(VARIANCE(Deaths),2) AS VarianceDeathCases,
    Round(STDDEV(Deaths),2) AS StdDevDeathCases
FROM Corona
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;

-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT 
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    ROUND(SUM(Recovered), 2) AS TotalRecoveredCases,
    ROUND(AVG(Recovered), 2) AS AverageRecoveredCases,
    ROUND(VARIANCE(Recovered), 2) AS VarianceRecoveredCases,
    ROUND(STDDEV(Recovered), 2) AS StdDevRecoveredCases
FROM Corona
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;

-- Q14. Find Country having highest number of the Confirmed case

SELECT Country, Confirmed  /* Highest confirmed number in a single month */
FROM Corona
WHERE Confirmed = (SELECT MAX(Confirmed) FROM Corona);

-- ------------------------------------------------OR

SELECT Country, MAX(Confirmed) AS MaxConfirmedCases  
FROM Corona
GROUP BY Country  /* Highest confirmed number in a single month */
ORDER BY MaxConfirmedCases DESC
LIMIT 1;

-- -----------------------------------------------OR

Select Sum(Confirmed) as TotalConfirmedCases, Country
From Corona
Group by Country  /* Highest total confirmed number */
Order by TotalConfirmedCases DESC Limit 1;

-- Q15. Find Country having lowest number of the death case

Select Sum(Deaths) as TotalDeaths, Country
From Corona
Group by Country
Order by TotalDeaths;

-- ---------------------------------------------OR

WITH CountryDeaths AS (
SELECT Country,SUM(Deaths) AS TotalDeaths,
DENSE_RANK() OVER (ORDER BY SUM(Deaths)) AS DeathRank
FROM Corona
GROUP BY Country
)
SELECT Country,TotalDeaths
FROM CountryDeaths
WHERE DeathRank = 1;


-- Q16. Find top 5 countries having highest recovered case

Select Country, SUM(Recovered) as TotalRecoveredCases
From Corona
Group by Country
Order by TotalRecoveredCases DESC Limit 5;
