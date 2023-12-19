--select *
--from PortfolioProject1.0.dbo.CovidDeathdec23
--order by 3,4

--select *
--from PortfolioProject1.0.dbo.CovidVaccinationdec23
--order by 3,4

--total deaths Vs total cases in Malaysia
select location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100 as DeathPercentage
from [PortfolioProject1.0].dbo.[covid death dec 23]
where location like 'Malays%'
order by 1,2

--Percentage of population got covid
select location, date, total_cases, population,  (total_cases/population)*100 as Population_infected_Percentage
from [PortfolioProject1.0].dbo.[covid death dec 23]
where location like 'Malays%'
order by 1,2

--Countries with Highest Infection Rate
select location, population, MAX(total_cases) as Highest_Infection_Rate ,  
MAX((total_cases/population)*100) as Highest_Population_Infection_Percentage
from [PortfolioProject1.0].dbo.[covid death dec 23]
where location like 'Malays%'
Group by location, population
order by Highest_Population_Infection_Percentage desc

--Countries with Highest Death Rate
select location, population, MAX(cast(total_deaths as int)) as Highest_Death_Rate ,  
MAX((total_deaths/population)*100) as Highest_Population_Death_Percentage
from [PortfolioProject1.0].dbo.[covid death dec 23]
where location like 'Malays%'
Group by location, population
order by Highest_Population_Death_Percentage desc

-- GROUP BY CONTINENT
select continent, MAX ( Convert(float, total_deaths)) as Total_Death_Count
from [PortfolioProject1.0].dbo.[covid death dec 23]
where continent is not null
group by continent
order by 2

-- Total Population vs Vaccinations 
select death.continent, Death.location, Death.date, Death.population, vacc.new_vaccinations
, SUM ( convert (float, Vacc.new_vaccinations)) 
OVER (partition by Death.location order by Death.location, death.date) as RollingPeopleVaccinated
from [PortfolioProject1.0]..[covid death dec 23] Death
join [PortfolioProject1.0]..[covid Vaccination dec 23] Vacc
	on death.location = vacc.location AND death.date = vacc.date
where death.continent is not null AND vacc.new_vaccinations is not null 
--and death.location like 'Malaysia%'
--order by 2,3

-- CTE
--Total Population vs Vaccinations
with PoppVSVacc (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, Death.location, Death.date, Death.population, vacc.new_vaccinations
, SUM ( convert (float, Vacc.new_vaccinations)) 
OVER (partition by Death.location order by Death.location, death.date) as RollingPeopleVaccinated
from [PortfolioProject1.0]..[covid death dec 23] Death
join [PortfolioProject1.0]..[covid Vaccination dec 23] Vacc
	on death.location = vacc.location AND death.date = vacc.date
where death.continent is not null AND vacc.new_vaccinations is not null 
--and death.location like 'Malaysia%'
)
select *, (RollingPeopleVaccinated/population)*100 as Percentage_of_VACCINATED
from PoppVSVacc
--order by 7 desc


-- TEMP TABLE
--Total Population vs Vaccinations
DROP table if exists #Percentage_of_VACCINATED
create table #Percentage_of_VACCINATED
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
RollingPeopleVaccinated float
)
insert into #Percentage_of_VACCINATED
select death.continent, Death.location, Death.date, Death.population, vacc.new_vaccinations
, SUM ( convert (float, Vacc.new_vaccinations)) 
OVER (partition by Death.location order by Death.location, death.date) as RollingPeopleVaccinated
from [PortfolioProject1.0]..[covid death dec 23] Death
join [PortfolioProject1.0]..[covid Vaccination dec 23] Vacc
	on death.location = vacc.location AND death.date = vacc.date
where death.continent is not null AND vacc.new_vaccinations is not null 
--and death.location like 'Malaysia%'
select * , (RollingPeopleVaccinated/population)*100 as Percentage_of_VACCINATED
from #Percentage_of_VACCINATED

