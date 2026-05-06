-- -------------------------------------------------------------------------
-- PL/SQL CHEATSHEET & CORE CONCEPTS
-- -------------------------------------------------------------------------

-- Always enable server output to see DBMS_OUTPUT.PUT_LINE results
SET SERVEROUTPUT ON;

-- 1. BLOCK STRUCTURE, VARIABLES & SCOPE
-- DECLARE: Variables (optional)
-- BEGIN: Logic (mandatory)
-- EXCEPTION: Error handling (optional)

DECLARE
    v_num INTEGER := 10;               -- Whole numbers
    v_dec NUMBER := 70.0 / 3.0;        -- Handles decimals too
    v_name VARCHAR2(20) := 'Ali';      -- Text up to 20 chars
    v_emp_name employees.FIRST_NAME%TYPE; --  %TYPE borrows a column's data type
BEGIN
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name || ', Num: ' || v_num);  -- prints on screen
END;
/

-- 2. SELECT INTO (Fetching Data)
-- Rule 1: Must return EXACTLY ONE row (0 or multiple rows = error).
-- Rule 2: Number/types of variables must match selected columns.
DECLARE
    v_emp_name employees.FIRST_NAME%TYPE;
BEGIN
    SELECT FIRST_NAME 
    INTO v_emp_name 
    FROM employees 
    WHERE EMPLOYEE_ID = 100;
    
    DBMS_OUTPUT.PUT_LINE('Fetched Name: ' || v_emp_name);
END;
/

-- 3. CONDITIONAL LOGIC
DECLARE
    v_sal NUMBER := 18000;
    v_did NUMBER := 50;
BEGIN
    -- IF-THEN-ELSIF-ELSE
    IF v_sal <= 15000 AND v_did = 50 THEN
        DBMS_OUTPUT.PUT_LINE('Low Bracket Shipping');
    ELSIF v_sal <= 20000 OR v_did = 80 THEN
        DBMS_OUTPUT.PUT_LINE('Mid Bracket or Sales');
    ELSE
        DBMS_OUTPUT.PUT_LINE('High Bracket Other');
    END IF;

    -- CASE
    CASE 
        WHEN v_did = 80 AND v_sal > 15000 THEN
            DBMS_OUTPUT.PUT_LINE('High Salary Sales');
        WHEN v_did = 50 OR v_did = 60 THEN
            DBMS_OUTPUT.PUT_LINE('Shipping or IT');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Other Department');
    END CASE;
END;
/

-- 4. LOOPS
-- No need to DECLARE 'c' as a variabl. It is implicitly declared as a record.
BEGIN
    FOR c IN (
        SELECT EMPLOYEE_ID, FIRST_NAME, SALARY 
        FROM employees 
        WHERE DEPARTMENT_ID = 90
    ) 
    LOOP
        DBMS_OUTPUT.PUT_LINE(c.FIRST_NAME || ' makes: ' || c.SALARY);
    END LOOP;
END;
/

-- 5. STORED PROCEDURES

-- IN Mode: Read-only input. Caller passes a value in.
CREATE OR REPLACE PROCEDURE Show_Employee (
    p_id IN NUMBER
) IS
    v_name employees.FIRST_NAME%TYPE;
BEGIN
    SELECT FIRST_NAME 
    INTO v_name 
    FROM employees 
    WHERE EMPLOYEE_ID = p_id;
    DBMS_OUTPUT.PUT_LINE('Procedure Output: ' || v_name);
END;
/

-- How to run: 
EXEC Show_Employee(100);


-- OUT Mode: Sends a value back to the caller. (Passing by reference) 
CREATE OR REPLACE PROCEDURE Get_Salary (
    p_id IN NUMBER, 
    p_sal OUT NUMBER
) IS
BEGIN
    SELECT SALARY 
    INTO p_sal 
    FROM employees 
    WHERE EMPLOYEE_ID = p_id;
END;
/

-- How to run (requires DECLARE to catch the OUT value):
DECLARE 
    v_sal NUMBER;
BEGIN
    Get_Salary(100, v_sal);
    DBMS_OUTPUT.PUT_LINE(v_sal);
END;
/


-- IN OUT Mode: Reads a value in AND sends it back modified.
CREATE OR REPLACE PROCEDURE Update_Value (
    p_num IN OUT NUMBER
) IS
BEGIN
    p_num := p_num + 10;
END;
/

-- How to run:
DECLARE 
    v_val NUMBER := 50;
BEGIN
    Update_Value(v_val);
    DBMS_OUTPUT.PUT_LINE('Updated: ' || v_val); 
END;
/