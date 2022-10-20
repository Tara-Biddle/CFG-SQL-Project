USE lawyers_firm;


---- Showing how the DB works ----

INSERT INTO employees(employee_id, first_name, last_name)
VALUES
('E4', 'New', 'Lawyer');
INSERT INTO employee_details(ed_id, employee_id, charge_per_day, speciality, seniority)
VALUES
('ed_4', 'E4', 120, 'Family Law', DEFAULT);
-- DEFAULT for seniority enters 'Trainee Lawyer' as specified when the table was created --
SELECT * FROM employee_details;

DELETE FROM employees
WHERE employee_id = 'E4';
-- Due to the ON DELETE CASCADE constraint put on the foreign key employee_id in employee_details the record for employee_id = 4 will also be deleted in the employee_details table --
SELECT * FROM employee_details;


-- Query to find cases with Judge Rinder or Judge Judy, in London, in the Upper Tribunal Courts, that were filed before 2022 --
SELECT * FROM cases
WHERE judge IN ('Judge Rinder', 'Judge Judy')
AND Location = 'London' 
AND court_system = 'Upper Tribunal'
AND date_filed < '2022-01-01';


-- Query shows the average salary per year of each employee --
SELECT employee_id, charge_per_day, ROUND(charge_per_day * 365, 2) AS Average_Salary_per_year
FROM employee_details;


-- Query to categorise the duration of each case --
SELECT case_name,
CASE
WHEN end_date - start_date > 365 THEN 'DIFFICULT CASE'
WHEN end_date - start_date > 90 THEN 'SLOW CASE'
WHEN end_date - start_date <= 90 THEN 'QUICK CASE'
ELSE 'RECENT CASE'
END
AS Case_Type
FROM cases, case_status
WHERE cases.case_id = case_status.case_id;


-- Shows the number of days each case is open for --
SELECT case_id, end_date - start_date AS Number_of_Days_Duration FROM case_status
WHERE end_date IS NOT NULL
ORDER BY case_id;
-- Shows the average number of days a case is open for --
SELECT round(AVG(end_date - start_date), 0) AS Average_Duration FROM case_status
WHERE end_date IS NOT NULL;


-- Shows the number of each type of case handled by Order By SQL --
/* Tableau Graph */
SELECT type, COUNT(*) FROM cases
GROUP BY 1
ORDER BY 2 DESC;


-- Shows the final price of each closed case --
/* Tableau Graph*/
SELECT billing.case_id, round(billing.billable_days*employee_details.charge_per_day, 2) AS Final_Price FROM billing, employee_details, case_status
WHERE billing.lawyer_assigned = employee_details.employee_id
AND billing.case_id = case_status.case_id
AND case_status.end_date IS NOT NULL
ORDER BY 1;


-- Average Case Price per Lawyer --
/* Tableau Graph*/
SELECT CONCAT(employees.first_name, ' ', employees.last_name) AS Lawyer_Name, round(AVG(billing.billable_days*employee_details.charge_per_day), 2) AS Average_Case_Price FROM billing, employee_details, case_status, employees
WHERE billing.lawyer_assigned = employee_details.employee_id
AND billing.case_id = case_status.case_id
AND billing.lawyer_assigned = employees.employee_id
AND case_status.end_date IS NOT NULL
GROUP BY Lawyer_Name;


-- Shows the number of cases handled/accepted each year --
/* Tableau Graph*/
SELECT YEAR(start_date) AS Year, COUNT(*) AS Number_of_Cases FROM case_status
GROUP BY 1
ORDER BY 1;


-- Query returns total takings from cases over time --
CREATE VIEW TimeVMoney
AS
SELECT cases.case_name AS Case_Name , case_status.end_date AS End_Date, round(billing.billable_days*employee_details.charge_per_day, 2) AS Price 
FROM billing
INNER JOIN cases
ON cases.case_id = billing.case_id
INNER JOIN employee_details
ON employee_details.employee_id = billing.lawyer_assigned
INNER JOIN case_status
ON case_status.case_id = billing.case_id
ORDER BY End_Date;

SELECT * FROM TimeVMoney
WHERE End_Date IS NOT NULL;

WITH data AS (
	SELECT End_Date, Price FROM TimeVMoney
    WHERE End_Date IS NOT NULL)
SELECT
  End_Date AS Date,
  SUM(Price) OVER (ORDER BY End_Date rows between unbounded preceding and current row) AS Total_Takings
FROM data;



---- Project Requirments ----

---  {Using any type of joins create a view that combines multiple tables in a logical way}
-- The view assigned_cases shows the employee ID and their last name, their speciality, and the cases they are assigned too --
CREATE VIEW assigned_cases
AS
SELECT employee_details.employee_id, employees.last_name, employee_details.speciality, cases.case_name FROM employee_details
INNER JOIN cases
ON cases.type = employee_details.speciality
INNER JOIN employees
ON employees.employee_id = employee_details.employee_id;

SELECT * FROM assigned_cases;


---  {Query with a subquery to demonstrate how to extract data from your DB for analysis}
-- A view which shows Case Name, the Customer Name, and the Assigned Lawyer --
-- A table like this may not be stored together in the database for data privacy reasons, but would be useful to check which lawyer is reponsible for which case and client --
CREATE VIEW client_case_lawyer
AS
SELECT cs.case_name AS Case_Name, e.first_name AS Lawyer_First_Name, e.last_name AS Lawyer_Last_Name, c.first_name AS Customer_First_Name, c.last_name AS Customer_Last_Name
FROM billing b
INNER JOIN employees e
ON e.employee_id = b.lawyer_assigned
INNER JOIN cases cs
ON cs.case_id = b.case_id
INNER JOIN customers c
ON c.customer_id = b.customer_id
ORDER BY case_name;

SELECT * FROM client_case_lawyer;

SELECT Customer_First_Name, Customer_Last_Name, Case_Name FROM client_case_lawyer
WHERE
Case_Name IN (SELECT case_name FROM cases
WHERE
location = 'London');


--- {Create a view that uses at least 3-4 base tables; prepare and demonstrate a query that uses the view to produce a logically arranged result set for analysis.}
-- A view which shows the Current Billable Price for each case --
CREATE VIEW Prices
AS
SELECT cases.case_name AS Case_Name , billing.billable_days AS Billable_Days, employee_details.charge_per_day  AS Charge_per_Day, round(billing.billable_days*employee_details.charge_per_day, 2) AS Current_Price 
FROM billing
INNER JOIN cases
ON cases.case_id = billing.case_id
INNER JOIN employee_details
ON employee_details.employee_id = billing.lawyer_assigned
ORDER BY Current_Price DESC;

SELECT * FROM Prices;

-- Here if we change the number of billable days in the billing table when another query is run on this view it'll automatically update --
START TRANSACTION;
SELECT * FROM billing;
UPDATE billing
SET billable_days = 20
WHERE case_id = 1;
SELECT * FROM billing;
-- View automatically updates when values in its base tables are changed, useful for being able to pull the most up to date price for each case --
SELECT * FROM Prices
WHERE Case_Name = 'Doe V Jade';
ROLLBACK;

-- After being rollbacked the billable days returns to its original value of 14 for case_id = 1 ('Doe V Jade')--
SELECT * FROM Prices
WHERE Case_Name = 'Doe V Jade';

-- The top 3 most expensive cases Order By SQL has handled --
SELECT Case_Name, Current_Price FROM Prices
ORDER BY Current_Price desc
LIMIT 3;

-- Average case price --
SELECT AVG(Current_Price) FROM Prices;

-- Minimum and Maximum Price of cases handled by Order By SQL --
SELECT MIN(Current_Price), MAX(Current_Price) FROM Prices;

-- All cases with their current price outside of £8000 and £2000 --
SELECT Case_Name, Current_Price FROM Prices
WHERE Current_Price NOT BETWEEN 2000 AND 8000;

-- Total amount made by the lawyers firm so far --
SELECT SUM(Current_Price) FROM Prices;


--- {In your database, create a stored function that can be applied to a query in your DB}
-- Function takes an input of a date and checks it against the current date and returns either ACTIVE, CLOSED, or ERROR. --
DELIMITER //
CREATE FUNCTION is_active(end_date date) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE status VARCHAR(20);
    IF (end_date > CURRENT_DATE() OR end_date IS NULL) THEN
        SET status = 'ACTIVE';
    ELSEIF end_date <= CURRENT_DATE() THEN
        SET status = 'CLOSED';
    ELSE
        SET status = 'ERROR';
    END IF;
    RETURN (status);
END//
DELIMITER ;

-- Creates view of case names and its activity status using the function above, orders results by alphabetical order for the case name. --
CREATE VIEW active_cases
AS
SELECT cases.case_name, is_active(case_status.end_date) AS status FROM case_status
INNER JOIN cases
ON cases.case_id = case_status.case_id
ORDER BY status;

SELECT * FROM active_cases;

-- Query returns Status of case 'Doe v Jade' --
SELECT status FROM active_cases
WHERE case_name = 'Doe v Jade';

-- Query returns Status of any cases whose names include 'Divorce' --
SELECT case_name, status FROM active_cases
WHERE case_name LIKE '%Divorce%';


--- {In your database, create a stored procedure and demonstrate how it runs}
-- Procedure that adds all of a customers details to the various customer tables in one go. --
DELIMITER //

CREATE PROCEDURE NewCustomer(
IN customerid VARCHAR(10), 
IN firstname VARCHAR(60),
IN lastname VARCHAR(60),
IN cdid VARCHAR(10),
IN phone_ INT,
IN email_ VARCHAR(60),
IN addressid VARCHAR(10),
IN buildingnumber VARCHAR(55),
IN street_ VARCHAR(55),
IN city_ VARCHAR(55)
)

BEGIN

INSERT INTO customers(customer_id, first_name, last_name)
VALUES (customerid, firstname, lastname);

INSERT INTO customer_details(cd_id, customer_id, phone, email)
VALUES (cdid, customerid, phone_, email_);

INSERT INTO customer_addresses(customer_id, address_id, building_number, street, city)
VALUES (customerid, addressid, buildingnumber, street_, city_);

END//
DELIMITER ;

START TRANSACTION;
CALL NewCustomer ('C16', 'Jack', 'Jones', 'cd_16', 01333333333, 'jackjones@random.com', 'A16', '2A', 'Oxford Street', 'London');
SELECT * FROM customers;
SELECT * FROM customer_details;
SELECT * FROM customer_addresses;
ROLLBACK;


--- {Prepare an example query with group by and having to demonstrate how to extract data from your DB for analysis}
-- Number of cases by location, where the number of total cases is greater than 3 --

SELECT COUNT(case_id), location
FROM cases
GROUP BY location
HAVING COUNT(case_id) > 3
ORDER BY COUNT(case_id);


--- {In your database, create a trigger and demonstrate how it runs}
-- Prevents deletion of data from the billing table --
DELIMITER $$

CREATE TRIGGER billing_DeletionPrevention
BEFORE DELETE ON billing 
FOR EACH ROW
BEGIN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deleting from billing is not allowed!'; -- '4500'- sets a user defined unknown error, then a custom error message is attached
END$$
DELIMITER ;

DELETE FROM billing WHERE lawyer_assigned = 'E2';


-- Triggers below capitalise the first letter of any first or last names added to the employees or customers tables --
DELIMITER //
CREATE TRIGGER NameConsistencyEmployees
BEFORE INSERT on employees
FOR EACH ROW
BEGIN
	SET NEW.first_name = CONCAT(UPPER(SUBSTRING(NEW.first_name,1,1)),
						LOWER(SUBSTRING(NEW.first_name FROM 2)));
	SET NEW.last_name = CONCAT(UPPER(SUBSTRING(NEW.last_name,1,1)),
						LOWER(SUBSTRING(NEW.last_name FROM 2)));
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER NameConsistencyCustomers
BEFORE INSERT on customers
FOR EACH ROW
BEGIN
	SET NEW.first_name = CONCAT(UPPER(SUBSTRING(NEW.first_name,1,1)),
						LOWER(SUBSTRING(NEW.first_name FROM 2)));
	SET NEW.last_name = CONCAT(UPPER(SUBSTRING(NEW.last_name,1,1)),
						LOWER(SUBSTRING(NEW.last_name FROM 2)));
END//
DELIMITER ;

START TRANSACTION;
INSERT INTO customers (customer_id, first_name, last_name)
VALUES ('C17', 'john', 'SMITH');
SELECT * FROM customers
WHERE customer_id = 'C17';
ROLLBACK;


--- {In your database, create an event and demonstrate how it runs}
-- This is a one time event updates an employees position who is scheduled for promotion --
SET GLOBAL event_scheduler = ON;

DELIMITER //
CREATE EVENT updating_employees_position
ON SCHEDULE AT "2022-08-29 12:00:00" 
DO BEGIN
	UPDATE employee_details
    SET seniority = "Assistant Lawyer"
	WHERE employee_id = 'E3';
END//
DELIMITER ;

-- using NOW() to demonstrate
DELIMITER //
CREATE EVENT updating_employees_position2
ON SCHEDULE AT NOW()
DO BEGIN
	UPDATE employee_details
    SET seniority = "Assistant Lawyer"
	WHERE employee_id = 'E3';
END//
DELIMITER ;

SELECT employee_id, seniority FROM employee_details;

UPDATE employee_details
SET seniority = 'Trainee Lawyer'
WHERE employee_id = 'E3';

DROP EVENT updating_employees_position;
