Use portfolio_project_db

Select * 
from coviddeaths
order by 2,3;

Select * 
from covidvaccinations
order by 2,3;

-- Select data that we are going to use from coviddeaths table
Select location, date, total_cases, new_cases,
total_deaths, population
from coviddeaths
order by 1,2;


-- Total_cases vs total_deaths
-- shows likelihood of dying if yoy contract covid in your country 
Select location, date , total_cases, total_deaths,
(total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like '%A%'
order by 1,2; 


-- total cases vs population
-- shows the percentage of population got covid 
Select location, date , total_cases, total_deaths, population,
(total_cases/population)*100 as Infection_percentage
from coviddeaths
order by 1,2; 


-- countries with highest infection rate compared to population
Select location, population,
max(total_cases) as highest_infectionsCount,
max((total_cases/population))*100 as Highest_Infection_Rate
from coviddeaths
group by location, population
order by Highest_infection_Rate desc; 


-- Countries with highest death count per population
Select location, population,
max(total_deaths) as highest_deathCount,
max((total_deaths/population))*100 as Highest_death_Rate
from coviddeaths
group by location, population
order by Highest_death_Rate desc; 


-- Continents with highest death count per population
Select continent,
max(total_deaths) as highest_deathCount,
max((total_deaths/population))*100 as Highest_death_Rate
from coviddeaths
group by continent
order by Highest_death_Rate desc; 



-- Select location,
-- max(total_deaths) as highest_deathCount
-- from coviddeaths
-- where continent is null
-- group by location
-- order by highest_deathCount desc;


-- joining both coviddeaths and covidvaccine table based on
-- location and date
Select * 
from coviddeaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.date = vac.date;



-- total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations
from coviddeaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- to find the running total of new_vaccinations based on location 
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location 
order by location, date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- using CTE to find out the population vs vaccinatiom
With PopVSVac(
continent , location, date, population,
new_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location 
order by location, date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

Select *, 
(RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
from PopVSVac;


 








