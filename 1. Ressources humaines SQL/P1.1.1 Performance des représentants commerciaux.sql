-- Performance des représentants commerciaux : Calculer le chiffre d’affaires généré par chaque employé chargé des ventes.
-- Chiffre des sales rep with %
SELECT employees.employeeNumber, employees.lastName, employees.firstName, employees.jobTitle, SUM(quantityOrdered*priceEach) AS Chiffre_affaire, ROUND(SUM(quantityOrdered*priceEach)*100/(SELECT SUM(quantityOrdered*priceEach)
FROM employees
JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
WHERE orders.status = 'Shipped')) AS Precentage, Count(customers.customerNumber) AS Number_of_custumers, MAX(orders.orderDate) AS Last_Order
FROM employees
LEFT JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
LEFT JOIN orders ON customers.customerNumber = orders.customerNumber
LEFT JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
WHERE orders.status = 'Shipped' OR salesRepEmployeeNumber IS NULL AND jobTitle = 'Sales Rep'
GROUP BY employees.employeeNumber
ORDER BY SUM(quantityOrdered*priceEach) DESC;
