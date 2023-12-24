select * 
From PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Nigeria%'
where continent is not NULL
order by 1,2


Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not NULL
order by 1,2


Select location, population, MAX(total_cases) as HighestInfectedPopulation, MAX((total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not NULL
group by location, population
order by InfectedPopulationPercentage desc

Select location, MAX(cast(total_deaths as int)) as HighestDeathCounts
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not NULL
group by location
order by HighestDeathCounts desc

Select location, MAX(cast(total_deaths as int)) as HighestDeathCounts
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is NULL
group by location
order by HighestDeathCounts desc


Select continent, MAX(cast(total_deaths as int)) as HighestDeathCounts, MAX(total_deaths/population)*100 as DeathPopulationPercentage
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not NULL
group by continent
order by DeathPopulationPercentage desc



Select date, SUM(new_cases)as TotalDailyCases, SUM(cast(new_deaths as int)) as TotalDailyDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Deathpercentage 
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not NULL
Group by date
order by 1,2

Select SUM(new_cases)as TotalDailyCases, SUM(cast(new_deaths as int)) as TotalDailyDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Deathpercentage 
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not NULL
--Group by date
order by 1,2


select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
 SUM(CAST(Vac.new_vaccinations as int)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

with PopvsVac (continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
as
(
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
 SUM(CAST(Vac.new_vaccinations as int)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)



Insert into #PercentPopulationVaccinated

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
 SUM(CAST(Vac.new_vaccinations as int)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
--where Dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
 SUM(CAST(Vac.new_vaccinations as int)) OVER (Partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
