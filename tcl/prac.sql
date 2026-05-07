-- 1. A new patient is being admitted into the hospital and their treatment entry must also be 
-- recorded in the log system. The system must ensure that both operations are completed 
-- together; if any issue occurs, no record should remain stored.

BEGIN 
    INSERT INTO PATIENTS VALUES (301, 'Ahmed Khan', 'admitted', 0);
    INSERT INTO TREATMENT_LOG VALUES (1001, 301, 'Initial assessment done');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;

-- 2. The hospital plans to change the status of all patients marked as "under observation" 
-- to "critical review". If the number of affected patients exceeds a safe operational 
-- limit, all changes must be undone.

DECLARE
    safeLimit NUMBER := 10;
BEGIN
    UPDATE PATIENTS
    SET STATUS = 'Critical Review'
    WHERE STATUS = 'Under Observation';

    IF (SQL%ROWCOUNT > safeLimit) THEN 
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END;

-- 3. Before adding a new patient record, the system must verify that no existing patient 
-- has the same name. If a duplicate is found, the entire process must be cancelled.

DECLARE
    name PATIENTS.PATIENT_NAME%TYPE := 'Lisa';
    cnt NUMBER;
BEGIN 
    SELECT COUNT(*) 
    INTO cnt
    FROM PATIENTS
    WHERE PATIENT_NAME = name;

    IF (cnt > 0) THEN
        ROLLBACK;
    ELSE
        INSERT INTO PATIENTS 
        VALUES (302, name, 'admitted', 0);
        COMMIT;
    END IF;
END;    

-- 4. The hospital performs multiple actions together: a new patient is admitted, an existing 
-- patient's billing amount is updated, and a discharged patient record is removed. 
-- These actions must either all succeed or all fail together.

BEGIN
    INSERT INTO PATIENTS VALUES (303, 'Usman Ali', 'Admitted', 0);

    UPDATE PATIENTS
    SET BILLING_AMOUNT = BILLING_AMOUNT + 5000
    WHERE PATIENT_ID = 210;

    DELETE FROM PATIENTS
    WHERE PATIENT_ID = 150
    AND status = 'Discharged';

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;

-- 5. During a batch update of patient treatment status, the system defines a checkpoint 
-- after completing the first phase of updates. If an error occurs in the next phase, 
-- only the changes after that checkpoint should be reversed while keeping earlier 
-- valid changes intact.

BEGIN
    UPDATE PATIENTS
    SET STATUS = 'treatment started'
    WHERE STATUS = 'admitted' AND PATIENT_ID BETWEEN 100 AND 200;

    SAVEPOINT phase1Done;

    UPDATE PATIENTS
    SET STATUS = 'treatment started'
    WHERE STATUS = 'admitted' AND PATIENT_ID BETWEEN 201 AND 300;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO phase1Done;
        COMMIT;
END;