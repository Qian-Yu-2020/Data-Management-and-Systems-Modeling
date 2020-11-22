# SQL 

# Sales Analysis 


# Reports the products that were only sold in 4th quarter, 2020. 

SELECT DISTINCT p.product_id, p.name
FROM Product p JOIN Order_line l USING(product_id) JOIN Order o USING(order_id)
WHERE o.date BETWEEN "2020-10-01" AND "2020-12-31"
AND p.product_id NOT IN (
	SELECT p.product_id, p.name
	FROM Product p JOIN Order_line l USING(product_id) JOIN Order o USING(order_id)
   	WHERE o.date > "2020-03-31" OR o.date < "2020-01-01")
ORDER BY p.product_id
;



# Find the percentage of paying in cash 

SELECT ROUND(AVG(CASE 
	WHEN Payment_Method = "Ca" THEN 1 
        ELSE 0 END)*100,2) AS immediate_percentage
FROM Delivery
;


# Products Ordered in a Period with certain amount

# Query the names of products with greater than or equal to 100 units ordered in the whole week before Thanksgiving

SELECT p.name, SUM(l.quantity) AS total_amount
FROM Order_line l
    JOIN Product p USING(product_id)
    JOIN Order o USING(order_id)
WHERE LEFT(o.date, 7) = "2020-11-27"
GROUP BY 2
HAVING SUM(l.quantity) >= 100
ORDER BY 2
;


# Sales by Day of the Week

# A sales report for category items and day of the week
# Report how many units in each category have been ordered on each day of the week
# Return the result table ordered by category

SELECT d.department_name AS Category,
    SUM(CASE WHEN DAYOFWEEK(o.date) = 2 THEN l.quantity ELSE 0 END) AS Monday,
    SUM(CASE WHEN DAYOFWEEK(o.date) = 3 THEN l.quantity ELSE 0 END) AS Tuesday,
    SUM(CASE WHEN DAYOFWEEK(o.date) = 4 THEN l.quantity ELSE 0 END) AS Wednesday,
    SUM(CASE WHEN DAYOFWEEK(o.date) = 5 THEN l.quantity ELSE 0 END) AS Thursday,
    SUM(CASE WHEN DAYOFWEEK(o.date) = 6 THEN l.quantity ELSE 0 END) AS Friday,
    SUM(CASE WHEN DAYOFWEEK(o.date) = 7 THEN l.quantity ELSE 0 END) AS Saturday,
    SUM(CASE WHEN DAYOFWEEK(o.date) = 1 THEN l.quantity ELSE 0 END) AS Sunday
FROM Department d
LEFT JOIN Product p USING(department_id)
LEFT JOIN Order_line l USING(product_id
LEFT JOIN Orders o USING(order_id)
GROUP BY d.department_name
ORDER BY d.department_name;


# Unique Orders and Customers Per Month
# find the number of unique orders and the number of unique customers with invoices > $20 for each different month

SELECT DATE_FORMAT(date,'%Y-%m') AS month,
	COUNT(DISTINCT order_id) AS order_count,
	COUNT(DISTINCT customer_id) AS customer_count
FROM Order 
WHERE total_amount > 20
GROUP BY DATE_FORMAT(order_date,'%Y-%m')














# Customer Pereference Behavior 

SELECT s.buyer_id
FROM Sales s JOIN Product p USING(product_id)
GROUP BY s.buyer_id 
HAVING SUM(p.product_name = "S8") > 0
AND SUM(p.product_name = "iPhone") = 0
;

# Find the total number of users and the total amount spent using mobile only, desktop only and both mobile and desktop together for each date

SELECT t2.spend_date
    , t2.platform
    , sum( IFNULL (total_amount, 0)) AS total_amount
    , count(user_id) AS total_users

FROM (select DISTINCT spend_date
        , t.platform
    FROM cte CROSS JOIN (
        SELECT 'desktop' AS platform union
        SELECT 'mobile' union
        SELECT 'both'
    ) t ) t2 
    LEFT JOIN cte ON t2.spend_date = cte.spend_date AND t2.platform = cte.platform
    GROUP BY t2.spend_date, t2.platform


# 1251. Average Selling Price

# Each row of this table indicates the price of the product_id in the period from start_date to end_date.
# For each product_id there will be no two overlapping periods. That means there will be no two intersecting periods for the same product_id.

SELECT p.product_id, ROUND(SUM(u.units*p.price)/SUM(u.units),2) AS average_price
FROM Prices p JOIN UnitsSold u USING(product_id)
WHERE u.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY 1
;


# 1511. Customer Order Frequency

# Report the customer_id and customer_name of customers who have spent at least $100 in each month of June and July 2020

SELECT c.customer_id, c.name
FROM Customers c
JOIN Orders o USING(customer_id)
JOIN Product p USING(product_id)
                GROUP BY o.customer_id 
                 HAVING SUM(IF(LEFT(o.order_date, 7) = '2020-06',o.quantity,0) * p.price) >= 100
                 AND SUM(IF(LEFT(o.order_date, 7) = '2020-07',o.quantity,0) * p.price) >= 100
;
     

# Report the difference between number of Blueberry Donut and Apple Turnover sold each day
# Return the result table ordered by sale_date in format ('YYYY-MM-DD')

SELECT sale_date, 
    SUM(CASE 
    		WHEN fruit = "Blueberry Donut" THEN sold_num 
    		ELSE (-sold_num) END) AS diff
FROM Sales
GROUP BY sale_date


# 1484. Group Sold Products By The Date

# find for each date, the number of distinct products sold and their names.
# The sold-products names for each date should be sorted lexicographically. 

SELECT DISTINCT sell_date, COUNT(DISTINCT product) AS num_sold, 
    GROUP_CONCAT(DISTINCT product ORDER BY product ASC SEPARATOR ',') AS products # aggregate the product names in one cell
FROM Activities 
GROUP BY sell_date
;




# 1532. The Most Recent Three Orders

# Find the most recent 3 orders of each user. If a user ordered less than 3 orders return all of their orders

SELECT c.name AS customer_name, c.customer_id, o.order_id, o.order_date
FROM Customers AS c
    JOIN Orders AS o ON c.customer_id = o.customer_id
WHERE(
    SELECT COUNT(*) 
    FROM Orders AS o2

    # when using SELF JOIN, it is easy to forgot to connect them first
    WHERE o.customer_id = o2.customer_id AND o.order_date< o2.order_date)<=2
ORDER BY customer_name,c.customer_id,o.order_date DESC
;





# Best seller by total sales quantity 
SELECT Product_ID
FROM ORDER
# Because there are most than one sale price of certain sell item 
GROUP BY seller_id
# After HAVING, most of aggregate functuion can be used 
HAVING SUM(price) = (
    SELECT SUM(price) 
        FROM Sales
        GROUP BY seller_id
        ORDER BY SUM(price) DESC
        LIMIT 1)
;








