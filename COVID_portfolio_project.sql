/*
Covid 19 Data Exploration

Skills used: JOINs, CTE's, Temp tables, Windows functions, Aggregate functions, Creating views, Converting data types

*/

SELECT *
FROM
	PortfolioProjects.dbo.CovidDeaths
WHERE
	continent is not null
ORDER BY
	3,4


--Select Data that we are going to be starting with

SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	PortfolioProjects.dbo.CovidDeaths
WHERE
	continent is not null
ORDER BY
	1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM
	PortfolioProjects.dbo.CovidDeaths
WHERE
	location like '%states%'
	and continent is not null
ORDER BY
	1,2


--Looking at Total Cases vs Population
--Shows what percentage of people contracted Covid

SELECT
	location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 AS PercentPopulationInfected
FROM
	PortfolioProjects.dbo.CovidDeaths
WHERE
	location like '%states%'
ORDER BY
	1,2


--Countries with highest infection rate compared to population

SELECT
	location,
	MAX(total_cases) AS HighestInfectionCount,
	population,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM
	PortfolioProjects.dbo.CovidDeaths
GROUP BY
	location,
	population
ORDER BY
	PercentPopulationInfected DESC


--Countries with the highest death count per population

SELECT
	location,
	MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM
	PortfolioProjects.dbo.CovidDeaths
WHERE
	continent is not null
GROUP BY
	location
ORDER BY
	TotalDeathCount DESC


--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

SELECT
	continent,
	MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM
	PortfolioProjects.dbo.CovidDeaths
WHERE
	continent is not null
GROUP BY
	continent
ORDER BY
	TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT
	date,
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM
	PortfolioProjects.dbo.CovidDeaths
WHERE
	continent is not null
GROUP BY
	date
ORDER BY
	1,2


--Total population vs vaccinations
--Shows percentage of population that has received at least one Covid vaccine

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/population)*100
FROM
	PortfolioProjects.dbo.CovidDeaths AS dea
JOIN 
	PortfolioProjects.dbo.CovidVaccinations AS vac
	ON
	dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY
	2,3


--Using CTE to perform calculation on PARTITION BY in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/population)*100
FROM
	PortfolioProjects.dbo.CovidDeaths AS dea
JOIN 
	PortfolioProjects.dbo.CovidVaccinations AS vac
	ON
	dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
--ORDER BY
--	2,3
)
SELECT *,
	(RollingPeopleVaccinated/population)*100
FROM
	PopvsVac


--Using Temp table to perform calculation on PARTITION BY in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/population)*100
FROM
	PortfolioProjects.dbo.CovidDeaths AS dea
JOIN 
	PortfolioProjects.dbo.CovidVaccinations AS vac
	ON
	dea.location = vac.location
	AND dea.date = vac.date
--WHERE
--	dea.continent is not null
--ORDER BY
--	2,3

SELECT
	*,
	(RollingPeopleVaccinated/population)*100
FROM
	#PercentPopulationVaccinated


--Creating view to store data for later visualizations

USE PortfolioProjects
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/population)*100
FROM
	PortfolioProjects.dbo.CovidDeaths AS dea
JOIN 
	PortfolioProjects.dbo.CovidVaccinations AS vac
	ON
	dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
