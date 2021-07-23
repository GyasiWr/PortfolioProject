SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

-----------------Breaking it Down by Location -------------------


--Looking at Total cases vs the Total Deaths
--Mortality Rate of Covid Focusing on The United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2 DESC

--Total Cases vs the Population Focusing on The United States
--Population that was Infected

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PopInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--order by 1,2

--Countries Peak Infection vs the Population

SELECT Location, population, MAX(total_cases) as PeakInfection, MAX((total_cases/population))*100 as PeakPopInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by PeakPopInfected DESC

--Countries with the Highest Death Count vs Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

------------ Breaking it Down by Continent ----------------

-- Total Deaths Per Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


------------------ Worldwide Numbers -------------------


SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
order by 1,2

--- Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeoVacc
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using a CTE

WITH PopVsVacc (Continent, Location, date, population, new_vaccinations, RollingPeoVacc)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeoVacc

FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeoVacc/population)*100 as PercentVacc
FROM PopVsVacc

--Temp Table

DROP TABLE if exist #PercetnPopulationVaccinated
CREATE TABLE #PercetnPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccination numeric,
RollingPeoVacc numeric
)

INSERT INTO #PercetnPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeoVacc
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeoVacc/population)*100
FROM #PercetnPopulationVaccinated

---------------- Creating View for Later Visualizations --------------


CREATE VIEW PercetnPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeoVacc
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date
WHERE dea.continent is not null
--ORDER BY 2,3

CREATE VIEW MortalityRateOfCountries as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--order by 1,2 DESC

Create View PecentOfPopInfected as
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PopInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
--order by 1,2

CREATE VIEW PeakPopInfectedByCountry as 
SELECT Location, population, MAX(total_cases) as PeakInfection, MAX((total_cases/population))*100 as PeakPopInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
--order by PeakPopInfected DESC

Create view DeathCountByCountry as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
--ORDER BY TotalDeathCount DESC