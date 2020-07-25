--create_customers.sql--
CREATE TABLE customers
SELECT c.user_id, c.first_name, c.last_name, c.job_title, p.user_agent AS operating_system 
FROM pageviews_tmp p
JOIN customers_tmp c 
ON p.user_id = c.user_id 
GROUP BY user_id;
