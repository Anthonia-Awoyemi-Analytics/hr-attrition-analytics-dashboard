-- ============================================================
-- HR ATTRITION ANALYTICS PROJECT
-- This project analyzes employee attrition patterns across workforce structure, employee experience, overtime, age, satisfaction, tenure,
--  promotion history, and demographics.
-- ============================================================


-- ============================================================
-- 1. Workforce Size
-- How large is the workforce being analyzed?
-- This query gives context for all attrition numbers.
-- ============================================================

SELECT 
    COUNT(*) AS total_employees
FROM employee_attrition;


-- ============================================================
-- 2. Total Attrition
-- How many employees left the company?
-- This helps to identify the raw turnover volume.
-- ============================================================

SELECT 
    COUNT(*) AS total_attrition
FROM employee_attrition
WHERE attrition = 'Yes';


-- ============================================================
-- 3. Active Employees
-- How many employees remained with the company?
-- This helps compare retained employees against attrition cases.
-- ============================================================

SELECT 
    COUNT(*) AS active_employees
FROM employee_attrition
WHERE attrition = 'No';


-- ============================================================
-- 4. Overall Attrition Rate
-- What percentage of the workforce left?
-- This is more useful than raw attrition count alone.
-- ============================================================

SELECT 
    ROUND(
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate
FROM employee_attrition;


-- ============================================================
-- 5. Workforce Summary KPIs
-- What are the main headline metrics for the dashboard?
-- This supports the KPI cards on the Workforce Overview page.
-- ============================================================

CREATE OR REPLACE VIEW vw_workforce_summary AS
SELECT 
    COUNT(*) AS total_employees,

    COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS total_attrition,

    COUNT(CASE WHEN attrition = 'No' THEN 1 END) AS active_employees,

    ROUND(
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate,

    ROUND(AVG(monthly_income), 2) AS average_monthly_income,

    ROUND(AVG(years_at_company), 2) AS average_tenure

FROM employee_attrition;


-- ============================================================
-- 6. Attrition Rate by Department
-- Which departments have the highest attrition risk?
-- Rate is used instead of raw count so departments can be compared fairly.
-- ============================================================

CREATE OR REPLACE VIEW vw_department_attrition AS
SELECT 
    department,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS total_attrition,

    ROUND(
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employee_attrition
GROUP BY department
ORDER BY attrition_rate DESC;


-- ============================================================
-- 7. Attrition by Overtime
-- Does overtime appear connected to employee turnover?
-- This compares attrition patterns between overtime and non-overtime employees.
-- ============================================================

CREATE OR REPLACE VIEW vw_overtime_attrition AS
SELECT 
    overtime,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS total_attrition,

    ROUND(
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employee_attrition
GROUP BY overtime
ORDER BY attrition_rate DESC;


-- ============================================================
-- 8. Attrition Rate by Age Group
-- Which age groups are more likely to leave?
-- Age is grouped to avoid misleading single-age comparisons.
-- sort_order is included so Power BI displays the groups correctly.
-- ============================================================

DROP VIEW IF EXISTS vw_age_group_attrition;

CREATE VIEW vw_age_group_attrition AS
SELECT 
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,

    CASE
        WHEN age < 25 THEN 1
        WHEN age BETWEEN 25 AND 34 THEN 2
        WHEN age BETWEEN 35 AND 44 THEN 3
        WHEN age BETWEEN 45 AND 54 THEN 4
        ELSE 5
    END AS sort_order,

    COUNT(*) AS total_employees,
    COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS total_attrition,

    ROUND(
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employee_attrition
GROUP BY age_group, sort_order
ORDER BY sort_order;


-- ============================================================
-- 9. Attrition Share by Gender
-- How is attrition distributed by gender?
-- This supports the gender attrition share visual.
-- ============================================================

CREATE OR REPLACE VIEW vw_gender_attrition AS
SELECT 
    gender,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS total_attrition,

    ROUND(
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employee_attrition
GROUP BY gender;


-- ============================================================
-- 10. Average Employee Experience Scores
-- What is the general employee experience level?
-- Average is used because satisfaction fields are rating scores, not totals.
-- ============================================================

SELECT
    ROUND(AVG(job_satisfaction), 2) AS avg_job_satisfaction,
    ROUND(AVG(work_life_balance), 2) AS avg_work_life_balance,
    ROUND(AVG(environment_satisfaction), 2) AS avg_environment_satisfaction,
    ROUND(AVG(relationship_satisfaction), 2) AS avg_relationship_satisfaction
FROM employee_attrition;


-- ============================================================
-- 11. Attrition by Job Satisfaction
-- Do employees with lower job satisfaction leave more?
-- This supports the satisfaction visual on the Employee Experience page.
-- ============================================================

SELECT
    job_satisfaction,
    COUNT(*) AS total_attrition
FROM employee_attrition
WHERE attrition = 'Yes'
GROUP BY job_satisfaction
ORDER BY job_satisfaction;


-- ============================================================
-- 12. Work-Life Balance by Attrition
-- How does work-life balance differ between employees who left and stayed?
-- This compares employee experience across attrition status.
-- ============================================================

SELECT
    work_life_balance,
    attrition,
    COUNT(*) AS employee_count
FROM employee_attrition
GROUP BY work_life_balance, attrition
ORDER BY work_life_balance, attrition;


-- ============================================================
-- 13. Attrition by Years Since Last Promotion
-- Does promotion timing appear connected to attrition?
-- This checks whether employees are leaving after promotion gaps.
-- ============================================================

SELECT
    years_since_last_promotion,
    COUNT(*) AS total_attrition
FROM employee_attrition
WHERE attrition = 'Yes'
GROUP BY years_since_last_promotion
ORDER BY years_since_last_promotion;


-- ============================================================
-- 14. Monthly Income vs Years at Company
-- How do income and tenure relate among employees who left?
-- This supports the scatter plot on the Employee Experience page.
-- ============================================================

SELECT
    employee_number,
    monthly_income,
    years_at_company,
    attrition
FROM employee_attrition
WHERE attrition = 'Yes';


-- ============================================================
-- 15. Workforce Distribution by Job Role
-- Which roles make up the largest parts of the workforce?
-- This helps identify major workforce groups for retention planning.
-- ============================================================

SELECT
    job_role,
    COUNT(*) AS total_employees
FROM employee_attrition
GROUP BY job_role
ORDER BY total_employees DESC;


-- ============================================================
-- 16. Workforce by Education Field
-- Which education backgrounds dominate the workforce?
-- This supports the demographic composition analysis.
-- ============================================================

SELECT
    education_field,
    COUNT(*) AS total_employees
FROM employee_attrition
GROUP BY education_field
ORDER BY total_employees DESC;


-- ============================================================
-- 17. Gender Distribution by Department
-- How does gender representation vary across departments?
-- This supports demographic comparison by department.
-- ============================================================

SELECT
    department,
    gender,
    COUNT(*) AS total_employees
FROM employee_attrition
GROUP BY department, gender
ORDER BY department, gender;


-- ============================================================
-- 18. Age Group and Marital Status Demographics
-- How does marital status vary across age groups?
-- This supports the demographic ribbon chart.
-- sort_order is included for correct age ordering in Power BI.
-- ============================================================

DROP VIEW IF EXISTS vw_age_demographics;

CREATE VIEW vw_age_demographics AS
SELECT
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,

    CASE
        WHEN age < 25 THEN 1
        WHEN age BETWEEN 25 AND 34 THEN 2
        WHEN age BETWEEN 35 AND 44 THEN 3
        WHEN age BETWEEN 45 AND 54 THEN 4
        ELSE 5
    END AS sort_order,

    marital_status,
    COUNT(*) AS total_employees

FROM employee_attrition
GROUP BY age_group, sort_order, marital_status
ORDER BY sort_order;


-- ============================================================
-- 19. Average Age and Tenure
-- What is the general workforce profile?
-- These metrics support the Employee Demographics KPI cards.
-- ============================================================

SELECT
    ROUND(AVG(age), 2) AS average_age,
    ROUND(AVG(years_at_company), 2) AS average_years_at_company
FROM employee_attrition;


-- ============================================================
-- 20. Largest Workforce Role
-- Which job role has the largest employee population?
-- This supports the Top Role KPI card.
-- ============================================================

SELECT
    job_role,
    COUNT(*) AS total_employees
FROM employee_attrition
GROUP BY job_role
ORDER BY total_employees DESC
LIMIT 1;


-- ============================================================
-- 21. Largest Department
-- Which department has the largest workforce population?
-- This supports the Largest Department KPI card.
-- ============================================================

SELECT
    department,
    COUNT(*) AS total_employees
FROM employee_attrition
GROUP BY department
ORDER BY total_employees DESC
LIMIT 1;