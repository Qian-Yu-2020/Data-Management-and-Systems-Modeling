/*Create a view that shows the number of online and in person orders 
in two separate columns with appropriate headings*/

/*create or replace v1 (OrderType, NumOrders)*/

CREATE OR REPLACE VIEW v1 AS
SELECT COUNT(CASE WHEN ordertype = 'O' THEN 1
                  ELSE NULL
             END) AS ONLINE_ORDER
       ,COUNT(CASE WHEN ordertype = 'S' THEN 1
                   ELSE NULL
              END) AS IN_PERSON_ORDER
    FROM t_order;

SELECT * FROM v1;

/*Create a view named v2 that shows all orders by city.  At least two cities must 
have multiple orders.  Include 4 columns from multiple tables*/

INSERT INTO t_Order VALUES ('33332', '01-feb-2017', 'Y', 'N', 'N', 'N', 'N', 'O', '06735', '10006', '11116'); COMMIT;
INSERT INTO t_Order VALUES ('33333', '24-feb-2017', 'Y', 'N', 'N', 'N', 'N', 'O', '06735', '10003', '11113'); COMMIT;
INSERT INTO t_Order VALUES ('33334', '22-feb-2017', 'Y', 'N', 'N', 'Y', 'Y', 'S', '06735', '10004', '11114'); COMMIT;
INSERT INTO t_Order VALUES ('33335', '22-feb-2017', 'Y', 'N', 'N', 'Y', 'Y', 'S', '06735', '10005', '11115'); COMMIT;

CREATE VIEW v2 AS 
SELECT t_order.orderid, orderdate, t_order.storeid, storecity
FROM t_order, t_store
WHERE t_order.storeid = t_store.storeid
ORDER BY orderid, storecity;

SELECT * FROM v2;

/*Create a view named v3 that demonstrates an outer join.  Please add more record to 
the tables in order to reflect the nature of that join.  Include 4 columns from tables used*/

CREATE VIEW v3 AS 
select ord.orderid
,ord.orderdate
,mem.ischacct
,mem.isppn
from t_order ord
left outer join t_member mem
on ord.memberid=mem.memberid;

SELECT * FROM v3;

/*Create a view named v4 based on at least three tables with two conditions in the WHERE clause.  
Please add more data to the tables to produce enough records.  Include 4 columns from tables used*/

CREATE VIEW v4 AS 
select ord.orderid
,sto.storecity
,mem.memberid
,mem.ischacct
from t_order ord
left join t_store sto
on ord.storeid=sto.storeid
left join t_member mem
on ord.memberid=mem.memberid
where sto.storecity = 'Framingham'
and mem.ischacct='Y';

SELECT * FROM v4;

/*Create a view named v5 that shows a breakfast item with highest total calories and lowest sodium content.  
Include 4 columns from tables used*/

CREATE VIEW v5 AS 
select distinct prod.productid
,prod.productname
--,nut.ttlcalories
--,nut.sodium
,f.foodtype
,case
when ttlcalories=(select max(ttlcalories) from t_nutrition n, t_food f where n.productid=f.foodproductid and f.foodtype='Breakfast') then 'Highest Total Calories'
else 'Lowest Sodium'
end as catg
from t_product prod, t_nutrition nut, t_food f
where prod.productid=nut.productid
and prod.productid=f.foodproductid
and (ttlcalories=(select max(ttlcalories) from t_nutrition n, t_food f where n.productid=f.foodproductid and f.foodtype='Breakfast')
or sodium=(select min(sodium) from t_nutrition n, t_food f where n.productid=f.foodproductid and f.foodtype='Breakfast'))
and f.foodtype='Breakfast';

SELECT * FROM v5;

/*Create a view named v6 that shows which cashier processed the highest number of transactions stored in the database.  
Include 4 columns from tables used*/

UPDATE t_order SET CASHIERID = 23132  WHERE orderid = 33322; COMMIT;
UPDATE t_order SET CASHIERID = 23132  WHERE orderid = 33323; COMMIT;
UPDATE t_order SET CASHIERID = 23123  WHERE orderid = 33324; COMMIT;
UPDATE t_order SET CASHIERID = 43656  WHERE orderid = 33325; COMMIT;
UPDATE t_order SET CASHIERID = 34123  WHERE orderid = 33326; COMMIT;
UPDATE t_order SET CASHIERID = 23132  WHERE orderid = 33327; COMMIT;
UPDATE t_order SET CASHIERID = 23132  WHERE orderid = 33328; COMMIT;

CREATE VIEW v6 AS
SELECT ord.cashierid
,emp.employeefirstname
,emp.employeelastname
,sto.storecity
--,COUNT(ORD.ORDERID)
FROM t_order ord
JOIN t_employee emp
ON ord.cashierid=emp.employeeid
JOIN t_store sto
on sto.storeid=emp.storeid
GROUP BY ord.cashierid
,emp.employeefirstname
,emp.employeelastname
,sto.storecity
HAVING COUNT(ORD.ORDERID)=
(SELECT MAX(COUNT(orderid))
FROM t_order
WHERE cashierid is not null
GROUP BY cashierid);

SELECT * FROM v6;

/*Create a view named v7 that shows customer names and city where they live who purchased gasoline and 
food items from the nearest store*/

UPDATE t_Customer SET customercity = 'Framingham'  WHERE customerid = 10001; COMMIT;
UPDATE t_Customer SET customercity = 'Framingham'  WHERE customerid = 10014; COMMIT;
UPDATE t_Customer SET customercity = 'Framingham'  WHERE customerid = 10002; COMMIT;
UPDATE t_Customer SET customercity = 'Framingham'  WHERE customerid = 10016; COMMIT;

CREATE VIEW v7 AS
select cust.customerfirstname || ', ' || cust.customerlastname as custname
,cust.customercity || ', ' || cust.customerstate as custlocation
,sto.storecity || ', ' || sto.storestate as storelocation
,count(distinct ord.orderid) as cnt_orders_food_or_gas
from t_order ord
left join t_customer cust
on ord.customerid=cust.customerid
left join t_store sto
on ord.storeid=sto.storeid
left join t_orderline ordl
on ord.orderid=ordl.orderid
left join t_food f
on f.foodproductid=ordl.productid
left join t_gas g
on g.gasproductid=ordl.productid
where (g.gasproductid is not null or f.foodproductid is not null)
and cust.customercity=sto.storecity
and cust.customerstate=sto.storestate
group by cust.customerfirstname || ', ' || cust.customerlastname
,cust.customercity || ', ' || cust.customerstate
,sto.storecity || ', ' || sto.storestate;

SELECT * FROM v7;