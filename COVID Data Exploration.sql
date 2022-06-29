
SELECT * FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4

--select * from PortfolioProjects..CovidVaccinations
--order by 3,4

--SELECTED DATA
SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProjects..CovidDeaths WHERE continent is not null ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS(Liklihood of dying of COVID in your country)
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths WHERE location LIKE '%states%' ORDER BY 1,2

--TOTAL CASES VS POPULATION(Percentage of population got COVID)
SELECT location,date,total_cases,population,(total_cases/population)*100 AS PerecentPopulationInfected
FROM PortfolioProjects..CovidDeaths WHERE location LIKE 'Ba%' ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE
SELECT location,population,MAX(total_cases), MAX(total_cases/population)*100 AS PerecentPopulationInfected
FROM PortfolioProjects..CovidDeaths WHERE continent is not null GROUP BY location,population ORDER BY PerecentPopulationInfected desc

--COUNTRIES WITH HIGHEST DEATH COUNTS
SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths WHERE continent is not null GROUP BY location ORDER BY TotalDeathCount DESC

--BREAK DOWN BY CONTINENT(Highest Death Count)
SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths WHERE continent is not null GROUP BY continent ORDER BY TotalDeathCount DESC

--GLOBAOL NUMBERS
SELECT date,SUM(new_cases) AS New_cases,SUM(CAST(new_deaths AS INT)) AS New_deaths,SUM(new_cases)/SUM(CAST(new_deaths AS INT)) *100 AS NewDeathPercentage
FROM PortfolioProjects..CovidDeaths WHERE continent is not null GROUP BY date ORDER BY 1,2

--TOTAL POPULATION VS VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea Join PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

--CTE
WITH PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea Join PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null)
SELECT *,(RollingPeopleVaccinated/population)*100 FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea Join PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date

SELECT *,(RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated

--CREATING VIEW
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea Join PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated