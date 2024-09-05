
--Total Cases vs Total Deaths


select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/nullif (total_cases,0))*100 as DeathPercentage


from CovidDeaths
where location like '%states%'
order by 1,2


--Total Cases vs Population

select 
	location,
	date,
	total_cases,
	population,
	(total_cases/nullif (population,0))*100 as DeathPercentage


from CovidDeaths
where location like '%states%'
order by 1,2


--Countries with highest infection rate

select 
	location,
	population,
	max(total_cases) as Highest_Infection_Count,
	max((total_cases/nullif (population,0)))*100 as Infected_Percentage 
	   
from CovidDeaths
group by location,population
order by Infected_Percentage desc




--Countries with the highest death count per population

select 
	location,
	max(cast(total_deaths as int)) as Total_Death_Count
	 
from CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc


--LET'S BREAK DOWN BY CONTINENT

select 
	continent,
	max(cast(total_deaths as int)) as Total_Death_Count
	   
from CovidDeaths
where continent is not null 
group by continent
order by Total_Death_Count desc


--Global Numbers

select 
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/coalesce(sum(new_cases),0)*100 as DeathPercentage


from CovidDeaths
where continent is not null
order by 1,2
	

--Total Population vs Vaccinations

Select 
	dea.continent,
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Use a CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select 
	dea.continent,
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--Temp Table

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select 
	dea.continent,
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating View for later visualizations

Create View PercentPopulationVaccinated as

Select 
	dea.continent,
	dea.location,
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 