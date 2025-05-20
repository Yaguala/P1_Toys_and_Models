-- Performance des bureaux : Mesurer le chiffre d’affaires généré par chaque bureau.
SELECT offices.city, SUM(quantityOrdered*priceEach) AS Chiffre_affaire, ROUND((SUM(quantityOrdered*priceEach)*100)/(SELECT SUM(quantityOrdered*priceEach) AS Total_chiffre
FROM employees
JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
WHERE orders.status = 'Shipped')) AS Precentage, COUNT(customers.customerNumber) AS number_of_customers,  MAX(orders.orderDate) AS Last_Order
FROM employees
LEFT JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
LEFT JOIN offices ON employees.officeCode = offices.officeCode
WHERE orders.status = 'Shipped' -- AND orders.orderDate LIKE '2024-%'
GROUP BY offices.city
ORDER BY SUM(quantityOrdered*priceEach) DESC;
