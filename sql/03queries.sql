-- ============================================================
-- BEGINNER SQL PRACTICE QUERIES
-- Subscription Billing System
-- ============================================================

USE subscription_billing_system;

-- ------------------------------------------------------------
-- 1. BASIC SELECT -- view all data in a table
-- ------------------------------------------------------------
SELECT * FROM customers;

SELECT * FROM plans;


-- ------------------------------------------------------------
-- 2. SELECT specific columns only
-- ------------------------------------------------------------
SELECT full_name, email, city FROM customers;


-- ------------------------------------------------------------
-- 3. WHERE -- filter rows
-- ------------------------------------------------------------
-- Customers from Madurai
SELECT full_name, city, state
FROM customers
WHERE city = 'Madurai';

-- Active subscriptions only
SELECT * FROM subscriptions
WHERE status = 'Active';

-- Plans priced above 1000
SELECT plan_name, price
FROM plans
WHERE price > 1000;


-- ------------------------------------------------------------
-- 4. ORDER BY -- sort results
-- ------------------------------------------------------------
-- Plans from cheapest to most expensive
SELECT plan_name, price
FROM plans
ORDER BY price ASC;

-- Customers, most recently signed up first
SELECT full_name, signup_date
FROM customers
ORDER BY signup_date DESC;


-- ------------------------------------------------------------
-- 5. LIMIT -- restrict number of rows returned
-- ------------------------------------------------------------
-- Top 5 most expensive plans
SELECT plan_name, price
FROM plans
ORDER BY price DESC
LIMIT 5;


-- ------------------------------------------------------------
-- 6. WHERE with AND / OR
-- ------------------------------------------------------------
-- Active customers from Tamil Nadu
SELECT full_name, city, state, status
FROM customers
WHERE state = 'Tamil Nadu' AND status = 'Active';

-- Customers from Chennai or Madurai
SELECT full_name, city
FROM customers
WHERE city = 'Chennai' OR city = 'Madurai';


-- ------------------------------------------------------------
-- 7. IN -- match against a list of values
-- ------------------------------------------------------------
SELECT full_name, city
FROM customers
WHERE city IN ('Chennai', 'Madurai', 'Coimbatore');


-- ------------------------------------------------------------
-- 8. BETWEEN -- range filter
-- ------------------------------------------------------------
SELECT plan_name, price
FROM plans
WHERE price BETWEEN 500 AND 2000;


-- ------------------------------------------------------------
-- 9. LIKE -- pattern matching
-- ------------------------------------------------------------
-- Customers whose name starts with 'K'
SELECT full_name FROM customers
WHERE full_name LIKE 'K%';

-- Plans with "Yearly" in the name
SELECT plan_name FROM plans
WHERE plan_name LIKE '%Yearly%';


-- ------------------------------------------------------------
-- 10. COUNT -- count rows
-- ------------------------------------------------------------
-- Total number of customers
SELECT COUNT(*) AS total_customers FROM customers;

-- Number of active subscriptions
SELECT COUNT(*) AS active_subscriptions
FROM subscriptions
WHERE status = 'Active';


-- ------------------------------------------------------------
-- 11. GROUP BY -- group rows and aggregate
-- ------------------------------------------------------------
-- Number of customers per city
SELECT city, COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC;

-- Number of subscriptions per status
SELECT status, COUNT(*) AS total
FROM subscriptions
GROUP BY status;


-- ------------------------------------------------------------
-- 12. SUM / AVG / MAX / MIN -- basic aggregate functions
-- ------------------------------------------------------------
SELECT SUM(amount) AS total_revenue FROM payments;

SELECT AVG(price) AS average_plan_price FROM plans;

SELECT MAX(price) AS most_expensive_plan FROM plans;

SELECT MIN(price) AS cheapest_plan FROM plans;


-- ------------------------------------------------------------
-- 13. GROUP BY + aggregate together
-- ------------------------------------------------------------
-- Total payment amount collected per payment method
SELECT payment_method, SUM(amount) AS total_collected
FROM payments
GROUP BY payment_method;


-- ------------------------------------------------------------
-- 14. HAVING -- filter after grouping
-- ------------------------------------------------------------
-- Cities with more than 5 customers
SELECT city, COUNT(*) AS customer_count
FROM customers
GROUP BY city
HAVING COUNT(*) > 5;


-- ------------------------------------------------------------
-- 15. JOIN -- combine two related tables
-- ------------------------------------------------------------
-- Show each subscription with the customer's name and plan name
SELECT c.full_name, p.plan_name, s.start_date, s.end_date, s.status
FROM subscriptions s
JOIN customers c ON s.customer_id = c.customer_id
JOIN plans p ON s.plan_id = p.plan_id;


-- ------------------------------------------------------------
-- 16. JOIN + WHERE
-- ------------------------------------------------------------
-- Active subscriptions with customer and plan names
SELECT c.full_name, p.plan_name, s.status
FROM subscriptions s
JOIN customers c ON s.customer_id = c.customer_id
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.status = 'Active';


-- ------------------------------------------------------------
-- 17. JOIN across 3 tables
-- ------------------------------------------------------------
-- Show customer name, plan, and payment amount
SELECT c.full_name, pl.plan_name, pay.amount, pay.payment_date
FROM payments pay
JOIN subscriptions s ON pay.subscription_id = s.subscription_id
JOIN customers c ON s.customer_id = c.customer_id
JOIN plans pl ON s.plan_id = pl.plan_id
ORDER BY pay.payment_date DESC;


-- ------------------------------------------------------------
-- 18. DISTINCT -- remove duplicate values
-- ------------------------------------------------------------
-- List of unique cities customers are from
SELECT DISTINCT city FROM customers;


-- ------------------------------------------------------------
-- 19. IS NULL / IS NOT NULL
-- ------------------------------------------------------------
-- Support tickets not yet resolved
SELECT ticket_id, subject, status
FROM support_tickets
WHERE resolved_date IS NULL;


-- ------------------------------------------------------------
-- 20. UPDATE -- modify existing data
-- ------------------------------------------------------------
-- Mark a specific customer as Inactive (always test WHERE first with SELECT!)
-- SELECT * FROM customers WHERE customer_id = 5;
UPDATE customers
SET status = 'Inactive'
WHERE customer_id = 5;


-- ------------------------------------------------------------
-- 21. DELETE -- remove data (be careful, always SELECT first!)
-- ------------------------------------------------------------
-- SELECT * FROM notifications WHERE notification_id = 200;
-- DELETE FROM notifications WHERE notification_id = 200;