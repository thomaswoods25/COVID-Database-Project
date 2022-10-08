select *
From [Personal Portfolio Project].dbo.CovidDeaths
Where continent is not null
order by 3,4

Select *
from [Personal Portfolio Project].dbo.CovidVaccinations
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Personal Portfolio Project].dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Personal Portfolio Project].dbo.CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Personal Portfolio Project].dbo.CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Personal Portfolio Project].dbo.CovidDeaths
-- Where Location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc
--Data shows Crypus is the leading country with the highest percent population infected
-- 1. Crypus, 2. Faeroe Islands, 3. San Marino

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Personal Portfolio Project].dbo.CovidDeaths
-- Where Location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing Continets with Highest Death Count per Population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Personal Portfolio Project].dbo.CovidDeaths
-- Where Location like '%states%'
Where continent is not null 
Group by Continent
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases) *100 as DeathPercentage
From [Personal Portfolio Project].dbo.CovidDeaths
-- Where Location like '%states%'
where continent is not null
Group by date
order by 1,2

--Total Global Number

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases) *100 as DeathPercentage
From [Personal Portfolio Project].dbo.CovidDeaths
-- Where Location like '%states%'
where continent is not null
-- Group by date
order by 1,2

-- Using Covid Vaccinations Table Now

Select *
from [Personal Portfolio Project]..CovidVaccinations

-- Joining Covid Deaths and Covid Vaccination tables

Select *
from [Personal Portfolio Project]..CovidDeaths
join [Personal Portfolio Project]..CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date

-- Looking at Total Population vs Vaccinations

Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
from [Personal Portfolio Project]..CovidDeaths
join [Personal Portfolio Project]..CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3

-- Looking at Total Population vs Vaccinations
-- Make sure you use BIGINT
 
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.Date) as RollingPeopleVaccinated
from [Personal Portfolio Project]..CovidDeaths
join [Personal Portfolio Project]..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Personal Portfolio Project]..CovidDeaths
join [Personal Portfolio Project]..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Personal Portfolio Project]..CovidDeaths
join [Personal Portfolio Project]..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations
--Temp Views are not being allowed -- fix later

Create View #PercentPopulationVaccinated as
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Personal Portfolio Project]..CovidDeaths
join [Personal Portfolio Project]..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3