-- Q1

-- 1: Display the department name, employee name, job title, and salary for 
-- the highest-paid employee in each department, ordered by department name.

SELECT D.DEPARTMENT_NAME, E.EMPLOYEE_NAME, J.JOB_TITLE, E.SALARY
FROM DEPARTMENTS D
JOIN EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
JOIN JOBS J ON E.JOB_ID = J.JOB_ID
WHERE (E.DEPARTMENT_ID, E.SALARY) IN (
    SELECT DEPARTMENT_ID, MAX(SALARY)
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
)
ORDER BY D.DEPARTMENT_NAME;

-- 2: Find departments where the difference between the highest-paid and lowest-paid 
-- employee is greater than $4000. Display the department name, maximum salary, 
-- minimum salary, and the salary difference.

SELECT D.DEPARTMENT_NAME, MAX(E.SALARY), MIN(E.SALARY), (MAX(E.SALARY) - MIN(E.SALARY)) AS DIFFERENCE
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
GROUP BY D.DEPARTMENT_NAME
HAVING MAX(E.SALARY) - MIN(E.SALARY) > 4000; 

-- 3: Identify the year and department that hired the most employees. Show the 
-- department name, year, and the number of hires.

SELECT DNAME, HIREYEAR, CNT 
FROM (
    SELECT D.DEPARTMENT_NAME AS DNAME, EXTRACT(YEAR FROM E.HIRE_DATE) AS HIREYEAR, COUNT(*) AS CNT 
    FROM EMPLOYEES E 
    JOIN DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
    GROUP BY D.DEPARTMENT_NAME, EXTRACT(YEAR FROM E.HIRE_DATE) 
) 
WHERE CNT = (
    SELECT MAX(CNT) FROM (
        SELECT COUNT(*) AS CNT 
        FROM EMPLOYEES E 
        JOIN DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
        GROUP BY D.DEPARTMENT_ID, EXTRACT(YEAR FROM E.HIRE_DATE) 
    )
);

-- 4: Find employees whose salary has not changed since they were hired. Display the 
-- employee name, hire date, current salary, and the department they work in.



-- 5: Write a query to find the employees who earn more than their direct manager. 
-- Display the employee name, manager’s name, and their salary.

-- Q2

-- (a): Create a trigger named stock_threshold_check that fires BEFORE UPDATE on 
-- the PRODUCTS table. The trigger should monitor the STOCK_QUANTITY column. 
-- If the new stock quantity is below 5, log a warning in the STOCK_ALERT table.
-- Table Schema: STOCK_ALERT (alert_id, product_id, current_stock, alert_message, alert_date)

CREATE OR REPLACE TRIGGER stock_threshold_check
BEFORE UPDATE OF STOCK_QUANTITY ON PRODUCTS
FOR EACH ROW
BEGIN
    IF :NEW.STOCK_QUANTITY < 5 THEN 
        INSERT INTO STOCK_ALERT (alert_id, product_id, current_stock, alert_message, alert_date)
        VALUES (0, :NEW.PRODUCT_ID, :NEW.STOCK_QUANTITY, 'STOCK ALERT', SYSDATE);
    END IF; 
END;
/

-- (b): Create a hotel guest reservation system. 
-- Tables: 
--   1. guests (guest_id, name, email)
--   2. rooms (room_id, room_type, price)
--   3. reservations (reservation_id, guest_id, room_id, check_in, check_out)
--   4. payments (payment_id, reservation_id, amount)
--   5. reservation_log (log_id, reservation_id, action)
-- Task: Insert a new guest, select a room, make a reservation, process the payment, 
-- and log the action. Ensure that the transaction is committed only if all steps 
-- succeed; otherwise, roll back the changes.

CREATE TABLE guests (
    guest_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100)
);

CREATE TABLE rooms (
    room_id NUMBER PRIMARY KEY,
    room_type VARCHAR2(50),
    price NUMBER(10, 2)
);

CREATE TABLE reservations (
    reservation_id NUMBER PRIMARY KEY,
    guest_id NUMBER REFERENCES guests(guest_id),
    room_id NUMBER REFERENCES rooms(room_id),
    check_in DATE,
    check_out DATE
);

CREATE TABLE payments (
    payment_id NUMBER PRIMARY KEY,
    reservation_id NUMBER REFERENCES reservations(reservation_id),
    amount NUMBER(10, 2)
);

CREATE TABLE reservation_log (
    log_id NUMBER PRIMARY KEY,
    reservation_id NUMBER,
    action VARCHAR2(100),
    log_date DATE DEFAULT SYSDATE
);

DECLARE
    v_guest_id NUMBER := 1;
    v_room_id  NUMBER := 101;
    v_res_id   NUMBER := 5001;
    v_pay_id   NUMBER := 9001;
    v_price    NUMBER;
BEGIN
    INSERT INTO guests (guest_id, name, email) 
    VALUES (v_guest_id, 'Ali Ahmed', 'ali.ahmed@example.com');

    INSERT INTO rooms (room_id, room_type, price) 
    VALUES (v_room_id, 'Suite', 250.00);
    
    SELECT price INTO v_price FROM rooms WHERE room_id = v_room_id;

    INSERT INTO reservations (reservation_id, guest_id, room_id, check_in, check_out)
    VALUES (v_res_id, v_guest_id, v_room_id, SYSDATE, SYSDATE + 3);

    INSERT INTO payments (payment_id, reservation_id, amount)
    VALUES (v_pay_id, v_res_id, v_price * 3);

    INSERT INTO reservation_log (reservation_id, action)
    VALUES (v_res_id, 'Reservation Created and Payment Processed');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Success: Reservation transaction committed.');

EXCEPTION
    WHEN OTHERS THEN
        -- If any step fails, roll back everything
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Transaction failed. Changes rolled back.');
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
END;
/

-- Q3

-- Q3 (a): Create a stored procedure named 'RecordSale' for a retail company.
-- Tables:
--   1. Products (product_id, product_name, price, stock_quantity)
--   2. Sales (sale_id, product_id, sale_date, sale_amount)
--
-- Procedure Parameters: (p_product_id, p_sale_amount)
-- Logic Requirements:
--   1. Check if product exists. If not, display: "Product not found."
--   2. If product is found, check if sale amount > stock quantity. 
--      If yes, display: "Insufficient stock for the sale."
--   3. If sale is possible:
--      - Update stock_quantity in Products table.
--      - Insert a record in the Sales table.

CREATE OR REPLACE PROCEDURE RecordSale (
    p_product_id IN Products.product_id%TYPE,
    p_sale_amount IN Sales.sale_amount%TYPE 
)
IS  
    cnt NUMBER;
    sq NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO cnt
    FROM Products 
    WHERE Products.product_id = p_product_id;

    IF cnt = 0 THEN 
        DBMS_OUTPUT.PUT_LINE('Product not found.');
    ELSE 
        SELECT stock_quantity
        INTO sq
        FROM Products 
        WHERE product_id = p_product_id;

        IF p_sale_amount > sq THEN 
            DBMS_OUTPUT.PUT_LINE('Insufficient stock for the sale.');
        ELSE 
            UPDATE Products
            SET stock_quantity = stock_quantity - p_sale_amount
            WHERE product_id = p_product_id;

            INSERT INTO Sales (product_id, sale_date, sale_amount)
            VALUES (p_product_id, SYSDATE, p_sale_amount);
            COMMIT;
        END IF;    
    END IF;
END;
/

-- Q3 (b): Create a stored function named 'GetTotalSalesAmount'.
-- Parameters: product_id (Input)
-- Return: Total sales amount (Sum of sale_amount for the given product from Sales table).

CREATE OR REPLACE PROCEDURE GetTotalSalesAmount (
    p_product_id IN NUMBER;
    
)
IS
    totalAmount NUMBER := 0;
BEGIN
    FOR c IN (
        SELECT sales_amount
        FROM Sales
        WHERE product_id = p_product_id;
    )
    LOOP
        totalAmount := totalAmount + c.sales_amount;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total Sales Amount: ' || totalAmount);
END;