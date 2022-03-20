select * from dbo.Coviddeaths
where continent is not null
order by 3,4;

select * from dbo.CovidVaccinations
order by 3,4;

-- Data I'm going to be using

select Location,Date,total_cases, new_cases,total_deaths,population
From dbo.CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
select Location,Date,total_cases, new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population

select Location,Date,Population,total_cases,(total_deaths/Population)*100 as DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
order by 1,2


--Looking Countries with highest infection rate compared to population
select Location,Population,MAX(total_cases)as HighestInfectionCount,MAX(total_deaths/Population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per population
select Location,MAX(cast(total_deaths as int))as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Breakdown by continent
select continent ,MAX(cast(total_deaths as int))as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Gloabal Numbers

select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2

select DEA.continent,DEA.location,DEA.date,DEA.population,VAC.New_vaccinations,
SUM(convert(int, VAC.new_vaccinations)) over (partition by DEA.location order by DEA.location,
DEA.date) as rollingpeoplevaccinated
from dbo.CovidDeaths DEA
join dbo.CovidVaccinations VAC
on DEA.location=VAC.location
and DEA.date=VAC.date
where DEA.continent is not null
order by 2,3;

--Using CTE to perform Calculation on Partition By in previous query

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

select * from PercentPopulationVaccinated

