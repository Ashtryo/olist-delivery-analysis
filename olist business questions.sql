/* 
QUESTION 1: Out of all the orders that can be used for delay analysis, 
what percentage were delivered late? 
*/
SELECT COUNT(*) AS order_analysis, 
       ROUND(AVG(is_late)*100, 2) AS late_pct 
FROM orders
WHERE in_delay_analysis = 1;

/* 
QUESTION 2: Do late orders get lower review scores than on-time orders, 
and by how much? 
*/
SELECT is_late,
       COUNT(*) AS no_of_orders,
       ROUND(AVG(review_score), 2) AS avg_score,
       ROUND(AVG(review_score = 1) * 100, 2) AS one_star_pct
FROM orders
JOIN reviews ON orders.order_id = reviews.order_id
WHERE in_delay_analysis = 1
GROUP BY is_late
ORDER BY is_late;

/* 
QUESTION 3: How do the number of orders, the late rate and the average 
delivery time change from month to month? Is there seasonality? 
*/
SELECT order_month, 
       order_year, 
       COUNT(order_id) AS no_of_order, 
       ROUND(AVG(is_late) * 100, 2) AS late_pct, 
       ROUND(AVG(delivery_days), 2) AS avg_days 
FROM orders
WHERE in_delay_analysis = 1
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

/* 
QUESTION 4: Which customer states have the highest late rate, and what 
do customers in those states score on average? 
*/
SELECT customer_state,
       COUNT(orders.order_id) AS no_of_orders, 
       ROUND(AVG(review_score), 2) AS avg_review, 
       ROUND(AVG(is_late) * 100, 2) AS late_pct 
FROM reviews
JOIN orders ON orders.order_id = reviews.order_id
JOIN customers ON orders.customer_id = customers.customer_id
WHERE in_delay_analysis = 1
GROUP BY customer_state
ORDER BY late_pct DESC;

/* 
QUESTION 5: How does the review score change as the delay gets longer? 
Group orders into 4 delay buckets and compare them. 
*/
SELECT COUNT(orders.order_id) AS no_of_orders, 
       ROUND(AVG(review_score), 2) AS avg_review, 
       ROUND(AVG(reviews.review_score = 1) * 100, 2) AS one_star_pct,
       (CASE 
           WHEN is_late = 0 THEN 'on_time' 
           WHEN delivery_delay_days BETWEEN 1 AND 3 THEN '1-3 days late'
           WHEN delivery_delay_days BETWEEN 4 AND 7 THEN '4-7 days late' 
           WHEN delivery_delay_days > 7 THEN '8+ days late' 
       END) AS delay_bucket 
FROM orders
JOIN reviews ON orders.order_id = reviews.order_id
WHERE in_delay_analysis = 1
GROUP BY delay_bucket
ORDER BY MIN(delivery_delay_days);

/* 
QUESTION 6: Among all the 1-star reviews, what percentage belong to 
orders that were delivered late? 
*/
SELECT COUNT(*) AS one_star_reviews, 
       ROUND(AVG(is_late) * 100, 2) AS late_share_pct 
FROM orders
JOIN reviews ON orders.order_id = reviews.order_id
WHERE in_delay_analysis = 1 
  AND review_score = 1;

/* 
QUESTION 7: When an order is late, which part of the journey takes 
longer: the seller preparing the parcel, or the carrier delivering it? 
*/
SELECT is_late,
       COUNT(*) AS no_of_orders, 
       ROUND(AVG(seller_handling_days), 2) AS avg_handling_days, 
       ROUND(AVG(transit_days), 2) AS avg_transit_days 
FROM orders
WHERE in_delay_analysis = 1
GROUP BY is_late
ORDER BY is_late;

/* 
QUESTION 8: Which product categories have the highest late rate? 
Only consider categories with at least 300 orders. 
*/
WITH cat_orders AS (
    SELECT DISTINCT orders.order_id, 
           orders.is_late, 
           products.product_category
    FROM orders 
    JOIN order_items ON order_items.order_id = orders.order_id
    JOIN products ON products.product_id = order_items.product_id
    WHERE in_delay_analysis = 1
)
SELECT product_category,
       COUNT(*) AS orders,
       ROUND(AVG(is_late) * 100, 2) AS late_pct
FROM cat_orders
GROUP BY product_category
HAVING COUNT(*) >= 300
ORDER BY late_pct DESC
LIMIT 10;