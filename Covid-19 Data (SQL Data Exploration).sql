/*
Covid19 Data Exploration

Skills used: JOINs, CTE, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types

NOTE: The date in this data is from 2020-01-01 to 2021-11-18

Tableau dashboard can be found [here.](https://public.tableau.com/app/profile/peter.masternak/viz/Portfolio_Project_Covid_1/Dashboard1)
*/

-- Data that we are going to be using
SELECT 
	death.location, 
	death.date, 
	death.total_cases, 
	death.new_cases, 
	death.total_deaths, 
	death.population,
	vaccine.new_vaccinations,
	vaccine.people_fully_vaccinated
FROM portfolio_project_1..covid_deaths AS death
JOIN portfolio_project_1..covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE 
	death.continent IS NOT NULL
ORDER BY 1,2





---- ### BY COUNTRY ### ----



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT 
	location, 
	date, 
	ISNULL(total_cases,0) AS total_cases, 
	ISNULL(total_deaths,0) AS total_deaths,
	ISNULL(ROUND((total_deaths/total_cases)*100,4),0) AS percent_death_per_case
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NOT NULL
	-- AND location LIKE '%canada%'
ORDER BY 1,2



-- Total Cases vs Population
-- Shows what percentage of population got covid over time
SELECT 
	location, 
	date, 
	population,
	ISNULL(total_cases,0) AS total_cases,
	ISNULL(ROUND((total_cases/population)*100,4),0) AS percent_population_infected
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NOT NULL
	-- AND location LIKE '%canada%'
ORDER BY 1,2



-- Countries with highest infection rates compared to population
SELECT 
	location, 
	population,
	MAX(total_cases) AS highest_infection_count,
	ROUND(MAX((total_cases/population))*100,4) AS percent_population_infected
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NOT NULL
	-- AND location LIKE '%canada%'
GROUP BY
	location,
	population
ORDER BY percent_population_infected DESC



-- Countries with highest death count compared to Population
SELECT 
	location, 
	population,
	MAX(CAST(total_deaths AS INT)) AS total_death_count, -- column is NVARCHAR
	ROUND(MAX((total_deaths/population))*100,4) AS percent_population_dead
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NOT NULL
	-- AND location LIKE '%canada%'
GROUP BY
	population,
	location
ORDER BY total_death_count DESC



-- Total Population vs Daily Rolling New Vaccinations
-- Shows daily rolling numbers of people recieving a vaccination shot
-- Shows number of people fully vacinated
-- Using CTE to use the result of the SUM aggregate function (rolling_total_vaccination_shots) to give us a percentage
WITH pop_vs_vacc (location, date, population, people_fully_vaccinated, new_vaccinations, rolling_total_vaccination_shots)
AS
(
SELECT 
	death.location, 
	death.date,
	death.population,
	vaccine.people_fully_vaccinated,
	vaccine.new_vaccinations,
	SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) OVER -- Creating rolling numbers over time
		(PARTITION BY death.location  -- Rolling number resets every location
		ORDER BY death.location, death.date) AS rolling_total_vaccination_shots
FROM portfolio_project_1..covid_deaths AS death
JOIN portfolio_project_1..covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE 
	death.continent IS NOT NULL
)
SELECT *,
	ISNULL(ROUND((rolling_total_vaccination_shots/population)*100,4),0) AS rolling_vacc_shot_by_pop_percent
FROM pop_vs_vacc
ORDER BY location, date





---- ### BY CONTINENT ### ----



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your continent
-- NOTE: Using 'continent' in SELECT will not result in correct numbers
SELECT 
	location, 
	date, 
	ISNULL(total_cases,0) AS total_cases, 
	ISNULL(total_deaths,0) AS total_deaths,
	ISNULL(ROUND((total_deaths/total_cases)*100,4),0) AS percent_death_per_case
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location NOT LIKE '%income%' -- There was income level data that is not needed
	AND location NOT LIKE '%international%' -- International is part of World
	AND location NOT LIKE '%world%'
	AND location NOT LIKE '%union%' -- European Union is part of Europe
ORDER BY 1,2



-- Total Cases vs Population
-- Shows what percentage of the continent population got covid over time
-- NOTE: Using 'continent' in SELECT will not result in correct numbers
SELECT 
	location, 
	date, 
	population,
	ISNULL(total_cases,0) AS total_cases,
	ISNULL(ROUND((total_cases/population)*100,4),0) AS percent_population_infected
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location NOT LIKE '%income%' -- There was income level data that is not needed
	AND location NOT LIKE '%international%' -- International is part of World
	AND location NOT LIKE '%world%'
	AND location NOT LIKE '%union%' -- European Union is part of Europe
ORDER BY 1,2



-- Continents with highest infection rates compared to the population
-- NOTE: Using 'continent' in SELECT will not result in correct numbers
SELECT 
	location, 
	population,
	MAX(total_cases) AS highest_infection_count,
	ROUND(MAX((total_cases/population))*100,4) AS percent_population_infected
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location NOT LIKE '%income%' -- There was income level data that is not needed
	AND location NOT LIKE '%international%' -- International is part of World
	AND location NOT LIKE '%world%'
	AND location NOT LIKE '%union%' -- European Union is part of Europe
GROUP BY
	location,
	population
ORDER BY percent_population_infected DESC



-- Continents with highest death count compared to Population
-- NOTE: Using 'continent' in SELECT will not result in correct numbers
SELECT 
	location, 
	population,
	MAX(CAST(total_deaths AS INT)) AS total_death_count, -- Column is NVARCHAR
	ROUND(MAX((total_deaths/population))*100,4) AS percent_population_dead
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location NOT LIKE '%income%' -- There was income level data that is not needed
	AND location NOT LIKE '%international%' -- International is part of World
	AND location NOT LIKE '%world%'
	AND location NOT LIKE '%union%' -- European Union is part of Europe
GROUP BY
	location,
	population
ORDER BY total_death_count DESC



-- Total Population vs Daily Rolling New Vaccinations
-- Shows daily rolling numbers of people recieving a vaccination shot
-- Shows number of people fully vacinated
-- Using CTE to use the result of the SUM aggregate function (rolling_total_vaccination_shots) to give us a percentage
WITH pop_vs_vacc (location, date, population, people_fully_vaccinated, new_vaccinations, rolling_total_vaccination_shots)
AS
(
SELECT 
	death.location, 
	death.date,
	death.population,
	vaccine.people_fully_vaccinated,
	vaccine.new_vaccinations,
	SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) OVER -- Creating rolling numbers over time
		(PARTITION BY death.location  -- Rolling number resets every location
		ORDER BY death.location, death.date) AS rolling_total_vaccination_shots
FROM portfolio_project_1..covid_deaths AS death
JOIN portfolio_project_1..covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE 
	death.continent IS NULL
	AND death.location NOT LIKE '%income%' -- There was income level data that is not needed 
	AND death.location NOT LIKE '%international%' -- International is part of World
	AND death.location NOT LIKE '%world%'
	AND death.location NOT LIKE '%union%' -- European Union is part of Europe
)
SELECT *,
	ISNULL(ROUND((rolling_total_vaccination_shots/population)*100,4),0) AS rolling_vacc_shot_by_pop_percent
FROM pop_vs_vacc
ORDER BY location, date





---- ### GLOBAL ### ----



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in general
SELECT 
	location, 
	date, 
	ISNULL(total_cases,0) AS total_cases, 
	ISNULL(total_deaths,0) AS total_deaths,
	ISNULL(ROUND((total_deaths/total_cases)*100,4),0) AS percent_death_per_case
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location LIKE '%world%'
ORDER BY 2 DESC -- For most recent up to date results



-- Total Cases vs Population
-- Shows what percentage of global population got covid over time
SELECT 
	location, 
	date, 
	population,
	ISNULL(total_cases,0) AS total_cases,
	ISNULL(ROUND((total_cases/population)*100,4),0) AS percent_case_by_population
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location LIKE '%world%'
ORDER BY 1,2



-- Total Population vs Daily Rolling New Vaccinations
-- Shows daily rolling numbers of people recieving a vaccination shot
-- Shows number of people fully vacinated
-- Using Temp Table to use the result of the SUM aggregate function (rolling_total_vaccination_shots) to give us a percentage
-- DROP TABLE IF EXISTS percent_population_vaccinated -- In case of any changes to the table
CREATE TABLE percent_population_vaccinated
(
	location NVARCHAR(225),
	date DATETIME,
	population NUMERIC,
	people_fully_vaccinated NUMERIC,
	new_vaccinations NUMERIC,
	rolling_total_vaccination_shots NUMERIC
)

INSERT INTO percent_population_vaccinated
SELECT 
	death.location, 
	death.date,
	death.population,
	vaccine.people_fully_vaccinated,
	vaccine.new_vaccinations,
	SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) OVER -- Creating rolling numbers over time
		(PARTITION BY death.location  -- Rolling number resets every location
		ORDER BY death.location, death.date) AS rolling_total_vaccination_shots
FROM portfolio_project_1..covid_deaths AS death
JOIN portfolio_project_1..covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE 
	death.continent IS NULL
	AND death.location LIKE '%world%'
GROUP BY
	death.location, 
	death.date,
	death.population,
	vaccine.new_vaccinations,
	vaccine.people_fully_vaccinated

SELECT *,
	ISNULL(ROUND((rolling_total_vaccination_shots/population)*100,4),0) AS rolling_vacc_shot_by_pop_percent
FROM percent_population_vaccinated
ORDER BY date





---- ### CREATE VIEWS FROM ABOVE QUERIES  ### ----

CREATE VIEW country_case_death AS
SELECT 
	location, 
	date, 
	ISNULL(total_cases,0) AS total_cases, 
	ISNULL(total_deaths,0) AS total_deaths,
	ISNULL(ROUND((total_deaths/total_cases)*100,4),0) AS percent_death_per_case
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NOT NULL

CREATE VIEW country_case_population AS
SELECT 
	location, 
	date, 
	population,
	ISNULL(total_cases,0) AS total_cases,
	ISNULL(ROUND((total_cases/population)*100,4),0) AS percent_population_infected
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NOT NULL

CREATE VIEW country_vaccine_population AS
WITH pop_vs_vacc (location, date, population, people_fully_vaccinated, new_vaccinations, rolling_total_vaccination_shots)
AS
(
SELECT 
	death.location, 
	death.date,
	death.population,
	vaccine.people_fully_vaccinated,
	vaccine.new_vaccinations,
	SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) OVER -- Creating rolling numbers over time
		(PARTITION BY death.location  -- Rolling number resets every location
		ORDER BY death.location, death.date) AS rolling_total_vaccination_shots
FROM portfolio_project_1..covid_deaths AS death
JOIN portfolio_project_1..covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE 
	death.continent IS NOT NULL
)
SELECT *,
	ISNULL(ROUND((rolling_total_vaccination_shots/population)*100,4),0) AS rolling_vacc_shot_by_pop_percent
FROM pop_vs_vacc

CREATE VIEW continent_case_death AS
SELECT 
	location, 
	date, 
	ISNULL(total_cases,0) AS total_cases, 
	ISNULL(total_deaths,0) AS total_deaths,
	ISNULL(ROUND((total_deaths/total_cases)*100,4),0) AS percent_death_per_case
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location NOT LIKE '%income%' 
	AND location NOT LIKE '%international%' 
	AND location NOT LIKE '%world%'
	AND location NOT LIKE '%union%'

CREATE VIEW continent_case_population AS
SELECT 
	location, 
	date, 
	population,
	ISNULL(total_cases,0) AS total_cases,
	ISNULL(ROUND((total_cases/population)*100,4),0) AS percent_population_infected
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location NOT LIKE '%income%' 
	AND location NOT LIKE '%international%' 
	AND location NOT LIKE '%world%'
	AND location NOT LIKE '%union%'

CREATE VIEW continent_vaccine_population AS 
WITH pop_vs_vacc (location, date, population, people_fully_vaccinated, new_vaccinations, rolling_total_vaccination_shots)
AS
(
SELECT 
	death.location, 
	death.date,
	death.population,
	vaccine.people_fully_vaccinated,
	vaccine.new_vaccinations,
	SUM(CONVERT(BIGINT,vaccine.new_vaccinations)) OVER -- Creating rolling numbers over time
		(PARTITION BY death.location  -- Rolling number resets every location
		ORDER BY death.location, death.date) AS rolling_total_vaccination_shots
FROM portfolio_project_1..covid_deaths AS death
JOIN portfolio_project_1..covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE 
	death.continent IS NULL
	AND death.location NOT LIKE '%income%' 
	AND death.location NOT LIKE '%international%' 
	AND death.location NOT LIKE '%world%'
	AND death.location NOT LIKE '%union%'
)
SELECT *,
	ISNULL(ROUND((rolling_total_vaccination_shots/population)*100,4),0) AS rolling_vacc_shot_by_pop_percent
FROM pop_vs_vacc

CREATE VIEW global_case_death AS 
SELECT 
	location, 
	date, 
	ISNULL(total_cases,0) AS total_cases, 
	ISNULL(total_deaths,0) AS total_deaths,
	ISNULL(ROUND((total_deaths/total_cases)*100,4),0) AS percent_death_per_case
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location LIKE '%world%'

CREATE VIEW global_case_population AS 
SELECT 
	location, 
	date, 
	population,
	ISNULL(total_cases,0) AS total_cases,
	ISNULL(ROUND((total_cases/population)*100,4),0) AS percent_case_by_population
FROM portfolio_project_1..covid_deaths
WHERE 
	continent IS NULL
	AND location LIKE '%world%'

CREATE VIEW global_vaccine_population AS 
SELECT *,
	ISNULL(ROUND((rolling_total_vaccination_shots/population)*100,4),0) AS rolling_vacc_shot_by_pop_percent
FROM percent_population_vaccinated
