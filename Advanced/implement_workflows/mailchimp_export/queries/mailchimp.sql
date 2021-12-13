 SELECT 
   email,
   SPLIT_PART(COALESCE(name, 'UNKNOWN UNKNOWN'), ' ', 1) AS fname, 
   SPLIT_PART(COALESCE(name, 'UNKNOWN UNKNOWN'), ' ', 2) AS lname 
 FROM orders 
 WHERE email IS NOT NULL
