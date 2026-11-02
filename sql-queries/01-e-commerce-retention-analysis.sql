-- E-Commerce Cohort Retention & Churn Analysis
-- Analyzes user retention over a 6-month period following initial signup.

WITH first_purchase AS (
    SELECT
        user_id,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE order_status = 'COMPLETED'
    GROUP BY user_id
),
monthly_activity AS (
    SELECT
        o.user_id,
        DATE_TRUNC('month', o.order_date) AS active_month,
        fp.cohort_month,
        (EXTRACT(YEAR FROM o.order_date) - EXTRACT(YEAR FROM fp.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM fp.cohort_month)) AS month_number
    FROM orders o
    JOIN first_purchase fp ON o.user_id = fp.user_id
    WHERE o.order_status = 'COMPLETED'
)
SELECT
    cohort_month,
    month_number,
    COUNT(DISTINCT user_id) AS active_users,
    ROUND(
        COUNT(DISTINCT user_id)::NUMERIC / 
        FIRST_VALUE(COUNT(DISTINCT user_id)) OVER (PARTITION BY cohort_month ORDER BY month_number) * 100, 
        2
    ) AS retention_rate_percentage
FROM monthly_activity
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;
