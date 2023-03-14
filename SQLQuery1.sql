ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float
ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations float

Select *
From SQLProject..CovidDeaths


Select Location, date, total_cases, total_deaths, Population, (total_deaths/Population)*100 as PopulationDeath, (total_deaths/total_cases)*100 as MortalityPercent, max((total_cases/Population)*100) as InfectionRate
From SQLProject..CovidDeaths


Select Location, Population, max((total_cases/Population)*100) as InfectionRate
From CovidDeaths
GROUP BY Location, Population
Order by InfectionRate DESC

Select Location, Population, max(total_deaths) as HighestDeaths, max((total_deaths/Population)*100) as MaxDeaths
From CovidDeaths
Where continent is NULL
GROUP BY Location, Population
Order by HighestDeaths DESC

Select Location, Population, max(total_deaths) as HighestDeaths, max((total_deaths/Population)*100) as MaxDeaths
From CovidDeaths
Where continent is NULL
GROUP BY Location, Population
Order by MaxDeaths DESC

--CTE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RunningVaccinations) as

(Select CovidDeaths.date, CovidDeaths.Location, CovidDeaths.Continent, CovidDeaths.Population, CovidVaccinations.new_vaccinations, sum(CovidVaccinations.new_vaccinations) OVER (Partition by CovidDeaths.Location ORDER BY CovidDeaths.date,CovidDeaths.Location) as RunningVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.date = CovidVaccinations.date
AND CovidDeaths.Location = CovidVaccinations.Location
--Order by 2,1
)

Select *, (RunningVaccinations/Population)*100 AS RunningVaccinationPercent From PopvsVac

--Temp TABLE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DROP Table if exists PercentPopVac
Create Table PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population float,
new_vaccinations float,
RunningVaccinations float
)

Insert into PercentPopVac
Select CovidDeaths.date, CovidDeaths.Location, CovidDeaths.Continent, CovidDeaths.Population, CovidVaccinations.new_vaccinations, sum(CovidVaccinations.new_vaccinations) OVER (Partition by CovidDeaths.Location ORDER BY CovidDeaths.date,CovidDeaths.Location) as RunningVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.date = CovidVaccinations.date
AND CovidDeaths.Location = CovidVaccinations.Location
--Order by 2,1

Select *, (RunningVaccinations/Population)*100 AS RunningVaccinationPercent From PercentPopVac

--Creating Views for Visualizations~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create View PercentPopulationVaccinatedByDateLocation as
Select CovidDeaths.date, CovidDeaths.Location, CovidDeaths.Continent, CovidDeaths.Population, CovidVaccinations.new_vaccinations, sum(CovidVaccinations.new_vaccinations) OVER (Partition by CovidDeaths.Location ORDER BY CovidDeaths.date,CovidDeaths.Location) as RunningVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.date = CovidVaccinations.date
AND CovidDeaths.Location = CovidVaccinations.Location
--Order by 2,1
