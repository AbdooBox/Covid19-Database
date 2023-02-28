select *
from PORTOFOLIO..[covid death upd]
where continent is not null
order by 3,4

select *
from PORTOFOLIO..[covidVaccinationupd]
order by 3,4

select location, date, total_cases,new_cases, total_deaths, population
from PORTOFOLIO..[covid death upd]
where continent is not null
order by 1,2

-- Looking at total cases VS total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PORTOFOLIO..[covid death upd]
where location like '%turkey%'
and continent is not null
order by 1,2

-- Looking at total cases VS Population
--shows what percentage of population got covid

select location, date, Population,total_cases, (total_cases/Population)*100 as CovidPercentage
from PORTOFOLIO..[covid death upd]
where location like '%turkey%'
order by 1,2

-- looking at countries with highest Infection Rate compared to population

select location, Population, max(total_cases)as HighestInfectionCount, MAX(total_cases/Population)*100 as PercentPopulationInfected
from PORTOFOLIO..[covid death upd]
--where location like '%turkey%'
Group by location, Population 
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PORTOFOLIO..[covid death upd]
--where location like '%turkey%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's Break Thigs down by continent with the highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PORTOFOLIO..[covid death upd]
--where location like '%turkey%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

select sum(new_cases)as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from PORTOFOLIO..[covid death upd]
--where location like '%turkey%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as SumOfVac
--,(SumOfVac/population )*100
from PORTOFOLIO..[covid death upd] dea
Join PORTOFOLIO..[covidVaccinationupd] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Total Vaccinations In each Country Vs population

select dea.location,dea.population, max(cast(total_deaths as int)) as TotalDeathCount,
 max(cast(vac.new_vaccinations as bigint)/dea.population)*100 as PercentPopulationVaccinated
--,(SumOfVac/population )*100
from PORTOFOLIO..[covid death upd] dea
Join PORTOFOLIO..[covidVaccinationupd] vac
     on dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null 
Group by dea.location,dea.population
order by TotalDeathCount desc


--use CTE

with PopvsVac (continent, Location, Date, population,new_vaccinations, SumOfVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as SumOfVac
--,(SumOfVac/population )*100
from PORTOFOLIO..[covid death upd] dea
Join PORTOFOLIO..[covidVaccinationupd] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select* ,(SumOfVac/population )*100 as VacPopRate
from PopvsVac


-- Using Temp Table to make Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
SumOfVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as SumOfVac
--, (SumOfVac/population)*100 as per
from PORTOFOLIO..[covid death upd] dea
Join PORTOFOLIO..[covidVaccinationupd] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (SumOfVac/Population)*100
From #PercentPopulationVaccinated


 --Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as SumOfVac
--, (SumOfVac/population)*100
from PORTOFOLIO..[covid death upd] dea
Join PORTOFOLIO..[covidVaccinationupd] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select*
from PercentPopulationVaccinated



/*

Queries used for Tableau Project

*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
From PORTOFOLIO..[covid death upd]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2. 
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PORTOFOLIO..[covid death upd]
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Low income', 'Lower middle income')
Group by location
order by TotalDeathCount desc


-- 3.

--Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
--From PORTOFOLIO..[covid death upd]
----Where location like '%states%'
--Group by Location, Population
--order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PORTOFOLIO..[covid death upd]
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

--5.map of the Population Vaccinated Percentage

select dea.location,dea.population, max(cast(total_deaths as int)) as TotalDeathCount, 
MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/population))*100 as PercentPopulationInfected,
max(cast(vac.new_vaccinations as bigint)/dea.population)*100 as PercentPopulationVaccinated
--,(SumOfVac/population )*100
from PORTOFOLIO..[covid death upd] dea
Join PORTOFOLIO..[covidVaccinationupd] vac
     on dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null 
Group by dea.location,dea.population
order by TotalDeathCount desc
