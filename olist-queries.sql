-- ==============================================
-- Project: Olist E-Commerce Database
-- Author: Greg Lauray
-- Date: April 2026
-- Description: Brazilian e-commerce dataset analysis
--              covering customers, orders, products,
--              sellers, payments and reviews
-- ==============================================

use olist;
select * from orderitems;



-- This query returns the top 5 states with the most customers. We extract SP as the top query which is relevant for the query beloe
SELECT 
	customer_state,
    count(*) customer_count 
FROM customers
group by customer_state
order by customer_count desc
limit 5;


-- This query return the top 5 categories in the state with the most customers(SP)
WITH top_categories_by_city AS (
    SELECT 
        c.customer_city,
        ct.product_category_name,
        COUNT(*) AS frequency,
        DENSE_RANK() OVER (
            PARTITION BY c.customer_city 
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM customers c
    INNER JOIN orders o      ON c.customer_id = o.customer_id
    INNER JOIN orderitems oi ON oi.order_id = o.order_id
    INNER JOIN products p    ON p.product_id = oi.product_id
    INNER JOIN category ct   ON ct.category_id = p.category_id
    WHERE c.customer_state = 'SP'
    GROUP BY c.customer_city, ct.product_category_name
)
SELECT *
FROM top_categories_by_city
WHERE rnk <= 5
ORDER BY customer_city, rnk;


-- Q3


-- This query returns products in each with an average review score below 3
SELECT
    p.product_id,
    ct.product_category_name,
    COUNT(r.review_score) AS review_count,
    MIN(r.review_score) AS min_review_score,
    MAX(r.review_score) AS max_review_score,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews r
INNER JOIN orderitems oi ON oi.order_id = r.order_id
INNER JOIN products p    ON p.product_id = oi.product_id
INNER JOIN category ct   ON ct.category_id = p.category_id
GROUP BY p.product_id, ct.product_category_name
HAVING AVG(r.review_score) < 3
   AND COUNT(r.review_score) >= 10
ORDER BY avg_review_score ASC;









-- this query returns which sellers have the best reviews by state
WITH seller_state_performance AS (
    SELECT 
        oi.seller_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT CASE 
            WHEN o.order_delivered_customer_date <= o.order_estimated_deleivery_date 
            THEN o.order_id 
        END) AS on_time_deliveries,
        ROUND(100.0 * COUNT(DISTINCT CASE 
            WHEN o.order_delivered_customer_date <= o.order_estimated_deleivery_date -- deleivery is spelled this way because it was mispelled in the dataset
            THEN o.order_id 
        END) / COUNT(DISTINCT o.order_id), 1) AS on_time_rate,
        ROUND(AVG(r.review_score), 2) AS avg_review_score
    FROM orders o
    INNER JOIN customers c     ON c.customer_id = o.customer_id
    INNER JOIN orderitems oi   ON oi.order_id = o.order_id
    INNER JOIN order_reviews r ON r.order_id = o.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY oi.seller_id, c.customer_state
    HAVING COUNT(DISTINCT o.order_id) >= 10
),
ranked_sellers AS (
    SELECT 
        *,
        DENSE_RANK() OVER (
            PARTITION BY customer_state 
            ORDER BY avg_review_score DESC, on_time_rate DESC
        ) AS rnk
    FROM seller_state_performance
)
SELECT 
    customer_state,
    seller_id,
    total_orders,
    on_time_rate,
    avg_review_score,
    rnk
FROM ranked_sellers
WHERE rnk <= 5
ORDER BY customer_state, rnk;




-- this query compares monthly earnings by product category over each year and by month. to get a gage on seaonal performance. so we know when to increase inventory


WITH order_payments_agg AS (
	-- filters out duplicates
    SELECT 
        order_id, 
        SUM(payment_value) AS payment_value 
    FROM order_payments
    GROUP BY order_id  
),
order_items_agg AS (
	-- filters out duplicates
    SELECT 
        order_id,
        SUM(price) AS order_items_total,
        COUNT(*) AS item_count
    FROM orderitems
    GROUP BY order_id
),
order_level AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
        EXTRACT(DAY FROM o.order_purchase_timestamp) AS day,
        op.payment_value, 
        oi.order_items_total,
        oi.item_count
    FROM orders o
    INNER JOIN order_payments_agg op ON o.order_id = op.order_id
    INNER JOIN order_items_agg oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
)
-- compare monthly earnings by product category over each year and by month. to get a gage on seaonal performance. so we know when to 
SELECT 
    ol.year,
    ol.month,
    c.product_category_name_english AS category,
    SUM(oi.price) AS monthly_revenue
FROM order_level ol
INNER JOIN orderitems oi ON oi.order_id = ol.order_id
INNER JOIN products p    ON p.product_id = oi.product_id
INNER JOIN category c    ON c.category_id = p.category_id
GROUP BY ol.year, ol.month, c.product_category_name_english
ORDER BY category, year, month;

-- Average delivery time by customer state

SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_delivered_orders,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) 
        AS avg_delivery_days,
    ROUND(AVG(DATEDIFF(o.order_estimated_deleivery_date, o.order_purchase_timestamp)), 1) 
        AS avg_estimated_days,
    ROUND(100.0 * COUNT(DISTINCT CASE 
        WHEN o.order_delivered_customer_date <= o.order_estimated_deleivery_date 
        THEN o.order_id 
    END) / COUNT(DISTINCT o.order_id), 1) AS on_time_rate
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;
    


-- KPI summary


WITH order_totals AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_delivered_customer_date,
        o.order_estimated_deleivery_date,
        SUM(oi.price) AS order_value
    FROM orders o
    INNER JOIN orderitems oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id, o.customer_id, o.order_status,
             o.order_delivered_customer_date, o.order_estimated_deleivery_date
)
SELECT 
    COUNT(DISTINCT ot.order_id) AS total_orders,
    COUNT(DISTINCT ot.customer_id) AS total_customers,
    ROUND(SUM(ot.order_value), 2) AS total_revenue,
    ROUND(AVG(ot.order_value), 2) AS avg_order_value,
    ROUND(100.0 * COUNT(DISTINCT CASE 
        WHEN ot.order_delivered_customer_date <= ot.order_estimated_deleivery_date 
        THEN ot.order_id 
    END) / COUNT(DISTINCT ot.order_id), 2) AS on_time_delivery_rate,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_totals ot
LEFT JOIN order_reviews r ON r.order_id = ot.order_id;