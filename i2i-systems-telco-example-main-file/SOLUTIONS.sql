------------------------------------------------------------
-- 1. TARIFF-BASED CUSTOMER QUERIES
------------------------------------------------------------

-- This query lists customers subscribed to the 'Kobiye Destek' tariff.
-- It joins CUSTOMERS and TARIFFS using tariff_id to match each customer to their plan.
-- The filter ensures only customers in the specified tariff are returned.
-- This helps identify users in a specific tariff group.

SELECT c.customer_id, c.name, c.city
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t ON c.tariff_id = t.tariff_id
WHERE t.tariff_name = 'Kobiye Destek';


-- This query finds the newest customer in the 'Kobiye Destek' tariff.
-- It orders customers by signup_date in descending order so the newest appears first.
-- ROWNUM = 1 ensures only one record is returned.
-- This helps identify the latest subscriber in that tariff.

SELECT *
FROM (
    SELECT c.customer_id, c.name, c.signup_date
    FROM SYSTEM.CUSTOMERS c
    JOIN SYSTEM.TARIFFS t ON c.tariff_id = t.tariff_id
    WHERE t.tariff_name = 'Kobiye Destek'
    ORDER BY c.signup_date DESC
)
WHERE ROWNUM = 1;


------------------------------------------------------------
-- 2. TARIFF DISTRIBUTION
------------------------------------------------------------

-- This query counts how many customers are subscribed to each tariff.
-- It joins CUSTOMERS and TARIFFS using tariff_id.
-- The results are grouped by tariff_name.
-- This shows the distribution of customers across tariff plans.

SELECT t.tariff_name, COUNT(*) AS customer_count
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t ON c.tariff_id = t.tariff_id
GROUP BY t.tariff_name;


------------------------------------------------------------
-- 3. CUSTOMER SIGNUP ANALYSIS
------------------------------------------------------------

-- This query finds the earliest customers based on signup date.
-- It uses MIN(signup_date) to find the first registration date.
-- All customers with that date are returned.
-- This identifies the first users of the system.

SELECT customer_id, name, signup_date
FROM SYSTEM.CUSTOMERS
WHERE signup_date = (SELECT MIN(signup_date) FROM SYSTEM.CUSTOMERS);


-- This query shows how earliest customers are distributed across cities.
-- It filters by the earliest signup date.
-- It groups results by city to count customers.
-- This shows where early users came from.

SELECT city, COUNT(*) AS customer_count
FROM SYSTEM.CUSTOMERS
WHERE signup_date = (SELECT MIN(signup_date) FROM SYSTEM.CUSTOMERS)
GROUP BY city;


------------------------------------------------------------
-- 4. MISSING MONTHLY RECORDS
------------------------------------------------------------

-- This query finds customers with missing usage data.
-- It uses LEFT JOIN to include all customers.
-- NULL values indicate missing records.
-- This detects incomplete monthly usage data.

SELECT c.customer_id
FROM SYSTEM.CUSTOMERS c
LEFT JOIN SYSTEM.USAGE_DATA u ON c.customer_id = u.customer_id
WHERE u.customer_id IS NULL;


-- This query shows missing usage customers by city.
-- It groups missing records by city.
-- This identifies whether missing data is region-specific.
-- This helps detect data issues in certain areas.

SELECT c.city, COUNT(*) AS missing_count
FROM SYSTEM.CUSTOMERS c
LEFT JOIN SYSTEM.USAGE_DATA u ON c.customer_id = u.customer_id
WHERE u.customer_id IS NULL
GROUP BY c.city;


------------------------------------------------------------
-- 5. USAGE ANALYSIS
------------------------------------------------------------

-- This query finds customers who used at least 75% of their data limit.
-- It ensures valid comparison by filtering out invalid limits.
-- It compares usage ratio against tariff limit.
-- This identifies high usage customers.

SELECT c.customer_id, c.name, u.data_used, t.data_limit
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.USAGE_DATA u ON c.customer_id = u.customer_id
JOIN SYSTEM.TARIFFS t ON c.tariff_id = t.tariff_id
WHERE t.data_limit > 0
AND u.data_used >= 0.75 * t.data_limit;


-- This query finds customers who fully exhausted all package limits.
-- It checks data, minutes, and SMS usage against tariff limits.
-- All conditions must be satisfied simultaneously.
-- This identifies extreme usage customers.

SELECT c.customer_id, c.name
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.USAGE_DATA u ON c.customer_id = u.customer_id
JOIN SYSTEM.TARIFFS t ON c.tariff_id = t.tariff_id
WHERE u.data_used >= t.data_limit
  AND u.minutes_used >= t.minutes_limit
  AND u.sms_used >= t.sms_limit;


------------------------------------------------------------
-- 6. PAYMENT ANALYSIS
------------------------------------------------------------

-- This query finds customers with missing usage data (assumed inactive/unpaid).
-- It uses LEFT JOIN to detect customers without usage records.
-- Missing usage is interpreted as no monthly activity.
-- This identifies potentially inactive customers.

SELECT c.customer_id, c.name
FROM SYSTEM.CUSTOMERS c
LEFT JOIN SYSTEM.USAGE_DATA u ON c.customer_id = u.customer_id
WHERE u.customer_id IS NULL;


-- This query shows tariff distribution including inactive customers.
-- It joins customers and tariffs, then checks usage presence.
-- It counts total customers per tariff.
-- This shows activity distribution across tariffs.

SELECT t.tariff_name, COUNT(c.customer_id) AS total_customers
FROM SYSTEM.CUSTOMERS c
JOIN SYSTEM.TARIFFS t ON c.tariff_id = t.tariff_id
LEFT JOIN SYSTEM.USAGE_DATA u ON c.customer_id = u.customer_id
GROUP BY t.tariff_name;
