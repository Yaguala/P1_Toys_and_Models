-- Calcule, chiffre affaire total.
WITH chiffre_affaire_total AS (
SELECT SUM(quantityOrdered*priceEach) AS Total_chiffre
FROM orders
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
WHERE orders.status = 'Shipped'
),
-- Calcule chiffre affaire fait par chaque SALES REP
	orders_price AS (
SELECT employees.employeeNumber AS Nemploy , employees.lastName AS lastname, employees.firstName AS fristname, employees.jobTitle AS JobPostion, 
		SUM(quantityOrdered*priceEach) AS Chiffre, COUNT(Distinct(customers.customerNumber)) AS Number_of_custumers, MAX(orders.orderDate) AS Last_Order,  MIN(orders.orderDate) AS First_Order
FROM employees
LEFT JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
LEFT JOIN orders ON customers.customerNumber = orders.customerNumber
LEFT JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
WHERE orders.status = 'Shipped' OR salesRepEmployeeNumber IS NULL AND employees.jobTitle = 'Sales Rep'
GROUP BY employeeNumber
),
-- Calcule de chifre affiare par OFFICE
	offices_city AS (
SELECT offices.city AS office_city, SUM(quantityOrdered*priceEach) AS Chiffre_affaire_Office, offices.officeCode AS officeCode,  COUNT(Distinct(customers.customerNumber)) AS Number_of_Customers_Office, offices.territory AS Region
FROM employees 
LEFT JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
LEFT JOIN offices ON employees.officeCode = offices.officeCode
WHERE orders.status = 'Shipped' OR salesRepEmployeeNumber IS NULL AND employees.jobTitle = 'Sales Rep'
GROUP BY offices.officeCode
),
-- Calcule de Cadence de commendes par SALES REP
	CaOrder AS (
select orders.customerNumber, employees.employeeNumber as Nemployee, employees.lastname as lastname,
LAG(orderDate) over (partition by employees.lastName order by orderDate) as previous_order_date, orderDate
from orders
JOIN customers ON orders.customerNumber = customers.customerNumber
JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
WHERE orders.status = 'Shipped'
),
-- Report to Sales REP
	ctereport AS (
SELECT employeeNumber AS ctereportID, concat(lastname," ", firstName," ", jobTitle) AS ctereportsTO
FROM employees
),
-- payment de customers
    cte_payments AS(
SELECT employees.employeeNumber AS cte_paymentsID , SUM(payments.amount) AS Payments
FROM employees
LEFT JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
LEFT JOIN payments ON customers.customerNumber = payments.customerNumber
GROUP BY employees.employeeNumber
)
SELECT Nemploy, 
		orders_price.lastname,
        fristname, 
        JobPostion,
        orders_price.Number_of_custumers,
        Chiffre,
        ROUND(((Chiffre*100)/ chiffre_affaire_total.Total_chiffre)) AS Precentage_Repsales,
        cte_payments.Payments,
		ROUND(cte_payments.Payments/orders_price.Chiffre, 3) AS Ratio, 
		cte_payments.Payments-orders_price.Chiffre AS Difference,
        offices_city.officeCode,
		offices_city.office_city,
        offices_city.Number_of_Customers_Office,
        Chiffre_affaire_Office, 
        ROUND(((Chiffre_affaire_Office*100)/ chiffre_affaire_total.Total_chiffre)) AS Precentage_Office,
        ctereportsTO,
        offices_city.Region,
        orders_price.First_Order,
        orders_price.Last_Order,
		ROUND(AVG(datediff(orderDate, previous_order_date))) AS MoyenneJoursPorCommande
FROM employees
JOIN chiffre_affaire_total 
JOIN orders_price ON employees.employeeNumber = orders_price.Nemploy
JOIN offices_city ON employees.officeCode = offices_city.officeCode
LEFT JOIN Caorder ON employees.employeeNumber = CaOrder.Nemployee
JOIN ctereport ON employees.reportsTo = ctereport.ctereportID
LEFT JOIN cte_payments ON employees.employeeNumber = cte_payments.cte_paymentsID
GROUP BY employees.employeeNumber, chiffre_affaire_total.Total_chiffre;