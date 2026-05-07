-- -------------------------------------------------------------------------
-- ORACLE TRIGGERS CHEATSHEET & CONCEPTS
-- -------------------------------------------------------------------------

SET SERVEROUTPUT ON;

-- 1. DML TRIGGERS (INSERT, UPDATE, DELETE)

-- BEFORE: Validate values before they are written.
-- AFTER: Logging changes after the operation is complete.
-- FOR EACH ROW: Fires for every row affected (Row-level).

-- :NEW and :OLD Pseudo-Records:
-- Operation | :NEW (New Values) | :OLD (Previous Values)
-- ----------|-------------------|-----------------------
-- INSERT    | YES               | NULL
-- UPDATE    | YES               | YES
-- DELETE    | NULL              | YES

-- Example: Trigger for Single Operation
CREATE OR REPLACE TRIGGER tr_check_salary
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary cannot be negative');
    END IF;
END;
/

-- Example: Trigger for Multiple Operations
CREATE OR REPLACE TRIGGER tr_superheroes
BEFORE INSERT OR DELETE OR UPDATE ON superheroes
FOR EACH ROW
DECLARE
    v_user VARCHAR2(30);
BEGIN
    SELECT user INTO v_user FROM dual;       -- returns the currently logged in user
    
    IF INSERTING THEN
        DBMS_OUTPUT.PUT_LINE('Inserted by ' || v_user);
    ELSIF DELETING THEN
        DBMS_OUTPUT.PUT_LINE('Deleted by ' || v_user);
    ELSIF UPDATING THEN
        DBMS_OUTPUT.PUT_LINE('Updated by ' || v_user);
    END IF;
END;
/

-- Table Auditing and Backup

-- Synchronized Backup Trick: Copies structure but no rows.
CREATE TABLE superheroes_backup AS SELECT * FROM superheroes WHERE 1=2;

CREATE OR REPLACE TRIGGER sh_backup
BEFORE INSERT OR DELETE OR UPDATE ON superheroes
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO superheroes_backup (SH_NAME) VALUES (:NEW.SH_NAME);
    ELSIF DELETING THEN
        DELETE FROM superheroes_backup WHERE SH_NAME = :OLD.SH_NAME;
    ELSIF UPDATING THEN
        UPDATE superheroes_backup 
        SET SH_NAME = :NEW.SH_NAME 
        WHERE SH_NAME = :OLD.SH_NAME;
    END IF;
END;
/

-- 2. DDL TRIGGERS (CREATE, ALTER, DROP)
-- AFTER DDL ON SCHEMA: Monitors the current user.
-- AFTER DDL ON DATABASE: Monitors entire DB (Requires DBA privileges).

-- ora_sysevent -> Operation (CREATE, DROP, etc.)
-- ora_dict_obj_type -> Object type (TABLE, INDEX, etc.)
-- ora_dict_obj_name -> Object name
-- sys_context('USERENV', 'CURRENT_USER') -> returns the currently logged in user

CREATE OR REPLACE TRIGGER hr_audit_tr
AFTER DDL ON SCHEMA
BEGIN
    INSERT INTO schema_audit VALUES (
        sysdate,
        sys_context('USERENV', 'CURRENT_USER'),   -- returns the currently logged in user
        ora_dict_obj_type,
        ora_dict_obj_name,
        ora_sysevent
    );
END;
/

CREATE OR REPLACE TRIGGER tr_prevent_drop
BEFORE DROP ON SCHEMA
BEGIN
    IF ora_dict_obj_type = 'TABLE' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Dropping tables is not allowed!');
    END IF;
END;
/

-- 3. SYSTEM & DATABASE EVENT TRIGGERS
-- LOGON  -> Uses AFTER - schema level
-- LOGOFF -> Uses BEFORE - schema level
-- STARTUP -> Uses AFTER - database level (requires DBA privileges)
-- SHUTDOWN -> Uses BEFORE - database level (requires DBA privileges)    

CREATE OR REPLACE TRIGGER hr_lgon_audit
AFTER LOGON ON SCHEMA
BEGIN
    INSERT INTO hr_evnt_audit (event_type, logon_date)
    VALUES (ora_sysevent, sysdate);
END;
/

CREATE OR REPLACE TRIGGER log_off_audit
BEFORE LOGOFF ON SCHEMA
BEGIN
  INSERT INTO hr_evnt_audit
  VALUES (ora_sysevent, NULL, NULL, sysdate, TO_CHAR(sysdate,'hh24:mi:ss'));
  COMMIT;
END;
/

CREATE OR REPLACE TRIGGER startup_audit
AFTER STARTUP ON DATABASE
BEGIN
  INSERT INTO startup_audit
  VALUES (ora_sysevent, sysdate, TO_CHAR(sysdate,'hh24:mm:ss'));
END;
/

CREATE OR REPLACE TRIGGER tr_shutdown_audit
BEFORE SHUTDOWN ON DATABASE
BEGIN
  INSERT INTO startup_audit
  VALUES (ora_sysevent, sysdate, TO_CHAR(sysdate,'hh24:mm:ss'));
END;
/

-- Used to make non-updatable views (joins, groups, etc.) editable.
-- Rule: Always Row-Level (FOR EACH ROW) and written ON VIEW_NAME.

-- Tables
CREATE TABLE trainer (full_name VARCHAR2(20));
CREATE TABLE subject (subject_name VARCHAR2(15));

-- Non-updatable joined view
CREATE VIEW db_lab_09 AS
  SELECT full_name, subject_name FROM trainer, subject;

-- INSTEAD OF INSERT
CREATE OR REPLACE TRIGGER tr_io_insert
INSTEAD OF INSERT ON db_lab_09
FOR EACH ROW
BEGIN
  INSERT INTO trainer (full_name) VALUES (:NEW.full_name);
  INSERT INTO subject (subject_name) VALUES (:NEW.subject_name);
END;
/

-- INSTEAD OF UPDATE
CREATE OR REPLACE TRIGGER io_update
INSTEAD OF UPDATE ON db_lab_09
FOR EACH ROW
BEGIN
  UPDATE trainer SET full_name = :NEW.full_name WHERE full_name = :OLD.full_name;
  UPDATE subject SET subject_name = :NEW.subject_name WHERE subject_name = :OLD.subject_name;
END;
/

-- INSTEAD OF DELETE
CREATE OR REPLACE TRIGGER io_delete
INSTEAD OF DELETE ON db_lab_09
FOR EACH ROW
BEGIN
  DELETE FROM trainer WHERE full_name = :OLD.full_name;
  DELETE FROM subject WHERE subject_name = :OLD.subject_name;
END;
/