
-- Cheking the CovidDeaths and CovidVacintions excel sheets for available information
SELECT * 
FROM CovidDeaths
ORDER BY 3,4

SELECT * 
FROM CovidVaccinations
ORDER BY 3,4

SELECT * 
FROM CovidDeaths

--Keeping the most useful rows
SELECT Location, date, population, total_cases, new_cases, total_deaths
FROM CovidDeaths
ORDER BY 1,2

--Death percentage using total_cases vs Total_deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 As DeathPercentage
FROM CovidDeaths 
WHERE Location = 'Asia'
ORDER BY 1,2

-- Number of people got effected with Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as EffectedPopulationPercentage
FROM CovidDeaths
WHERE LOCATION = 'ASIA'
ORDER BY 1,2

-- Countries with highest infection rate
SELECT Location, population, MAX(total_cases) as TotalCases,  MAX(total_cases/population)*100 as EffectedPopulationPercentage
FROM CovidDeaths
GROUP BY Location, population
ORDER BY EffectedPopulationPercentage DESC

--Country with Highest Deaths
SELECT Location, MAX(total_cases) CountryHighestDeaths
FROM CovidDeaths
GROUP BY Location
ORDER BY CountryHighestDeaths DESC

--Need to modify the data a bit by removing nulls in the continent
SELECT Location, MAX(total_cases) CountryHighestDeaths
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY CountryHighestDeaths DESC

--Cases sorted by date
SELECT date, SUM(new_cases) Datewise_Cases, SUM(cast(new_deaths as int)) Datewise_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 GlobalDeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total number of cases
SELECT SUM(new_cases) Totalcases, SUM(cast(new_deaths as int)) NumberofDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM CovidDeaths

--Join Cavid deaths with Covid Vaccinations
SELECT * 
FROM CovidDeaths as Death
JOIN CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	and Death.date = Vacc.date

--Vaccinated population out of total people around the world
SELECT Death.continent, Death.location, Death.date, population, Vacc.new_vaccinations
FROM CovidDeaths as Death
JOIN CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	and Death.date = Vacc.date
	--and Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
ORDER BY 1,2 

--Number of vaccinations increased by day
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations as int)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) Vacc.new_vaccinations
FROM CovidDeaths as Death
JOIN CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	and Death.date = Vacc.date
	--and Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
ORDER BY 2,3

--USE CTE 
WITH PopulationwithVacc (continent, location, date, population, new_vaccinations, Vacc_IncreasedbyDate)
as
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations as int)) OVER (PARTITION BY Death.location, Death.date) Vacc_IncreasedbyDate 
FROM CovidDeaths as Death
JOIN CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	and Death.date = Vacc.date
	--and Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Vacc_IncreasedbyDate/population)*100 AS PercentageIncrease
FROM PopulationwithVacc


--TEMP table
DROP TABLE IF EXISTS #PerPopulationVaccinated
CREATE TABLE #PerPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Vacc_IncreasedbyDate numeric
)
INSERT INTO #PerPopulationVaccinated
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations as int)) OVER (PARTITION BY Death.location, Death.date) Vacc_IncreasedbyDate 
FROM CovidDeaths as Death
JOIN CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	and Death.date = Vacc.date
	--and Death.date = Vacc.date
WHERE Death.continent IS NOT NULL

SELECT *, (Vacc_IncreasedbyDate/population)*100 AS PercentageIncrease
FROM #PerPopulationVaccinated

--Creating data for later visualisations

CREATE VIEW PerPopulationVaccinated as
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations as int)) OVER (PARTITION BY Death.location, Death.date) Vacc_IncreasedbyDate 
FROM CovidDeaths as Death
JOIN CovidVaccinations as Vacc
	ON Death.location = Vacc.location
	and Death.date = Vacc.date
	--and Death.date = Vacc.date
WHERE Death.continent IS NOT NULL

SELECT * 
FROM PerPopulationVaccinated