-- Sales Performance Analysis with Window Functions
-- Calculates 30-day rolling averages and revenue rankings per product category.

SELECT
    order_date,
    category_name,
    product_name,
    daily_revenue,
    -- 7-day moving average revenue
    ROUND(
        AVG(daily_revenue) OVER (
            PARTITION BY category_name 
            ORDER BY order_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_7d_avg_revenue,
    -- Rank within category for the day
    DENSE_RANK() OVER (
        PARTITION BY category_name, order_date 
        ORDER BY daily_revenue DESC
    ) AS category_daily_rank
FROM daily_product_sales
WHERE order_date >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY category_name, order_date DESC;
