--1--
CREATE VIEW high_value_customers AS
SELECT c.customer_id,
       c.customer_name,
       SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT COUNT(*)
FROM high_value_customers;

--2--
CREATE VIEW regional_monthly_sales AS
SELECT c.region,
       DATE_TRUNC('month', o.order_date) AS month,
       SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region, DATE_TRUNC('month', o.order_date);

SELECT *
FROM regional_monthly_sales
WHERE region = 'West';

--3--
CREATE VIEW analyst_orders AS
SELECT order_id,
       customer_id,
       product_id,
       sales,
       quantity,
       discount
FROM orders;

SELECT profit FROM orders;


--4--
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';
--5--
SELECT DATE_TRUNC('month', order_date) AS month,
       SUM(sales) AS monthly_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month ASC;
--6--
SELECT c.customer_name,
       o.order_id,
       o.order_date,
       o.profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.region = 'West'
  AND o.order_date >= '2024-01-01';
--7--
CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales DECIMAL(10,2);
BEGIN
    SELECT SUM(sales)
    INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Customer ID: %, Total Sales: %', p_customer_id, v_total_sales;
END;
$$;
CALL get_customer_sales('C001');

--9--
--10--
CREATE OR REPLACE PROCEDURE apply_regional_discount(
    p_region_name VARCHAR,
    p_discount_rate DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - p_discount_rate)
    WHERE region = p_region_name;

    RAISE NOTICE 'Applied discount of % to region %', p_discount_rate, p_region_name;
END;
$$;
CALL apply_regional_discount('West', 0.10);
CALL apply_regional_discount('West', 0.10);

--11--
CREATE OR REPLACE PROCEDURE get_sales_between(
    p_start_date DATE,
    p_end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales DECIMAL(10,2);
BEGIN
    SELECT SUM(sales)
    INTO v_total_sales
    FROM orders
    WHERE order_date BETWEEN p_start_date AND p_end_date;

    RAISE NOTICE 'Start date: %, End date: %, Total sales: %',
                 p_start_date, p_end_date, v_total_sales;
END;
$$;
CALL get_sales_between('2024-01-01', '2024-03-31');