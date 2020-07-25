CREATE TABLE pageviews 
SELECT * FROM pageviews_tmp
WHERE user_id IN (
    SELECT user_id
		FROM customers_tmp
		WHERE job_title NOT LIKE '%Sales%');