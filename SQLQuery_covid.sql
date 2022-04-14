SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL --remove null values
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total cases vs Total deaths-> get death rate
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
FROM PortfolioProject..CovidDeaths$
WHERE location like 'India'  
ORDER BY 1,2

--Total cases vs population-> what % of population got covid
SELECT location, date,  population, total_cases, (total_cases/population)*100 AS CaseRate
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE 'India'
ORDER BY 1,2

--Countries with highest case rate compared to population 
SELECT location,  population, MAX(total_cases) AS HighestCaseCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC

--Countries with highest Death Rate per population
SELECT location, population, MAX(cast(total_deaths AS INT)) AS HighestDeathCount, MAX((cast(total_deaths AS INT))/population)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathRate DESC

--Country with Highest deaths
SELECT location,MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--locations in dataset which are not countries
SELECT location,MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--ANALYSIS WRT CONTINENTS
-- continents in descending order of death count
SELECT continent,MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--GLOBAL NUMBERS
--Total number of cases globally
SELECT SUM(total_cases) AS TotalCases, SUM(cast(total_deaths AS INT)) AS TotalDeaths, SUM(cast(total_deaths AS INT))/SUM(total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date 
ORDER BY 1,2

--Cases and Deaths globally grouped by dates
SELECT date, SUM(total_cases) AS TotalCases, SUM(cast(total_deaths AS INT)) AS TotalDeaths, SUM(cast(total_deaths AS INT))/SUM(total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2

--Vaccinations
SELECT *
FROM PortfolioProject..CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY 3,4

--Joining deaths and vaccinations data
SELECT * 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL


--Total vaccinations  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Rolling count of vaccinated people
--CTE 
WITH PopvsVac (Continent, Location, date, Population, New_vaccinations, RollingPeopleVaccinated )
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VacPerPopulation
FROM PopvsVac


--temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated --to make alterations
CREATE TABLE #PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 as VacPerPopulation
FROM #PercentPopulationVaccinated

--Creating View
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated
