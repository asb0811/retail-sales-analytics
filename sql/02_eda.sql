-- 1. row count
SELECT COUNT(*) AS total_rows FROM orders;


-- 2. check for duplicate order and product combinations
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT CONCAT(order_id, '-', product_id)) AS distinct_order_products
FROM orders;


-- 2b. order and product pairs that repeat
SELECT order_id, product_id, COUNT(*) AS times_appeared
FROM orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY times_appeared DESC;


-- 2c. full details for the repeating pairs
SELECT row_id, order_id, product_id, order_date, ship_date, 
       customer_id, customer_name, product_name, sales
FROM orders
WHERE (order_id, product_id) IN (
    ('CA-2017-129714', 'OFF-PA-10001970'),
    ('US-2017-123750', 'TEC-AC-10004659'),
    ('CA-2017-137043', 'FUR-FU-10003664'),
    ('CA-2018-152912', 'OFF-ST-10003208'),
    ('US-2015-150119', 'FUR-CH-10002965'),
    ('CA-2016-103135', 'OFF-BI-10000069'),
    ('CA-2018-118017', 'TEC-AC-10002006'),
    ('CA-2017-140571', 'OFF-PA-10001954')
)
ORDER BY order_id, product_id, row_id;


-- 3. time range
SELECT 
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS total_days_span,
    COUNT(DISTINCT order_date) AS distinct_dates_with_orders
FROM orders;


-- 3b. yearly distribution
SELECT 
    YEAR(order_date) AS order_year,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY YEAR(order_date)
ORDER BY order_year;


-- 3c. yoy growth
SELECT 
    YEAR(order_date) AS order_year,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value,
    ROUND(
        (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)))
        / LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)) * 100
    , 1) AS sales_yoy_pct_change
FROM orders
GROUP BY YEAR(order_date)
ORDER BY order_year;


-- 4. nulls per column
SELECT 
    SUM(CASE WHEN row_id        IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN order_id      IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date    IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN ship_date     IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
    SUM(CASE WHEN ship_mode     IS NULL THEN 1 ELSE 0 END) AS null_ship_mode,
    SUM(CASE WHEN customer_id   IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS null_customer_name,
    SUM(CASE WHEN segment       IS NULL THEN 1 ELSE 0 END) AS null_segment,
    SUM(CASE WHEN country       IS NULL THEN 1 ELSE 0 END) AS null_country,
    SUM(CASE WHEN city          IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN state         IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN postal_code   IS NULL THEN 1 ELSE 0 END) AS null_postal_code,
    SUM(CASE WHEN region        IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN product_id    IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN category      IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN sub_category  IS NULL THEN 1 ELSE 0 END) AS null_sub_category,
    SUM(CASE WHEN product_name  IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN sales         IS NULL THEN 1 ELSE 0 END) AS null_sales
FROM orders;


-- 4b. empty string check for text columns
SELECT 
    SUM(CASE WHEN TRIM(order_id) = ''      THEN 1 ELSE 0 END) AS blank_order_id,
    SUM(CASE WHEN TRIM(ship_mode) = ''     THEN 1 ELSE 0 END) AS blank_ship_mode,
    SUM(CASE WHEN TRIM(customer_id) = ''   THEN 1 ELSE 0 END) AS blank_customer_id,
    SUM(CASE WHEN TRIM(customer_name) = '' THEN 1 ELSE 0 END) AS blank_customer_name,
    SUM(CASE WHEN TRIM(segment) = ''       THEN 1 ELSE 0 END) AS blank_segment,
    SUM(CASE WHEN TRIM(country) = ''       THEN 1 ELSE 0 END) AS blank_country,
    SUM(CASE WHEN TRIM(city) = ''          THEN 1 ELSE 0 END) AS blank_city,
    SUM(CASE WHEN TRIM(state) = ''         THEN 1 ELSE 0 END) AS blank_state,
    SUM(CASE WHEN TRIM(postal_code) = ''   THEN 1 ELSE 0 END) AS blank_postal_code,
    SUM(CASE WHEN TRIM(region) = ''        THEN 1 ELSE 0 END) AS blank_region,
    SUM(CASE WHEN TRIM(product_id) = ''    THEN 1 ELSE 0 END) AS blank_product_id,
    SUM(CASE WHEN TRIM(category) = ''      THEN 1 ELSE 0 END) AS blank_category,
    SUM(CASE WHEN TRIM(sub_category) = ''  THEN 1 ELSE 0 END) AS blank_sub_category,
    SUM(CASE WHEN TRIM(product_name) = ''  THEN 1 ELSE 0 END) AS blank_product_name
FROM orders;


-- 4c. inspect rows with blank postal_code
SELECT row_id, order_id, city, state, postal_code, region
FROM orders
WHERE TRIM(postal_code) = '';


-- 5. full row duplicates
SELECT 
    order_id, order_date, ship_date, ship_mode, customer_id, customer_name,
    segment, country, city, state, postal_code, region, product_id, 
    category, sub_category, product_name, sales,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY 
    order_id, order_date, ship_date, ship_mode, customer_id, customer_name,
    segment, country, city, state, postal_code, region, product_id, 
    category, sub_category, product_name, sales
HAVING COUNT(*) > 1;


-- 6. cardinality per column
SELECT 
    COUNT(DISTINCT row_id)          AS distinct_row_ids,
    COUNT(DISTINCT order_id)        AS distinct_order_ids,
    COUNT(DISTINCT order_date)      AS distinct_order_dates,
    COUNT(DISTINCT ship_date)       AS distinct_ship_dates,
    COUNT(DISTINCT ship_mode)       AS distinct_ship_modes,
    COUNT(DISTINCT customer_id)     AS distinct_customers,
    COUNT(DISTINCT customer_name)   AS distinct_customer_names,
    COUNT(DISTINCT segment)         AS distinct_segments,
    COUNT(DISTINCT country)         AS distinct_countries,
    COUNT(DISTINCT city)            AS distinct_cities,
    COUNT(DISTINCT state)           AS distinct_states,
    COUNT(DISTINCT postal_code)     AS distinct_postal_codes,
    COUNT(DISTINCT region)          AS distinct_regions,
    COUNT(DISTINCT product_id)      AS distinct_products,
    COUNT(DISTINCT category)        AS distinct_categories,
    COUNT(DISTINCT sub_category)    AS distinct_sub_categories,
    COUNT(DISTINCT product_name)    AS distinct_product_names
FROM orders;


-- 7a. zero or negative sales
SELECT row_id, order_id, product_name, sales
FROM orders
WHERE sales <= 0;


-- 7b. ship date before order date
SELECT row_id, order_id, order_date, ship_date,
       DATEDIFF(ship_date, order_date) AS ship_duration_days
FROM orders
WHERE ship_date < order_date;


-- 7c. sales distribution summary
SELECT 
    COUNT(*) AS total_rows,
    MIN(sales) AS min_sales,
    MAX(sales) AS max_sales,
    ROUND(AVG(sales), 2) AS avg_sales,
    ROUND(STDDEV(sales), 2) AS stddev_sales
FROM orders;


-- 7d. ship duration summary
SELECT 
    MIN(DATEDIFF(ship_date, order_date)) AS min_days,
    MAX(DATEDIFF(ship_date, order_date)) AS max_days,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 2) AS avg_days
FROM orders;


-- 8a. customer name consistency
SELECT customer_id, COUNT(DISTINCT customer_name) AS distinct_names
FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT customer_name) > 1;


-- 8b. product id to product name consistency
SELECT product_id, COUNT(DISTINCT product_name) AS distinct_names
FROM orders
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1;


-- 8c. count of products with inconsistent names
SELECT COUNT(*) AS products_with_inconsistent_names
FROM (
    SELECT product_id
    FROM orders
    GROUP BY product_id
    HAVING COUNT(DISTINCT product_name) > 1
) AS t;


-- 8d. distinct products by id vs by name
SELECT 
    COUNT(DISTINCT product_id) AS distinct_products_by_id,
    COUNT(DISTINCT product_name) AS distinct_products_by_name
FROM orders;


-- 8e. product names shared across multiple ids
SELECT product_name, COUNT(DISTINCT product_id) AS distinct_ids
FROM orders
GROUP BY product_name
HAVING COUNT(DISTINCT product_id) > 1
ORDER BY distinct_ids DESC;


-- 8f. count of shared product names
SELECT COUNT(*) AS shared_name_count
FROM (
    SELECT product_name
    FROM orders
    GROUP BY product_name
    HAVING COUNT(DISTINCT product_id) > 1
) AS t;