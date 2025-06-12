-- CREATE DATABASE covid;

-- Explore and Test the Data
SELECT * FROM covid..covid_deaths
ORDER BY 3,4;

SELECT * FROM covid..covid_vaccinations
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM covid..covid_deaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths:
-- Shows likelihood of dying if you get diagnosed with Covid
-- Can be filtered via country, here I have filtered for United States
SELECT location, date, total_cases, total_deaths, (total_deaths*100.0/total_cases) as death_rate_pct
FROM covid..covid_deaths
WHERE total_cases <> 0  -- avoid division by 0
AND location LIKE '%States%'
AND continent IS NOT NULL 
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- What percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases*100.0/ population) as infected_population_pct
FROM covid..covid_deaths
WHERE total_cases <> 0  -- avoid division by 0
AND location LIKE '%States%'
AND continent IS NOT NULL 
ORDER BY 1,2;

-- Looking at Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases*100.0/ population)) as infected_population_pct
FROM covid..covid_deaths
WHERE total_cases <> 0  -- avoid division by 0
-- AND continent IS NOT NULL
GROUP BY location, population
ORDER BY infected_population_pct desc;

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as total_death_count
FROM covid..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count desc;

-- By Continent

-- Showing the continents with the highest death couny per population
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count desc;

-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)*100.0/SUM(new_cases)) as death_rate_pct
FROM covid..covid_deaths
WHERE new_cases <> 0  -- avoid division by 0
  AND continent IS NOT NULL 
ORDER BY 1,2;

-- Looking at Total Population vs Total Vaccinations
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_count_people_vaccination -- gets the rolling count of vaccinations
FROM covid..covid_vaccinations AS vac
JOIN covid..covid_deaths AS death
    ON death.location = vac.location 
    AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3; 

-- Want to use the rolling_count_vaccination for further aggregation and calculation
-- Let's dive in using CTE:
WITH pop_vs_vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Count_People_Vaccinated)
AS 
(
   SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_count_people_vaccination -- gets the rolling count of vaccinations
    FROM covid..covid_vaccinations AS vac
    JOIN covid..covid_deaths AS death
        ON death.location = vac.location 
        AND death.date = vac.date
    WHERE death.continent IS NOT NULL 
)
SELECT *, (Rolling_Count_People_Vaccinated * 100.0 / Population) 
FROM pop_vs_vac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Count_People_Vaccinated numeric
) ;

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_count_people_vaccination -- gets the rolling count of vaccinations
    FROM covid..covid_vaccinations AS vac
    JOIN covid..covid_deaths AS death
        ON death.location = vac.location 
        AND death.date = vac.date;

SELECT * 
FROM #PercentPopulationVaccinated;

-- CREATE MORE meaningful VIEWS
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_count_people_vaccination -- gets the rolling count of vaccinations
    FROM covid..covid_vaccinations AS vac
    JOIN covid..covid_deaths AS death
        ON death.location = vac.location 
        AND death.date = vac.date; 

