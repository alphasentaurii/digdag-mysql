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
WHERE operating_system NOT REGEXP 'Macintosh|Linux|Windows';