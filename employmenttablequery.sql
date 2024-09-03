-- total employee count
select count(empId) as totalEmployees
from employees_data;

-- how many female and female employees work here
select 
	sum(case when gender = 'Male' then 1 else 0 end) as male_employees,
    sum(case when gender = 'Female' then 1 else 0 end) as female_employees
from employees_data;

-- count employees by maritalstatus
select
	sum(case when maritaldesc = 'married' then 1 else 0 end) as married_count,
	sum(case when MaritalDesc = 'widowed' then 1 else 0 end) as widowed_count,
	sum(case when MaritalDesc = 'single' then 1 else 0 end) as single_count,
	sum(case when MaritalDesc = 'divorced' then 1 else 0 end) as divorced_count
from employees_data;

/* ======================== */
-- Gender and Diversity:
-- ======================== --

-- What is the gender distribution across different departments?
select departmenttype,
	sum(case when gender = 'Male' then 1 else 0 end) as male_emp,
	sum(case when gender = 'female' then 1 else 0 end) as female_emp,
    count(empId) as total_emps
from employees_data
group by departmenttype;

-- How does the racial diversity vary across business units?
select departmenttype,
	sum(case when race = 'black' then 1 else 0 end) as black_emps,
	sum(case when race = 'asian' then 1 else 0 end) as asian_emps,
	sum(case when race = 'white' then 1 else 0 end) as white_emps,
	sum(case when race = 'hispanic' then 1 else 0 end) as hispanic_emps,
    count(empid) as total_emps
from employees_data
group by departmenttype;
    
/* ======================== */
-- Employment Tenure
-- ======================== --

-- What is the average employment length by department?
select departmenttype as department, round(sum(employmentLength) / 365, 2) as lengthofemploy
from employees_data
group by departmenttype
order by lengthofemploy DESC;

-- Which departments have the highest and lowest employee retention rates?
SELECT 
    departmenttype AS department,
    ROUND(SUM(CASE
                WHEN isActive THEN 1
                ELSE 0
            END) / COUNT(empId) * 100,
            2) AS retention_rate
FROM
    employees_data
GROUP BY departmenttype
ORDER BY retention_rate DESC;

-- How does employment length differ between full-time and part-time employees?
SELECT 
    departmenttype AS department,
    employeetype,
    ROUND(AVG(employmentLength) / 365, 2) AS average_employment_length_years
FROM
    employees_data
GROUP BY departmenttype , employeetype
ORDER BY 
    departmenttype, average_employment_length_years DESC;

    
/* ======================== */
-- Salary and Compensation
/* ======================== */

-- How does salary vary across different pay zones?
SELECT 
    payzone, ROUND(AVG(salary), 2) AS avg_salary
FROM
    employees_data
GROUP BY payzone
ORDER BY avg_salary DESC;

-- What is the average salary for each job title or department?
select departmenttype as department,
	title,
    count(empid) as employeeCount,
    round(avg(salary),2) avg_salary
from employees_data
group by departmenttype, title
order by DepartmentType, avg_salary desc;

-- How does the salary distribution differ by gender, race, or marital status?
SELECT 
    departmenttype AS department,
    gender,
    ROUND(AVG(salary), 2) avg_salary
FROM
    employees_data
GROUP BY department , gender
ORDER BY DepartmentType , avg_salary DESC;

-- Are there any noticeable pay gaps across different demographics?
SELECT 
    gender,
    race,
    ROUND(AVG(salary), 2) AS average_salary
FROM 
    employees_data
GROUP BY 
    gender, 
    race
ORDER BY 
    race, average_salary DESC;


/* ======================== */
--  Performance and Supervision
/* ======================== */

-- Which departments have the highest average employment ratings?
select departmenttype as department, avg(employeerating) as avg_rating
from employees_data
group by DepartmentType
order by avg_rating desc;


/* ======================== */
-- Organizational Structure and Hierarchy
/* ======================== */

-- What is the employee distribution across different departments?
select departmenttype as department,
count(empid) as employee_count
from employees_data
group by department
order by employee_count desc;

-- How many employees does each supervisor manage, 
-- and how does this relate to employee performance and retention?
SELECT 
    supervisor, 
    COUNT(empId) AS num_employees,
    ROUND(AVG(employeerating), 2) AS avg_performance,
    ROUND(SUM(CASE WHEN exitdate IS NULL THEN 1 ELSE 0 END) / COUNT(empId) * 100, 2) AS retention_rate
FROM 
    employees_data
GROUP BY 
    supervisor
ORDER BY 
    num_employees DESC;
    
-- What are the most common job titles within the organization?
select title, count(empId) as employee_count
from employees_data
group by title
order by employee_count desc;

-- How does job title distribution vary across business units or departments?
select departmenttype as department, title, count(empId) as employee_count
from employees_data
group by department, title
order by department, employee_count desc;


/* ======================== */
-- Geographical Analysis
/* ======================== */

-- How is the workforce distributed across different states?
select state, count(empId) as employee_count
from employees_data
group by state
order by employee_count desc;

-- How does the turnover rate differ between departments, supervisors, or employment types?
SELECT 
    departmenttype AS department,
    supervisor,
    employeetype,
    ROUND(SUM(CASE WHEN exitdate IS NOT NULL THEN 1 ELSE 0 END) / COUNT(empId) * 100, 2) AS turnover_rate
FROM 
    employees_data
GROUP BY 
    departmenttype, 
    supervisor, 
    employeetype
ORDER BY 
    turnover_rate DESC;

/* ======================== */
-- Advanced Queries
/* ======================== */

-- Who are the top 3 performing employees in each department based on their employment rating?
WITH RankedEmployees AS (
    SELECT 
        empId, 
        firstName,
        lastName,
        departmenttype,
        employeerating,
        ROW_NUMBER() OVER (PARTITION BY departmenttype ORDER BY employeerating DESC) AS employee_rank
    FROM 
        employees_data
)
SELECT 
    empId, 
    firstName,
    lastName,
    departmenttype, 
    employeerating
FROM 
    RankedEmployees
WHERE 
    employee_rank <= 3
ORDER BY 
    departmenttype, employee_rank;

-- What percentage of employees in each department fall into different pay zones?
WITH DepartmentCounts AS (
    SELECT 
        departmenttype,
        COUNT(empId) AS department_total
    FROM 
        employees_data
    GROUP BY 
        departmenttype
)
SELECT 
    e.departmenttype, 
    e.payzone,
    COUNT(e.empId) AS payzone_count,
    ROUND(COUNT(e.empId) * 100.0 / dc.department_total, 2) AS percentage
FROM 
    employees_data e
JOIN 
    DepartmentCounts dc ON e.departmenttype = dc.departmenttype
GROUP BY 
    e.departmenttype, e.payzone, dc.department_total
ORDER BY 
    e.departmenttype, percentage DESC;

-- Which employees have participated in the most training programs, 
-- and how does their performance compare to others?
WITH TrainingCounts AS (
    SELECT 
        t.employeeid,
        COUNT(t.trainingname) AS training_count
    FROM 
        trainings t
    GROUP BY 
        t.employeeid
)
SELECT 
    e.empId, 
    e.firstName, 
    e.lastName, 
    tc.training_count,
    e.employeerating
FROM 
    employees_data e
JOIN 
    TrainingCounts tc ON e.empId = tc.employeeid
ORDER BY 
    tc.training_count DESC, e.employeerating DESC;

-- What is the year-over-year growth rate in the number of employees for each department?
WITH YearlyCounts AS (
    SELECT 
        departmenttype, 
        YEAR(StartDate) AS year,
        COUNT(empId) AS employee_count
    FROM 
        employees_data
    GROUP BY 
        departmenttype, YEAR(StartDate)
)
SELECT 
    departmenttype, 
    year, 
    employee_count,
    LAG(employee_count) OVER (PARTITION BY departmenttype ORDER BY year) AS prev_year_count,
    ROUND((employee_count - LAG(employee_count) OVER (PARTITION BY departmenttype ORDER BY year)) / LAG(employee_count) OVER (PARTITION BY departmenttype ORDER BY year) * 100, 2) AS yoy_growth
FROM 
    YearlyCounts
ORDER BY 
    departmenttype, year;

-- How effective are training programs in improving employee performance?
WITH TrainingEffectiveness AS (
    SELECT 
        e.empId,
        t.trainingname,
        AVG(CASE WHEN t.trainingdate > e.StartDate THEN e.employeerating ELSE NULL END) AS avg_rating_post_training,
        AVG(CASE WHEN t.trainingdate <= e.StartDate THEN e.employeerating ELSE NULL END) AS avg_rating_pre_training
    FROM 
        employees_data e
    JOIN 
        trainings t ON e.empId = t.employeeid
    GROUP BY 
        e.empId, t.trainingname
)
SELECT 
    empId, 
    trainingname, 
    avg_rating_pre_training,
    avg_rating_post_training,
    (avg_rating_post_training - avg_rating_pre_training) AS improvement
FROM 
    TrainingEffectiveness
WHERE 
    avg_rating_post_training IS NOT NULL AND avg_rating_pre_training IS NOT NULL
ORDER BY 
    improvement DESC;


select count(distinct empid)
from employees_data;

select * 
from employees_data;