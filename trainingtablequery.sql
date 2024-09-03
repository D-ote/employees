SELECT * FROM employees.trainings;

select count(`employee id`) from employees.trainings;

UPDATE trainings
SET `training date` = STR_TO_DATE(`training date`, '%d-%b-%Y');

-- change column names
alter table employees.trainings
change column `employee Id` EmployeeId INT,
change column `Training Date` TrainingDate DATE,
change column `Training Program Name` TrainingName VARCHAR(45),
change column `Training Outcome` TrainingOutcome VARCHAR(45),
change column `training Cost` TrainingCost DECIMAL(5,2)
;

select distinct location
from trainings;

SELECT 
    e.empId,
    e.departmenttype,
    t.TrainingName,
    ROUND(AVG(e.employeerating), 2) AS avg_rating_before_training,
    ROUND(AVG(CASE WHEN t.trainingdate > e.trainingdate THEN e.employeerating ELSE NULL END), 2) AS avg_rating_after_training
FROM 
    employees_data e
LEFT JOIN 
    trainings t ON e.empId = t.employee_id
GROUP BY 
    e.empId, t.TrainingName
ORDER BY 
    avg_rating_after_training DESC;
    
    
    
    
    
-- Does participation in training programs affect employee retention rates?

SELECT 
    t.TrainingName,
    COUNT(e.empId) AS num_employees,
    ROUND(SUM(CASE WHEN e.exitdate IS NULL THEN 1 ELSE 0 END) / COUNT(e.empId) * 100, 2) AS retention_rate
FROM 
    employees_data e
LEFT JOIN 
    trainings t ON e.empId = t.employeeid
GROUP BY 
    t.TrainingName
ORDER BY 
    retention_rate DESC;


-- What is the cost of training programs, and how does it correlate with employee performance improvements?
SELECT 
    t.TrainingName,
    SUM(t.TrainingCost) AS total_training_cost,
    ROUND(AVG(e.employeerating), 2) AS avg_performance_post_training
FROM 
    employees_data e
LEFT JOIN 
    trainings t ON e.empId = t.employeeid
WHERE 
    t.trainingOutcome = 'Successful'
GROUP BY 
    t.TrainingName
ORDER BY 
    total_training_cost DESC;

-- How does the frequency of training sessions attended by an employee correlate with their performance rating?
SELECT 
    e.empId,
    COUNT(t.trainingdate) AS training_count,
    ROUND(AVG(e.employeerating), 2) AS avg_performance
FROM 
    employees_data e
LEFT JOIN 
    trainings t ON e.empId = t.employeeid
GROUP BY 
    e.empId
ORDER BY 
    training_count DESC, avg_performance DESC;

