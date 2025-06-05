USE AircargoDB;

SHOW TABLES;
SELECT * FROM customer;
SELECT * FROM passengers_on_flights;
SELECT * FROM routes;
SELECT * FROM ticket_details;
SELECT * FROM route_details;

SELECT COUNT(*) as total , brand FROM ticket_details GROUP BY brand ;

SELECT * FROM ticket_details WHERE brand = "Emirates";

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
    #t.p_date,    
    # t.class_id AS ticket_class_id,   
    t.no_of_tickets
    #t.a_code,   
    #t.price_per_ticket
    #t.brand 
FROM customer c 
INNER JOIN passengers_on_flights p ON c.customer_id = p.customer_id
INNER JOIN ticket_details t ON c.customer_id = t.customer_id
INNER JOIN passengers_on_flights pf ON pf.aircraft_id = t.aircraft_id



CREATE TABLE route_details (
    route_id INT PRIMARY KEY,  -- Unique and primary key constraint
    flight_num INT CHECK (flight_num > 0),  -- Check constraint for flight number (positive integer)
    origin_airport TEXT NOT NULL,
    destination_airport TEXT NOT NULL,
    aircraft_id TEXT NOT NULL,  -- Match with routes & ticket_details
    distance_miles INT CHECK (distance_miles > 0)  -- Distance must be positive
);

INSERT INTO route_details (route_id, flight_num, origin_airport, destination_airport, aircraft_id, distance_miles)
SELECT DISTINCT r.route_id, r.flight_num, r.origin_airport, r.destination_airport, r.aircraft_id, r.distance_miles
FROM routes r
JOIN passengers_on_flights p ON r.route_id = p.route_id
JOIN ticket_details t ON r.aircraft_id = t.aircraft_id;

DESCRIBE routes;
DESCRIBE ticket_details;

SELECT * FROM route_details


SELECT * FROM passengers_on_flights 
SELECT customer_id,route_id FROM passengers_on_flights 
WHERE route_id BETWEEN 01 AND 25

SELECT * FROM ticket_details

SELECT customer_id, class_id, 
       SUM(price_per_ticket) AS Total_individual_price, 
       (SELECT SUM(price_per_ticket) FROM ticket_details WHERE class_id = 'Bussiness') AS Total_price
FROM ticket_details
WHERE class_id = 'Bussiness'
GROUP BY customer_id,class_id;

SELECT * FROM customer
SELECT c.first_name, c.last_name, CONCAT(first_name,' ',last_name) as full_name FROM customer as c


SELECT * FROM customer;
SELECT * FROM ticket_details;

SELECT DISTINCT c.customer_id, c.first_name, c.last_name, c.date_of_birth, c.gender, 
       t.p_date, t.aircraft_id, t.class_id, t.no_of_tickets, t.a_code, t.Price_per_ticket, t.brand
FROM customer AS c 
JOIN ticket_details AS t ON t.customer_id = c.customer_id 
WHERE t.no_of_tickets = 1;

SELECT * FROM customer;
SELECT * FROM ticket_details;

SELECT DISTINCT t.customer_id, t.brand, c.first_name, c.last_name FROM ticket_details as t
JOIN customer as c ON c.customer_id = t.customer_id
WHERE brand = "Emirates"


SELECT * FROM customer;
SELECT * FROM passengers_on_flights;

SELECT customer_id, COUNT(*) AS total_trips
FROM passengers_on_flights
GROUP BY customer_id
HAVING COUNT(*) > 0 AND MAX(class_id) = "Economy Plus";

SELECT * FROM ticket_details

DELIMITER //

CREATE PROCEDURE CheckRevenue()
BEGIN
    DECLARE total_revenue INT;

    SELECT SUM(price_per_ticket) INTO total_revenue FROM ticket_details;

    IF total_revenue > 10000 THEN
        SELECT 'YES, REVENUE ABOVE 10000' AS result;
    ELSE
        SELECT 'NO, REVENUE BELOW 10000' AS result;
    END IF;
END //

DELIMITER ;

CALL CheckRevenue();


CREATE USER IF NOT EXISTS 'new_user'@'localhost' IDENTIFIED BY 'Teja9469#';
GRANT ALL PRIVILEGES ON aircargodb.* TO 'new_user'@'localhost';

SELECT user, host FROM mysql.user; # see all users in host

# to drop user use - DROP USER 'new_user'@'%';

 
SELECT * FROM ticket_details;

SELECT MAX(price_per_ticket) as max_tkprice , MIN(price_per_ticket) as min_tkprice,class_id FROM ticket_details
GROUP BY class_id

# win function

SELECT class_id,MAX(price_per_ticket) OVER(PARTITION BY class_id) as max_tk_price FROM ticket_details

SELECT * FROM passengers_on_flights 

-- Ensure an index exists on route_id for faster filtering
CREATE INDEX idx_route_id ON passengers_on_flights(route_id);

SELECT * FROM passengers_on_flights as p 
WHERE p.route_id = 4

SELECT * FROM passengers_on_flights
EXPLAIN SELECT * FROM passengers_on_flights WHERE route_id = 4

SELECT * FROM routes;
SELECT * FROM route_details;
SELECT * FROM ticket_details;

SELECT aircraft_id, brand, SUM(price_per_ticket) as total_revenue 
FROM ticket_details 
GROUP BY aircraft_id, brand WITH ROLLUP;

SELECT * FROM passengers_on_flights

CREATE VIEW business_class_customers AS
SELECT *
FROM passengers_on_flights
WHERE class_id = 'Bussiness';

SELECT * FROM business_class_customers ;# view name

SELECT * FROM routes

/*DELIMITER //
CREATE PROCEDURE customer_by_range(
	IN start_route VARCHAR(50),
    IN end_route VARCHAR(50))
BEGIN 
     DECLARE table_exist INT;
	 SELECT COUNT(*) INTO table_exist
	 FROM aircargodb.Tables
	 WHERE table_name = "customer_id";
IF table_exists = 0 THEN
	 SIGNAL SQLSTATE '45000'
	 SET MESSAGE_TEXT = 'Error: passenger_details table does not exist!';
     ELSE
		 SELECT * FROM passenger_details
        WHERE route BETWEEN start_route AND end_route;
    END IF;
END //
DELIMITER ;*/


DELIMITER $$

CREATE PROCEDURE GetPassengersByRouteRange(
    IN start_route INT,
    IN end_route INT
)
BEGIN
    -- Check if required tables exist
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables 
        WHERE table_schema = 'aircargodb' 
        AND table_name IN ('customer', 'passengers_on_flights', 'routes')
        HAVING COUNT(DISTINCT table_name) = 3  -- Ensure all 3 tables exist
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
        FROM passengers_on_flights pof
        INNER JOIN customer c ON pof.customer_id = c.customer_id
        INNER JOIN routes r ON pof.route_id = r.route_id
        WHERE r.route_id BETWEEN start_route AND end_route
        ORDER BY pof.travel_date, pof.flight_num, pof.seat_num;
    END IF;
END$$

DELIMITER ;

CALL GetPassengersByRouteRange (1,100) #route id from 1 to 100

SELECT * FROM passengers_on_flights

SELECT * FROM routes
#new
DELIMITER $$
CREATE PROCEDURE route_details(
IN distance INT)
BEGIN
	SELECT * FROM routes
    WHERE routes.distance_miles >= distance;
END $$
DELIMITER ;
    
CALL route_details (2000)

SELECT * FROM routes

#new
DELIMITER $$

CREATE PROCEDURE flight_details(IN categorie_type CHAR(3))
BEGIN 

	IF categorie_type NOT IN ('SDT', 'IDT', 'LDT') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid category type. Use SDT, IDT, or LDT.';
    ELSE

	SELECT * FROM routes as r
		WHERE (categorie_type = "SDT" AND r.distance_miles BETWEEN 0 AND 2000 )
	OR
		(categorie_type = "IDT" AND r.distance_miles BETWEEN 2001 AND 6500)
	OR
		(categorie_type = "SDT" AND r.distance_miles > 6500);
	END IF;
END $$

DELIMITER ;

CALL flight_details("SDT")

SELECT * FROM ticket_details

DELIMITER $$

CREATE FUNCTION get_complimentary_services(class_id VARCHAR(20)) 
RETURNS VARCHAR(3) DETERMINISTIC
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

DELIMITER $$

CREATE PROCEDURE get_ticket_details()
BEGIN
    SELECT p_date, customer_id, class_id, 
           get_complimentary_services(class_id) AS complimentary_services
    FROM ticket_details;
END $$

DELIMITER ;

CALL get_ticket_details();


#20
SELECT * FROM customer

DELIMITER $$

CREATE PROCEDURE fetch_first_scot_customer()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE cust_id INT;
    DECLARE f_name VARCHAR(50);
    DECLARE l_name VARCHAR(50);

    -- 1) Cursor selects all customers whose last_name ends in 'Scot', ordered by customer_id
    DECLARE cur CURSOR FOR
      SELECT customer_id, first_name, last_name
      FROM customer
      WHERE last_name LIKE '%Scot'   -- match any name ending with 'Scot'
      ORDER BY customer_id;

    -- 2) If the cursor fetch finds no rows, set done = 1
    DECLARE CONTINUE HANDLER FOR NOT FOUND
      SET done = 1;

    OPEN cur;

    -- 3) Fetch just the very first row from that result set
    FETCH cur INTO cust_id, f_name, l_name;

    -- 4) If no row was returned (done = 1), show the “not found” message
    IF done = 1 THEN
        SELECT 'No matching record found' AS message;
    ELSE
        SELECT cust_id    AS customer_id,
               f_name      AS first_name,
               l_name      AS last_name;
    END IF;

    CLOSE cur;
END$$

DELIMITER ;

CALL fetch_first_scot_customer();
SELECT * FROM customer WHERE last_name = 'Scot';

#END