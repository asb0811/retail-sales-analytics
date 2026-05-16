USE superstore;

-- Q1: category and sub-category performance

-- categories ranked by sales
SELECT 
    category,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 1) AS revenue_share
FROM orders
GROUP BY category
ORDER BY total_sales DESC;


-- sub-categories ranked by sales
SELECT 
    category,
    sub_category,
    COUNT(*) AS items_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 1) AS revenue_share
FROM orders
GROUP BY category, sub_category
ORDER BY total_sales DESC;


-- sub-categories with rank and cumulative share (pareto view)
SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 1) AS revenue_share,
    ROUND(SUM(SUM(sales)) OVER (ORDER BY SUM(sales) DESC) * 100 / SUM(SUM(sales)) OVER (), 1) AS cumulative_share,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM orders
GROUP BY category, sub_category
ORDER BY total_sales DESC;



-- Q2: regional performance

-- region overview
SELECT 
    region,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT customer_id) AS distinct_customers,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 1) AS revenue_share
FROM orders
GROUP BY region
ORDER BY total_sales DESC;


-- regions ranked with cumulative share
SELECT 
    region,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT customer_id) AS distinct_customers,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (), 1) AS revenue_share,
    ROUND(SUM(SUM(sales)) OVER (ORDER BY SUM(sales) DESC) * 100 / SUM(SUM(sales)) OVER (), 1) AS cumulative_share,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM orders
GROUP BY region
ORDER BY total_sales DESC;


-- yearly sales trend per region with year-over-year change
SELECT 
    region,
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        (SUM(sales) - LAG(SUM(sales)) OVER (PARTITION BY region ORDER BY YEAR(order_date)))
        / LAG(SUM(sales)) OVER (PARTITION BY region ORDER BY YEAR(order_date)) * 100
    , 1) AS sales_yoy_pct_change
FROM orders
GROUP BY region, YEAR(order_date)
ORDER BY region, order_year;



-- Q3: regional product mix

-- sub-category sales per region with within-region share
SELECT 
    region,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (PARTITION BY region), 1) AS share_within_region
FROM orders
GROUP BY region, sub_category
ORDER BY region, total_sales DESC;


-- top 5 and bottom 5 sub-categories per region
WITH ranked AS (
    SELECT 
        region,
        sub_category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(sales) * 100 / SUM(SUM(sales)) OVER (PARTITION BY region), 1) AS share_within_region,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rank_top,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sales) ASC) AS rank_bottom
    FROM orders
    GROUP BY region, sub_category
)
SELECT 
    region,
    sub_category,
    total_sales,
    share_within_region,
    CASE 
        WHEN rank_top <= 5 THEN 'TOP'
        WHEN rank_bottom <= 5 THEN 'BOTTOM'
    END AS position
FROM ranked
WHERE rank_top <= 5 OR rank_bottom <= 5
ORDER BY region, rank_top;



-- Q4: customer retention by region

-- multi-year customer count per region
WITH customer_years AS (
    SELECT 
        region,
        customer_id,
        COUNT(DISTINCT YEAR(order_date)) AS years_active
    FROM orders
    GROUP BY region, customer_id
)
SELECT 
    region,
    COUNT(*) AS distinct_customers,
    SUM(CASE WHEN years_active = 1 THEN 1 ELSE 0 END) AS one_year_only,
    SUM(CASE WHEN years_active = 2 THEN 1 ELSE 0 END) AS two_years,
    SUM(CASE WHEN years_active = 3 THEN 1 ELSE 0 END) AS three_years,
    SUM(CASE WHEN years_active = 4 THEN 1 ELSE 0 END) AS four_years,
    ROUND(SUM(CASE WHEN years_active >= 2 THEN 1 ELSE 0 END) * 100 / COUNT(*), 1) AS multi_year_pct
FROM customer_years
GROUP BY region
ORDER BY multi_year_pct DESC;



-- Q5: shipping service quality by region

-- ship duration by region
SELECT 
    region,
    COUNT(*) AS items_sold,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 2) AS avg_ship_days,
    MIN(DATEDIFF(ship_date, order_date)) AS min_ship_days,
    MAX(DATEDIFF(ship_date, order_date)) AS max_ship_days,
    ROUND(STDDEV(DATEDIFF(ship_date, order_date)), 2) AS stddev_ship_days
FROM orders
GROUP BY region
ORDER BY avg_ship_days DESC;


-- ship mode mix by region
SELECT 
    region,
    ship_mode,
    COUNT(*) AS items_sold,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY region), 1) AS share_within_region
FROM orders
GROUP BY region, ship_mode
ORDER BY region, items_sold DESC;