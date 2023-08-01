-- Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of the population fot Covid

Select Location, date, total_cases, population, (total_cases/population)* 100 AS PopulationPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Countries with the highest Infection Rate compared to population

Select Location, population,  max(total_cases) as HighestInfectionCount, max((total_cases/population))* 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population
order by PercentPopulationInfected DESC


-- Looking countries with the highest death count per populaton

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is Null
Group by Location
order by TotalDeathCount Desc 



--Let's break things down by continent

-- Showing the continenet with the highest death count

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not Null
Group by Location
order by TotalDeathCount Desc 


-- Global Numbers of deaths by date

Select date, sum(new_cases) as TotalCases,  sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
order by 1,2


-- Total Deaths Overall

Select sum(new_cases) as TotalCases,  sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


--	Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,
From PortfolioProject..CovidDeaths$ as Dea
Join PortfolioProject..CovidVaccinations$ as Vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

with PopvsVac( continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as Dea
Join PortfolioProject..CovidVaccinations$ as Vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--Temp Table

Drop Table if exist #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as Dea
Join PortfolioProject..CovidVaccinations$ as Vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as Dea
Join PortfolioProject..CovidVaccinations$ as Vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
