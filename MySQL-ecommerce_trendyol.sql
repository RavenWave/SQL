CREATE TABLE address (
	order_id VARCHAR(55),
    city VARCHAR(55),
    town VARCHAR(55)
);
CREATE TABLE customers (
	order_id VARCHAR(55),
    customer_name VARCHAR(55),
    gender VARCHAR(55)
);

CREATE TABLE order_details (
	order_id VARCHAR(55),
    commission_rate DECIMAL(5, 2),
    quantity INT,
    unit_price DECIMAL(7, 2),
    total_sales DECIMAL(7, 2),
    total_discount DECIMAL(7, 2),
    invoice_amount DECIMAL(7, 2)
);

CREATE TABLE orders (
	order_id VARCHAR(55),
    order_date DATETIME,
    shipping_date DATETIME,
	delivery_date DATETIME
);

CREATE TABLE products (
	order_id VARCHAR(55),
    product_id VARCHAR(55)
);

CREATE TABLE shipping (
	order_id VARCHAR(55),
    cargo_firm VARCHAR(100),
    desi DECIMAL(4, 1)
);

CREATE TABLE product_details (
	product_id VARCHAR(55),
    model_id VARCHAR(55),
    size VARCHAR(55),
    category VARCHAR(55),
    product_name VARCHAR(355)
);


SHOW VARIABLES LIKE 'secure_file_priv';


LOAD DATA INFILE 'address.csv'
INTO TABLE address
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'shipping.csv'
INTO TABLE shipping
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'product_details.csv'
INTO TABLE product_details
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM address;
SELECT * FROM customers;
SELECT * FROM order_details;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM shipping;
SELECT * FROM product_details;

/*
LIST OF VIEWS
- 0. ListOfViews
	Lists the list of views.
- 1. CountOfRecords
	Shows the record count of all tables.
- 2. AddressD
	Shows the address table as distinct.
- 3. RatioOfCities
	Shows distribution of cities of orders.
- 4. CustomersD
	Shows the customers as distinct.
- 5. CustomersMultipleOrders
	Shows the customers who have placed multiple orders.
- 6. RatioOfGenders
	Gives ratio of genders.
- 7. TotalProductOrdered
	Gives total product ordered.
- 8. TotalProductOrdered
	Gives total sales ordered.
- 9. RatioProductToSales
	Gives product to sales ratio.
- 10. OrderDetailsD
	Gives order_details as distinct.
- 11. OrdersD
	Gives orders as distinct.
- 12. CountOfOrdersByMonth
	Gives as number of orders by month.
- 13. CountOfOrdersByDays
	Gives as number of orders by days of month.
- 14. TimeDurationOfTermin
	Calculates the difference days between shipping_date and order_date. 
- 15. AvgTerminTime
	Calculates average termin time.
- 16. CountOfProducsOrdered
	Gives us the number of products ordered.
- 17. ShippingD
	Shows the shipping table as distinct.
- 18. NumOfCargo
	Gives us the distribution of cargo firm.
*/

CREATE VIEW ListOfViews AS
SELECT 
	ROW_NUMBER() OVER() AS row_id,
    TABLE_NAME AS view_name
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'new_trendyol';

SELECT * FROM ListOfViews;

CREATE VIEW CountOfRecords AS
SELECT 'address' AS table_name, COUNT(*) AS count_records FROM address
UNION
SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION
SELECT 'order_details' AS table_name, COUNT(*) FROM order_details
UNION
SELECT 'orders' AS table_name, COUNT(*) FROM orders
UNION
SELECT 'products' AS table_name, COUNT(*) FROM products
UNION
SELECT 'shipping' AS table_name, COUNT(*) FROM shipping
UNION
SELECT 'product_details' AS table_name, COUNT(*) FROM product_details;

SELECT * FROM CountOfRecords;

-- 01. address
SELECT * FROM address;

CREATE VIEW AddressD AS
SELECT 
	order_id,
    city,
    town
FROM address
GROUP BY 
	order_id,
    city,
    town
ORDER BY city;

SELECT * FROM AddressD;

SELECT COUNT(*) AS num_orders FROM AddressD;

CREATE VIEW RatioOfCities as
SELECT 
	city,
    COUNT(*) AS count_of_city,
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM AddressD)) * 100, 2), '%') AS ratio
FROM AddressD
GROUP BY city
ORDER BY count_of_city DESC;

SELECT * FROM RatioOfCities;

-- 02. customers
SELECT * FROM customers;

CREATE VIEW CustomersD AS
SELECT 
	order_id,
    customer_name,
    gender
FROM customers
GROUP BY
	order_id,
    customer_name,
    gender
ORDER BY customer_name;

SELECT * FROM CustomersD;
SELECT COUNT(*) FROM CustomersD;

CREATE VIEW CustomersMultipleOrders AS 
SELECT
	customer_name,
    COUNT(*) AS count_of_names
FROM CustomersD
GROUP BY customer_name
HAVING COUNT(*) > 1
ORDER BY count_of_names DESC;

SELECT * FROM CustomersMultipleOrders;

CREATE VIEW RatioOfGenders AS
SELECT
	gender,
    COUNT(*) AS count_of_gender,
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM CustomersD)) * 100, 2), '%') AS ratio
FROM CustomersD
GROUP BY gender
HAVING COUNT(*) > 1
ORDER BY count_of_gender DESC;

SELECT * FROM RatioOfGenders;

-- 03. order_details
SELECT * FROM order_details;

CREATE VIEW TotalProductOrdered AS
SELECT
	SUM(quantity) AS total_quantity_ordered
FROM order_details;

SELECT * FROM TotalProductOrdered;

CREATE VIEW TotalSalesOrdered AS
SELECT COUNT(*) 
FROM (SELECT 
	COUNT(order_id)
FROM order_details
GROUP BY order_id) t1;

SELECT * FROM TotalSalesOrdered;

CREATE VIEW RatioProductToSales AS
SELECT 
	total_quantity_ordered / (SELECT * FROM TotalSalesOrdered) AS ratio_product_to_sales
FROM TotalProductOrdered;

SELECT * FROM RatioProductToSales;

SELECT
	'Sales:' AS Info,
	FORMAT(SUM(total_sales), 2) AS Total
FROM order_details
UNION
SELECT
	'Discount:',
	FORMAT(SUM(total_discount), 2)
FROM order_details
UNION 
SELECT
	'Invoice Amount:',
	FORMAT(SUM(invoice_amount), 2)
FROM order_details;

CREATE VIEW OrderDetailsD AS
SELECT 
	order_id,
    SUM(quantity) as quantity,
    SUM(total_sales) as total_sales,
    SUM(total_discount) as total_discount,
    SUM(invoice_amount) as invoice_amount
FROM order_details
GROUP BY order_id
ORDER BY invoice_amount DESC;

SELECT * FROM OrderDetailsD;

-- 04. orders
SELECT * FROM orders;

CREATE VIEW OrdersD AS
SELECT 
	order_id,
    order_date,
    shipping_date,
    delivery_date
FROM orders
GROUP BY 
	order_id, 
	order_date,
    shipping_date,
    delivery_date;

SELECT * FROM OrdersD;

CREATE VIEW CountOfOrdersByMonth AS
SELECT 
	MONTH(order_date) as month,
    COUNT(*) as count_orders
FROM OrdersD
GROUP BY month
ORDER BY month;

SELECT * FROM CountOfOrdersByMonth;

CREATE VIEW CountOfOrdersByDays AS
SELECT 
	DAY(order_date) as days_of_month,
    COUNT(*) as count_orders
FROM OrdersD
GROUP BY days_of_month
ORDER BY days_of_month;

SELECT * FROM CountOfOrdersByDays;

SELECT * FROM OrdersD;

SELECT 
	CONCAT(DAY(order_date), ' - ', HOUR(order_date), ':', MINUTE(order_date)) as order_hour,
    CONCAT(DAY(shipping_date), ' - ', HOUR(shipping_date), ':', MINUTE(shipping_date)) as shipping_hour
FROM OrdersD;


SELECT * FROM OrdersD;

CREATE VIEW try_view AS
SELECT 
	*,
    CASE
		WHEN TIME(order_date) BETWEEN '00:00:00' AND '08:00:00'
        THEN CAST(CONCAT(DATE(order_date), ' ', TIME('08:00:00')) as DATETIME)
        WHEN TIME(order_date) BETWEEN '08:00:00' AND '17:00:00'
        THEN order_date
        WHEN TIME(order_date) BETWEEN '17:00:00' AND '23:59:59'
        THEN CAST(CONCAT(DATE_ADD(DATE(order_date), INTERVAL 1 DAY), ' ', TIME('08:00:00')) as DATETIME)
	END as new_date
FROM OrdersD; 

CREATE VIEW try_view_2 AS
SELECT 
	*,
    CASE 
		WHEN DAYNAME(new_date) = DAYNAME(shipping_date)
        THEN new_date
		WHEN (DAYNAME(new_date) = 'Saturday' AND TIME(new_date) > ('12:00:00'))
		THEN CAST(CONCAT(DATE_ADD(DATE(new_date), INTERVAL 2 DAY), ' ', TIME('08:00:00')) as DATETIME)
        WHEN DAYNAME(new_date) = 'Sunday'
        THEN CAST(CONCAT(DATE_ADD(DATE(new_date), INTERVAL 1 DAY), ' ', TIME('08:00:00')) as DATETIME)
        ELSE new_date
	END as time_duration
FROM try_view;

CREATE VIEW TimeDurationOfTermin AS
SELECT  
	order_id,
    order_date,
    shipping_date,
    delivery_date,
    CASE
		WHEN DAYNAME(time_duration) = 'Friday' AND DAYNAME(shipping_date) = 'Tuesday'
        THEN sec_to_time(time_to_sec((DATE_ADD(TIMEDIFF(CAST(CONCAT(DATE(time_duration), ' ', TIME('17:00:00')) as DATETIME), time_duration), INTERVAL (4 * 60) MINUTE))) + 
    time_to_sec(TIMEDIFF(shipping_date, CAST(CONCAT(DATE(shipping_date), ' ', TIME('08:00:00')) as DATETIME))))
		WHEN DAY(shipping_date) - DAY(time_duration) = 1
        THEN sec_to_time(time_to_sec((TIMEDIFF(CAST(CONCAT(DATE(time_duration), ' ', TIME('17:00:00')) as DATETIME), time_duration))) + 
    time_to_sec(TIMEDIFF(shipping_date, CAST(CONCAT(DATE(shipping_date), ' ', TIME('08:00:00')) as DATETIME))))
		WHEN DAYNAME(time_duration) = 'Saturday' AND DAYNAME(shipping_date) = 'Monday'
        THEN sec_to_time(time_to_sec((TIMEDIFF(CAST(CONCAT(DATE(time_duration), ' ', TIME('12:00:00')) as DATETIME), time_duration))) + 
    time_to_sec(TIMEDIFF(shipping_date, CAST(CONCAT(DATE(shipping_date), ' ', TIME('08:00:00')) as DATETIME))))
		WHEN DAY(shipping_date) - DAY(time_duration) = 2
        THEN sec_to_time(time_to_sec((DATE_ADD(TIMEDIFF(CAST(CONCAT(DATE(time_duration), ' ', TIME('17:00:00')) as DATETIME), time_duration), INTERVAL (9 * 60) MINUTE))) + 
    time_to_sec(TIMEDIFF(shipping_date, CAST(CONCAT(DATE(shipping_date), ' ', TIME('08:00:00')) as DATETIME))))
		ELSE TIMEDIFF(shipping_date, time_duration)
    END AS time_duration
FROM try_view_2;

CREATE VIEW AvgTerminTime AS
SELECT CONCAT(HOUR(SEC_TO_TIME(AVG(TIME_TO_SEC(time_duration)))), ' hour ', MINUTE(SEC_TO_TIME(AVG(TIME_TO_SEC(time_duration)))), ' minutes') as avg_termin_time
FROM TimeDurationOfTermin;

DROP VIEW try_view;
DROP VIEW try_view_2;

SELECT *
FROM TimeDurationOfTermin;

SELECT * FROM OrdersD;

-- 05. Products
SELECT * FROM products;

CREATE VIEW CountOfProducsOrdered AS
SELECT 
	product_id,
    COUNT(*) AS count_products
FROM products
GROUP BY product_id
ORDER BY count_products DESC;

SELECT * FROM CountOfProducsOrdered;

-- 07. Shipping
SELECT * FROM shipping;

CREATE VIEW ShippingD AS
SELECT
	order_id,
    cargo_firm,
    desi
FROM shipping
GROUP BY 
	order_id,
	cargo_firm,
    desi;

SELECT * FROM ShippingD;

SELECT COUNT(*) FROM ShippingD;

CREATE VIEW NumOfCargo AS
SELECT 
	cargo_firm,
    COUNT(*) as number_of_cargo
FROM ShippingD
GROUP BY cargo_firm
ORDER BY number_of_cargo DESC;

SELECT * FROM NumOfCargo;
-------------------------------------------
SELECT * FROM listofviews;

SELECT * FROM addressd;
SELECT * FROM customersd;
SELECT * FROM orderdetailsd;
SELECT * FROM ordersd;
SELECT * FROM shippingd;
SELECT * FROM products;
SELECT * FROM product_details;

SELECT * FROM countofordersbydays;
SELECT * FROM countofordersbymonth;
SELECT * FROM countofproducsordered;
SELECT * FROM customersmultipleorders;
SELECT * FROM numofcargo;
SELECT * FROM ratioofcities;
SELECT * FROM ratioofgenders;
SELECT * FROM ratioproducttosales;
SELECT * FROM totalsalesordered;
SELECT * FROM totalproductordered;




































































































