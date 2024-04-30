USE Retail;

SHOW tables;

SELECT * 
FROM ret_customer;
-- COLUMNS AVAILABLE: 'cust_id,' 'DOB', 'Customer Year', 'Customer Age', 'Gender', 'City', 'Cat _SubCat'--

SELECT * 
FROM ret_product;
-- COLUMNS AVAILABLE: 'prod_subcat_code', 'prod_subcat', 'prod_cat_code', 'prod_cat'--

SELECT * 
FROM ret_transactions;
-- COLUMNS AVAILABLE: 'transaction_id', 'cust_id', 'tran_date', 'tran_month_no', 'tran_month', 'tran_year', 'prod_subcat_code',	'prod_cat_code', 'Qty',	'Returns',	'Rate',	'Tax',	'total_amt', 'Store_type' --

-- AOV --

SELECT 
    AVG(total_amt) AS average_order_value
FROM 
    ret_transactions;
    
-- AOV add category --
SELECT 
    AVG(total_amt) AS average_order_value, prod_cat
FROM 
    ret_transactions AS trans
JOIN 
    ret_product AS prod ON trans.prod_cat_code = prod.prod_cat_code
GROUP BY prod.prod_cat;

--  Find total amount, quantity, and percentage split by store type
SELECT 
    store_type,
    CONCAT('£', FORMAT(SUM(total_amt), 2)) AS total_amount,
    SUM(qty) AS total_quantity,
    CONCAT(FORMAT((SUM(total_amt) * 100.0) / (SELECT SUM(total_amt) FROM ret_transactions), 2), '%') AS percentage_split
FROM 
    ret_transactions
GROUP BY 
    store_type;

-- Perform a join on ret_customer table against ret_transactions table
SELECT *
FROM ret_customer as cust 
LEFT JOIN ret_transactions as trans
ON cust.cust_id = trans.cust_id;

-- Show Number of transactions across gender --
SELECT cust.gender, COUNT(trans.transaction_id) AS transaction_count
FROM ret_customer AS cust
LEFT JOIN ret_transactions AS trans ON cust.cust_id = trans.cust_id
GROUP BY cust.gender;

-- Show Number of transactions across gender as a percentage--
SELECT 
    cust.gender,
    COUNT(trans.transaction_id) AS transaction_count,
    COUNT(trans.transaction_id) * 100.0 / SUM(COUNT(trans.transaction_id)) 
OVER() AS gender_percentage_spilt
FROM 
    ret_customer AS cust
LEFT JOIN 
    ret_transactions AS trans ON cust.cust_id = trans.cust_id
GROUP BY 
    cust.gender;


-- Show highest transaction date --
SELECT MAX(tran_date) AS highest_transaction_date
FROM ret_transactions;

-- Show Highest, minimum and average order value (Only orders greater then 0)
SELECT 
	CONCAT('£',FORMAT(MAX(total_amt),0)) AS Highest_Order_Value,
	CONCAT('£',FORMAT(MIN(total_amt),0)) AS Min_Order_Value,
    CONCAT('£',FORMAT(AVG(total_amt),0)) AS Avg_Order_Value
FROM ret_transactions
WHERE 
    total_amt > 0;

-- Perform a join on ret_customer table against ret_transactions table

SELECT *
FROM ret_product AS prod 
LEFT JOIN ret_transactions AS trans
ON prod.prod_subcat_code = trans.prod_subcat_code;


-- Show number of transactions, total sales, total tax and qty --
SELECT 
    COUNT(ret_transactions.transaction_id) AS total_items_sold,
    SUM(ret_transactions.total_amt) AS total_sales,
    SUM(ret_transactions.tax) AS total_tax,
    SUM(ret_transactions.qty) AS total_quantity_sold
FROM 
    ret_transactions;
    
-- Show number of transactions, total sales,and qty and show the results formatted --
SELECT 
    CONCAT(FORMAT(COUNT(ret_transactions.transaction_id),0)) AS No_Transactions,
    CONCAT('£', FORMAT(SUM(ret_transactions.total_amt),0)) AS Total_Sales,
	CONCAT(FORMAT(SUM(ret_transactions.qty),0)) AS Total_Qty_sold
FROM ret_transactions

   
-- FORMAT Number of  transactions, total sales, total tax and qty V2 to include text in results --
SELECT 
    CONCAT('Total Items Sold: ', FORMAT(COUNT(ret_transactions.transaction_id),0)) AS total_items_sold,
    CONCAT('Total Sales: £', FORMAT(SUM(ret_transactions.total_amt),0)) AS total_sales,
    CONCAT('Total Tax: £', FORMAT(SUM(ret_transactions.tax), 0)) AS total_tax,
	CONCAT('Total Quantity Sold: ', FORMAT(SUM(ret_transactions.qty),0)) AS total_quantity_sold
FROM 
    ret_transactions;

    
-- Amend Colun Names in ret_customer Table --

ALTER TABLE ret_customer
CHANGE COLUMN `Customer Age` Customer_Age INT;

ALTER TABLE ret_customer
CHANGE COLUMN `Customer Year` Customer_Year INT;

-- Show age, gender and store type in order of age --
SELECT cust.Customer_Age, cust.gender, trans.store_type
FROM ret_customer AS cust
LEFT JOIN ret_transactions AS trans 
ON cust.cust_id = trans.cust_id
WHERE cust.gender = 'F'
ORDER BY Customer_Age;

-- Show sales by store type --

SELECT store_type, CONCAT('Total Sales: £', FORMAT(SUM(total_amt),0)) AS sales_by_store_type
FROM ret_transactions
GROUP BY store_type
ORDER BY 1 ASC;

-- Top 10 Total Spend per customer --
SELECT 
    cust_id, 
    CONCAT('Total Sales: £', FORMAT(SUM(total_amt),0)) AS spend_per_customer
FROM 
    ret_transactions
WHERE 
	total_amt > 0 -- excludes returns
GROUP BY cust_id
ORDER BY SUM(total_amt) DESC
LIMIT 10;

-- min, max, avg age
SELECT 
	MAX(cust.customer_age) AS Max_Age,
	MIN(cust.customer_age) AS Min_Age,
    CONCAT(FORMAT(AVG(cust.customer_age),0)) AS Avg_Age
    
FROM ret_transactions AS trans
JOIN ret_customer AS cust ON trans.cust_id = cust.cust_id
WHERE trans.total_amt > 0;
    
-- What did top Spend  customer buy --
-- '274227','272354','272799','270458', '273481'--
SELECT 
    DISTINCT prod.prod_cat,
    CONCAT('£', FORMAT(SUM(trans.total_amt),0)) AS Top_5_cust_spend
FROM 
    ret_transactions AS trans
JOIN 
    ret_product AS prod ON trans.prod_cat_code = prod.prod_cat_code
WHERE 
    trans.cust_id IN ('274227','272354','272799','270458', '273481')
GROUP BY 
    prod.prod_cat
ORDER BY 
	SUM(trans.total_amt) DESC;


-- Top 5 Total Spend per customer incl. City & Age --
SELECT CONCAT('Total Sales: £', FORMAT(SUM(trans.total_amt),0)) AS Spend_per_customer, 
	 cust.cust_id, cust.city, cust.customer_age
FROM ret_transactions AS trans
JOIN ret_customer AS cust ON trans.cust_id = cust.cust_id
WHERE trans.total_amt > 0 
GROUP BY trans.cust_id, cust.city, cust.customer_age
ORDER BY SUM(trans.total_amt) ASC
LIMIT 5;

-- BOTTOM 5 Total Spend per customer incl. City & Age --
SELECT CONCAT('Total Sales: £', FORMAT(SUM(trans.total_amt),0)) AS Spend_per_customer, 
	 cust.cust_id, cust.city, cust.customer_age
FROM ret_transactions AS trans
JOIN ret_customer AS cust ON trans.cust_id = cust.cust_id
WHERE trans.total_amt > 0 
GROUP BY trans.cust_id, cust.city, cust.customer_age
ORDER BY SUM(trans.total_amt) ASC
LIMIT 5;

SELECT 
    cust_id, 
    store_type, 
    prod_cat_code,
    total_amt,
    CASE
        WHEN RANK() OVER (ORDER BY total_amt DESC) <= 5 THEN 'Top Spenders'
        WHEN RANK() OVER (ORDER BY total_amt ASC) <= 5 THEN 'Bottom Spenders'
        ELSE 'Others'
    END AS spender_category
FROM 
   ret_transactions;
   
SELECT 
    cust_id, 
    total_amt,
    store_type, 
    prod_cat_code,
    CASE   
		WHEN total_amt > 210125 THEN 'Top Spenders'
		WHEN total_amt BETWEEN 0 AND 145 THEN 'Bottom Spenders'
		ELSE 'Others'
	END AS spender_category
FROM 
   ret_transactions
WHERE
    total_amt > 210125 OR total_amt BETWEEN 0 AND 143;
    
--  'when' case to add column bottom spenders --
    
SELECT 
    CONCAT('Total Sales: £', FORMAT(SUM(trans.total_amt), 0)) AS Spend_per_customer,
    cust.cust_id,
    cust.city,
    cust.customer_age,
    CASE
        WHEN SUM(trans.total_amt) > 97 THEN 'Bottom 5 Spenders'
    END AS spender_category
FROM 
    ret_transactions AS trans
JOIN 
    ret_customer AS cust ON trans.cust_id = cust.cust_id
WHERE 
    trans.total_amt > 0 
GROUP BY 
    trans.cust_id, cust.city, cust.customer_age
ORDER BY 
    SUM(trans.total_amt) ASC
LIMIT 5;    


--  Top 5 Total Spend per customer incl. City & Age, Use when case to add column top 5 spenders --
SELECT 
    CONCAT('Total Sales: £', FORMAT(SUM(trans.total_amt), 0)) AS Spend_per_customer,
    cust.cust_id,
    cust.city,
    cust.customer_age,
    CASE
        WHEN SUM(trans.total_amt) > 210120 THEN 'Top 10 Spenders'
    END AS spender_category
FROM 
    ret_transactions AS trans
JOIN 
    ret_customer AS cust ON trans.cust_id = cust.cust_id
WHERE 
    trans.total_amt > 0 
GROUP BY 
    trans.cust_id, cust.city, cust.customer_age
ORDER BY 
    SUM(trans.total_amt) DESC
LIMIT 5;     
    
-- find average age of top buyers --

SELECT 
    AVG(cust.customer_age) AS average_age_of_top_20_customers
FROM 
    (SELECT 
        cust.customer_age
    FROM 
        ret_transactions AS trans
    JOIN 
        ret_customer AS cust ON trans.cust_id = cust.cust_id
    GROUP BY 
        trans.cust_id, cust.city, cust.customer_Age
    ORDER BY 
        SUM(trans.total_amt) DESC
    LIMIT 20) AS top_20_customers;


-- Top 5 Total Spend per customer with Age --

SELECT 
    cust.cust_id, 
    prod.prod_subcat_code,
    COUNT(*) AS purchase_count
FROM 
    ret_customer AS cust
LEFT JOIN 
    ret_transactions AS trans  ON cust.cust_id = trans.cust_id
LEFT JOIN 
    ret_product AS prod ON trans.prod_subcat_code = prod.prod_subcat_code
WHERE 
    trans.total_amt > 0 
GROUP BY 
    cust.cust_id, 
    prod.prod_subcat_code
    
    
-- ORDER BY cust.cust_id, purchase_count DESC
LIMIT 5;


SELECT 
    CONCAT('Total Sales: £', FORMAT(SUM(trans.total_amt), 0)) AS Spend_per_category,
    prod.prod_cat,
    cust.city,
    cust.cust_id,
    cust.customer_age
FROM 
    ret_transactions AS trans
JOIN 
    ret_customer AS cust ON trans.cust_id = cust.cust_id
JOIN 
    ret_product AS prod ON trans.prod_subcat_code = prod.prod_subcat_code
WHERE 
    trans.total_amt > 0 
GROUP BY 
    prod.prod_cat
ORDER BY 
    SUM(trans.total_amt) DESC
LIMIT 5;

-- Show Average Spend and items by Customer --

SELECT 
    CONCAT('£', FORMAT(AVG(average_spend_per_customer), 0)) AS Average_spend,
    FORMAT(AVG(average_items_per_customer), 1) AS Average_items
	FROM (SELECT cust_id, 
        AVG(total_amt) AS average_spend_per_customer,
        AVG(qty) AS average_items_per_customer
    FROM ret_transactions
    GROUP BY cust_id) AS subquery;
    
    SELECT 
    CONCAT('£', FORMAT(AVG(average_spend_per_customer), 0)) AS Average_spend,
    FORMAT(AVG(average_items_per_customer), 1) AS Average_items,
    prod_cat
FROM 
    (SELECT 
        cust_id, 
        prod_cat,
        AVG(total_amt) AS average_spend_per_customer,
        AVG(qty) AS average_items_per_customer
    FROM 
        ret_transactions
    JOIN 
        ret_product ON ret_transactions.prod_cat_code = ret_product.prod_cat_code
    GROUP BY 
        cust_id, prod_cat) AS subquery
GROUP BY 
    prod_cat;
    
    
