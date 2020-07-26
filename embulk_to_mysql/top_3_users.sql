WITH p2 AS (
	SELECT user_id, max(timestamp) last_timestamp 
	FROM pageviews 
	WHERE user_id 
    IN (
        SELECT user_id 
        FROM pageviews 
        WHERE url LIKE '%.gov%'
        ) 
	GROUP BY user_id 
	ORDER BY COUNT(url) DESC 
    LIMIT 3)
SELECT user_id, url last_page_viewed 
FROM pageviews 
WHERE user_id 
IN (
    SELECT user_id 
	FROM p2 
	WHERE timestamp=last_timestamp
    )
ORDER BY timestamp DESC;