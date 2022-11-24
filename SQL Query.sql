
--DATA PREPARATION AND UNDERSTANDING
--Q1.
SELECT * FROM (
SELECT 'Customer' AS TABLE_NAME, COUNT (*) AS NO_OF_ROWS FROM Customer UNION ALL 
SELECT 'prod_cat_info' AS TABLE_NAME, COUNT (*) AS NO_OF_ROWS FROM prod_cat_info UNION ALL 
SELECT 'Transactions' AS TABLE_NAME, COUNT (*) AS NO_OF_ROWS FROM Transactions) TBL

--Q2.
SELECT  COUNT (transaction_id) AS RETURN_TRANSCATION FROM Transactions 
WHERE total_amt < 0

/*
  Q3.
  While importing the csv file into SQL Server, under advance setting i have changed the datatype for the columns.
*/
--Q4.
SELECT MIN(TRAN_DATE) AS START_DATE ,MAX(TRAN_DATE) AS END_DATE ,DATEDIFF(DAY,MIN(TRAN_DATE),MAX(TRAN_DATE))  AS [DAY],
									 DATEDIFF(MONTH,MIN(TRAN_DATE),MAX(TRAN_DATE))  AS [MONTH],
									 DATEDIFF(YEAR,MIN(TRAN_DATE),MAX(TRAN_DATE))  AS [YEAR] FROM Transactions

--Q5.
SELECT prod_cat FROM prod_cat_info
WHERE prod_subcat = 'DIY'

---------------------------------------------------------------------------------------------------------------------
--DATA ANALYSIS
--Q1.
SELECT CHANNELS FROM (
SELECT TOP 1 STORE_TYPE AS CHANNELS, COUNT(TRANSACTION_ID) AS No_of_transaction
FROM Transactions
GROUP BY Store_type
ORDER BY  No_of_transaction DESC ) AS A


--Q2.
SELECT Gender, COUNT(CUSTOMER_ID) AS Gender_Count
FROM Customer
GROUP BY Gender
HAVING Gender != ' '

--Q3.
SELECT TOP 1 CITY_CODE, COUNT(CUSTOMER_ID) AS COUNT_OF_CUSTOMER
FROM Customer
GROUP BY city_code
ORDER BY COUNT_OF_CUSTOMER DESC

--Q4
SELECT COUNT(PROD_SUBCAT) AS COUNT_OF_SUBCAT
FROM prod_cat_info
WHERE prod_cat = 'BOOKS'

--Q5.
SELECT TOP 1 COUNT_QUANTITY as Max_Quantity FROM (
select t1.prod_cat_code,prod_cat,
SUM(qty) as count_quantity 
from prod_cat_info as t1 
INNER join Transactions as t2
on t1.prod_cat_code =t2.prod_cat_code
AND T1.prod_sub_cat_code=T2.prod_subcat_code
group by t1.prod_cat_code,prod_cat ) AS A
ORDER BY count_quantity DESC

--Q6.
SELECT prod_cat, SUM(TOTAL_AMT-Tax) AS TOTAL_REVENUE FROM prod_cat_info AS T1 
INNER JOIN 
Transactions AS T2
ON T1.prod_cat_code = T2.prod_cat_code
and t1.prod_sub_cat_code = t2.prod_subcat_code
WHERE PROD_CAT IN ('ELECTRONICS','BOOKS')
GROUP BY prod_cat

--Q7.
SELECT COUNT(COUNT_OF_TRANSACTION) AS CUSTOMER_COUNT FROM (SELECT cust_id, COUNT(transaction_id) AS COUNT_OF_TRANSACTION
FROM Transactions
WHERE Qty > 0
GROUP BY cust_id
HAVING COUNT(transaction_id) > 10 ) AS X

--Q8.
SELECT store_type AS Category, SUM(TOTAL_AMT-Tax) AS COMBINED_REVENUE FROM prod_cat_info AS T1 
INNER JOIN 
Transactions AS T2
ON T1.prod_cat_code = T2.prod_cat_code
and t1.prod_sub_cat_code = t2.prod_subcat_code
where prod_cat in ('Electronics','Clothing')
group by store_type
having store_type = 'Flagship store'

--Q9.
SELECT  T2.PROD_SUBCAT,SUM(TOTAL_AMT-Tax) AS TOTAL_REVENUE FROM 
Customer AS T1 INNER JOIN 
(SELECT CUST_ID, PROD_SUBCAT,PROD_CAT,PROD_SUBCAT_CODE,TOTAL_AMT,Tax 
FROM prod_cat_info LEFT JOIN Transactions 
ON prod_cat_info.prod_sub_cat_code =Transactions.prod_subcat_code
AND prod_cat_info.prod_cat_code=Transactions.prod_cat_code)AS T2
ON CUSTOMER_ID = CUST_ID
WHERE GENDER = 'M' and prod_cat ='Electronics'
GROUP BY T2.prod_subcat

--Q10.
SELECT  TOP 5 PROD_SUBCAT,
(SUM(CASE WHEN total_amt > 0  THEN total_amt  end)/SUM(total_amt))*100 as Sales_percentage,
abs (SUM( CASE WHEN total_amt < 0 THEN total_amt  end)/SUM(total_amt))*100 as  Return_percentage
FROM prod_cat_info INNER JOIN Transactions 
ON prod_cat_info.prod_sub_cat_code =Transactions.prod_subcat_code
AND prod_cat_info.prod_cat_code=Transactions.prod_cat_code
GROUP BY prod_subcat
ORDER BY Sales_percentage DESC

--Q11.
SELECT SUM(total_amt-Tax) AS TOTAL_REVENUE FROM Customer AS T1 
INNER JOIN 
Transactions AS T2
ON T1.customer_Id=T2.cust_id
WHERE DOB BETWEEN DATEADD(YEAR,-35,(SELECT MAX(TRAN_DATE) FROM Transactions)) AND DATEADD(YEAR,-25,(SELECT MAX(TRAN_DATE) FROM Transactions))
AND TRAN_DATE >=(SELECT MAX(TRAN_DATE) FROM Transactions)-30

--Q12.
SELECT TOP 1 PROD_CAT FROM (SELECT PROD_CAT,ABS(SUM(total_amt)) AS RETURN_AMT
FROM prod_cat_info AS T1 INNER JOIN Transactions AS T2
ON T1.prod_cat_code=T2.prod_cat_code
AND T1.prod_sub_cat_code=T2.prod_subcat_code
WHERE total_amt < 0
AND tran_date > DATEADD(MONTH,-3,(SELECT MAX(TRAN_DATE) FROM Transactions))
GROUP BY  prod_cat) AS X
ORDER BY RETURN_AMT DESC


--Q13.
SELECT * FROM (SELECT  TOP 1 STORE_TYPE , SUM(QTY) AS QUANTITY_SOLD FROM Transactions
GROUP BY Store_type
ORDER BY QUANTITY_SOLD DESC) AS T1
LEFT JOIN
(SELECT  TOP 1 STORE_TYPE , SUM(total_amt) AS TOTAL_SALES FROM Transactions
GROUP BY Store_type
ORDER BY TOTAL_SALES DESC) AS T2 
ON T1.STORE_TYPE=T2.STORE_TYPE 


--Q14.
SELECT prod_cat FROM (SELECT prod_cat,AVG(TOTAL_AMT-Tax) AS CATEGORY_WISE_AVG 
					  FROM prod_cat_info AS T1 LEFT JOIN 
					  Transactions AS T2 
					  ON T1.prod_cat_code=T2.prod_cat_code
					  AND T1.prod_sub_cat_code=T2.prod_subcat_code
					  GROUP BY prod_cat
                      HAVING AVG(TOTAL_AMT-Tax) > (SELECT AVG(TOTAL_AMT-Tax) AS OVERALL_AVERAGE FROM Transactions)) AS X

--Q15.
SELECT T2.prod_subcat,TOTAL_REVENUE,AVERAGE FROM ( SELECT  TOP 5 prod_cat,T1.prod_cat_code, SUM(QTY) QUANTITY_SOLD FROM prod_cat_info AS T1 LEFT JOIN 
						 Transactions AS T2 
						 ON T1.prod_cat_code=T2.prod_cat_code
						 AND T1.prod_sub_cat_code=T2.prod_subcat_code
						 GROUP BY Prod_cat,T1.prod_cat_code
						 ORDER BY QUANTITY_SOLD DESC) AS T1
						 LEFT JOIN
						(SELECT PROD_SUBCAT,T1.prod_cat_code, SUM(TOTAL_AMT-Tax) AS TOTAL_REVENUE,AVG(TOTAL_AMT) AS AVERAGE FROM prod_cat_info AS T1 LEFT JOIN 
						 Transactions AS T2 
						 ON T1.prod_cat_code=T2.prod_cat_code
						 AND T1.prod_sub_cat_code=T2.prod_subcat_code
						 GROUP BY prod_subcat,T1.prod_cat_code) AS T2
						 ON T1.prod_cat_code=T2.prod_cat_code