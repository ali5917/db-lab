-- DDL
CREATE TABLE IF NOT EXISTS Customers (
    CUSTOMER_ID INT PRIMARY KEY,
    CUSTOMER_NAME VARCHAR2(100) NOT NULL,
    CITY VARCHAR2(100)
);

CREATE TABLE IF NOT EXISTS Books (
    BOOK_ID INT PRIMARY KEY,
    TITLE VARCHAR2(100) NOT NULL,
    PRICE NUMERIC NOT NULL,
    PUBLISHER VARCHAR2(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS Authors (
    AUTHOR_ID INT PRIMARY KEY,
    AUTHOR_NAME VARCHAR2(100) NOT NULL 
);

CREATE TABLE IF NOT EXISTS Book_Authors (
    BOOK_ID INT NOT NULL,
    AUTHOR_ID INT NOT NULL,
    CONSTRAINT fk_book FOREIGN KEY (BOOK_ID) REFERENCES Books(BOOK_ID),
    CONSTRAINT fk_author FOREIGN KEY (AUTHOR_ID) REFERENCES Authors(AUTHOR_ID),
    CONSTRAINT pk_book_authors PRIMARY KEY (BOOK_ID, AUTHOR_ID)
);

CREATE TABLE IF NOT EXISTS Purchases (
    PURCHASE_ID INT PRIMARY KEY,
    CUSTOMER_ID INT NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (CUSTOMER_ID) REFERENCES Customers(CUSTOMER_ID),
    PURCHASE_DATE DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Purchase_Details (
    PURCHASE_ID INT NOT NULL,
    BOOK_ID INT NOT NULL,
    QUANTITY INT NOT NULL,
    CONSTRAINT fk_purchases FOREIGN KEY (PURCHASE_ID) REFERENCES Purchases(PURCHASE_ID),
    CONSTRAINT fk_books FOREIGN KEY (BOOK_ID) REFERENCES Books(BOOK_ID),
    CONSTRAINT pk_purchase_details PRIMARY KEY (PURCHASE_ID, BOOK_ID)
);

-- Queries

-- A. Retrieve the names of customers who purchased books 
-- whose price is greater than the average price of all books in the system.
SELECT DISTINCT CUSTOMER_NAME FROM CUSTOMERS
WHERE CUSTOMER_ID IN (
    SELECT CUSTOMER_ID FROM PURCHASES 
    WHERE PURCHASE_ID IN (
        SELECT PURCHASE_ID FROM PURCHASE_DETAILS 
        WHERE BOOK_ID IN (
            SELECT BOOK_ID FROM BOOKS 
            WHERE PRICE > (SELECT AVG(PRICE) FROM BOOKS)
        )
    )
); 

-- B. Display the titles of books whose price is greater than 
-- the average price of books published by the same publisher.
SELECT B1.TITLE FROM BOOKS B1
WHERE B1.PRICE > (
    SELECT AVG(B2.PRICE)
    FROM BOOKS B2
    WHERE B2.PUBLISHER = B1.PUBLISHER
)


-- C. List the names of customers who have purchased at least one book, 
-- but have never purchased any book published by 'Pearson'
SELECT CUSTOMER_NAME FROM CUSTOMERS C
WHERE EXISTS (
    SELECT 1 FROM PURCHASES P
    WHERE P.CUSTOMER_ID = C.CUSTOMER_ID
) AND NOT EXISTS (
    SELECT 1 FROM PURCHASES P
    WHERE P.CUSTOMER_ID = C.CUSTOMER_ID AND P.PURCHASE_ID IN (
        SELECT PURCHASE_ID FROM PURCHASE_DETAILS
        WHERE BOOK_ID IN (
            SELECT BOOK_ID FROM BOOKS
            WHERE PUBLISHER = 'Pearson'
        )
    )
)

-- D. Display book titles that have never been purchased by any customer.
SELECT TITLE FROM BOOKS B1
WHERE NOT EXISTS (
    SELECT 1 FROM PURCHASE_DETAILS
    WHERE BOOK_ID = B1.BOOK_ID
)

-- E. Retrieve the names of authors who have written books 
-- priced higher than the average book price in the system.
SELECT AUTHOR_NAME FROM AUTHORS
WHERE AUTHOR_ID IN (
    SELECT AUTHOR_ID FROM BOOK_AUTHORS 
    WHERE BOOK_ID IN (
        SELECT BOOK_ID FROM BOOKS 
        WHERE PRICE > (SELECT AVG(PRICE) FROM BOOKS)
    )
);

-- F. Display the customer_id and total quantity of books purchased by each customer, but only
-- include those customers whose total purchased quantity is greater than 10.

SELECT C.CUSTOMER_ID, (
    SELECT SUM(QUANTITY) FROM PURCHASE_DETAILS
    WHERE PURCHASE_ID IN (
        SELECT PURCHASE_ID FROM PURCHASES
        WHERE CUSTOMER_ID = C.CUSTOMER_ID
    )  
) AS TOTAL_QUANTITY
FROM CUSTOMERS C 
WHERE (
    SELECT SUM(QUANTITY) FROM PURCHASE_DETAILS
    WHERE PURCHASE_ID IN (
        SELECT PURCHASE_ID FROM PURCHASES
        WHERE CUSTOMER_ID = C.CUSTOMER_ID
    ) 
) > 10;                                                                   