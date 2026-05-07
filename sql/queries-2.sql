-- QUERIES

-- 1. Write a query to retrieve employees who have been employed in multiple departments, 
--    including their start and end dates in each department 
SELECT E.FIRST_NAME, JH.START_DATE, JH.END_DATE
FROM EMPLOYEES E
JOIN JOB_HISTORY JH USING (EMPLOYEE_ID)
WHERE E.EMPLOYEE_ID IN (
    SELECT EMPLOYEE_ID
    FROM JOB_HISTORY
    GROUP BY EMPLOYEE_ID
    HAVING COUNT(DISTINT DEPARTMENT_ID) > 1
)

-- 2. Write a query to update department_id of all employees to be equal to the 
-- one with state province Texas, given that its initial value is NULL

UPDATE EMPLOYEES
SET DEPARTMENT_ID = (
    SELECT DEPARTMENT_ID 
    FROM DEPARTMENTS D
    JOIN LOCATIONS L USING (LOCATION_ID)
    WHERE STATE_PROVINCE = 'Texas'
)
WHERE DEPARTMENT_ID IS NULL;

-- 3. Write a query to find the departments with the highest and lowest salary payouts, 
--    along with the total number of employees in each department.
SELECT DEPT_NAME, SALARY_PAYOUT, TOTAL_EMPLOYEES FROM (
    SELECT D.DEPARTMENT_NAME AS DEPT_NAME, SUM(E.SALARY) AS SALARY_PAYOUT, COUNT(E.EMPLOYEE_ID) AS TOTAL_EMPLOYEES
    FROM EMPLOYEES E 
    JOIN DEPARTMENTS D USING(DEPARTMENT_ID) 
    GROUP BY D.DEPARTMENT_NAME 
    ORDER BY SUM(E.SALARY) DESC 
    FETCH FIRST 1 ROW ONLY
)

UNION

SELECT DEPT_NAME, SALARY_PAYOUT, TOTAL_EMPLOYEES FROM (
    SELECT D.DEPARTMENT_NAME AS DEPT_NAME, SUM(E.SALARY) AS SALARY_PAYOUT, COUNT(E.EMPLOYEE_ID) AS TOTAL_EMPLOYEES
    FROM EMPLOYEES E 
    JOIN DEPARTMENTS D USING(DEPARTMENT_ID) 
    GROUP BY D.DEPARTMENT_NAME 
    ORDER BY SUM(E.SALARY)
    FETCH FIRST 1 ROW ONLY
);


-- 4. Write a query to identify the ten most senior employees 
--    and display their tenure periods.
SELECT FIRST_NAME || ' ' || LAST_NAME AS NAME, ROUND((CURRENT_DATE - HIRE_DATE) / 365, 2) AS TENURE_YEARS
FROM EMPLOYEES 
ORDER BY TENURE_YEARS DESC
FETCH FIRST 10 ROWS ONLY;

-- 5. List employees whose salaries, after a 20% increment, are still below 3000.
SELECT FIRST_NAME, SALARY AS ORIGINAL_SALARY, (SALARY * 1.2) AS INCREASED_SALARY
FROM EMPLOYEES 
WHERE SALARY * 1.2 < 3000; 

-- 6. Write a query to display Department ID, Department Name, Manager Name, 
--    Manager Salary, and Department City.
SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, E.FIRST_NAME, E.SALARY, L.CITY 
FROM DEPARTMENTS D
JOIN EMPLOYEES E ON D.MANAGER_ID = E.EMPLOYEE_ID
JOIN LOCATIONS L USING (LOCATION_ID);

-- 7. Write a query to display all employee information for those whose 
--    salary falls within the range of the lowest salary and 2500.
SELECT *
FROM EMPLOYEES
WHERE SALARY BETWEEN (
    SELECT MIN(SALARY) FROM EMPLOYEES
) AND 2500;

-- 8. Write a query to retrieve the names of employees whose 
--    salary exceeds 50% of their department's total salary expenditure.
SELECT E1.FIRST_NAME
FROM EMPLOYEES E1
WHERE SALARY > 0.5 * (
    SELECT SUM(SALARY)
    FROM EMPLOYEES E2
    WHERE E2.DEPARTMENT_ID = E1.DEPARTMENT_ID        
)

-- 9. SQL query to retrieve the full name, job title, start date, and end date 
--    of the most recent job held by employees who did not receive any commission.
SELECT E.FIRST_NAME || ' ' || E.LAST_NAME AS FULL_NAME, J.JOB_TITLE, (
    SELECT START_DATE 
    FROM JOB_HISTORY 
    WHERE EMPLOYEE_ID = E.EMPLOYEE_ID
    ORDER BY START_DATE DESC
    FETCH FIRST 1 ROW ONLY
) AS START_DATE, (
    SELECT END_DATE 
    FROM JOB_HISTORY 
    WHERE EMPLOYEE_ID = E.EMPLOYEE_ID
    ORDER BY START_DATE DESC
    FETCH FIRST 1 ROW ONLY
) AS END_DATE
FROM EMPLOYEES E
JOIN JOBS J USING (JOB_ID)
WHERE E.COMMISSION_PCT IS NULL

-- 10. Query to calculate the total salary for each state 
--     where the second letter of the state name is 'a'.
SELECT L.STATE_PROVINCE, SUM(E.SALARY)
FROM EMPLOYEES E
JOIN DEPARTMENTS D USING (DEPARTMENT_ID)
JOIN LOCATIONS L USING (LOCATION_ID)
WHERE L.STATE_PROVINCE LIKE '_a%'
GROUP BY L.STATE_PROVINCE