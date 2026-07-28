USE defaultdb;

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_location;
DROP TABLE IF EXISTS stg_sales;

USE defaultdb;

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_location;
DROP TABLE IF EXISTS stg_sales;

SHOW TABLES;
USE defaultdb;
SHOW TABLES;

INSERT INTO dim_customer (customer_name, segment)
SELECT DISTINCT
    customer_name,
    segment
FROM stg_sales;



INSERT INTO dim_product
(product_id, category, sub_category, product_name)
SELECT DISTINCT
    product_id,
    category,
    sub_category,
    product_name
FROM stg_sales;



INSERT INTO dim_location
(state, country, market, region)
SELECT DISTINCT
    state,
    country,
    market,
    region
FROM stg_sales;

INSERT INTO dim_date
(
    full_date,
    year,
    quarter,
    month_number,
    month_name,
    year_month_text
)
SELECT DISTINCT
    order_date,
    order_year,
    order_quarter,
    month_number,
    month_name,
    year_month_text
FROM stg_sales;











ALTER TABLE dim_date
MODIFY COLUMN date_key INT NOT NULL AUTO_INCREMENT;



SELECT COUNT(*) AS fact_rows
FROM fact_sales;




DROP TABLE fact_sales;
DROP TABLE dim_date;

CREATE TABLE dim_date (
    date_key INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month_number INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year_month_text VARCHAR(7) NOT NULL
);








INSERT INTO dim_date
(
    full_date,
    year,
    quarter,
    month_number,
    month_name,
    year_month_text
)
SELECT DISTINCT
    order_date,
    order_year,
    order_quarter,
    month_number,
    month_name,
    year_month_text
FROM stg_sales;

SHOW CREATE TABLE fact_sales;


SHOW TABLES;


SHOW CREATE TABLE dim_date;


SHOW COLUMNS FROM dim_date;

TRUNCATE TABLE stg_sales;







INSERT INTO dim_date
(
    full_date,
    year,
    quarter,
    month_number,
    month_name,
    year_month_text
)
SELECT DISTINCT
    order_date,
    order_year,
    order_quarter,
    month_number,
    month_name,
    year_month_text
FROM stg_sales;


SELECT COUNT(*) FROM dim_date;



SHOW CREATE TABLE dim_customer;
SHOW CREATE TABLE dim_product;
SHOW CREATE TABLE dim_location;



DESCRIBE dim_customer;
DESCRIBE dim_product;
DESCRIBE dim_location;

SHOW CREATE TABLE fact_sales;
SHOW TABLES LIKE 'fact_sales';













CREATE TABLE fact_sales (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,

    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    location_key INT NOT NULL,

    order_id VARCHAR(50),
    ship_date DATE,
    ship_mode VARCHAR(50),

    sales DECIMAL(12,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(12,2),
    shipping_cost DECIMAL(12,2),
    shipping_days INT,
    profit_margin DECIMAL(10,2),
    order_priority VARCHAR(30),

    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key)
);




INSERT INTO fact_sales
(
    date_key,
    customer_key,
    product_key,
    location_key,
    order_id,
    ship_date,
    ship_mode,
    sales,
    quantity,
    discount,
    profit,
    shipping_cost,
    shipping_days,
    profit_margin,
    order_priority
)
SELECT
    d.date_key,
    c.customer_key,
    p.product_key,
    l.location_key,
    s.order_id,
    s.ship_date,
    s.ship_mode,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    s.shipping_cost,
    s.shipping_days,
    s.profit_margin,
    s.order_priority
FROM stg_sales s
JOIN dim_customer c
    ON s.customer_name = c.customer_name
   AND s.segment = c.segment
JOIN dim_product p
    ON s.product_id = p.product_id
   AND s.product_name = p.product_name
JOIN dim_location l
    ON s.state = l.state
   AND s.country = l.country
   AND s.market = l.market
   AND s.region = l.region
JOIN dim_date d
    ON s.order_date = d.full_date;

SELECT COUNT(*) AS fact_rows
FROM fact_sales;


SELECT COUNT(*) FROM stg_sales;
SELECT COUNT(*) FROM fact_sales;

TRUNCATE TABLE fact_sales;



SELECT COUNT(*) FROM fact_sales;

SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_location;
SELECT COUNT(*) FROM dim_date;


SELECT COUNT(*)
FROM stg_sales s
JOIN dim_customer c
ON s.customer_name = c.customer_name
AND s.segment = c.segment;


SELECT COUNT(*)
FROM stg_sales s
JOIN dim_product p
ON s.product_id = p.product_id
AND s.product_name = p.product_name;


SELECT COUNT(*)
FROM stg_sales s
JOIN dim_location l
ON s.state = l.state
AND s.country = l.country
AND s.market = l.market
AND s.region = l.region;



SELECT COUNT(*)
FROM stg_sales s
JOIN dim_date d
ON s.order_date = d.full_date;

TRUNCATE TABLE dim_date;
DELETE FROM dim_date;
ALTER TABLE dim_date AUTO_INCREMENT = 1;




INSERT INTO dim_date
(
    full_date,
    year,
    quarter,
    month_number,
    month_name,
    year_month_text
)
SELECT
    order_date,
    MAX(order_year),
    MAX(order_quarter),
    MAX(month_number),
    MAX(month_name),
    MAX(year_month_text)
FROM stg_sales
GROUP BY order_date;


SELECT COUNT(*) FROM dim_date;

SELECT COUNT(*)
FROM stg_sales s
JOIN dim_date d
ON s.order_date = d.full_date;


DELETE FROM dim_date;
ALTER TABLE dim_date AUTO_INCREMENT = 1;
SELECT COUNT(*) FROM dim_date;

SELECT TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'dim_date'
AND TABLE_SCHEMA = 'defaultdb';

DELETE FROM dim_date;




SET SQL_SAFE_UPDATES = 0;

DELETE FROM dim_date;


SELECT COUNT(*) FROM dim_date;


INSERT INTO dim_date
(
    full_date,
    year,
    quarter,
    month_number,
    month_name,
    year_month_text
)
SELECT
    order_date,
    MAX(order_year),
    MAX(order_quarter),
    MAX(month_number),
    MAX(month_name),
    MAX(year_month_text)
FROM stg_sales
GROUP BY order_date;

SELECT COUNT(*) FROM dim_date;

SELECT COUNT(DISTINCT full_date) FROM dim_date;


SELECT COUNT(*)
FROM stg_sales s
JOIN dim_date d
ON s.order_date = d.full_date;





TRUNCATE TABLE fact_sales;



INSERT INTO fact_sales
(
    date_key,
    customer_key,
    product_key,
    location_key,
    order_id,
    ship_date,
    ship_mode,
    sales,
    quantity,
    discount,
    profit,
    shipping_cost,
    shipping_days,
    profit_margin,
    order_priority
)
SELECT
    d.date_key,
    c.customer_key,
    p.product_key,
    l.location_key,
    s.order_id,
    s.ship_date,
    s.ship_mode,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    s.shipping_cost,
    s.shipping_days,
    s.profit_margin,
    s.order_priority
FROM stg_sales s
JOIN dim_customer c
    ON s.customer_name = c.customer_name
   AND s.segment = c.segment
JOIN dim_product p
    ON s.product_id = p.product_id
   AND s.product_name = p.product_name
JOIN dim_location l
    ON s.state = l.state
   AND s.country = l.country
   AND s.market = l.market
   AND s.region = l.region
JOIN dim_date d
    ON s.order_date = d.full_date;
    
    
    
    
SELECT COUNT(*) AS fact_rows
FROM fact_sales;








TRUNCATE TABLE fact_sales;


SELECT COUNT(*) FROM fact_sales;




USE defaultdb;

SELECT COUNT(*) AS total_rows
FROM stg_sales;


USE defaultdb;

SHOW TABLES;



USE defaultdb;
DROP TABLE IF EXISTS stg_sales;

CREATE TABLE stg_sales (
    stg_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),

    customer_name VARCHAR(150),
    segment VARCHAR(50),

    state VARCHAR(100),
    country VARCHAR(100),
    market VARCHAR(50),
    region VARCHAR(100),

    product_id VARCHAR(50),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255),

    sales DECIMAL(15,2),
    quantity INT,
    discount DECIMAL(10,4),
    profit DECIMAL(15,2),
    shipping_cost DECIMAL(15,2),

    order_priority VARCHAR(50),

    order_year INT,
    order_quarter INT,
    month_number INT,
    month_name VARCHAR(20),
    year_month_text VARCHAR(7),

    shipping_days INT,
    profit_margin DECIMAL(15,2)
);
TRUNCATE TABLE stg_sales;
SELECT COUNT(*)
FROM stg_sales;






USE defaultdb;

CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    segment VARCHAR(50)
);


DESCRIBE dim_customer;

INSERT INTO dim_customer (
    customer_name,
    segment
)
SELECT DISTINCT
    customer_name,
    segment
FROM stg_sales
WHERE customer_name IS NOT NULL;



SELECT COUNT(*)
FROM dim_customer;


SELECT *
FROM dim_customer
LIMIT 20;


SELECT
    customer_name,
    segment,
    COUNT(*) AS occurrences
FROM dim_customer
GROUP BY customer_name, segment
HAVING COUNT(*) > 1;

SELECT
    customer_name,
    COUNT(DISTINCT segment) AS segment_count
FROM stg_sales
GROUP BY customer_name
HAVING COUNT(DISTINCT segment) > 1;


SELECT
    product_id,
    COUNT(DISTINCT product_name) AS product_name_count
FROM stg_sales
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1;

SELECT
    product_id,
    COUNT(DISTINCT category) AS category_count,
    COUNT(DISTINCT sub_category) AS sub_category_count
FROM stg_sales
GROUP BY product_id
HAVING
    COUNT(DISTINCT category) > 1
    OR COUNT(DISTINCT sub_category) > 1;
    
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM stg_sales
WHERE product_id = 'OFF-AVE-10002102';


SELECT
    product_id,
    product_name,
    category,
    sub_category,
    COUNT(*) AS occurrences
FROM stg_sales
WHERE product_id = 'OFF-AVE-10002102'
GROUP BY
    product_id,
    product_name,
    category,
    sub_category
ORDER BY occurrences DESC;

SELECT
    product_id,
    COUNT(DISTINCT product_name) AS product_names
FROM stg_sales
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1
ORDER BY product_names DESC;


SELECT
    product_id,
    product_name,
    COUNT(DISTINCT category) AS category_count,
    COUNT(DISTINCT sub_category) AS subcategory_count
FROM stg_sales
GROUP BY
    product_id,
    product_name
HAVING
    COUNT(DISTINCT category) > 1
    OR COUNT(DISTINCT sub_category) > 1;
    
    
CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    sub_category VARCHAR(100),

    UNIQUE (product_id, product_name)
);

INSERT INTO dim_product (
    product_id,
    product_name,
    category,
    sub_category
)
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM stg_sales
WHERE product_id IS NOT NULL
  AND product_name IS NOT NULL;
  
  
SELECT COUNT(*) AS dimension_products
FROM dim_product;


SELECT COUNT(*) AS source_products
FROM (
    SELECT DISTINCT
        product_id,
        product_name
    FROM stg_sales
    WHERE product_id IS NOT NULL
      AND product_name IS NOT NULL
) AS products;

SELECT
    state,
    COUNT(DISTINCT country) AS countries
FROM stg_sales
GROUP BY state
HAVING COUNT(DISTINCT country) > 1;

SELECT COUNT(*) AS unique_locations
FROM (
    SELECT DISTINCT
        state,
        country,
        market,
        region
    FROM stg_sales
) AS locations;

CREATE TABLE dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,

    state VARCHAR(100),
    country VARCHAR(100),
    market VARCHAR(50),
    region VARCHAR(100),

    UNIQUE (state, country, market, region)
);


INSERT INTO dim_location (
    state,
    country,
    market,
    region
)
SELECT DISTINCT
    state,
    country,
    market,
    region
FROM stg_sales;

SELECT COUNT(*)
FROM dim_location;


SELECT *
FROM dim_location
LIMIT 20;

SELECT
    country,
    COUNT(DISTINCT market) AS market_count
FROM stg_sales
GROUP BY country
HAVING COUNT(DISTINCT market) > 1;

SELECT
    country,
    state,
    COUNT(DISTINCT region) AS region_count
FROM stg_sales
GROUP BY country, state
HAVING COUNT(DISTINCT region) > 1;SELECT
    country,
    state,
    COUNT(DISTINCT region) AS region_count
FROM stg_sales
GROUP BY country, state
HAVING COUNT(DISTINCT region) > 1;


SELECT DISTINCT
    country,
    market,
    region
FROM stg_sales
WHERE country IN (
    SELECT country
    FROM stg_sales
    GROUP BY country
    HAVING COUNT(DISTINCT market) > 1
)
ORDER BY country, market, region;

SELECT DISTINCT
    country,
    state,
    market,
    region
FROM stg_sales
WHERE (country, state) IN (
    SELECT country, state
    FROM stg_sales
    GROUP BY country, state
    HAVING COUNT(DISTINCT region) > 1
)
ORDER BY country, state, market, region;

SELECT COUNT(*) AS source_locations
FROM (
    SELECT DISTINCT
        state,
        country,
        market,
        region
    FROM stg_sales
) x;

SELECT COUNT(*) AS dimension_locations
FROM dim_location;

SELECT
    MIN(order_date) AS first_date,
    MAX(order_date) AS last_date
FROM stg_sales;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,

    year INT NOT NULL,
    quarter INT NOT NULL,
    month_number INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year_month_text VARCHAR(7) NOT NULL
);
INSERT INTO dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month_number,
    month_name,
    year_month_text
)
SELECT DISTINCT
    CAST(DATE_FORMAT(order_date, '%Y%m%d') AS UNSIGNED),
    order_date,
    YEAR(order_date),
    QUARTER(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    DATE_FORMAT(order_date, '%Y-%m')
FROM stg_sales
WHERE order_date IS NOT NULL;


SELECT *
FROM dim_date
ORDER BY full_date
LIMIT 20;

SELECT COUNT(DISTINCT order_date)
FROM stg_sales;
SELECT COUNT(*)
FROM dim_date;



CREATE TABLE fact_sales (
    sales_key BIGINT AUTO_INCREMENT PRIMARY KEY,

    order_id VARCHAR(50) NOT NULL,

    date_key INT,
    customer_key INT,
    product_key INT,
    location_key INT,

    ship_date DATE,
    ship_mode VARCHAR(50),
    order_priority VARCHAR(50),

    sales DECIMAL(15,2),
    quantity INT,
    discount DECIMAL(10,4),
    profit DECIMAL(15,2),
    shipping_cost DECIMAL(15,2),
    shipping_days INT,

    FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    FOREIGN KEY (product_key)
        REFERENCES dim_product(product_key),

    FOREIGN KEY (location_key)
        REFERENCES dim_location(location_key)
);

DESCRIBE fact_sales;

SELECT
    s.customer_name,
    s.segment,
    c.customer_key
FROM stg_sales s

LEFT JOIN dim_customer c
    ON s.customer_name = c.customer_name
    AND s.segment = c.segment

LIMIT 20;


SELECT COUNT(*) AS unmatched_customers
FROM stg_sales s

LEFT JOIN dim_customer c
    ON s.customer_name = c.customer_name
    AND s.segment = c.segment

WHERE c.customer_key IS NULL;


SELECT
    s.product_id,
    s.product_name,
    p.product_key
FROM stg_sales s

LEFT JOIN dim_product p
    ON s.product_id = p.product_id
    AND s.product_name = p.product_name

LIMIT 20;



SELECT COUNT(*) AS unmatched_products
FROM stg_sales s

LEFT JOIN dim_product p
    ON s.product_id = p.product_id
    AND s.product_name = p.product_name

WHERE p.product_key IS NULL;


SELECT
    s.state,
    s.country,
    s.market,
    s.region,
    l.location_key
FROM stg_sales s

LEFT JOIN dim_location l
    ON s.state = l.state
    AND s.country = l.country
    AND s.market = l.market
    AND s.region = l.region

LIMIT 20;


SELECT COUNT(*) AS unmatched_locations
FROM stg_sales s

LEFT JOIN dim_location l
    ON s.state = l.state
    AND s.country = l.country
    AND s.market = l.market
    AND s.region = l.region

WHERE l.location_key IS NULL;

SELECT
    s.order_date,
    d.date_key
FROM stg_sales s

LEFT JOIN dim_date d
    ON s.order_date = d.full_date

LIMIT 20;

SELECT COUNT(*) AS unmatched_dates
FROM stg_sales s

LEFT JOIN dim_date d
    ON s.order_date = d.full_date

WHERE d.date_key IS NULL;


INSERT INTO fact_sales (
    order_id,
    date_key,
    customer_key,
    product_key,
    location_key,
    ship_date,
    ship_mode,
    order_priority,
    sales,
    quantity,
    discount,
    profit,
    shipping_cost,
    shipping_days
)

SELECT
    s.order_id,
    d.date_key,
    c.customer_key,
    p.product_key,
    l.location_key,
    s.ship_date,
    s.ship_mode,
    s.order_priority,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    s.shipping_cost,
    s.shipping_days

FROM stg_sales s

JOIN dim_customer c
    ON s.customer_name = c.customer_name
    AND s.segment = c.segment

JOIN dim_product p
    ON s.product_id = p.product_id
    AND s.product_name = p.product_name

JOIN dim_location l
    ON s.state = l.state
    AND s.country = l.country
    AND s.market = l.market
    AND s.region = l.region

JOIN dim_date d
    ON s.order_date = d.full_date;
    
    
SELECT COUNT(*) AS fact_rows
FROM fact_sales;

SELECT COUNT(*) AS staging_rows
FROM stg_sales;


SELECT *
FROM fact_sales
LIMIT 10;


SELECT
    f.order_id,
    d.full_date AS order_date,

    c.customer_name,
    c.segment,

    p.product_name,
    p.category,
    p.sub_category,

    l.country,
    l.market,
    l.region,

    f.sales,
    f.profit

FROM fact_sales f

JOIN dim_customer c
    ON f.customer_key = c.customer_key
JOIN dim_product p
    ON f.product_key = p.product_key
JOIN dim_location l
    ON f.location_key = l.location_key
JOIN dim_date d
    ON f.date_key = d.date_key
LIMIT 20;

SELECT
    ROUND(SUM(sales), 2) AS staging_sales,
    ROUND(SUM(profit), 2) AS staging_profit,
    SUM(quantity) AS staging_quantity
FROM stg_sales;

SELECT
    ROUND(SUM(sales), 2) AS fact_sales,
    ROUND(SUM(profit), 2) AS fact_profit,
    SUM(quantity) AS fact_quantity
FROM fact_sales;


SELECT
    SUM(customer_key IS NULL) AS missing_customer,
    SUM(product_key IS NULL) AS missing_product,
    SUM(location_key IS NULL) AS missing_location,
    SUM(date_key IS NULL) AS missing_date
FROM fact_sales;


SELECT
    p.category,
    ROUND(SUM(f.sales), 2) AS total_revenue,
    ROUND(SUM(f.profit), 2) AS total_profit
FROM fact_sales f

JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

#DATA WAREHOUSING DONE










#SQL Revenue Analytics




SELECT
    ROUND(SUM(sales), 2) AS total_revenue
FROM fact_sales;

SELECT
    ROUND(SUM(profit), 2) AS total_profit
FROM fact_sales;

SELECT
    ROUND(
        SUM(profit) * 100.0 / NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_pct
FROM fact_sales;


SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM fact_sales;

SELECT
    SUM(quantity) AS total_units_sold
FROM fact_sales;


SELECT
    ROUND(
        SUM(sales) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM fact_sales;



SELECT
    ROUND(SUM(sales), 2) AS total_revenue,

    ROUND(SUM(profit), 2) AS total_profit,

    ROUND(
        SUM(profit) * 100.0 /
        NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_pct,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity) AS total_units_sold,

    ROUND(
        SUM(sales) /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value

FROM fact_sales;


SELECT
    d.year,
    ROUND(SUM(f.sales), 2) AS revenue
FROM fact_sales f

JOIN dim_date d
    ON f.date_key = d.date_key

GROUP BY d.year
ORDER BY d.year;


SELECT
    d.year,
    d.month_number,
    d.month_name,
    ROUND(SUM(f.sales), 2) AS monthly_revenue
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month_number,
    d.month_name
ORDER BY
    d.year,
    d.month_number;
#MONTH OVER MONTH REVENUE GROWTH


WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_number,
        d.month_name
)
SELECT *
FROM monthly_sales
ORDER BY year, month_number;




WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_number,
        d.month_name
)

SELECT
    year,
    month_number,
    month_name,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        LAG(revenue) OVER (
            ORDER BY year, month_number
        ),
        2
    ) AS previous_month_revenue
FROM monthly_sales
ORDER BY year, month_number;


WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_number,
        d.month_name
),

revenue_with_previous AS (
    SELECT
        year,
        month_number,
        month_name,
        revenue,

        LAG(revenue) OVER (
            ORDER BY year, month_number
        ) AS previous_month_revenue

    FROM monthly_sales
)

SELECT
    year,
    month_number,
    month_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2)
        AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct
FROM revenue_with_previous
ORDER BY year, month_number;



#YOY REVENUE GROWTH


WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_number,
        d.month_name
)
SELECT *
FROM monthly_sales
ORDER BY year, month_number;


WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        d.year,
        d.month_number,
        d.month_name
)

SELECT
    year,
    month_number,
    month_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        LAG(revenue, 12) OVER (
            ORDER BY year, month_number
        ),
        2
    ) AS previous_year_revenue
FROM monthly_sales
ORDER BY year, month_number;


WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        d.year,
        d.month_number,
        d.month_name
),

yoy_data AS (
    SELECT
        year,
        month_number,
        month_name,
        revenue,

        LAG(revenue, 12) OVER (
            ORDER BY year, month_number
        ) AS previous_year_revenue

    FROM monthly_sales
)

SELECT
    year,
    month_number,
    month_name,

    ROUND(revenue, 2) AS revenue,

    ROUND(previous_year_revenue, 2)
        AS previous_year_revenue,

    ROUND(
        (revenue - previous_year_revenue)
        * 100.0 /
        NULLIF(previous_year_revenue, 0),
        2
    ) AS yoy_growth_pct
FROM yoy_data
ORDER BY year, month_number;




WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        d.year,
        d.month_number,
        d.month_name
),

growth_data AS (
    SELECT
        year,
        month_number,
        month_name,
        revenue,

        LAG(revenue) OVER (
            ORDER BY year, month_number
        ) AS previous_month_revenue,

        LAG(revenue, 12) OVER (
            ORDER BY year, month_number
        ) AS previous_year_revenue

    FROM monthly_sales
)

SELECT
    year,
    month_number,
    month_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        (revenue - previous_month_revenue)
        * 100.0 /
        NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct,
    ROUND(
        (revenue - previous_year_revenue)
        * 100.0 /
        NULLIF(previous_year_revenue, 0),
        2
    ) AS yoy_growth_pct
FROM growth_data
ORDER BY year, month_number;

#Running Revenue + Moving Average


WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_number,
        d.month_name
)

SELECT
    year,
    month_number,
    month_name,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        SUM(revenue) OVER (
            ORDER BY year, month_number
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ),
        2
    ) AS running_revenue

FROM monthly_sales
ORDER BY year, month_number;








WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_number,
        d.month_name
)

SELECT
    year,
    month_number,
    month_name,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        SUM(revenue) OVER (
            PARTITION BY year
            ORDER BY month_number
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ),
        2
    ) AS ytd_revenue

FROM monthly_sales
ORDER BY year, month_number;









WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_number,
        d.month_name
)

SELECT
    year,
    month_number,
    month_name,

    ROUND(revenue, 2) AS revenue,

    ROUND(
        AVG(revenue) OVER (
            ORDER BY year, month_number
            ROWS BETWEEN 2 PRECEDING
                     AND CURRENT ROW
        ),
        2
    ) AS moving_avg_3_month

FROM monthly_sales
ORDER BY year, month_number;



WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month_number,
        d.month_name
)

SELECT
    year,
    month_number,
    month_name,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        AVG(revenue) OVER (
            ORDER BY year, month_number
            ROWS BETWEEN 3 PRECEDING
                     AND 1 PRECEDING
        ),
        2
    ) AS previous_3_month_avg
FROM monthly_sales
ORDER BY year, month_number;








SELECT
    p.category,
    ROUND(SUM(f.sales), 2) AS revenue,
    ROUND(
        SUM(f.sales) * 100.0 /
        SUM(SUM(f.sales)) OVER (),
        2
    ) AS revenue_contribution_pct
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC;






SELECT
    p.category,
    ROUND(SUM(f.sales), 2) AS revenue,
    ROUND(
        SUM(f.sales) * 100.0 /
        SUM(SUM(f.sales)) OVER (),
        2
    ) AS revenue_contribution_pct,
    DENSE_RANK() OVER (
        ORDER BY SUM(f.sales) DESC
    ) AS revenue_rank
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue_rank;




SELECT
    l.market,
    ROUND(SUM(f.sales), 2) AS revenue,
    ROUND(
        SUM(f.sales) * 100.0 /
        SUM(SUM(f.sales)) OVER (),
        2
    ) AS revenue_contribution_pct,
    DENSE_RANK() OVER (
        ORDER BY SUM(f.sales) DESC
    ) AS revenue_rank
FROM fact_sales f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.market
ORDER BY revenue_rank;










SELECT
    l.market,
    l.region,
    ROUND(SUM(f.sales), 2) AS revenue,
    DENSE_RANK() OVER (
        PARTITION BY l.market
        ORDER BY SUM(f.sales) DESC
    ) AS region_rank
FROM fact_sales f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY
    l.market,
    l.region
ORDER BY
    l.market,
    region_rank;
    
    
    
SELECT
    p.product_name,

    ROUND(SUM(f.sales), 2) AS revenue,

    ROUND(SUM(f.profit), 2) AS profit,

    DENSE_RANK() OVER (
        ORDER BY SUM(f.sales) DESC
    ) AS revenue_rank
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_key,
    p.product_name
ORDER BY revenue_rank
LIMIT 5;






WITH product_performance AS (
    SELECT
        p.category,
        p.product_key,
        p.product_name,
        SUM(f.sales) AS revenue,

        DENSE_RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(f.sales) DESC
        ) AS product_rank

    FROM fact_sales f

    JOIN dim_product p
        ON f.product_key = p.product_key

    GROUP BY
        p.category,
        p.product_key,
        p.product_name
)

SELECT
    category,
    product_name,
    ROUND(revenue, 2) AS revenue,
    product_rank
FROM product_performance
WHERE product_rank <= 5
ORDER BY
    category,
    product_rank;
    
    
#Profitability & Loss Analysis.





#1.overall profablity


SELECT
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) * 100.0 /
        NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_pct
FROM fact_sales;



#Profitability by category


SELECT
    p.category,

    ROUND(SUM(f.sales), 2) AS revenue,
    ROUND(SUM(f.profit), 2) AS profit,

    ROUND(
        SUM(f.profit) * 100.0 /
        NULLIF(SUM(f.sales), 0),
        2
    ) AS profit_margin_pct
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY profit DESC;



#Find loss-making products


SELECT
    p.product_key,
    p.product_name,
    p.category,

    ROUND(SUM(f.sales), 2) AS revenue,
    ROUND(SUM(f.profit), 2) AS profit

FROM fact_sales f

JOIN dim_product p
    ON f.product_key = p.product_key

GROUP BY
    p.product_key,
    p.product_name,
    p.category
HAVING SUM(f.profit) < 0
ORDER BY profit ASC;



#High-revenue but low-profit products
WITH product_performance AS (
    SELECT
        p.product_key,
        p.product_name,
        p.category,

        SUM(f.sales) AS revenue,
        SUM(f.profit) AS profit,

        SUM(f.profit) * 100.0 /
        NULLIF(SUM(f.sales), 0) AS profit_margin_pct

    FROM fact_sales f

    JOIN dim_product p
        ON f.product_key = p.product_key

    GROUP BY
        p.product_key,
        p.product_name,
        p.category
)

SELECT
    product_name,
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit,
    ROUND(profit_margin_pct, 2) AS profit_margin_pct
FROM product_performance
WHERE revenue > (
    SELECT AVG(revenue)
    FROM product_performance
)
AND profit_margin_pct < 5
ORDER BY revenue DESC;




#Discount impact analysis
SELECT
    CASE
        WHEN discount = 0
            THEN 'No Discount'

        WHEN discount <= 0.10
            THEN '1-10%'

        WHEN discount <= 0.20
            THEN '11-20%'

        WHEN discount <= 0.30
            THEN '21-30%'

        ELSE 'Above 30%'
    END AS discount_band,

    ROUND(SUM(sales), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(
        SUM(profit) * 100.0 /
        NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_pct
FROM fact_sales
GROUP BY discount_band
ORDER BY
    MIN(discount);
    
    
#Loss-making order lines


SELECT
    COUNT(*) AS total_order_lines,
    SUM(
        CASE
            WHEN profit < 0 THEN 1
            ELSE 0
        END
    ) AS loss_making_lines,
    ROUND(
        SUM(
            CASE
                WHEN profit < 0 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS loss_line_pct
FROM fact_sales;

#Profitability by market
SELECT
    l.market,

    ROUND(SUM(f.sales), 2) AS revenue,
    ROUND(SUM(f.profit), 2) AS profit,

    ROUND(
        SUM(f.profit) * 100.0 /
        NULLIF(SUM(f.sales), 0),
        2
    ) AS profit_margin_pct,

    DENSE_RANK() OVER (
        ORDER BY SUM(f.profit) DESC
    ) AS profit_rank
FROM fact_sales f
JOIN dim_location l
    ON f.location_key = l.location_key
GROUP BY l.market
ORDER BY profit_rank;






#Revenue Decline & Root-Cause Analysis


# Months Where Revenue Declined

WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_number,
        d.month_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    GROUP BY
        d.year,
        d.month_number,
        d.month_name
),

monthly_change AS (
    SELECT
        year,
        month_number,
        month_name,
        revenue,

        LAG(revenue) OVER (
            ORDER BY year, month_number
        ) AS previous_month_revenue

    FROM monthly_sales
)

SELECT
    year,
    month_number,
    month_name,

    ROUND(revenue, 2) AS current_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,

    ROUND(
        revenue - previous_month_revenue,
        2
    ) AS revenue_change,

    ROUND(
        (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct

FROM monthly_change
WHERE revenue < previous_month_revenue
ORDER BY year, month_number;





WITH market_monthly AS (
    SELECT
        d.year,
        d.month_number,
        l.market,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_location l
        ON f.location_key = l.location_key

    WHERE
        (d.year = 2014 AND d.month_number = 6)
        OR
        (d.year = 2014 AND d.month_number = 7)

    GROUP BY
        d.year,
        d.month_number,
        l.market
),

market_comparison AS (
    SELECT
        market,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 6
                THEN revenue
                ELSE 0
            END
        ) AS previous_month_revenue,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 7
                THEN revenue
                ELSE 0
            END
        ) AS current_month_revenue

    FROM market_monthly

    GROUP BY market
)

SELECT
    market,
    ROUND(previous_month_revenue, 2)
        AS previous_month_revenue,
    ROUND(current_month_revenue, 2)
        AS current_month_revenue,
    ROUND(
        current_month_revenue - previous_month_revenue,
        2
    ) AS revenue_change
FROM market_comparison
ORDER BY revenue_change;





WITH market_monthly AS (
    SELECT
        d.year,
        d.month_number,
        l.market,
        SUM(f.sales) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    JOIN dim_location l
        ON f.location_key = l.location_key

    WHERE
        (d.year = 2014 AND d.month_number = 6)
        OR
        (d.year = 2014 AND d.month_number = 7)

    GROUP BY
        d.year,
        d.month_number,
        l.market
),

comparison AS (
    SELECT
        market,

        SUM(CASE
            WHEN year = 2014 AND month_number = 6
            THEN revenue ELSE 0
        END) AS previous_revenue,

        SUM(CASE
            WHEN year = 2014 AND month_number = 7
            THEN revenue ELSE 0
        END) AS current_revenue

    FROM market_monthly
    GROUP BY market
),

changes AS (
    SELECT
        market,
        previous_revenue,
        current_revenue,
        current_revenue - previous_revenue AS revenue_change
    FROM comparison
)

SELECT
    market,

    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(current_revenue, 2) AS current_revenue,
    ROUND(revenue_change, 2) AS revenue_change,

    ROUND(
        ABS(revenue_change) * 100.0 /
        NULLIF(
            SUM(
                CASE
                    WHEN revenue_change < 0
                    THEN ABS(revenue_change)
                    ELSE 0
                END
            ) OVER (),
            0
        ),
        2
    ) AS decline_contribution_pct
FROM changes
WHERE revenue_change < 0
ORDER BY revenue_change;




# Market Root Cause

WITH market_monthly AS (
    SELECT
        d.year,
        d.month_number,
        l.market,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_location l
        ON f.location_key = l.location_key

    WHERE
        (d.year = 2014 AND d.month_number = 6)
        OR
        (d.year = 2014 AND d.month_number = 7)

    GROUP BY
        d.year,
        d.month_number,
        l.market
),

market_comparison AS (
    SELECT
        market,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 6
                THEN revenue
                ELSE 0
            END
        ) AS previous_revenue,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 7
                THEN revenue
                ELSE 0
            END
        ) AS current_revenue

    FROM market_monthly
    GROUP BY market
)

SELECT
    market,

    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(current_revenue, 2) AS current_revenue,

    ROUND(
        current_revenue - previous_revenue,
        2
    ) AS revenue_change,

    ROUND(
        (current_revenue - previous_revenue) * 100.0 /
        NULLIF(previous_revenue, 0),
        2
    ) AS growth_pct
FROM market_comparison
ORDER BY revenue_change;







# Region Root Cause

WITH region_monthly AS (
    SELECT
        d.year,
        d.month_number,
        l.region,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_location l
        ON f.location_key = l.location_key

    WHERE l.market = 'APAC'
      AND (
            (d.year = 2014 AND d.month_number = 6)
            OR
            (d.year = 2014 AND d.month_number = 7)
          )

    GROUP BY
        d.year,
        d.month_number,
        l.region
),

region_comparison AS (
    SELECT
        region,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 6
                THEN revenue
                ELSE 0
            END
        ) AS previous_revenue,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 7
                THEN revenue
                ELSE 0
            END
        ) AS current_revenue

    FROM region_monthly

    GROUP BY region
)

SELECT
    region,

    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(current_revenue, 2) AS current_revenue,
    ROUND(
        current_revenue - previous_revenue,
        2
    ) AS revenue_change,
    ROUND(
        (current_revenue - previous_revenue) * 100.0 /
        NULLIF(previous_revenue, 0),
        2
    ) AS growth_pct
FROM region_comparison
ORDER BY revenue_change;










# Category Root Cause

WITH category_monthly AS (
    SELECT
        d.year,
        d.month_number,
        p.category,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_location l
        ON f.location_key = l.location_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE l.market = 'APAC'
      AND l.region = 'Oceania'
      AND (
            (d.year = 2014 AND d.month_number = 6)
            OR
            (d.year = 2014 AND d.month_number = 7)
          )

    GROUP BY
        d.year,
        d.month_number,
        p.category
),

category_comparison AS (
    SELECT
        category,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 6
                THEN revenue
                ELSE 0
            END
        ) AS previous_revenue,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 7
                THEN revenue
                ELSE 0
            END
        ) AS current_revenue

    FROM category_monthly

    GROUP BY category
)

SELECT
    category,

    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(current_revenue, 2) AS current_revenue,

    ROUND(
        current_revenue - previous_revenue,
        2
    ) AS revenue_change,
    ROUND(
        (current_revenue - previous_revenue) * 100.0 /
        NULLIF(previous_revenue, 0),
        2
    ) AS growth_pct
FROM category_comparison
ORDER BY revenue_change;






# Sub-Category Root Cause

WITH subcategory_monthly AS (
    SELECT
        d.year,
        d.month_number,
        p.sub_category,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_location l
        ON f.location_key = l.location_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE l.market = 'APAC'
      AND l.region = 'Oceania'
      AND p.category = 'Technology'
      AND (
            (d.year = 2014 AND d.month_number = 6)
            OR
            (d.year = 2014 AND d.month_number = 7)
          )

    GROUP BY
        d.year,
        d.month_number,
        p.sub_category
),

subcategory_comparison AS (
    SELECT
        sub_category,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 6
                THEN revenue
                ELSE 0
            END
        ) AS previous_revenue,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 7
                THEN revenue
                ELSE 0
            END
        ) AS current_revenue

    FROM subcategory_monthly

    GROUP BY sub_category
)

SELECT
    sub_category,

    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(current_revenue, 2) AS current_revenue,

    ROUND(
        current_revenue - previous_revenue,
        2
    ) AS revenue_change,

    ROUND(
        (current_revenue - previous_revenue) * 100.0 /
        NULLIF(previous_revenue, 0),
        2
    ) AS growth_pct
FROM subcategory_comparison
ORDER BY revenue_change;




# Product Root Cause

WITH product_monthly AS (
    SELECT
        d.year,
        d.month_number,
        p.product_key,
        p.product_name,
        SUM(f.sales) AS revenue
    FROM fact_sales f

    JOIN dim_date d
        ON f.date_key = d.date_key

    JOIN dim_location l
        ON f.location_key = l.location_key

    JOIN dim_product p
        ON f.product_key = p.product_key

    WHERE l.market = 'APAC'
      AND l.region = 'Oceania'
      AND p.category = 'Technology'
      AND p.sub_category = 'Phones'
      AND (
            (d.year = 2014 AND d.month_number = 6)
            OR
            (d.year = 2014 AND d.month_number = 7)
          )

    GROUP BY
        d.year,
        d.month_number,
        p.product_key,
        p.product_name
),

product_comparison AS (
    SELECT
        product_key,
        product_name,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 6
                THEN revenue
                ELSE 0
            END
        ) AS previous_revenue,

        SUM(
            CASE
                WHEN year = 2014 AND month_number = 7
                THEN revenue
                ELSE 0
            END
        ) AS current_revenue

    FROM product_monthly

    GROUP BY
        product_key,
        product_name
)
SELECT
    product_name,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(current_revenue, 2) AS current_revenue,
    ROUND(
        current_revenue - previous_revenue,
        2
    ) AS revenue_change,
    ROUND(
        (current_revenue - previous_revenue) * 100.0 /
        NULLIF(previous_revenue, 0),
        2
    ) AS growth_pct
FROM product_comparison
ORDER BY revenue_change;



# Check Fact Sales Columns

DESCRIBE fact_sales;



# Check Date Dimension Columns

DESCRIBE dim_date;
# Check fact_sales date_key

SELECT
    date_key
FROM fact_sales
LIMIT 10;
# Check dim_date full_date

SELECT
    full_date
FROM dim_date
LIMIT 10;
# Test the join

SELECT
    COUNT(*) AS matched_rows
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.full_date;
    
    
    
    
    
# Check fact_sales date_key values

SELECT date_key
FROM fact_sales
LIMIT 10;
# Test Corrected Date Join

SELECT COUNT(*) AS matched_rows
FROM fact_sales f
JOIN dim_date d
    ON STR_TO_DATE(
        CAST(f.date_key AS CHAR),
        '%Y%m%d'
    ) = d.full_date;
    
    
    
DESCRIBE dim_product;
DESCRIBE dim_location;
DESCRIBE dim_customer;
DESCRIBE dim_date;

# Check dim_date full_date values

SELECT full_date
FROM dim_date
LIMIT 10;
