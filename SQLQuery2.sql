SELECT*
FROM [Portfolio Project]..CovidDeaths$
order by 3,4



--SELECT*
--FROM [Portfolio Project]..CovidVaccinations$
--order by 3,4


--Select the data we are going to be using

Select location,date,total_cases,total_deaths,new_cases,population
from [Portfolio Project]..CovidDeaths$
ORDER BY 1,2


--Looking at Total cases VS Total Deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
from [Portfolio Project]..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths for Homecountry
--Shows the likelihood of dieying in your home country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
from [Portfolio Project]..CovidDeaths$
Where location like '%South Africa%'
ORDER BY 1,2

--Look at Total cases vs Population
--Shows what percentage of population got covid

Select location,date,population,total_cases,(total_cases/population)*100 AS Population_Covid_contraction_percentage
from [Portfolio Project]..CovidDeaths$
Where location like '%South Africa%'
ORDER BY 1,2


--Looking at countries with Highest infection rate compared to population

Select location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 AS Population_Covid_contraction_percentage
from [Portfolio Project]..CovidDeaths$
--Where location like '%South Africa%'
Group BY location,population
ORDER BY Population_Covid_contraction_percentage desc


--Showing countries with highest death count per population

Select location,MAX(CAST(Total_deaths as int)) as Total_Death_Count
from [Portfolio Project]..CovidDeaths$
--Where location like '%South Africa%'
Where continent is not null
Group BY location
ORDER BY Total_Death_Count desc

--Lets Break things down by continent
--Showing continents with highest death count per population
Select location,MAX(CAST(Total_deaths as int)) as Total_Death_Count
from [Portfolio Project]..CovidDeaths$
--Where location like '%South Africa%'
Where continent is null
Group BY location
ORDER BY Total_Death_Count desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as Death_Percentage
from [Portfolio Project]..CovidDeaths$
--Where location like '%South Africa%'
 where continent is not null
Group By date
ORDER BY 1,2

--Overall across the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as Death_Percentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
ORDER BY 1,2

--Were gonna join the coviddeaths table to the covidvaccinations table using JOINS joining on date and location

Select*
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
   on dea.location = vac.location
   AND dea.date = vac.date


--Looking at Total Population VS Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
   on dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent is not null
   Order By 1,2,3

-- We want the column to add up by new vaccinations
----Partition so it can add  all new vaccinations but its gonna sum by that specific(one) location, 
----so we add order by and order location and date and the date is whats gonna seperate it out. 
----It has to add up every single consecutive one(its a rolling count)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) Over (Partition By dea.location ORDER BY dea.location, dea.date) 
as Rolling_Count_of_People_Vaccinated
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
   on dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent is not null
   Order By 2,3

---USE CTE

With PopsvsVac (Continent, Location, Date, Population, New_Populations, Rolling_Count_of_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) Over (Partition By dea.location ORDER BY dea.location, dea.date) 
as Rolling_Count_of_People_Vaccinated
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
   on dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent is not null
   --Order By 2,3
)
Select*, (Rolling_Count_of_People_Vaccinated/Population)*100
From PopsvsVac


--TEMP TABLE

Create Table #PerecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Count_of_People_Vaccinated numeric
)

Insert into #PerecentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) Over (Partition By dea.location ORDER BY dea.location, dea.date) 
as Rolling_Count_of_People_Vaccinated
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
   on dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent is not null
   --Order By 2,3

Select*, (Rolling_Count_of_People_Vaccinated/Population)*100
From #PerecentPopulationVaccinated

--TEMP TABLE
---to do alterations do DROP Table If exists

Drop table if exists #PerecentPopulationVaccinated
Create Table #PerecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Count_of_People_Vaccinated numeric
)

Insert into #PerecentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) Over (Partition By dea.location ORDER BY dea.location, dea.date) 
as Rolling_Count_of_People_Vaccinated
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
   on dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent is not null
   --Order By 2,3

Select*, (Rolling_Count_of_People_Vaccinated/Population)*100
From #PerecentPopulationVaccinated

---Creating View To Store Data for later vizualizations

Create view PerecentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) Over (Partition By dea.location ORDER BY dea.location, dea.date) 
as Rolling_Count_of_People_Vaccinated
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
   on dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent is not null
---Order By 2,3