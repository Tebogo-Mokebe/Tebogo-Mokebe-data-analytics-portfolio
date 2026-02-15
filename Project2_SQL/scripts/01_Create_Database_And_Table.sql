CREATE DATABASE hr_analytics_portfolio;

CREATE TABLE employees
(
Age INT COMMENT 'HR: Demographic for generational analysis',
Attrition VARCHAR(3) COMMENT 'HR Target: Yes/No - Turnover indicator',
BusinessTravel VARCHAR(20) COMMENT 'HR: Worl-life impact',
DailyRate INT COMMENT 'HR: Compensation detail',
Department VARCHAR(100) COMMENT 'HR: Org structure for dept turnover',
DistanceFromHome INT COMMENT 'HR: Commute stress factor',
Education INT COMMENT 'HR: Skill level (1-5)',
EducationField VARCHAR(20) COMMENT 'HR: Talent pipeline diversity',
EmployeeCount INT COMMENT 'Constant 1 - Ignore',
EmployeeNumber INT COMMENT 'Unique ID',
EnivornmentSatisfaction INT COMMENT 'HR: Workplace morale (1-4)',
Gender VARCHAR(10) COMMENT 'HR: Diversity & inclusion',
HourlyRate INT COMMENT 'HR: Compensation',
JobInvolvement INT COMMENT 'HR: Engagement (1-4)',
JobeLevel INT COMMENT 'HR: Hierarchy for promotion analysis',
JobRole VARCHAR(30) COMMENT 'HR: Role-specific retention',
JobSatisfaction INT COMMENT 'HR: Key morale metric (1-4)',
MartialStatus VARCHAR(10) COMMENT 'HR: Family status imapact',
MonthlyIncome INT COMMENT 'HR: Salary equity analysis',
MonthlyRate INT COMMENT 'HR: Billing rate',
NumCompaniesWorked INT COMMENT 'HR: Job hopping indicator',
Over18 VARCHAR(1) COMMENT 'Constant Y - Ignore',
OverTime VARCHAR(3) COMMENT 'HR: Burnout risk (Yes/No)',
PercentageSalaryHike INT COMMENT 'HR: Reward & motivation',
PerformanceRating INT COMMENT 'HR: Appraisal (3-4)',
RelationshipSatisfaction INT COMMENT 'HR: Team dynamics (1-4)',
StandardHours INT COMMENT 'Constant 80 - Ignore',
StockOptionLevel INT COMMENT 'HR: Incentive (0-3)',
TotalWorkingYears INT COMMENT 'HR: Experience retention',
TrainingTimesLastYear INT COMMENT 'HR: Development investment',
WorkLifeBalance INT COMMENT 'HR: Wellness metric (1-4)',
YearsAtCompany INT COMMENT 'HR: Tenure loyalty',
YearsInCurrentRole INT COMMENT 'HR: Stagnation risk',
YearsSinceLastPromotion INT COMMENT 'HR: Promotion frustration',
YearsWithCurrManager INT COMMENT 'HR: Manager relationship'
)

DESCRIBE employees;

SELECT COUNT(*) FROM employees;

SELECT * FROM employees LIMIT 5;

CREATE INDEX idx_dept_attrition ON employees (Department, Attrition);
CREATE INDEX idx_satisfaction 
ON employees (JobSatisfaction, EnivornmentSatisfaction);


CREATE VIEW hr_attrition_overview AS
SELECT
      Department,
      Jobrole,
      AVG(MonthlyIncome) AS Avg_Income,
      AVG(JobSatisfaction) AS Avg_Satisfaction,
      SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Attrition_Rate
FROM employees
GROUP BY Department, JobRole;

SELECT * FROM hr_attrition_overview;

DELIMITER //
CREATE PROCEDURE GetHRAttritionByDept(IN dept_name VARCHAR(100))
BEGIN
     SELECT
     JobRole,
     Gender,
     AVG(WorkLifeBalance) AS Avg_WorkLife,
     SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Attrition_Rate
	FROM employees
    WHERE Department = dept_name
    GROUP BY JobRole, Gender;
END //
DELIMITER ;

CALL GetHRAttritionByDept('Sales');

WITH Attrition AS (
    SELECT
        JobRole,
        COUNT(*) AS Total_Employees,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers
    FROM employees
    GROUP BY JobRole
)
SELECT
    JobRole,
    (Leavers * 100.0 / Total_Employees) AS Attrition_Rate,
    RANK() OVER (ORDER BY (Leavers * 100.0 / Total_Employees) DESC) AS Attrition_Rank
FROM Attrition;

-- Descriptive Stats (HR: Averages for key metrics)
SELECT
	AVG(Age) AS Avg_Age,
    AVG(MonthlyIncome) AS Avg_Income,
    AVG(JobSatisfaction) AS Avg_Satisfaction,
    AVG(WorkLifeBalance) AS Avg_WorkLife
FROM employees;

-- Categorical Distribution (HR: Diversity by Gender/Department
SELECT Gender, Department, COUNT(*) AS Count
FROM employees
GROUP BY Gender, Department;

-- Univariate: Attrition Breakdown
SELECT Attrition, COUNT(*) AS count
FROM employees
GROUP BY Attrition;

-- Bivariate: Attrition Rate by OverTime (HR: Burnout analysis)
SELECT OverTime,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Attrition_Rate
FROM employees
GROUP BY OverTime;

--Multivariate: Avg Income/Satisfaction by Dept, Attrition, Gender (HR: Equity check)
SELECT Department, Attrition, Gender,
       AVG(MonthlyIncome) AS Avg_Income,
       AVG(JobSatisfaction) AS Avg_Satisfaction
FROM employees
GROUP BY Department, Attrition, Gender;

-- Numerical Analysis: Tenure by Age Group with Attrition (HR: Generational retention)
SELECT
    CASE
        WHEN Age <= 25 THEN 'Under 25'
        WHEN Age <= 35 THEN '26-35'
        WHEN age <= 45 THEN '36-45'
        ELSE '46+'
	END AS Age_Group,
    AVG(YearsAtCompany) AS Avg_Tenure,
    AVG(MonthlyIncome) AS Avg_Income,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Attrition_Rate
FROM employees
GROUP BY Age_Group;








