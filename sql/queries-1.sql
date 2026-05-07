-- Queries

-- Show full name of those employees whose name starts with A and ends with n.
SELECT FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME
FROM EMPLOYEES
WHERE FIRST_NAME LIKE 'A%n';

-- Show all employees' last three letters of last name.
SELECT SUBSTR(LAST_NAME, -3, 3)
FROM EMPLOYEES

-- Display First_Name, job_id, salary of all the employees whose job is "ACCOUNTANT".
-- Accountant may be in capital, small or combination of small capital characters in the table.
SELECT E.FIRST_NAME, JOB_ID, J.JOB_TITLE, E.SALARY 
FROM EMPLOYEES E
JOIN JOBS J USING (JOB_ID)
WHERE UPPER(J.JOB_TITLE) = 'ACCOUNTANT';


-- Display the Employee_ID, First_Name, salary of employees. 
-- In that, the highest paid employee should display first and lowest paid should display last.
SELECT EMPLOYEE_ID, FIRST_NAME, SALARY
FROM EMPLOYEES 
ORDER BY SALARY DESC;

-- Display the employee Id, job name, job id, department id, 
-- number of days worked in for all those jobs in department 90.
SELECT JH.EMPLOYEE_ID, J.JOB_TITLE, JOB_ID, JH.DEPARTMENT_ID, NVL(JH.END_DATE, SYSDATE) - JH.START_DATE AS DAYS_WORKED 
FROM JOB_HISTORY JH
JOIN JOBS J USING(JOB_ID)
WHERE JH.DEPARTMENT_ID = 90;

-- Display new names of the employees by combining 
-- the first 3 characters of the First_Name and last 3 characters of the Email.
SELECT SUBSTR(FIRST_NAME, 1, 3) || SUBSTR(EMAIL, -3, 3)
FROM EMPLOYEES;

-- List the department names and get the count of employees working in each department.
SELECT D.DEPARTMENT_NAME, COUNT(E.EMPLOYEE_ID)
FROM DEPARTMENTS D
JOIN EMPLOYEES E USING (DEPARTMENT_ID)
GROUP BY D.DEPARTMENT_NAME;

-- Display the first name, salary, phone number, hire date and 
-- department Id for those employees whose department is located in the city Toronto.
SELECT E.FIRST_NAME, E.SALARY, E.PHONE_NUMBER, E.HIRE_DATE, DEPARTMENT_ID
FROM EMPLOYEES E
JOIN DEPARTMENTS D USING (DEPARTMENT_ID)
JOIN LOCATIONS L USING (LOCATION_ID)
WHERE L.CITY = 'Toronto';

-- Display employee's full name along with the total number of years in the department.
SELECT E.FIRST_NAME || ' ' || E.LAST_NAME AS FULL_NAME, ROUND((
    SELECT SUM (NVL(END_DATE, SYSDATE) - START_DATE)  
    FROM JOB_HISTORY
    WHERE EMPLOYEE_ID = E.EMPLOYEE_ID AND DEPARTMENT_ID = E.DEPARTMENT_ID
) / 365, 2) AS TOTAL_YEARS
FROM EMPLOYEES E

-- Display the Manager_ID and the salary of the lowest paid employee of that manager. 
-- Exclude anyone whose manager is not known. 
-- Exclude any groups where the minimum salary is 2000. 
-- Sort the output is descending order of the salary.
SELECT MANAGER_ID, MIN(SALARY)
FROM EMPLOYEES
WHERE MANAGER_ID IS NOT NULL
GROUP BY MANAGER_ID
HAVING MIN(SALARY) != 2000
ORDER BY MIN(SALARY) DESC

-- Display the country name, city, and number 
-- of those departments where at least 3 employees are working.
SELECT COUNT(D.DEPARTMENT_ID), C.COUNTRY_NAME, L.CITY 
FROM DEPARTMENTS D
JOIN LOCATIONS L USING (LOCATION_ID)
JOIN COUNTRIES C USING (COUNTRY_ID)
WHERE DEPARTMENT_ID IN (
    SELECT DEPARTMENT_ID
    FROM EMPLOYEES 
    GROUP BY DEPARTMENT_ID
    HAVING COUNT(EMPLOYEE_ID) >= 3
)
GROUP BY C.COUNTRY_NAME, L.CITY;

-- Display the Department_Name and average salary of those departments whose average salary is greater than 2500.
SELECT D.DEPARTMENT_NAME, ROUND(AVG(E.SALARY), 2) AS AVG_SALARY
FROM EMPLOYEES E 
JOIN DEPARTMENTS D USING (DEPARTMENT_ID)
GROUP BY D.DEPARTMENT_NAME
HAVING AVG(E.SALARY) > 2500;

-- Display all the information of those employees who did not have any job in the past.
SELECT *
FROM EMPLOYEES E
WHERE NOT EXISTS (
    SELECT 1
    FROM JOB_HISTORY
    WHERE EMPLOYEE_ID = E.EMPLOYEE_ID 
)