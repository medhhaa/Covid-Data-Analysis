-- CREATE DATABASE covid;

-- Explore and Test the Data
-- Check raw structure of both datasets to understand available columns
SELECT * FROM covid..covid_deaths ORDER BY 3,4;
SELECT * FROM covid..covid_vaccinations ORDER BY 3,4;

-- Quick look at daily reported cases and deaths
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM covid..covid_deaths
ORDER BY 1,2;

-- Total Cases vs Total Deaths: Indicator of fatality risk by country
SELECT location, date, total_cases, total_deaths, 
       (total_deaths*100.0/total_cases) as death_rate_pct
FROM covid..covid_deaths
WHERE total_cases <> 0  -- avoid division by 0
  AND location LIKE '%States%'
  AND continent IS NOT NULL 
ORDER BY 1,2;

-- Total Cases vs Population: Infection rate compared to entire population
SELECT location, date, population, total_cases, 
       (total_cases*100.0/ population) as infected_population_pct
FROM covid..covid_deaths
WHERE total_cases <> 0
  AND location LIKE '%States%'
  AND continent IS NOT NULL 
ORDER BY 1,2;

-- Highest Infection Rate vs Population: Countries with most widespread outbreaks
SELECT location, population, MAX(total_cases) as highest_infection_count, 
       MAX((total_cases*100.0/ population)) as infected_population_pct
FROM covid..covid_deaths
WHERE total_cases <> 0
GROUP BY location, population
ORDER BY infected_population_pct DESC;

-- Countries with Highest Absolute Death Count
SELECT location, MAX(total_deaths) as total_death_count
FROM covid..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Continents with Highest Death Count
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global Aggregates for Total Cases and Deaths
SELECT SUM(new_cases) AS total_cases, 
       SUM(new_deaths) as total_deaths, 
       (SUM(new_deaths)*100.0/SUM(new_cases)) as death_rate_pct
FROM covid..covid_deaths
WHERE new_cases <> 0
  AND continent IS NOT NULL 
ORDER BY 1,2;

-- Total Vaccinations and Rolling Count per Location/Date
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as rolling_count_people_vaccination -- gets the rolling count of vaccinations
FROM covid..covid_vaccinations AS vac
JOIN covid..covid_deaths AS death
  ON death.location = vac.location AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3; 

-- CTE: Calculating % Population Vaccinated
WITH pop_vs_vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Count_People_Vaccinated) AS 
(
  SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
         SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
  FROM covid..covid_vaccinations AS vac
  JOIN covid..covid_deaths AS death
    ON death.location = vac.location AND death.date = vac.date
  WHERE death.continent IS NOT NULL 
)
SELECT *, (Rolling_Count_People_Vaccinated * 100.0 / Population) AS percent_vaccinated
FROM pop_vs_vac;

-- Temp Table for % Population Vaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  Rolling_Count_People_Vaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
FROM covid..covid_vaccinations AS vac
JOIN covid..covid_deaths AS death
  ON death.location = vac.location AND death.date = vac.date;

SELECT * FROM #PercentPopulationVaccinated;

-- View for Reusable Vaccination Stats
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
FROM covid..covid_vaccinations AS vac
JOIN covid..covid_deaths AS death
  ON death.location = vac.location AND death.date = vac.date;

SELECT * FROM PercentPopulationVaccinated; 

-- Full COVID Statistics View (Join both tables + rolling vaccination count)
CREATE VIEW CovidFullStats AS
SELECT death.continent, death.location, death.date, death.population,
       death.total_cases, death.total_deaths, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
       AS rolling_count_people_vaccination
FROM covid..covid_deaths AS death
JOIN covid..covid_vaccinations AS vac
  ON death.location = vac.location AND death.date = vac.date
WHERE death.continent IS NOT NULL;

SELECT * FROM CovidFullStats;

-- Identify High-Risk Countries: High case count + death rate + low vaccination
CREATE VIEW HighRiskCountries AS
SELECT location,
       MAX(total_cases) AS max_cases,
       MAX(total_deaths) AS max_deaths,
       MAX(total_deaths) * 100.0 / NULLIF(MAX(total_cases),0) AS death_rate_pct,
       MAX(rolling_count_people_vaccination) * 100.0 / NULLIF(MAX(population),0) AS percent_vaccinated
FROM CovidFullStats
GROUP BY location
HAVING MAX(total_cases) > 500000;

SELECT * FROM HighRiskCountries ORDER BY death_rate_pct DESC;
