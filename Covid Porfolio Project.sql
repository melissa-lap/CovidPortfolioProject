SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ..CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths in US

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage
FROM CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL
order by 1,2

-- Looking at the countries with highest infection rate 

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY percent_population_infected DESC
-- 
-- Showing countries with the highest death count per population

SELECT location, MAX(CAST (total_deaths as int)) as highest_death_count
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY highest_death_count DESC

-- Breaking it down by continent - This may mess up the visualization Melissa

SELECT location, MAX(CAST(total_deaths as int)) as highest_death_count
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY highest_death_count DESC

-- this is incorrect data:

SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by continent
Order by TotalDeathCount desc


-- Global numbers


SELECT SUM(new_cases) as total_cases, sum(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/sum(new_cases)*100 as death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
order by 1,2


SELECT date, SUM(new_cases) as total_cases, sum(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/sum(new_cases)*100 as death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2


-- Total Population vs vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations as int)) OVER (partition by d.location ORDER BY d.location, d.date) as rolling_people_vaccinated
	FROM ..CovidDeaths d
JOIN ..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations as int)) OVER (partition by d.location ORDER BY d.location, d.date) as rolling_people_vaccinated
FROM ..CovidDeaths d
JOIN ..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
)
Select *, (rolling_people_vaccinated/population)*100 as percentage_population_vaccinated
FROM PopvsVac

-- Using Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations as int)) OVER (partition by d.location ORDER BY d.location, d.date) as rolling_people_vaccinated
FROM ..CovidDeaths d
JOIN ..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *, (Rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating viow

CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations as int)) OVER (partition by d.location ORDER BY d.location, d.date) as rolling_people_vaccinated
FROM ..CovidDeaths d
JOIN ..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL