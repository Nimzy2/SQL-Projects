/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views,
*/

Select *
from `covid-415419.Covid.covid_deaths`
order by 3,4


-- Select Data that we are going to be starting with

select location,date,total_cases,new_cases,total_deaths,population
from `covid-415419.Covid.covid_deaths`
where continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from `covid-415419.Covid.covid_deaths`
where location = 'Kenya'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location,date,population,total_cases,(total_cases/population)*100 as population_infected_percentage 
from `covid-415419.Covid.covid_deaths`
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location,population,MAX(total_cases) as Highest_infection,MAX((total_cases/population))*100 as percent_population_infected 
from `covid-415419.Covid.covid_deaths`
group by location,population  
order by percent_population_infected desc


-- Countries with Highest Death Count per Population

select location, Max(total_deaths) as total_death_count
from `covid-415419.Covid.covid_deaths`
where continent is not null
group by location
order by total_death_count desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, Max(total_deaths) as total_death_count
from `covid-415419.Covid.covid_deaths`
where continent is not null
group by continent
order by total_death_count desc



-- GLOBAL NUMBERS

select date,sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as global_death_percentange
from `covid-415419.Covid.covid_deaths`
where continent is not null
group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


