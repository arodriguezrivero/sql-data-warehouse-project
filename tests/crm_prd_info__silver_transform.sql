/*
Data Cleaning and Transformation (crm_prd_info): Silver Layer

To start, I check all the data into bronze Layer, in order to clean it. Create queries to do that
Once I have the queries, I can Load cleaned data into Silver Layer

*/


-- Check for nulls or Duplicates in Primary Key
-- Expectation: No result

SELECT 
	prd_id,
	COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

--OK no records


/*
Final Select to use in order to insert into Silver Layer of crm_prd_info
*/

SELECT 
	prd_id,	
	REPLACE(SUBSTRING(prd_key,1,5), '-','_' ) AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	TRIM(prd_nm),
	ISNULL(prd_cost,0) AS prd_cost,
	prd_line = CASE UPPER(TRIM(prd_line))  
					WHEN 'M' THEN 'Mountain'
					WHEN 'R' THEN 'Road'
					WHEN 'S' THEN 'Other Sales'
					WHEN 'T' THEN 'Touring'					
					ELSE 'n/a'
					END,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	prd_end_dt = (CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE))
FROM bronze.crm_prd_info
ORDER BY prd_key ASC

/******************************************
Final Insert into silver.crm_prd_info
*******************************************/

INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt)
SELECT 
	prd_id,	
	REPLACE(SUBSTRING(prd_key,1,5), '-','_' ) AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	TRIM(prd_nm),
	ISNULL(prd_cost,0) AS prd_cost,
	prd_line = CASE UPPER(TRIM(prd_line))  
					WHEN 'M' THEN 'Mountain'
					WHEN 'R' THEN 'Road'
					WHEN 'S' THEN 'Other Sales'
					WHEN 'T' THEN 'Touring'					
					ELSE 'n/a'
					END,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	prd_end_dt = (CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE))
FROM bronze.crm_prd_info


/**********************************************/
/* Block for varoius cheks, selects, etc      */
/*============================================*/

--For checking purposes
--WHERE REPLACE(SUBSTRING(prd_key,1,5), '-','_' ) NOT IN (SELECT distinct id FROM bronze.erp_px_cat_g1V2)

--WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN (SELECT sls_prd_key FROM bronze.crm_sales_details) ...products that don't have any orders

--We can check in the erp cat table
SELECT distinct id FROM bronze.erp_px_cat_g1V2

--prd_key...we need it in order to join with sls_prd_key
SELECT sls_prd_key FROM bronze.crm_sales_details

--Check for Nulls or Negative Numbers
SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL


SELECT distinct prd_line
FROM bronze.crm_prd_info

SELECT distinct prd_line
FROM silver.crm_prd_info

--Invalid Date Orders

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--Important Business Rule: End Date should be the start date of the NEXT record - 1, in same product (same prd_key). Because product table has history of updates during time, so we can se how the X product has incresed
--                         its value over the time. (or decrease..depends on the business)

--Test in at leas two cases:
SELECT prd_id,
	   prd_key,
	   prd_nm,
	   prd_cost,
	   prd_line,
	   prd_start_dt,
	   prd_end_dt,
	   (CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE)) AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509')






/*============================================*/