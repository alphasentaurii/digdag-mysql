SELECT COUNT(url) AS total_views 
FROM pageviews 
WHERE user_id 
IN (
  SELECT user_id 
  FROM customers 
  WHERE operating_system = 'Windows' 
  OR job_title LIKE '%Engineer%'
  )