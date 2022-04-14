--GLOBAL COUNTS
CREATE VIEW GlobalTotal AS
SELECT SUM(total_cases) AS TotalCases, SUM(cast(total_deaths AS INT)) AS TotalDeaths, SUM(cast(total_deaths AS INT))/SUM(total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL

-- HIGHEST DEATH COUNT PER CONTINENT
CREATE VIEW TotalDeathCountPerContinent AS
SELECT continent,MAX(CONVERT(INT,total_deaths)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent

/*SELECT * 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL*/

--HIGHEST CASE COUNTS AND % OF POPULATION INFECTED 
CREATE VIEW HighestCaseCounts AS
SELECT location, population, MAX(total_cases) AS HighestCaseCount, (MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY location, population

CREATE VIEW HighCountWithDate AS
SELECT location, population, date, MAX(total_cases) AS HighestCaseCount, (MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY location, population,date
