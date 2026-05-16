-- create database and orders table

CREATE DATABASE superstore;
USE superstore;

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    row_id          INT PRIMARY KEY,
    order_id        VARCHAR(20) NOT NULL,
    order_date      DATE NOT NULL,
    ship_date       DATE NOT NULL,
    ship_mode       VARCHAR(20),
    customer_id     VARCHAR(20) NOT NULL,
    customer_name   VARCHAR(100),
    segment         VARCHAR(20),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    product_id      VARCHAR(20) NOT NULL,
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(200),
    sales           DECIMAL(10, 2) NOT NULL
);


-- check allowed file load directory
SHOW VARIABLES LIKE 'secure_file_priv';


-- load data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/superstore_orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(row_id, order_id, @order_date_raw, @ship_date_raw, ship_mode, customer_id, 
 customer_name, segment, country, city, state, postal_code, region, 
 product_id, category, sub_category, product_name, sales)
SET 
    order_date = STR_TO_DATE(@order_date_raw, '%d/%m/%Y'),
    ship_date  = STR_TO_DATE(@ship_date_raw, '%d/%m/%Y');


-- verify
SELECT COUNT(*) FROM orders;
SHOW WARNINGS;