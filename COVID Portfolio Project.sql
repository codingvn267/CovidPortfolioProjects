SELECT *
FROM CovidDeaths$
Where continent is not NULL	
ORDER BY 3,4

--SELECT *
--FROM PorforlioProject..CovidVaccine$
--ORDER BY 3,4
-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
Where location like '%states%'
ORDER BY 1,2
-- Looking at the total cases vs population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage
FROM CovidDeaths$
Where location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location,  population, MAX (total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths$
GROUP BY location, population
ORDER BY 4 desc
-- Showing countries with highest Death Count per Population
-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX (cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
Where continent is not NULL	
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT location, MAX (cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
Where continent is NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT date, SUM (new_cases) as total_cases, SUM (cast(new_deaths as float)) as total_deaths, SUM (cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2 

-- Looking at Total Population vs Vaccinations
-- USE CTE


WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccine$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population) *100
FROM PopvsVac

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW PopvsVac as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccine$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT*
FROM PopvsVac