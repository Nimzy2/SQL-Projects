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

  select death.continent, 
    death.location, 
    death.date, 
    vaccination.new_vaccinations,
    death.population, 
    SUM(vaccination.new_vaccinations) OVER (PARTITION BY death.location order by death.location,death.date) as Rolling_people_vaccinated
from `covid-415419.Covid.covid_deaths` as death
join `covid-415419.Covid.covid_vaccinations` as vaccination
    on death.location = vaccination.location
    and death.date = vaccination.date
where death.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PercentPopulationVaccinated AS (
  SELECT 
    death.continent, 
    death.location, 
    death.date AS Date, 
    death.population, 
    vaccination.new_vaccinations AS New_vaccinations, 
    SUM(vaccination.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_people_vaccinated
  FROM 
    `covid-415419.Covid.covid_deaths` AS death
  JOIN 
    `covid-415419.Covid.covid_vaccinations` AS vaccination
  ON 
    death.location = vaccination.location
    AND death.date = vaccination.date
  WHERE 
    death.continent IS NOT NULL
)
SELECT 
  continent, 
  location, 
  Date, 
  population, 
  New_vaccinations, 
  Rolling_people_vaccinated, 
  (Rolling_people_vaccinated / population) * 100 AS Percentage
FROM 
  PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

CREATE VIEW `covid-415419.Covid.PercentPopulationVaccinated` AS
SELECT 
    death.continent, 
    death.location, 
    death.date, 
    vaccination.new_vaccinations,
    death.population, 
    SUM(vaccination.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Rolling_people_vaccinated
FROM 
    `covid-415419.Covid.covid_deaths` AS death
JOIN 
    `covid-415419.Covid.covid_vaccinations` AS vaccination
ON 
    death.location = vaccination.location
    AND death.date = vaccination.date
WHERE 
    death.continent IS NOT NULL;

-- Creating View to store data for later visualizations
create view `covid-415419.Covid.ContinentTotalDeaths` as
select
    continent, 
    MAX(total_deaths) as total_death_count
from 
    `covid-415419.Covid.covid_deaths`
where
    continent is not null
group by
    continent
order by
    total_death_count desc;

-- Creating View to store data for later visualizations

create view `covid-415419.Covid.GlobalCovidStats` as
select date,sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as global_death_percentange
from `covid-415419.Covid.covid_deaths`
where continent is not null
group by date
order by 1,2

	
-- Creating View to store data for later visualizations

create view `covid-415419.Covid.LocationTotalDeaths` as
select location, Max(total_deaths) as total_death_count
from `covid-415419.Covid.covid_deaths`
where continent is not null
group by location
order by total_death_count desc

