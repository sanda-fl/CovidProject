-- MySQL Workbench 8.0
-- Global COVID-19 data, up to 03-Aug-2022



-- Select data that we are going to use
select location, date, total_cases, new_cases, total_deaths, population from deaths
order by 1,2;

-- Looking at Total Cases vs Totatl Deaths
-- Shows us the likelihood of dying if one persone has covid in a specific location
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from deaths
where location = "Romania"
order by date desc;


-- Looking at total cases vs the population
-- What percentage of the population got covid ever
select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage from deaths
where location = "Romania"
order by date desc;


-- Check countries with highest infeciton rate compared to Population
select location, date, max(total_cases) as HighestNumberOfCases, population, max((total_cases/population)*100) as InfectionPercentage from deaths
group by location, population
order by InfectionPercentage desc;


-- Actual deaths - showing countries with the highest Death Count per Population
select location, population, max(total_deaths) as TotalDeathCount, max((total_deaths/population)*100) as DeathPercentage 
from deaths
where continent is not null # to only check the countries themselves and ignore the totals for the whole continents/world
group by location, population
order by TotalDeathCount desc;


-- Breaking visualization by Higher Level groupings
-- Showing the continents with the highest death count
select location, max(total_deaths) as TotalDeathCount
from deaths
where continent is null
group by location
order by TotalDeathCount desc;


-- Checking global values
-- Total number of registered deaths at current observed date
select Date, sum(total_deaths) TotalDeaths
from ( 						# generate a table that contains the sum of the total deaths for each country
	select max(total_deaths) total_deaths, max(date) Date
    from deaths 
    where continent is not null 
    group by location) all_deaths;


-- Checking how the numbers grew day by day in world's countries
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
		sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from deaths
where continent is not null
group by date
order by date desc;


# 6367396 cu sum new_deaths 
# 6409809 cu sum total_deaths
# smth weird here. some deaths declarated covid-caused were later not covid-caused? hmm



-- Vaccinations table

-- Looking at total vaccinations vs population and checking how the vaccination percentage evolves
-- USE CTE
with PopVsVac (continent, location, population, date, new_vaccinations, vaccinations_to_this_date)
as
(
select deaths. continent, deaths.location, deaths. population, vacc.date, vacc.new_vaccinations,
		sum(vacc.new_vaccinations) over (partition by deaths.location order by deaths.location, deaths.date) as vaccinations_to_this_date
from deaths
join vacc
	on vacc.location=deaths.location and vacc.date=deaths.date
where deaths.continent is not null 
order by 2,3
)
select *, (vaccinations_to_this_date/population)*100 as VaccPercentage from popvsvac;


-- Now trying with a TEMP TABLE. We create a table and then insert into it the rows we get from the SELECT statement

create table percentpopvac
(
continent varchar(50) null,
location varchar(50) not null,
`date` datetime not null,
population int not null,
new_vaccinations int null,
vaccinations_to_this_date int null
);

insert into percentpopvac (continent, location, population, date, new_vaccinations, vaccinations_to_this_date)
select deaths.continent, deaths.location, deaths. population, vacc.date, vacc.new_vaccinations,
		sum(vacc.new_vaccinations) over (partition by deaths.location order by deaths.location, deaths.date) as vaccinations_to_this_date
from deaths
join vacc
	on vacc.location=deaths.location and vacc.date=deaths.date
where deaths.continent is not null 
order by 2,3;


# Now we check the rate at which the Vaccination Percentage evolves
select *, (vaccinations_to_this_date/population)*100 as VaccPercentage from percentpopvac;

-- Create View to store data later for visualization

create view number_deaths_ro as 
select location, date, total_cases total_cases_so_far, new_cases, total_deaths total_deaths_so_far, new_deaths, (new_deaths/total_cases)*100 as CurrentDeathPercentage from deaths
where location = "Romania"
order by date desc;









