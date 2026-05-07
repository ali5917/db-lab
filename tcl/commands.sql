-- -------------------------------------------------------------------------
-- ORACLE TCL (Transaction Control Language) CHEATSHEET
-- -------------------------------------------------------------------------

-- 1. COMMIT
-- Concept: Saves all changes permanently to the database.
-- Rules:
--   * Changes become visible to other users only after COMMIT.
--   * After COMMIT, ROLLBACK has no effect.
--   * DDL statements (CREATE, DROP, ALTER) auto-commit automatically.

UPDATE employees 
SET salary = salary + 1000 
WHERE employee_id = 101;

COMMIT; -- Changes are now permanent


-- 2. ROLLBACK
-- Concept: Undoes all uncommitted changes since the last COMMIT.
-- Rules:
--   * Only works on UNCOMMITTED changes.
--   * After ROLLBACK, data returns to its last committed state.

DELETE FROM employees 
WHERE employee_id = 105;

ROLLBACK; -- Deletion cancelled, row restored.


-- 3. SAVEPOINT
-- Concept: Creates a checkpoint within a transaction for partial rollbacks.

INSERT INTO employees (employee_id, first_name, salary) 
VALUES (201, 'Ali', 30000);

SAVEPOINT sp1; -- Checkpoint created

UPDATE employees 
SET salary = 35000 
WHERE employee_id = 201;

ROLLBACK TO sp1; -- UPDATE is undone, but INSERT remains.
-- Note: Transaction is still OPEN. You still need to COMMIT or ROLLBACK.


-- 4. SET TRANSACTION
-- Concept: Sets properties for the current transaction. 
-- Must be the FIRST statement in a transaction.
-- Modes:
--   * READ ONLY: Only SELECT allowed.
--   * READ WRITE: Default mode; all DML allowed.

SET TRANSACTION READ ONLY;
SELECT * FROM employees; -- Allowed
-- Any UPDATE/DELETE here would throw an error.


-- 5. AUTOCOMMIT (Environment Setting)
-- Concept: Automatically commits every DML statement immediately.

SET AUTOCOMMIT ON;
-- Every INSERT/UPDATE/DELETE after this is permanent instantly.

SET AUTOCOMMIT OFF; -- Default Oracle behavior
-- You must manually write COMMIT to save changes.