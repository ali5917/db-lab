-- 1. Create a trigger to control employee transfers between departments. Ensure new 
-- department exists and is active. Record details (ID, old/new dept, date) into 
-- history table. Prevent transfers to inactive/invalid departments.

CREATE TABLE HISTORY (
    ID EMPLOYEES.EMPLOYEE_ID%TYPE,
    OLD_DEPT DEPARTMENTS.DEPARTMENT_ID%TYPE,
    NEW_DEPT DEPARTMENTS.DEPARTMENT_ID%TYPE, 
    TRANSFER_DATE DATE
);

CREATE OR REPLACE TRIGGER tr1
BEFORE UPDATE OF DEPARTMENT_ID ON EMPLOYEES
FOR EACH ROW
DECLARE
    deptCount NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO deptCount
    FROM DEPARTMENTS 
    WHERE DEPARTMENT_ID = :NEW.DEPARTMENT_ID;
    
    IF (deptCount = 0) THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Department does not exist.')
    ELSE 
        INSERT INTO HISTORY (ID, OLD_DEPT, NEW_DEPT, TRANSFER_DATE) 
        VALUES (:OLD.EMPLOYEE_ID, :OLD.DEPARTMENT_ID, :NEW.DEPARTMENT_ID, SYSDATE);
    END IF;
END;
/

-- 3. Create a trigger to update 'employee_bonus' (10% of salary) when a new 
-- employee is added.

CREATE OR REPLACE TRIGGER tr2
AFTER INSERT ON EMPLOYEES
FOR EACH ROW
DECLARE 
    bonus NUMBER;
BEGIN 
    bonus:= :NEW.SALARY * 0.1;
    INSERT INTO employee_bonus (id, bonus)
    VALUES (:NEW.EMPLOYEE_ID, bonus);
END;
/

-- 4.  Create a trigger that checks the new salary value being updated in the employees table. If the
--     new salary is greater than a threshold (say 10,000), display an error message to the user.

CREATE OR REPLACE TRIGGER tr3
BEFORE UPDATE OF SALARY ON EMPLOYEES
FOR EACH ROW
BEGIN
    IF (:NEW.SALARY > 10000) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Above threshold!');
    END IF;
END;
/

-- 5. Create a trigger to log deleted records from 'Employees' into 'Deleted_Employees_Log'.

CREATE OR REPLACE TRIGGER tr4
BEFORE DELETE ON EMPLOYEES
FOR EACH ROW
BEGIN
    INSERT INTO Deleted_Employees_Log
    VALUES (:OLD.emp_id, :OLD.emp_name, :OLD.salary, sysdate);
END;
/

-- 7. Create a trigger to log every new table created (name, time, user) into 'Audit_Log'.

CREATE OR REPLACE TRIGGER tr6
AFTER CREATE ON SCHEMA
BEGIN
    IF (ora_dict_obj_type = 'TABLE') THEN
        INSERT INTO Audit_Log 
        VALUES (ora_dict_obj_name, SYSDATE, sys_context('USERENV', 'CURRENT_USER'));
    END IF;
END;
/

-- 8. Create a trigger to prevent ALTER statements on 'employees' table outside 
-- business hours (6 PM to 8 AM).

CREATE OR REPLACE TRIGGER tr7
BEFORE ALTER ON SCHEMA
BEGIN
    IF (ora_dict_obj_name = 'EMPLOYEES') THEN 
        IF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) > 18 OR TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) < 6 THEN
            RAISE_APPLICATION_ERROR(-20002, 'OUTSIDE BUSINESS HOURS');
        END IF;
    END IF;    
END;
/

-- 9. Create a trigger to log every DROP operation (user, time) to 'Drop_Log'.

CREATE OR REPLACE TRIGGER tr8
AFTER DROP ON SCHEMA
BEGIN
    INSERT INTO Drop_Log 
    VALUES (sys_context('USERENV', 'CURRENT_USER'), SYSDATE);
END;    
/

-- 10. Create a trigger to prevent dropping the 'Audit_Log' table.

CREATE OR REPLACE TRIGGER tr9
BEFORE DROP ON SCHEMA
BEGIN
    IF (ora_dict_obj_name = 'AUDIT_LOG') THEN
        RAISE_APPLICATION_ERROR(-20001, 'PREVENTED');
    END IF;
END;
/

-- 11. Create a trigger to log database startup time and status into 'System_Logs'.

CREATE OR REPLACE TRIGGER tr10
AFTER STARTUP ON DATABASE
BEGIN
    INSERT INTO system_logs
    VALUES (
        ora_sysevent,          
        'Database Started',
        SYSDATE,
        TO_CHAR(SYSDATE, 'HH24:MI:SS')
    );
END;
/

-- 13. Create a view joining Employees and Departments, with an INSTEAD OF INSERT trigger 
-- to distribute data to both tables.

CREATE VIEW empDays AS
SELECT
e.emp_id,
e.first_name,
e.salary,
d.dept_id,
d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

CREATE OR REPLACE TRIGGER tr13
INSTEAD OF INSERT ON empDays
FOR EACH ROW
BEGIN
    INSERT INTO EMPLOYEES 
    VALUES (:NEW.emp_id, :NEW.first_name, :NEW.salary, :NEW.dept_id);
    INSERT INTO DEPARTMENTS 
    VALUES (:NEW.dept_id, :new.dept_name);
END;
/

-- 14. Create a view for employee salaries with an INSTEAD OF UPDATE trigger to prevent 
-- salary reductions of more than 20%.

CREATE VIEW emp_salaries AS
SELECT id, SALARY
FROM EMPLOYEES;

CREATE OR REPLACE TRIGGER tr14
INSTEAD OF UPDATE ON emp_salaries
FOR EACH ROW
BEGIN
    IF (:NEW.SALARY < 0.8 * :OLD.SALARY) THEN
        RAISE_APPLICATION_ERROR(-20001, 'EXCEEDED REDUCTION LIMIT');
    ELSE 
        UPDATE EMPLOYEES
        SET SALARY = :NEW.SALARY
        WHERE EMPLOYEE_ID = :OLD.id;    
    END IF;
END;
/