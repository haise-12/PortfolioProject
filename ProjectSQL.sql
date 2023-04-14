CREATE DATABASE PortfolioProject
GO

USE PortfolioProject
GO


SELECT * 
from dbo.CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1, 2


--Looking at total cases and total deaths
-- Shows likihood of dying if you contract covid in your country
SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM dbo.CovidDeaths
WHERE [location] like '%state%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Looking at total cases of population
-- Show what percentage of population got covid 
SELECT [location], [date], total_cases, population, (total_cases/population)*100 AS PercentagePoputaionInfected
FROM dbo.CovidDeaths
WHERE [location] like '%VietNam%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to population

SELECT [location],population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePoputaionInfected
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location], population
ORDER BY PercentagePoputaionInfected DESC


--Showing Countries with highest death count per Population

SELECT [location], MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC   


-- let's break things downs by continent
--Showing continents with the highest death count per population

SELECT [location], MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT 
    --[date],
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    ROUND(SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100, 2) AS PercentageDeaths
FROM 
    dbo.CovidDeaths
WHERE 
    continent IS NOT NULL 
    AND new_cases > 0 -- add condition to exclude rows where new_cases is zero
--GROUP BY [date]
ORDER BY 
    1,2

--Looking at total popution vs vaccinations

SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location ,dea.date) AS RollingPeopelVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not null 
ORDER BY 2,3



--USE CTE 

WITH PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopelVaccinated)
AS
(
    SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location ,dea.date) AS RollingPeopelVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, RollingPeopelVaccinated/population*100 AS percentagePopVsVac
FROM PopVsVac
--WHERE [location] = 'Macao'
ORDER BY 2,3
--percentage pop vs vac (MAX)
-- SELECT  [location],MAX(RollingPeopelVaccinated/population*100) AS percentagePopVsVacMAX
-- FROM PopVsVac
-- GROUP BY location


-- USE temp table

DROP TABLE IF EXISTS #PercentagePopVac
CREATE TABLE #PercentagePopVac(
continent NVARCHAR(50),
location NVARCHAR(50),
date DATE,
population FLOAT,
new_vaccinations FLOAT,
RollingPeopelVaccinated FLOAT
)

INSERT INTO #PercentagePopVac
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location ,dea.date) AS RollingPeopelVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not null 

SELECT * , #PercentagePopVac.RollingPeopelVaccinated/population*100 AS percentagePopVsVac
FROM #PercentagePopVac



--Creating view to store data for later visualations

CREATE VIEW ViewPercentagePopVac 
AS
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location ,dea.date) AS RollingPeopelVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not null 


SELECT * 
FROM ViewPercentagePopVac
