--create_customers.sql--
WITH t AS (SELECT user_id, MAX(timestamp) as time 
FROM pageviews_tmp 
GROUP BY user_id)
, s AS (SELECT p.user_id, p.user_agent, p.timestamp 
  FROM pageviews_tmp p 
  JOIN t ON p.user_id = t.user_id 
  AND p.timestamp = t.time) 
SELECT c.user_id, c.first_name, c.last_name, c.job_title, s.user_agent AS operating_system 
FROM customers_tmp c 
JOIN s ON c.user_id = s.user_id
CREATE TABLE customers
SELECT c.user_id, c.first_name, c.last_name, c.job_title, p.user_agent AS operating_system 
FROM pageviews_tmp p
JOIN customers_tmp c 
ON p.user_id = c.user_id 
GROUP BY user_id;
