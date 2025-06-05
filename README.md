# ✈️ Aircargo DataBase 
   **MySQL Scripts Documentation
**Last Updated:** June 2025  
**Author:** [Your Name or Team]  
**License:** MIT  
**Repository:** [https://github.com/your-username/AircargoDB-MySQL-Scripts](https://github.com/your-username/AircargoDB-MySQL-Scripts)

---

## 📦 1. Overview

### 📘 Project Name  
**AircargoDB MySQL Scripts**

### 🧾 Description

This repository provides a comprehensive collection of **MySQL scripts** to manage and query the **AircargoDB** dataset. These scripts cover:

- 🔍 Table structure inspection & row counts  
- 🔗 Table joins (customer-flight-ticket insights)  
- 📊 Aggregations (revenue, passenger class counts)  
- 🛫 Auxiliary table creation (`route_details`)  
- ⚡ Index creation and query optimization  
- 👓 View for business-class passengers  
- 🧠 Stored procedures & functions  
- 🔐 Security tasks (user creation, privileges)

🎯 Intended for DBAs, backend engineers, and data analysts working with AircargoDB.

---

## 🛠️ 2. Technical Specifications

### 💾 Database

- **Name:** `AircargoDB`  
- **Engine:** MySQL (Recommended: 5.7+ or 8.0+)

### 🧑‍💻 Query Language

- SQL (MySQL dialect)  
- PL/SQL-style stored routines

### 📐 Schema Overview

#### 1. `customer`

| Column         | Type     |
|----------------|----------|
| customer_id    | INT (PK) |
| first_name     | VARCHAR  |
| last_name      | VARCHAR  |
| date_of_birth  | DATE     |
| gender         | CHAR(1)  |

#### 2. `passengers_on_flights`

| Column        | Type    |
|---------------|---------|
| customer_id   | INT (FK) |
| aircraft_id   | TEXT    |
| route_id      | INT (FK) |
| depart        | DATETIME |
| arrival       | DATETIME |
| seat_num      | VARCHAR |
| class_id      | VARCHAR |
| travel_date   | DATE    |
| flight_num    | INT     |

#### 3. `routes`

| Column            | Type |
|-------------------|------|
| route_id          | INT (PK) |
| flight_num        | INT |
| origin_airport    | TEXT |
| destination_airport | TEXT |
| aircraft_id       | TEXT |
| distance_miles    | INT |

#### 4. `ticket_details`

| Column           | Type |
|------------------|------|
| customer_id      | INT (FK) |
| aircraft_id      | TEXT |
| class_id         | VARCHAR |
| no_of_tickets    | INT |
| p_date           | DATE |
| a_code           | VARCHAR |
| price_per_ticket | INT |
| brand            | VARCHAR |

#### 5. `route_details` (Auxiliary)

| Column         | Type |
|----------------|------|
| route_id       | INT (PK) |
| flight_num     | INT |
| origin_airport | TEXT |
| destination_airport | TEXT |
| aircraft_id    | TEXT |
| distance_miles | INT (>0) |

---

## 📦 3. Dependencies & Requirements

- **MySQL Server:** 5.7 or 8.0+
- **Client Tools:** MySQL CLI, Workbench, phpMyAdmin, HeidiSQL
- **Filesystem:** Access to SQL files for execution via `SOURCE`

---

## 🚀 4. Installation & Setup

### 4.1. Clone the Repo

```bash
git clone https://github.com/your-username/AircargoDB-MySQL-Scripts.git
cd AircargoDB-MySQL-Scripts
```

### 4.2. Create and Use Database

```sql
CREATE DATABASE IF NOT EXISTS AircargoDB;
USE AircargoDB;
```

Import schema (if needed):

```sql
SOURCE /path/to/aircargodb_schema.sql;
```

### 4.3. Run SQL Scripts

```sql
SOURCE /path/to/SQL_QUERIES.sql;
```

Includes procedures, functions, views, optimizations, and more!

---

## 🧪 5. Usage Examples

### 🔍 View Tables

```sql
USE AircargoDB;
SHOW TABLES;
SELECT * FROM customer;
```

### 📊 Aggregations

```sql
SELECT brand, COUNT(*) AS total_tickets_sold
FROM ticket_details
GROUP BY brand;
```

### 🔗 Joins

```sql
SELECT c.first_name, p.aircraft_id, t.price_per_ticket
FROM customer AS c
JOIN passengers_on_flights AS p ON c.customer_id = p.customer_id
JOIN ticket_details AS t ON c.customer_id = t.customer_id;
```

---

## 🔧 6. Stored Procedures & Functions

- `GetPassengersByRouteRange(start_route, end_route)`
- `route_details(distance)`
- `flight_details(categorie_type)`
- `CheckRevenue()`
- `fetch_first_scot_customer()`
- `get_ticket_details()`
- **Function:** `get_complimentary_services(class_id)`
- **View:** `business_class_customers`

💡 Each routine is fully documented in [section 6](#6-documenting-stored-procedures-functions-and-views).

---

## 🚀 7. Performance Optimization

### Index Creation

```sql
CREATE INDEX idx_route_id ON passengers_on_flights(route_id);
```

### Query Plan Analysis

```sql
EXPLAIN SELECT * FROM passengers_on_flights WHERE route_id = 4;
```

---

## 🔐 8. Security

### 👤 Create New User

```sql
CREATE USER IF NOT EXISTS 'new_user'@'localhost' IDENTIFIED BY 'Teja9469#';
```

### 🛡️ Grant Privileges

```sql
GRANT ALL PRIVILEGES ON AircargoDB.* TO 'new_user'@'localhost';
```

### ❌ Drop User

```sql
DROP USER 'new_user'@'localhost';
```

---

## 🧯 9. Troubleshooting

### ⚠️ Data Truncation

> **Error 1265:** Check field type compatibility, e.g., `aircraft_id` as `TEXT`.

### ❓ Unknown Column

> **Error 1054:** Validate column names with `DESCRIBE table_name;`.

### 🧨 Stored Procedure Errors

> **Error 1064:** Double-check `DELIMITER`, `BEGIN...END`, and syntax.

---

## 📝 10. Documentation Tips

✅ Use code blocks  
✅ Document parameters  
✅ Add examples  
✅ Explain error handling  
✅ Update schema as needed  

---

## 🖼️ 11. Screenshots (Optional)

Place images in `/images` folder and use:

```markdown
![ER Diagram](images/er_diagram.png)
```

Example ideas:
- ER Diagram  
- Output of `CALL GetPassengersByRouteRange()`  
- `EXPLAIN` plan  
- `route_details` table view

---

## 🎯 12. Conclusion

With these MySQL scripts, you can:

- 🔎 Inspect and query AircargoDB tables  
- 📊 Analyze ticket sales and passenger info  
- 🛠️ Create views, stored procedures, and functions  
- ⚙️ Optimize performance  
- 🔐 Manage user access  

Feel free to contribute, fork, or raise issues!  
Happy querying! 🧠💻✈️

---

**📬 Contact / Issues:** Please use the [GitHub Issues page](https://github.com/your-username/AircargoDB-MySQL-Scripts/issues)  
**📄 License:** [MIT License](LICENSE)

```

Let me know if you’d like a version with real repository links, added table diagrams, or auto-generated badges (like license, build status, etc.)!
