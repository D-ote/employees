/* ==================================== */
/*     Employee Table Data Cleaning    */
/* ================================== */


-- add isActive column to table
alter table employees.employees_data
add column isActive boolean;

-- disable safemode
SET SQL_SAFE_UPDATES = 0;

-- populate isActive column
UPDATE employees.employees_data 
SET 
    isActive = CASE
        WHEN ExitDate = '' THEN TRUE
        ELSE FALSE
    END;

-- drop employeestatus column
alter table employees.employees_data
drop EmployeeStatus;

-- drop terminationdesc column
alter table employees.employees_data
drop TerminationDescription;

-- work on date fields
alter table employees.employees_data
add column start_date DATE,
add column exit_date DATE;

update employees.employees_data
set
    start_date = case 
        when StartDate = '' then null 
        else str_to_date(StartDate, '%d-%b-%y') 
    end,
    exit_date = case 
        when ExitDate = '' then null
        else str_to_date(ExitDate, '%d-%b-%y') 
    END;

alter table employees.employees_data
add column employment_length INT;

UPDATE employees.employees_data 
SET 
    employment_length = CASE
        WHEN exit_date IS NULL THEN DATEDIFF(CURDATE(), start_date)
        ELSE DATEDIFF(exit_date, start_date)
    END;

-- drop unnecessary columns
alter table employees.employees_data
drop column EmployeeClassificationType,
drop column TerminationType,
drop column Division,
drop column StartDate,
drop column ExitDate,
drop column JobFunctionDescription,
drop column LocationCode;

-- work on DOB
alter table employees.employees_data
add column Age INT;

-- change date format to be valid in MYSQL
UPDATE employees_data
SET DOB = STR_TO_DATE(DOB, '%d-%m-%Y');

-- change datatype to date
ALTER TABLE employees_data
MODIFY COLUMN DOB DATE;

-- calculate employees ages
UPDATE employees_data
SET Age = TIMESTAMPDIFF(YEAR, DOB, CURDATE());

-- compensation
alter table employees_data
add column Salary INT;

update employees_data
set Salary = case
    when PayZone = 'Zone A' then FLOOR(120000 + (RAND() * 190000))
    when PayZone = 'Zone B' then FLOOR(60000 + (RAND() * 120000))
    when PayZone = 'Zone C' then FLOOR(30000 + (RAND() * 70000))
    else null
end;

SELECT PayZone, Salary FROM employees_data LIMIT 10;

-- change column names
alter table employees.employees_data
change column start_date StartDate DATE,
change column exit_date ExitDate DATE,
change column employment_length EmploymentLength INT,
change column GenderCode Gender VARCHAR(45),
change column RaceDesc Race VARCHAR(45),
change column `Current employee rating` EmployeeRating INT
;



SELECT DISTINCT `Current Employee Rating`
FROM employees.employees_data;

select * from employees.employees_data;