-- ============================================================
-- Olist E-commerce Customer Segmentation & Retention Analysis
-- File: olist_analysis_queries.sql
-- Database: olist_ecommerce
--
-- Assumed table names in the imported database:
-- customers, orders, order_items, payments, reviews,
-- products, sellers, geolocation, category_translation
--
-- Notes:
-- 1. Run this script after selecting/importing the database.
-- 2. The RFM query uses delivered orders only.
-- 3. Monetary value is SUM(order_items.price), excluding freight.
-- 4. Review data can contain multiple review rows per order.
-- ============================================================

USE olist_ecommerce;


-- ============================================================
-- 1. DATASET OVERVIEW
-- ============================================================

-- 1.1 Row counts for the main tables
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;


-- 1.2 Order status distribution
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- 1.3 Orders by purchase year and month
SELECT
    YEAR(order_purchase_timestamp) AS purchase_year,
    MONTH(order_purchase_timestamp) AS purchase_month,
    COUNT(*) AS order_count
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY purchase_year, purchase_month;


-- ============================================================
-- 2. DATA QUALITY CHECKS
-- ============================================================

-- 2.1 Duplicate primary-key checks
SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id, order_item_id, COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Reviews may contain more than one review row per order.
-- Check duplicate review_id + order_id pairs, not order_id alone.
SELECT review_id, order_id, COUNT(*) AS duplicate_count
FROM reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;


-- 2.2 Orders without a matching customer
SELECT COUNT(*) AS orders_without_customer
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 2.3 Order items without a matching order
SELECT COUNT(*) AS items_without_order
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 2.4 Missing delivery and purchase timestamps
SELECT
    SUM(order_purchase_timestamp IS NULL) AS missing_purchase_timestamp,
    SUM(order_delivered_customer_date IS NULL) AS missing_delivery_timestamp,
    SUM(order_estimated_delivery_date IS NULL) AS missing_estimated_delivery
FROM orders;


-- 2.5 Chronology checks
-- These are validation counts; do not delete records automatically.
SELECT
    SUM(
        order_approved_at IS NOT NULL
        AND order_purchase_timestamp IS NOT NULL
        AND order_approved_at < order_purchase_timestamp
    ) AS approval_before_purchase,
    SUM(
        order_delivered_carrier_date IS NOT NULL
        AND order_approved_at IS NOT NULL
        AND order_delivered_carrier_date < order_approved_at
    ) AS carrier_before_approval,
    SUM(
        order_delivered_customer_date IS NOT NULL
        AND order_delivered_carrier_date IS NOT NULL
        AND order_delivered_customer_date < order_delivered_carrier_date
    ) AS customer_delivery_before_carrier
FROM orders;


-- ============================================================
-- 3. CUSTOMER AND REVENUE ANALYSIS
-- ============================================================

-- 3.1 Number of unique customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customer_count
FROM customers;


-- 3.2 Total item revenue (excludes freight)
SELECT
    ROUND(SUM(price), 2) AS total_item_revenue
FROM order_items;


-- 3.3 Average item revenue per delivered customer
-- First aggregate item revenue by order to avoid join duplication.
WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price) AS order_item_revenue
    FROM order_items
    GROUP BY order_id
),
customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(orv.order_item_revenue) AS customer_monetary
    FROM orders o
    INNER JOIN customers c
        ON o.customer_id = c.customer_id
    INNER JOIN order_revenue orv
        ON o.order_id = orv.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS delivered_customer_count,
    ROUND(SUM(customer_monetary), 2) AS delivered_item_revenue,
    ROUND(AVG(customer_monetary), 2) AS average_customer_monetary
FROM customer_revenue;


-- 3.4 Revenue by product category
SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS item_revenue
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY item_revenue DESC
LIMIT 20;


-- 3.5 Payment type distribution
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- ============================================================
-- 4. CUSTOMER PURCHASE BEHAVIOUR
-- ============================================================

-- 4.1 One-time customers vs repeat customers
WITH customer_order_frequency AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS frequency
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN frequency = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS purchase_type,
    COUNT(*) AS customer_count
FROM customer_order_frequency
GROUP BY
    CASE
        WHEN frequency = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END;


-- 4.2 Distribution of delivered purchase frequency
WITH customer_order_frequency AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS frequency
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    frequency,
    COUNT(*) AS customer_count
FROM customer_order_frequency
GROUP BY frequency
ORDER BY frequency;


-- ============================================================
-- 5. RFM ANALYSIS
-- ============================================================

-- Recency is measured in calendar days from each customer's
-- latest delivered date to the day after the latest delivered
-- date in the dataset. Frequency counts delivered orders.
-- Monetary sums item prices and excludes freight.
--
-- This query provides customer-level RFM values. It does not
-- perform K-Means clustering; clustering was performed in Python.

WITH delivered_order_revenue AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_delivered_customer_date,
        SUM(oi.price) AS order_item_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_delivered_customer_date
),
reference_date AS (
    SELECT
        DATE_ADD(
            MAX(DATE(order_delivered_customer_date)),
            INTERVAL 1 DAY
        ) AS analysis_date
    FROM delivered_order_revenue
),
customer_rfm AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(
            r.analysis_date,
            MAX(DATE(dor.order_delivered_customer_date))
        ) AS recency,
        COUNT(DISTINCT dor.order_id) AS frequency,
        ROUND(SUM(dor.order_item_revenue), 2) AS monetary
    FROM delivered_order_revenue dor
    INNER JOIN customers c
        ON dor.customer_id = c.customer_id
    CROSS JOIN reference_date r
    GROUP BY
        c.customer_unique_id,
        r.analysis_date
)
SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary
FROM customer_rfm
ORDER BY monetary DESC;


-- 5.1 RFM summary statistics
WITH delivered_order_revenue AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_delivered_customer_date,
        SUM(oi.price) AS order_item_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_delivered_customer_date
),
reference_date AS (
    SELECT
        DATE_ADD(
            MAX(DATE(order_delivered_customer_date)),
            INTERVAL 1 DAY
        ) AS analysis_date
    FROM delivered_order_revenue
),
customer_rfm AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(
            r.analysis_date,
            MAX(DATE(dor.order_delivered_customer_date))
        ) AS recency,
        COUNT(DISTINCT dor.order_id) AS frequency,
        SUM(dor.order_item_revenue) AS monetary
    FROM delivered_order_revenue dor
    INNER JOIN customers c
        ON dor.customer_id = c.customer_id
    CROSS JOIN reference_date r
    GROUP BY c.customer_unique_id, r.analysis_date
)
SELECT
    COUNT(*) AS customer_count,
    ROUND(AVG(recency), 2) AS average_recency,
    ROUND(AVG(frequency), 2) AS average_frequency,
    ROUND(AVG(monetary), 2) AS average_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary
FROM customer_rfm;


-- ============================================================
-- 6. DELIVERY PERFORMANCE
-- ============================================================

-- Delay days = actual delivered calendar date minus estimated
-- delivery calendar date. Negative means early; positive means late.
SELECT
    CASE
        WHEN DATEDIFF(
            DATE(order_delivered_customer_date),
            DATE(order_estimated_delivery_date)
        ) < 0 THEN 'Early'
        WHEN DATEDIFF(
            DATE(order_delivered_customer_date),
            DATE(order_estimated_delivery_date)
        ) = 0 THEN 'On-Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS order_count,
    ROUND(AVG(
        DATEDIFF(
            DATE(order_delivered_customer_date),
            DATE(order_estimated_delivery_date)
        )
    ), 2) AS average_delay_days
FROM orders
WHERE
    order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status
ORDER BY
    CASE delivery_status
        WHEN 'Early' THEN 1
        WHEN 'On-Time' THEN 2
        WHEN 'Late' THEN 3
    END;


-- ============================================================
-- 7. CUSTOMER REVIEW AND SATISFACTION ANALYSIS
-- ============================================================

-- 7.1 Review score distribution
SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM reviews),
        2
    ) AS review_percentage
FROM reviews
GROUP BY review_score
ORDER BY review_score;


-- 7.2 Average review score by delivery status
-- Aggregate reviews by order first because an order may have
-- more than one review row.
WITH order_review_scores AS (
    SELECT
        order_id,
        AVG(review_score) AS average_review_score
    FROM reviews
    GROUP BY order_id
),
order_delivery AS (
    SELECT
        order_id,
        CASE
            WHEN DATEDIFF(
                DATE(order_delivered_customer_date),
                DATE(order_estimated_delivery_date)
            ) < 0 THEN 'Early'
            WHEN DATEDIFF(
                DATE(order_delivered_customer_date),
                DATE(order_estimated_delivery_date)
            ) = 0 THEN 'On-Time'
            ELSE 'Late'
        END AS delivery_status
    FROM orders
    WHERE
        order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
        AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    od.delivery_status,
    COUNT(*) AS reviewed_order_count,
    ROUND(AVG(ors.average_review_score), 2) AS average_satisfaction
FROM order_delivery od
INNER JOIN order_review_scores ors
    ON od.order_id = ors.order_id
GROUP BY od.delivery_status
ORDER BY average_satisfaction DESC;


-- 7.3 Negative review rate by score (1 or 2)
SELECT
    COUNT(*) AS total_reviews,
    SUM(review_score IN (1, 2)) AS negative_reviews,
    ROUND(
        100.0 * SUM(review_score IN (1, 2)) / COUNT(*),
        2
    ) AS negative_review_rate_percentage
FROM reviews;


-- ============================================================
-- END OF ANALYSIS QUERIES
-- ============================================================
