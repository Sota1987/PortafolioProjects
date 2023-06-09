SELECT * 
FROM CovidData..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM CovidData..CovidVaccinations$
ORDER BY 3,4

--Select the data that I'm going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidData..CovidDeaths$
ORDER BY 1,2

--Looking at total_cases vs total_deaths
SELECT location, date,total_cases, total_deaths, CONCAT(ROUND(total_deaths/total_cases, 2), '%') AS DeathsPerCases
FROM CovidData..CovidDeaths$
WHERE location LIKE 'Cuba'
ORDER BY 1,2

--Looking at the total_cases vs population
--Showing what percent of the population got Covid
SELECT location, MAX(total_cases) AS TotalCases, MAX(population) AS Population, ROUND(MAX(total_cases/population)*100, 2) AS PercentOfPopulationInfected
FROM CovidData..CovidDeaths$
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 4 DESC


--Showing contries with highest death count
SELECT location, MAX(total_deaths) AS Deaths
FROM CovidData..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Showing the percent of the population death by covid
SELECT location, MAX(total_deaths) AS TotalDeaths, MAX(population) AS Population, ROUND(MAX(total_deaths/population)*100, 2) AS PercentOfPopulationDeaths
FROM CovidData..CovidDeaths$
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC

-- Looking at the countries with the highest infection rate compared to population
SELECT location, MAX(total_cases) AS TotalCases, population, ROUND(MAX(total_cases/population)*100, 2) AS PercentOfPopulationInfected
FROM CovidData..CovidDeaths$
WHERE total_cases IS NOT NULL and location like '%state%' AND continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--Lets break thing down by continent
SELECT continent, SUM(new_cases) AS Infected, SUM(new_deaths) AS Deaths
FROM CovidData..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2

--Showing global numbers per Day
SELECT date AS Date, SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) AS 'DeathRate(%)'
FROM CovidData..CovidDeaths$
WHERE new_cases IS NOT NULL AND new_cases <> 0
GROUP BY date
ORDER BY date

--Showing global numbers per Year
SELECT YEAR(date) AS Date, SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100 ,2) AS 'DeathRate(%)'
FROM CovidData..CovidDeaths$
GROUP BY YEAR(date)
ORDER BY 1 

--Showing global numbers

SELECT SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100 ,2) AS 'DeathRate(%)'
FROM CovidData..CovidDeaths$

--Join to tables
SELECT v.date AS Date, SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, SUM(new_vaccinations) AS Vaccinations
FROM CovidData..CovidDeaths$ d JOIN CovidData..CovidVaccinations$ v
ON d.date = v.date AND d.location = v.location
GROUP BY v.date
ORDER BY 1

--Looking at the total vaccinations VS population
SELECT d.continent, d.location, MAX(d.population) AS Population, MAX(v.people_fully_vaccinated) AS PeopleVaccinated, 
ROUND((MAX(v.people_fully_vaccinated)/MAX(d.population))*100, 2) AS PercentVaccination
FROM CovidData..CovidDeaths$ d JOIN CovidData..CovidVaccinations$ v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL
GROUP BY d.continent, d.location
ORDER BY 5 DESC

--Looking at the acummulate of people vaccination
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition By d.location ORDER BY d.location, d.date)
FROM CovidData..CovidDeaths$ d JOIN CovidData..CovidVaccinations$ v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--Use CTE
WITH CTE_PopVSVac AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition By d.location ORDER BY d.location, d.date) AS Acc_Vacc
FROM CovidData..CovidDeaths$ d JOIN CovidData..CovidVaccinations$ v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL)
SELECT *
FROM CTE_PopVSVac

WITH CTE_PopVSVac1 (Continent, Lacation, Date, Population, New_Vaccinations, Accumulate_Vaccinations) AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition By d.location ORDER BY d.location, d.date) AS Acc_Vacc
FROM CovidData..CovidDeaths$ d JOIN CovidData..CovidVaccinations$ v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL)
SELECT *
FROM CTE_PopVSVac1

--TEMPORARY TABLE
DROP TABLE IF EXISTS #PopVSVac
CREATE TABLE #PopVSVac(
	Continent nvarchar(255), 
	Lacation nvarchar(255), 
	Date datetime, 
	Population float, 
	New_Vaccinations float, 
	Accumulate_Vaccinations float)

INSERT INTO #PopVSVac
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition By d.location ORDER BY d.location, d.date) AS Acc_Vacc
FROM CovidData..CovidDeaths$ d JOIN CovidData..CovidVaccinations$ v
ON d.date = v.date AND d.location = v.location
--WHERE d.continent IS NOT NULL

SELECT *
FROM #PopVSVac

--Create a view
CREATE VIEW PopVSVac AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition By d.location ORDER BY d.location, d.date) AS Acc_Vacc
FROM CovidData..CovidDeaths$ d JOIN CovidData..CovidVaccinations$ v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL

SELECT *
FROM CovidData..PopVSVac

