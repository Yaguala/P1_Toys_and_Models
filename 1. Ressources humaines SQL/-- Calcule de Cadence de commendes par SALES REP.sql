WITH cte AS (select orders.customerNumber, employees.employeeNumber, employees.lastname as lastname,
LAG(orderDate) over (partition by employees.lastName order by orderDate) as previous_order_date, orderDate
from orders
JOIN customers ON orders.customerNumber = customers.customerNumber
JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
WHERE orders.status = 'Shipped')
SELECT cte.lastname, AVG(datediff(orderDate, previous_order_date))
FROM cte
GROUP BY cte.lastname;



select employees.employeeNumber, employees.lastname as lastname,
LAG(orderDate) over (partition by employees.lastName order by orderDate) as previous_order_date, orderDate
from orders
JOIN customers ON orders.customerNumber = customers.customerNumber
JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
WHERE orders.status = 'Shipped'
