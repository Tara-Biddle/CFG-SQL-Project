CREATE DATABASE lawyers_firm;
USE lawyers_firm;

---
# Employee Tables:

CREATE TABLE employees
(employee_id varchar(10) NOT NULL,
first_name varchar(60) NOT NULL,
last_name varchar(60) NOT NULL,
CONSTRAINT PK_employees PRIMARY KEY (employee_id));

CREATE TABLE employee_details
(ed_id varchar(10) NOT NULL,
employee_id varchar(10) NOT NULL,
charge_per_day float NOT NULL,
speciality varchar(60),
seniority varchar(60) DEFAULT 'Trainee Lawyer',
CONSTRAINT PK_ed PRIMARY KEY (ed_id));

ALTER TABLE employee_details  
ADD  CONSTRAINT 
FK_employee_id 
FOREIGN KEY(employee_id)
REFERENCES employees (employee_id) 
ON DELETE CASCADE;

---
# Customer Tables:

CREATE TABLE customers
(customer_id varchar(10) NOT NULL,
first_name varchar(60) NOT NULL,
last_name varchar(60) NOT NULL,
CONSTRAINT PK_customers PRIMARY KEY (customer_id));

CREATE TABLE customer_details
(cd_id varchar(10) NOT NULL,
customer_id varchar(10) NOT NULL,
phone integer NOT NULL,
email varchar(60) NOT NULL,
CONSTRAINT PK_cd PRIMARY KEY (cd_id));

ALTER TABLE customer_details  
ADD  CONSTRAINT 
FK_customer_id 
FOREIGN KEY(customer_id)
REFERENCES customers (customer_id)
ON DELETE CASCADE;

CREATE TABLE customer_addresses
(customer_id varchar(10) NOT NULL,
address_id varchar(10) NOT NULL,
building_number VARCHAR(55) NOT NULL,
street VARCHAR(55) NOT NULL,
city VARCHAR(55),
CONSTRAINT PK_Address PRIMARY KEY (address_id));

ALTER TABLE customer_addresses  
ADD  CONSTRAINT 
FK_customer_address_id 
FOREIGN KEY(customer_id)
REFERENCES customers (customer_id);

---
# Case Tables:

CREATE TABLE cases
(case_id integer NOT NULL,
case_name varchar(100) NOT NULL,
type varchar(100) NOT NULL,
court_system varchar(60),
location varchar(60) NOT NULL,
date_filed date NOT NULL,
-- Date Format YYYY-MM-DD
judge varchar(60),
CONSTRAINT PK_cases PRIMARY KEY (case_id));

CREATE TABLE case_status
(status_id varchar(10) NOT NULL,
case_id integer NOT NULL,
start_date date NOT NULL,
end_date date,
CONSTRAINT PK_status PRIMARY KEY (status_id));

ALTER TABLE case_status  
ADD  CONSTRAINT 
FK_case_status_id 
FOREIGN KEY(case_id)
REFERENCES cases (case_id);

CREATE TABLE billing
(bill_id varchar(10) NOT NULL,
lawyer_assigned varchar(10) NOT NULL,
customer_id varchar(10) NOT NULL,
case_id integer NOT NULL,
billable_days integer NOT NULL,
CONSTRAINT PK_bill PRIMARY KEY (bill_id));

ALTER TABLE billing  
ADD  CONSTRAINT 
FK_case_id 
FOREIGN KEY(case_id)
REFERENCES cases (case_id);

ALTER TABLE billing  
ADD  CONSTRAINT 
FK_client_id 
FOREIGN KEY(customer_id)
REFERENCES customers (customer_id);

ALTER TABLE billing  
ADD  CONSTRAINT 
FK_lawyer_id 
FOREIGN KEY(lawyer_assigned)
REFERENCES employees (employee_id);

---

# Adding Data
# Employee Data

INSERT INTO employees(employee_id, first_name, last_name)
VALUES
('E1', 'Andrea', 'Hricikova'),
('E2', 'Shannon', 'Carey'),
('E3', 'Tara', 'Biddle');

INSERT INTO employee_details(ed_id, employee_id, charge_per_day, speciality, seniority)
VALUES
('ed_1', 'E1', 150, 'Family Law', 'Assistant Lawyer'),
('ed_2', 'E2', 180, 'Criminal Defense', 'Partner'),
('ed_3', 'E3', 130, 'Corporate', 'Trainee Lawyer');

# Customer Data

INSERT INTO customers(customer_id, first_name, last_name)
VALUES
('C1', 'Jane', 'Doe'),
('C2', 'John', 'Smith'),
('C3', 'Eva', 'Jones'),
('C4', 'Ben', 'Grange'),
('C5', 'Jack', 'Griffiths'),
('C6', 'Audrey', 'Hudson'),
('C7', 'Iris', 'Jones'),
('C8', 'Janet', 'Kelloggs'),
('C9', 'Scott', 'Smith'),
('C10', 'Harry', 'Winsor'),
('C11', 'Emily', 'Slate'),
('C12', 'Davina', 'Bird');

INSERT INTO customer_details(cd_id, customer_id, phone, email)
VALUES
('cd_1', 'C1', 01234567891, 'jane.doe@email.com'),
('cd_2', 'C2', 01112131415, 'jsmith@gmail.com'),
('cd_3', 'C3', 01111111111, 'eva54@hotmail.com'),
('cd_4', 'C4', 0123567321, 'grangeltd@somewhere.com'),
('cd_5', 'C5', 0124567321, 'jack_griffiths@gmail.com'),
('cd_6', 'C6', 0125567322, 'hudsonhome@hotmail.com'),
('cd_7', 'C7', 0126567324, 'iris54@somewhere.com'),
('cd_8', 'C8', 0127567325, 'kellogscrunch@gmail.com'),
('cd_9', 'C9', 0128567327, 'scott.smith@gmail.com'),
('cd_10', 'C10', 0193567329, 'winsorpalace@email.com'),
('cd_11', 'C11', 0103567321, 'eslate23@hotmail.com'),
('cd_12', 'C12', 0133567322, 'bird_davina@hotmail.com');

INSERT INTO customer_addresses(customer_id, address_id, building_number, street, city)
VALUES
('C1', 'A1', '123', 'Maple Road', 'Manchester'),
('C1', 'A2', '50', 'Hill Street', 'Birmingham'),
('C2', 'A3', '456', 'Oak Drive', 'Leeds'),
('C3', 'A4', '789', 'Cedar Way', 'Birmingham'),
('C4', 'A5', '100', 'Beech View', 'London'),
('C5', 'A6', '1A', 'Slope Road', 'Birmingham'),
('C6', 'A7', 'The Lodge', 'Hampton Way', 'London'),
('C7', 'A8', '21', 'Oak Grove', 'Manchester'),
('C8', 'A9', '3', 'Orchard View', 'Manchester'),
('C9', 'A10', '62', 'Church View', 'Leeds'),
('C10', 'A11', '5C', 'Here Drive', 'Birmingham'),
('C11', 'A12', 'The Manor House', 'New Road', 'London'),
('C12', 'A13', '4', 'Apple Street', 'Manchester');

# Case Data

INSERT INTO cases(case_id, case_name, type, court_system, location, date_filed, judge)
VALUES
(1, 'Doe v Jade', 'Family Law', 'UK Supreme Court', 'London', '2022-08-13', 'Judge Rinder'),
(2, 'Messy Divorce', 'Family Law', 'UK Supreme Court', 'Birmingham', '2022-07-18', 'Judge Rinder'),
(3, 'Tax Avoidance', 'Corporate', 'First-Tier Tribunal', 'Manchester', '2020-06-10', 'Judge Jones'),
(4, 'Reduce Prison Sentence', 'Criminal Defense', 'Court of Appeal', 'Birmingham', '2022-05-23', 'Judge Judy'),
(5, 'Misadvertisment', 'Corporate', 'Upper Tribunal', 'London', '2019-04-03', 'Judge Judy'),
(6, 'Custody Boss Battle', 'Family Law', 'First-Tier Tribunal', 'Birmingham', '2018-05-09', 'Judge Jones'),
(7, 'Smith Fraud', 'Criminal Defense', 'UK Supreme Court', 'Manchester', '2017-06-03', 'Judge Rinder'),
(8, 'Jones Tax Avoidance', 'Corporate', 'UK Supreme Court', 'London', '2018-04-03', 'Judge Rinder'),
(9, 'Grange Custody', 'Family Law', 'Upper Tribunal', 'Birmingham', '2018-07-02', 'Judge Judy'),
(10, 'JPM Domestic Violence', 'Family Law', 'Court of Appeal', 'Leeds', '2019-09-08', 'Judge Jones'),
(11, 'Identity Theft', 'Criminal Defense', 'Upper Tribunal', 'London', '2019-12-03', 'Judge Judy'),
(12, 'J&J Unfair Dismissal', 'Corporate', 'UK Supreme Court', 'Manchester', '2020-10-03', 'Judge Rinder'),
(13, 'Griffiths Restraining Order', 'Family Law', 'Court of Appeal', 'Birmingham', '2020-02-04', 'Judge Jones'),
(14, 'RPS Workplace Bullying', 'Corporate', 'First-Tier Tribunal', 'London', '2021-01-01', 'Judge Judy'),
(15, 'Kelloggs Domestic Violence', 'Family Law', 'Court of Appeal', 'London', '2019-06-03', 'Judge Judy'),
(16, 'FED Unfair Dismissal', 'Corporate', 'Upper Tribunal', 'Manchester', '2021-11-11', 'Judge Rinder'),
(17, 'Waterbridge Burgalry', 'Criminal Defense', 'UK Supreme Court', 'Leeds', '2021-12-01', 'Judge Jones'),
(18, 'Placeminster Assault', 'Criminal Defense', 'First-Tier Tribunal', 'Birmingham', '2018-02-03', 'Judge Judy'),
(19, 'Hudson Divorce', 'Family Law', 'Upper Tribunal', 'London', '2017-09-11', 'Judge Rinder'),
(20, 'ABC Workplace Bullying', 'Corporate', 'UK Supreme Court', 'Manchester', '2019-04-03', 'Judge Rinder');


INSERT INTO case_status(status_id, case_id, start_date, end_date)
VALUES
('S1', 1, '2022-07-05', null),
('S2', 2, '2022-07-03', null),
('S3', 3, '2020-05-31', '2020-08-14'),
('S4', 4, '2022-05-01', null),
('S5', 5, '2019-03-24', '2020-01-21'),
('S6', 6, '2018-06-21', '2019-02-19'),
('S7', 7, '2017-07-12', '2018-02-13'),
('S8', 8, '2018-08-01', '2018-11-12'),
('S9', 9, '2018-09-21', '2020-03-07'),
('S10', 10, '2019-10-04', '2019-12-14'),
('S11', 11, '2019-12-09', '2020-03-20'),
('S12', 12, '2020-12-02', '2020-12-23'),
('S13', 13, '2020-03-03', '2021-01-17'),
('S14', 14, '2021-02-24', null),
('S15', 15, '2019-08-23', '2020-05-22'),
('S16', 16, '2021-12-18', null),
('S17', 17, '2021-12-24', '2022-06-30'),
('S18', 18, '2018-03-12', '2021-02-21'),
('S19', 19, '2017-11-18', '2017-12-28'),
('S20', 20, '2019-04-10', '2022-03-13');

INSERT INTO billing(bill_id, lawyer_assigned, customer_id, case_id, billable_days)
VALUES
('B1', 'E1', 'C1', 1, 14),
('B2', 'E1', 'C3', 2, 18),
('B3', 'E3', 'C4', 3, 25),
('B4', 'E2', 'C1', 4, 31),
('B5', 'E3', 'C2', 5, 56),
('B6', 'E1', 'C5', 6, 9),
('B7', 'E2', 'C9', 7, 12),
('B8', 'E3', 'C7', 8, 29),
('B9', 'E1', 'C4', 9, 48),
('B10', 'E1', 'C10', 10, 20),
('B11', 'E2', 'C12', 11, 61),
('B12', 'E3', 'C11', 12, 4),
('B13', 'E1', 'C5', 13, 34),
('B14', 'E3', 'C2', 14, 25),
('B15', 'E1', 'C8', 15, 51),
('B16', 'E3', 'C5', 16, 33),
('B17', 'E2', 'C8', 17, 41),
('B18', 'E2', 'C7', 18, 69),
('B19', 'E1', 'C6', 19, 12),
('B20', 'E3', 'C2', 20, 71);
