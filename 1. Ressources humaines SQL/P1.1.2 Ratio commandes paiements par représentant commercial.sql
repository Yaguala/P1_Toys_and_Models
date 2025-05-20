-- Ratio commandes/paiements par représentant commercial : Identifier les écarts entre les commandes passées et les paiements reçus pour chaque représentant.
WITH  orders_price AS (
SELECT employees.employeeNumber, employees.firstName, employees.jobTitle, SUM(quantityOrdered*priceEach) AS Chiffre
FROM employees
JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
WHERE orders.status = 'Shipped' OR salesRepEmployeeNumber IS NULL
GROUP BY employeeNumber
)
SELECT employees.employeeNumber, employees.lastName, employees.firstName, employees.jobTitle, SUM(payments.amount) AS Payments,  orders_price.Chiffre , ROUND(SUM(payments.amount)/orders_price.Chiffre, 3) AS Ratio, (SUM(payments.amount))-orders_price.Chiffre AS Difference
FROM employees
LEFT JOIN orders_price ON employees.employeeNumber = orders_price.employeeNumber
LEFT JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
LEFT JOIN payments ON customers.customerNumber = payments.customerNumber
WHERE employees.jobTitle = 'Sales Rep'
GROUP BY employees.employeeNumber
ORDER BY payments DESC;