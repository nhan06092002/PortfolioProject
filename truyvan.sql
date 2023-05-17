select * from Portfolio..CovidDeaths
order by 3,4
--order by 3,4 nghĩa là xắp xếp theo cột thứ 3 và thứ 4 tăng dần

--select * from Portfolio..CovidVaccinations
--order by 3,4


---Truy vấn dữ liệu cần sử dụng
select location,date,total_cases,new_cases,total_deaths,population
from Portfolio..CovidDeaths
where continent is not null
order by 1,2

--total_cases: số ca nhiễm tính đến thời điểm cập nhật dữ liệu
--new_cases: số ca nhiễm mới

--Tính toán tỷ lệ tử vong của VietNam dựa trên số ca nhiễm và số ca tử vong
select location,date,total_cases,total_deaths,
CONVERT(float, total_deaths) / CONVERT(float, total_cases)*100 AS DeathRate
from Portfolio..CovidDeaths
where location like '%iet%'
and continent is not null
order by 1,2

--Tìm kiếm nước nào có tỷ lệ lây nhiễm cao nhất dựa trên dân số
select location,population, MAX(CONVERT(int, total_cases)) as HighestInfectionCount,
MAX(CONVERT(int, total_cases)/population)*100 as Rate
from Portfolio..CovidDeaths
where continent is not null
group by location,population
order by Rate desc

--Hiển thị nước nào có tổng số người chết cao nhất
select location, MAX(convert(int, total_deaths)) as TotalDeathCounts
from Portfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCounts desc

--Hiển thị khu vực nào có tổng số người chết cao nhất
select location, max(convert(int, total_deaths)) as TotalDeathCounts
from Portfolio..CovidDeaths
where continent is null
group by location
order by TotalDeathCounts desc

--Tỷ lệ tử vong của toàn thế giới
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null 
order by 1,2


--Using CTE to perform Calculation on Partition By in previous query

with PopVac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated)
as(
select dea.continent,dea.location, vac.date, dea.population,vac.new_vaccinations,
SUM(convert(float , new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)select * ,(RollingPeopleVaccinated/population)*100 as rate
from PopVac


