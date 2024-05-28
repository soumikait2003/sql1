-- Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select * 
FROM [Covid Data Exploration]..CovidDeaths
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Data Exploration]..CovidDeaths
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, CAST(total_deaths AS decimal) /total_cases *100 as DeathPercentage
From [Covid Data Exploration]..CovidDeaths
Where location like '%india%' 
and continent is not null 
order by 1,2

-- Looking at Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population) *100 as DeathPercentage
From [Covid Data Exploration]..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2

-- Looking at Countries with Highest Infected Rate Compared to Population 

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Covid Data Exploration]..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 


-- Showing Countries with the Highest Death Count Per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [Covid Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with the Highest Death Count Per Population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM [Covid Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing the Global Percentage

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(CAST (new_deaths as decimal))/SUM(CAST(new_cases as decimal)))*100 AS DeathPercentage
FROM [Covid Data Exploration]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- JOINING Covid Deaths and Vaccinations

SELECT *
FROM [Covid Data Exploration]..CovidDeaths dea 
JOIN [Covid Data Exploration]..CovidVaccinations vac 
ON dea.[location] = vac.[location] and dea.[date] = vac.[date]

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Covid Data Exploration]..CovidDeaths dea 
JOIN [Covid Data Exploration]..CovidVaccinations vac 
ON dea.[location] = vac.[location] and dea.[date] = vac.[date]
WHERE dea.continent is not NULL
ORDER BY 2,3

-- Vaccination Percentage by Country

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Covid Data Exploration]..CovidDeaths dea 
JOIN [Covid Data Exploration]..CovidVaccinations vac 
ON dea.[location] = vac.[location] and dea.[date] = vac.[date]
WHERE dea.continent is not NULL 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

 -- Creating a New View For VaccinationPercentage
 
CREATE VIEW VaccinationPercentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Covid Data Exploration]..CovidDeaths dea 
JOIN [Covid Data Exploration]..CovidVaccinations vac 
ON dea.[location] = vac.[location] and dea.[date] = vac.[date]
WHERE dea.continent is not NULL
