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

-- 6. Print the name and salary of every employee in department 50.

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

-- 7. Create a procedure that takes a worker's ID and displays their salary.

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

-- 8. Create a procedure that takes a staff ID and returns their department code via an OUT parameter.

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

-- 9. Create a procedure that takes a number and increases it by 25% using an IN OUT parameter.

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

-- 10. Design a solution that takes a street address and city, country, finds the next unique ID 
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

    INSERT INTO LOCATIONS(LOCATION_ID, STREET_ADDRESS, POSTAL_CODE, CITY, STATE_PROVINCE, COUNTRY_ID
    ) VALUES (newID, addr, 'N/A', city, NULL, cID);

    DBMS_OUTPUT.PUT_LINE('New branch:');
    DBMS_OUTPUT.PUT_LINE('Location ID : ' || newID);
    DBMS_OUTPUT.PUT_LINE('Street: ' || addr);
    DBMS_OUTPUT.PUT_LINE('City: ' || city);
    DBMS_OUTPUT.PUT_LINE('Country ID: ' || cID);
END;
/

EXEC addBranch('Street 5, Shahrah-e-Faisal', 'Karachi', 'PK');