-- Customers with out sales Rep
SELECT Country, Count(country)
From customers
WHERE salesRepEmployeeNumber IS NULL
GROUP BY country;