# Aircargo Database 
  ## MySQL Scripts Documentation

**Last Updated:** June 2025

---

## 1. Overview

### Project Name

**AircargoDB MySQL Scripts**

### Project Description

This repository contains a collection of MySQL scripts designed to manage and query the **AircargoDB** database. The scripts cover tasks such as:

* Inspecting table structures and row counts
* Joining tables to retrieve combined customer-flight-ticket information
* Aggregations (e.g., revenue per brand, passenger counts by class)
* Creating and populating auxiliary tables (e.g., `route_details`)
* Index creation and query optimization (via `EXPLAIN`)
* View definitions for business‐class passengers
* Stored procedures for parameterized queries and business logic
* Stored functions to compute derived data (e.g., complimentary services)
* Security tasks (creating a new user, granting privileges)

These scripts are intended for use by database administrators, backend developers, and data analysts who need to maintain, extend, or analyze the AircargoDB dataset.

---

## 2. Technical Specifications

### Database

* **Database Name:** `AircargoDB`
* **Database Engine:** MySQL (5.7+ or 8.0+ recommended)

### Programming/Query Language

* **SQL Dialect:** MySQL
* **Stored Procedures & Functions:** MySQL PL/SQL‐style

### Schema Snapshot

Below is a high-level view of the main tables in the schema (columns shown for context):

1. **`customer`**

   * `customer_id` (INT, PK)
   * `first_name` (VARCHAR)
   * `last_name` (VARCHAR)
   * `date_of_birth` (DATE or TEXT)
   * `gender` (CHAR(1))
   * *…other attributes as needed*

2. **`passengers_on_flights`**

   * `customer_id` (INT, FK → `customer.customer_id`)
   * `aircraft_id` (TEXT)
   * `route_id` (INT, FK → `routes.route_id`)
   * `depart` (DATETIME or TEXT)
   * `arrival` (DATETIME or TEXT)
   * `seat_num` (VARCHAR)
   * `class_id` (VARCHAR)
   * `travel_date` (DATE or TEXT)
   * `flight_num` (INT)
   * *…other attributes as needed*

3. **`routes`**

   * `route_id` (INT, PK)
   * `flight_num` (INT)
   * `origin_airport` (TEXT)
   * `destination_airport` (TEXT)
   * `aircraft_id` (TEXT)
   * `distance_miles` (INT)

4. **`ticket_details`**

   * `customer_id` (INT, FK → `customer.customer_id`)
   * `aircraft_id` (TEXT)
   * `class_id` (VARCHAR)
   * `no_of_tickets` (INT)
   * `p_date` (DATE or TEXT)
   * `a_code` (VARCHAR)
   * `price_per_ticket` (INT)
   * `brand` (VARCHAR)

5. **`route_details`** (Auxiliary table)

   * `route_id` (INT, PK)
   * `flight_num` (INT)
   * `origin_airport` (TEXT)
   * `destination_airport` (TEXT)
   * `aircraft_id` (TEXT)
   * `distance_miles` (INT, > 0)

---

## 3. Dependencies and Requirements

* **MySQL Server**

  * Version 5.7 or newer (8.0+ for window‐functions and advanced JSON features)
  * Ensure you have permission to create tables, views, stored procedures, and users.

* **MySQL Client or GUI**

  * MySQL command‐line (`mysql`) or GUI tools such as MySQL Workbench, phpMyAdmin, or HeidiSQL.

* **Filesystem Access**

  * The `.sql` files in this repository (e.g., `SQL_QUERIES.sql`) must be accessible to the MySQL client if using `SOURCE` or `\. `.

---

## 4. Installation and Setup Instructions

### 4.1. Clone the Repository

```sql
git clone https://github.com/EaruvaTeja/Aircargo-Database.git
cd Aircargo-Database
```

### 4.2. Create & Use the Database

1. Log in as a MySQL user with adequate privileges (e.g., `root` or a DBA user):

   ```bash
   mysql -u root -p
   ```
2. Create the database (if not already present):

   ```sql
   CREATE DATABASE IF NOT EXISTS AircargoDB;
   USE AircargoDB;
   ```
3. (Optional) If the schema is defined elsewhere, run the DDL to create the core tables (`customer`, `passengers_on_flights`, `routes`, `ticket_details`).

   * If your organization has a separate schema file, import it now:

     ```sql
     SOURCE /path/to/aircargodb_schema.sql;
     ```

### 4.3. Run the Main SQL Script

Within the `mysql` client (or GUI), execute:

```sql
SOURCE /path/to/SQL_QUERIES.sql;
```

This single script file contains:

* `USE AircargoDB;`
* Table inspections (`SHOW TABLES`, `DESCRIBE …`)
* Sample `SELECT` statements to view data
* Aggregations and joins
* `CREATE TABLE route_details`
* `INSERT INTO route_details … SELECT …`
* Index creation, query optimizations (`EXPLAIN`)
* View creation (`business_class_customers`)
* Stored procedures (`GetPassengersByRouteRange`, `route_details`, `flight_details`, `fetch_first_scot_customer`, `CheckRevenue`, etc.)
* Stored function (`get_complimentary_services`)
* User creation and privilege grants

---

## 5. Usage Examples

Below are some common tasks and the SQL commands to accomplish them. You can paste these into your MySQL prompt or GUI.

### 5.1. Inspecting Table Contents

```sql
USE AircargoDB;

-- List all tables
SHOW TABLES;

-- View all customers
SELECT * FROM customer;

-- View all passengers on flights
SELECT * FROM passengers_on_flights;

-- View all routes
SELECT * FROM routes;

-- View all ticket details
SELECT * FROM ticket_details;
```

### 5.2. Simple Aggregations & Filters

1. **Count tickets per brand**

   ```sql
   SELECT 
     brand, 
     COUNT(*) AS total_tickets_sold
   FROM ticket_details
   GROUP BY brand;
   ```

2. **Show only “Emirates” brand tickets**

   ```sql
   SELECT *
   FROM ticket_details
   WHERE brand = 'Emirates';
   ```

3. **Total revenue per class for “Business” customers**

   ```sql
   SELECT 
     customer_id, 
     class_id, 
     SUM(price_per_ticket) AS total_individual_price,
     (SELECT SUM(price_per_ticket) 
      FROM ticket_details 
      WHERE class_id = 'Business') AS total_business_revenue
   FROM ticket_details
   WHERE class_id = 'Business'
   GROUP BY customer_id, class_id;
   ```

4. **Passengers count by class using window‐function (MySQL 8.0+)**

   ```sql
   SELECT 
     class_id,
     COUNT(*) OVER (PARTITION BY class_id) AS total_passengers_in_class
   FROM passengers_on_flights;
   ```

### 5.3. Joining Tables for Combined Insights

1. **List every customer’s flight and ticket info**

   ```sql
   SELECT DISTINCT 
     c.customer_id, 
     c.first_name, 
     c.last_name, 
     c.date_of_birth, 
     c.gender, 
     p.aircraft_id, 
     p.route_id, 
     p.depart, 
     p.arrival, 
     p.seat_num, 
     p.class_id, 
     p.travel_date, 
     p.flight_num, 
     t.no_of_tickets
   FROM customer   AS c
   INNER JOIN passengers_on_flights AS p 
     ON c.customer_id = p.customer_id
   INNER JOIN ticket_details         AS t 
     ON c.customer_id = t.customer_id
   INNER JOIN passengers_on_flights pf 
     ON pf.aircraft_id = t.aircraft_id;
   ```

   * Note: The last join (`pf`) links `ticket_details.aircraft_id` back into `passengers_on_flights` again, ensuring that every ticketed flight actually had a passenger entry for that same aircraft.

2. **Find customers with exactly 1 ticket**

   ```sql
   SELECT DISTINCT 
     c.customer_id, 
     c.first_name, 
     c.last_name, 
     c.date_of_birth, 
     c.gender,
     t.p_date, 
     t.aircraft_id, 
     t.class_id, 
     t.no_of_tickets, 
     t.a_code, 
     t.price_per_ticket, 
     t.brand
   FROM customer       AS c 
   JOIN ticket_details AS t 
     ON t.customer_id = c.customer_id 
   WHERE t.no_of_tickets = 1;
   ```

3. **Customers who traveled in “Economy Plus” class**

   ```sql
   SELECT c.customer_id, c.first_name, c.last_name
   FROM customer               AS c
   JOIN passengers_on_flights  AS p 
     ON c.customer_id = p.customer_id
   GROUP BY c.customer_id, c.first_name, c.last_name
   HAVING SUM(CASE WHEN p.class_id = 'Economy Plus' THEN 1 ELSE 0 END) > 0;
   ```

---

## 6. Documenting Stored Procedures, Functions, and Views

Below is a catalog of all stored routines (procedures/functions) and views defined in `SQL_QUERIES.sql`. Each routine is described with its purpose, input parameters (if any), and sample usage.

### 6.1. `GetPassengersByRouteRange(start_route, end_route)`

```sql
DELIMITER $$
CREATE PROCEDURE GetPassengersByRouteRange(
    IN start_route INT,
    IN end_route   INT
)
BEGIN
    -- Check if required tables exist
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables 
        WHERE table_schema = 'aircargodb' 
          AND table_name IN ('customer', 'passengers_on_flights', 'routes')
        HAVING COUNT(DISTINCT table_name) = 3
    ) THEN
        SELECT 'Error: One or more required tables do not exist in the database.' AS message;
    ELSE
        -- Main query to retrieve passenger flight details
        SELECT 
            c.first_name,
            c.last_name,
            c.date_of_birth,
            c.gender,
            pof.flight_num,
            r.origin_airport AS depart,
            r.destination_airport AS arrival,
            pof.seat_num,
            pof.class_id,
            pof.route_id,
            pof.travel_date,
            r.distance_miles
        FROM passengers_on_flights AS pof
        INNER JOIN customer ON pof.customer_id = customer.customer_id
        INNER JOIN routes   AS r ON pof.route_id = r.route_id
        WHERE r.route_id BETWEEN start_route AND end_route
        ORDER BY pof.travel_date, pof.flight_num, pof.seat_num;
    END IF;
END $$
DELIMITER ;
```

* **Purpose:** Retrieve all passenger flight details for routes whose `route_id` is between `start_route` and `end_route`.
* **Parameters:**

  * `start_route` (INT): Minimum `route_id` (inclusive).
  * `end_route`   (INT): Maximum `route_id` (inclusive).
* **Behavior:**

  1. Checks existence of `customer`, `passengers_on_flights`, and `routes`.
  2. If any required table is missing, returns an error message.
  3. Otherwise, joins the three tables and returns passenger name, gender, flight number, departure, arrival, seat number, class, route, travel date, and distance.
* **Sample Call:**

  ```sql
  CALL GetPassengersByRouteRange(1, 100);
  ```

---

### 6.2. `route_details(distance)`

```sql
DELIMITER $$
CREATE PROCEDURE route_details(
    IN distance INT
)
BEGIN
    SELECT *
    FROM routes
    WHERE distance_miles >= distance;
END $$
DELIMITER ;
```

* **Purpose:** Selects all rows from `routes` where `distance_miles` is at least the input value.
* **Parameters:**

  * `distance` (INT): Minimum distance in miles.
* **Sample Call:**

  ```sql
  CALL route_details(2000);
  ```

---

### 6.3. `flight_details(categorie_type)`

```sql
DELIMITER $$
CREATE PROCEDURE flight_details(
    IN categorie_type CHAR(3)
)
BEGIN 
    IF categorie_type NOT IN ('SDT', 'IDT', 'LDT') THEN
        -- SDT = Short-haul Distance Travel (0–2000 miles)
        -- IDT = Intermediate-haul Distance Travel (2001–6500 miles)
        -- LDT = Long-haul Distance Travel (>6500 miles)
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid category type. Use SDT, IDT, or LDT.';
    ELSE
        SELECT *
        FROM routes
        WHERE (categorie_type = 'SDT' AND distance_miles BETWEEN 0    AND 2000)
           OR (categorie_type = 'IDT' AND distance_miles BETWEEN 2001 AND 6500)
           OR (categorie_type = 'LDT' AND distance_miles > 6500);
    END IF;
END $$
DELIMITER ;
```

* **Purpose:** Return routes categorized by distance class:

  * `SDT` (Short-haul: 0–2000 miles)
  * `IDT` (Intermediate-haul: 2001–6500 miles)
  * `LDT` (Long-haul: > 6500 miles)
* **Parameters:**

  * `categorie_type` (CHAR(3)): One of `SDT`, `IDT`, or `LDT`.
* **Sample Call:**

  ```sql
  CALL flight_details('SDT');
  ```
* **Error Handling:**

  * Raises an SQLSTATE `45000` with message if `categorie_type` is invalid.

---

### 6.4. `CheckRevenue()`

```sql
DELIMITER //
CREATE PROCEDURE CheckRevenue()
BEGIN
    DECLARE total_revenue INT;
    SELECT SUM(price_per_ticket) 
      INTO total_revenue 
    FROM ticket_details;

    IF total_revenue > 10000 THEN
        SELECT 'YES, REVENUE ABOVE 10000' AS result;
    ELSE
        SELECT 'NO, REVENUE BELOW 10000' AS result;
    END IF;
END //
DELIMITER ;
```

* **Purpose:** Compute total ticket revenue and test if it exceeds 10,000.
* **Parameters:** None.
* **Behavior:**

  1. Sums `price_per_ticket` from `ticket_details`.
  2. Displays `“YES, REVENUE ABOVE 10000”` if the sum > 10000; otherwise, displays `“NO, REVENUE BELOW 10000”`.
* **Sample Call:**

  ```sql
  CALL CheckRevenue();
  ```

---

### 6.5. `fetch_first_scot_customer()`

```sql
DELIMITER $$
CREATE PROCEDURE fetch_first_scot_customer()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE cust_id INT;
    DECLARE f_name VARCHAR(50);
    DECLARE l_name VARCHAR(50);

    DECLARE cur CURSOR FOR
      SELECT customer_id, first_name, last_name
      FROM customer
      WHERE last_name LIKE '%Scot'
      ORDER BY customer_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
      SET done = 1;

    OPEN cur;
    FETCH cur INTO cust_id, f_name, l_name;

    IF done = 1 THEN
        SELECT 'No matching record found' AS message;
    ELSE
        SELECT cust_id AS customer_id,
               f_name   AS first_name,
               l_name   AS last_name;
    END IF;

    CLOSE cur;
END$$
DELIMITER ;
```

* **Purpose:** Fetch the **first** customer (smallest `customer_id`) whose `last_name` ends with “Scot.”
* **Parameters:** None.
* **Behavior:**

  1. Declares a cursor over `SELECT … FROM customer WHERE last_name LIKE '%Scot' ORDER BY customer_id`.
  2. Attempts to `FETCH` the first row.
  3. If no row is found, returns `“No matching record found”`; otherwise, returns that customer’s ID, first name, and last name.
* **Sample Call:**

  ```sql
  CALL fetch_first_scot_customer();
  ```

---

### 6.6. Stored Function: `get_complimentary_services(class_id)`

```sql
DELIMITER $$
CREATE FUNCTION get_complimentary_services(
    class_id VARCHAR(20)
) RETURNS VARCHAR(3) DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(3);
    IF class_id IN ('Business', 'Economy Plus') THEN
        SET result = 'Yes';
    ELSE
        SET result = 'No';
    END IF;
    RETURN result;
END $$
DELIMITER ;
```

* **Purpose:** Return `'Yes'` if the passenger’s class is `'Business'` or `'Economy Plus'`, otherwise return `'No'`.
* **Parameters:**

  * `class_id` (VARCHAR(20)): The ticket class.
* **Return Value:**

  * `'Yes'` or `'No'` (VARCHAR(3)).
* **Sample Usage (via stored procedure below):**

  ```sql
  SELECT p_date, customer_id, class_id,
         get_complimentary_services(class_id) AS complimentary_services
  FROM ticket_details;
  ```

---

### 6.7. `get_ticket_details()`

```sql
DELIMITER $$
CREATE PROCEDURE get_ticket_details()
BEGIN
    SELECT p_date,
           customer_id,
           class_id,
           get_complimentary_services(class_id) AS complimentary_services
    FROM ticket_details;
END $$
DELIMITER ;
```

* **Purpose:** Show ticket details along with an indicator of whether they receive complimentary services.
* **Parameters:** None.
* **Sample Call:**

  ```sql
  CALL get_ticket_details();
  ```

---

### 6.8. View: `business_class_customers`

```sql
CREATE VIEW business_class_customers AS
SELECT *
FROM passengers_on_flights
WHERE class_id = 'Business';
```

* **Purpose:** A convenient view listing all passengers whose `class_id = 'Business'`.
* **Usage:**

  ```sql
  SELECT * FROM business_class_customers;
  ```

---

## 7. Indexes & Query Optimization

### 7.1. Creating an Index on `route_id`

```sql
CREATE INDEX idx_route_id 
ON passengers_on_flights(route_id);
```

* **Purpose:** Speed up queries that filter `passengers_on_flights` by `route_id`.

### 7.2. Using `EXPLAIN`

To see how MySQL executes a query and whether it uses the index:

```sql
EXPLAIN SELECT *
FROM passengers_on_flights
WHERE route_id = 4;
```

* Check the `key` column in the `EXPLAIN` output to confirm if `idx_route_id` is used.

---

## 8. Security and User Management

### 8.1. Create a New User

```sql
CREATE USER IF NOT EXISTS 'new_user'@'localhost' IDENTIFIED BY 'Teja9469#';
```

* **Purpose:** Creates a user named `new_user` with password `Teja9469#`.

### 8.2. Grant Privileges

```sql
GRANT ALL PRIVILEGES ON AircargoDB.* 
TO 'new_user'@'localhost';
```

* **Purpose:** Grants full access to all schemas/tables in `AircargoDB`.

### 8.3. List All Users

```sql
SELECT user, host 
FROM mysql.user;
```

### 8.4. Drop a User

```sql
DROP USER 'new_user'@'localhost';
```

* **Purpose:** Remove the user and revoke all associated privileges.

---

## 9. Common Error Handling & Troubleshooting

### 9.1. Data Truncation for `aircraft_id`

**Symptom:**

```
Error Code: 1265. Data truncated for column 'aircraft_id' at row 1
```

**Cause:**

* The column data type in the destination table does not match or is too small for the source’s `TEXT` value.
  **Fix:**
* Ensure `route_details.aircraft_id` is defined as `TEXT` (matching `routes.aircraft_id` and `ticket_details.aircraft_id`).

### 9.2. “Unknown Column” Errors

**Symptom:**

```
Error Code: 1054. Unknown column 'aircraft_id' in 'field list'
```

**Cause:**

* You attempted to select a column that does not exist in the specified table.
  **Fix:**
* Verify the schema with `DESCRIBE <table_name>;` and correct your query’s column names.

### 9.3. Stored Procedure Syntax Errors

**Symptom:**

```
Error Code: 1064. You have an error in your SQL syntax …
```

**Possible Causes:**

* Missing or misplaced `DELIMITER` statements.
* Typo in `BEGIN…END` block.
* Mismatched parentheses/quotations.
  **Fix:**
* Make sure you switch to a different delimiter (e.g., `$$` or `//`) before creating procedures/functions, then switch back to `;` afterward.

  ```sql
  DELIMITER $$
  CREATE PROCEDURE … 
  BEGIN
    … 
  END $$
  DELIMITER ;
  ```

### 9.4. “Table Doesn’t Exist” in Stored Procedure

**Symptom:**
Stored procedure tries to query a table that is not yet created.
**Fix:**

* Ensure the required tables are created **before** you call the procedure.
* In `GetPassengersByRouteRange`, we explicitly check `information_schema.tables` to confirm the presence of required tables and return an error if missing.

---

## 10. Best Practices for Technical Documentation

1. **Use Clear, Descriptive Headings**

   * Break content into meaningful sections (Overview, Usage, Procedures, etc.) for easy navigation.

2. **Include Code Samples & Snippets**

   * Always surround SQL code with triple backticks (\`\`\`) for readability in Markdown.

3. **Explain Parameter Behavior**

   * For every stored routine, document input parameters, expected outputs, and side effects.

4. **Demonstrate Example Queries**

   * Show real‐world examples of how to call procedures, how to use views, and how to interpret results.

5. **Document Error Handling**

   * List common errors, their causes, and step‐by‐step resolutions.

6. **Keep Schema in Sync**

   * If the underlying table structures change, update this README immediately.

---

## 11. Formatting and Structure (in Markdown)

* Use `#`, `##`, `###` for section headings
* Use bullet lists (`-` or `*`) for itemization
* Use numbered lists (`1.`, `2.`) for ordered instructions
* Place code blocks in triple backticks (<code>`sql</code> … <code>`</code>)
* Bold keywords or important terms with `**bold**`
* Italicize clarifications or notes with `*italic*`
* Include tables for schema snapshots when helpful

---

## 12. Screenshots (Optional)

You can place relevant screenshots in an `/images` folder and reference them like so:

```markdown
[ER Diagram](Aircargo Database EER diagram.pdf)
```

* **Screenshot :** 
  ** ER Diagram of AircargoDB
  ** Sample output of `CALL GetPassengersByRouteRange(1,100)`
  ** EXPLAIN plan showing index usage on `passengers_on_flights`
  ** Output of `SELECT * FROM route_details;`

---

## 13. Conclusion

This documentation serves as a comprehensive guide to the MySQL scripts for **AircargoDB**. You now have:

* **Table inspections** (`SHOW TABLES`, `DESCRIBE`)
* **Data retrieval** (simple `SELECT`, joins, aggregations, window functions)
* **Auxiliary table** creation and population (`route_details`)
* **View** definition (`business_class_customers`)
* **Stored procedures** (`GetPassengersByRouteRange`, `route_details`, `flight_details`, `CheckRevenue`, `fetch_first_scot_customer`, `get_ticket_details`)
* **Stored function** (`get_complimentary_services`)
* **Index creation** and **EXPLAIN** usage for optimization
* **User management** (create user, grant privileges)

Feel free to clone this repo, customize the queries, and integrate them into your own MySQL environment. For any questions, feedback, or contributions, please open an issue or submit a pull request on GitHub.

**Happy querying!**

---
 

**Author:**  
## Earuva Teja  

**Certification:** [SQL Certification Simplilearn.pdf](https://github.com/EaruvaTeja/Aircargo-Database/blob/main/SQL%20Certification%20Simplilearn.pdf)

**Repository:** [Link](https://github.com/EaruvaTeja/Aircargo-Database/)  

**License:**  
MIT  

