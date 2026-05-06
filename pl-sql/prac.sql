-- 1. Take a product’s base price of $250, calculate a 15% luxury tax, and display both the 
-- tax amount and the final total price.

SET SERVEROUTPUT ON;
DECLARE 
    basePrice NUMBER := 250;
    taxAmount NUMBER;
    finalPrice NUMBER;     
BEGIN
    taxAmount := basePrice * 0.15;
    finalPrice := basePrice + taxAmount;
    DBMS_OUTPUT.PUT_LINE('Tax Amount: $' || taxAmount);
    DBMS_OUTPUT.PUT_LINE('Final Price: $' || finalPrice);
END;
/

-- 2. Retrieve the first name and monthly earnings of employee ID 105 from the staff records 
-- and print these details.

SET SERVEROUTPUT ON;
DECLARE
    fName EMPLOYEES.FIRST_NAME%TYPE;
    sal EMPLOYEES.SALARY%TYPE;
BEGIN
    SELECT FIRST_NAME, SALARY
    INTO fName, sal 
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = 105;

    DBMS_OUTPUT.PUT_LINE('First Name: ' || fName);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || sal);
END;
/

-- 3. For employee ID 110, if pay is less than $8,000, increase it by $1,200. 
-- Otherwise, increase it by $400. Update the record.

SET SERVEROUTPUT ON;
DECLARE
    sal EMPLOYEES.SALARY%TYPE;
    incSal NUMBER;
BEGIN
    SELECT SALARY
    INTO sal
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = 110;

    IF (sal < 8000) THEN
       incSal := sal + 1200; 
    ELSE 
       incSal := sal + 400; 
    END IF;  

    UPDATE EMPLOYEES
    SET SALARY = incSal
    WHERE EMPLOYEE_ID = 110;
END;
/

-- 4. Label roles by department code: 90 is "Administration", 60 is "Technical Services", 
-- others are "General Staff." Check for employee 115. Print the label.

SET SERVEROUTPUT ON;
DECLARE
    deptID EMPLOYEES.DEPARTMENT_ID%TYPE;
    label VARCHAR2(30);
BEGIN
    SELECT DEPARTMENT_ID
    INTO deptID
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = 115;

    label := 
        CASE
            WHEN deptID = 90 THEN 'Administration'
            WHEN deptID = 60 THEN 'Technical Services'
            ELSE 'General Staff'
        END;

    DBMS_OUTPUT.PUT_LINE('Label is ' || label);
END;
/

-- 5. Print the name and salary of every employee in department 50.

SET SERVEROUTPUT ON;
BEGIN
    FOR c IN (
        SELECT FIRST_NAME, SALARY
        FROM EMPLOYEES
        WHERE DEPARTMENT_ID = 50
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Name: ' || c.FIRST_NAME || ', Salary: $' || c.SALARY);
    END LOOP;
END;
/

-- 6. Create a procedure that takes a worker's ID and displays their salary.

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE printSal(
    id IN EMPLOYEES.EMPLOYEE_ID%TYPE
) IS 
    sal EMPLOYEES.SALARY%TYPE;
BEGIN
    SELECT SALARY
    INTO sal
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = id;

    DBMS_OUTPUT.PUT_LINE('ID: ' || id  || ', Salary: ' || sal);
END;
/

EXEC printSal(115);

-- 7. Create a procedure that takes a staff ID and returns their department code via an OUT parameter.

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE getDept(
    id IN EMPLOYEES.EMPLOYEE_ID%TYPE,
    deptID OUT EMPLOYEES.DEPARTMENT_ID%TYPE
) IS 
BEGIN
    SELECT DEPARTMENT_ID
    INTO deptID
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = id;
END;
/

DECLARE 
    deptID EMPLOYEES.DEPARTMENT_ID%TYPE;
BEGIN
    getDept(115, deptID);
    DBMS_OUTPUT.PUT_LINE('Employee 115 belongs to Department ID: ' || deptID);
END;
/

-- 8. Create a procedure that takes a number and increases it by 25% using an IN OUT parameter.

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE incNum(
    num IN OUT NUMBER
) IS 
BEGIN
    num := num * 1.25;
    DBMS_OUTPUT.PUT_LINE('Updated value: ' || num);
END;
/

DECLARE
    num NUMBER := 100;
BEGIN
    incNum(num);
END;
/

-- 9. Design a solution that takes a street address and city, country, finds the next unique ID 
-- (using COUNT), and inserts the new branch details.

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE addBranch (
    addr IN LOCATIONS.STREET_ADDRESS%TYPE,
    city IN LOCATIONS.CITY%TYPE,
    cID IN LOCATIONS.COUNTRY_ID%TYPE
)
IS
    newID NUMBER;
BEGIN
    SELECT MAX(LOCATION_ID) + 1
    INTO newID
    FROM LOCATIONS;

    INSERT INTO LOCATIONS (LOCATION_ID, STREET_ADDRESS, POSTAL_CODE, CITY, STATE_PROVINCE, COUNTRY_ID) 
    VALUES (newID, addr, 'N/A', city, NULL, cID);

    DBMS_OUTPUT.PUT_LINE('New branch:');
    DBMS_OUTPUT.PUT_LINE('Location ID : ' || newID);
    DBMS_OUTPUT.PUT_LINE('Street: ' || addr);
    DBMS_OUTPUT.PUT_LINE('City: ' || city);
    DBMS_OUTPUT.PUT_LINE('Country ID: ' || cID);
END;
/

EXEC addBranch('Street 5, Shahrah-e-Faisal', 'Karachi', 'PK');

-- 10. Create a procedure that displays total and average salary for each department.

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE totAvg
IS
BEGIN
    FOR c IN (
        SELECT SUM(SALARY) AS totalSal, AVG(SALARY) AS avgSal, DEPARTMENT_ID 
        FROM EMPLOYEES
        WHERE DEPARTMENT_ID IS NOT NULL
        GROUP BY DEPARTMENT_ID
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE (
            'Dept ID: '       || c.DEPARTMENT_ID  || 
            ', Total: $'    || c.totalSal       ||
            ', Average: $'  || c.avgSal
        );
    END LOOP;
END;
/

-- 11. Identify employees hired on weekends (Sat/Sun) and log them into 'weekend_hires_log'.

CREATE TABLE weekend_hires_log (
    EMPLOYEE_ID  NUMBER,
    FIRST_NAME   VARCHAR2(20)
);

SET SERVEROUTPUT ON;
BEGIN
    FOR c IN (
        SELECT FIRST_NAME, EMPLOYEE_ID
        FROM EMPLOYEES
        WHERE TRIM(TO_CHAR(hire_date, 'Day')) IN ('Saturday', 'Sunday')    
    )
    LOOP
        INSERT INTO weekend_hires_log (FIRST_NAME, EMPLOYEE_ID) 
        VALUES (c.FIRST_NAME, c.EMPLOYEE_ID);
    END LOOP;
END;
/

-- 12. Create a procedure that removes duplicate employees (same first/last name), 
-- keeping only one valid entry.

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE remDupl 
IS
    saveId EMPLOYEES.EMPLOYEE_ID%TYPE;
BEGIN
    FOR c IN (
        SELECT FIRST_NAME, LAST_NAME, COUNT(EMPLOYEE_ID) 
        FROM EMPLOYEES
        GROUP BY FIRST_NAME, LAST_NAME
        HAVING COUNT(EMPLOYEE_ID) > 1
    )
    LOOP 
        SELECT MIN(EMPLOYEE_ID) 
        INTO saveId
        FROM EMPLOYEES
        WHERE FIRST_NAME = c.FIRST_NAME AND LAST_NAME = c.LAST_NAME;

        DELETE FROM EMPLOYEES
        WHERE FIRST_NAME = c.FIRST_NAME AND LAST_NAME = c.LAST_NAME
        AND EMPLOYEE_ID != saveId;
    END LOOP;
END;
/