--create_customers.sql--
CREATE TABLE customers
SELECT c.user_id, c.first_name, c.last_name, c.job_title, p.user_agent AS operating_system 
FROM pageviews_tmp p
JOIN customers_tmp c 
ON p.user_id = c.user_id 
GROUP BY user_id;

UPDATE customers 
  SET operating_system = 'Macintosh' 
  WHERE operating_system LIKE '%Mac%';

UPDATE customers 
  SET operating_system = 'Linux' 
  WHERE operating_system LIKE '%X11%';

UPDATE customers 
  SET operating_system = 'Windows' 
  WHERE operating_system LIKE '%Windows%';

UPDATE customers 
  SET operating_system = 'Other' 
  WHERE operating_system LIKE '%bot%';