/*
Data Cleaning and Transformation (crm_cust_info): Silver Layer

To start, I check all the data into bronze Layer, in order to clean it. Create queries to do that
Once I have the queries, I can Load cleaned data into Silver Layer

*/


-- Check for nulls or Duplicates in Primary Key
-- Expectation: No result

SELECT 
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

/*
Result:

cst_id      count
----------- -----------
29449       2
29473       2
29433       2
NULL        3
29483       2
29466       3

(6 rows affected)
*/

/* In-depth analysis */

SELECT 
	*
FROM bronze.crm_cust_info
WHERE cst_id = 29466

/* 
cst_id      cst_key                                            cst_firstname                                      cst_lastname                                       cst_marital_status                                 cst_gndr                                           cst_create_date
----------- -------------------------------------------------- -------------------------------------------------- -------------------------------------------------- -------------------------------------------------- -------------------------------------------------- ---------------
29466       AW00029466                                         NULL                                               NULL                                               NULL                                               NULL                                               2026-01-25
29466       AW00029466                                         Lance                                              Jimenez                                            M                                                  NULL                                               2026-01-26
29466       AW00029466                                         Lance                                              Jimenez                                            M                                                  M                                                  2026-01-27

(3 rows affected)

In this case, there are 3 inputs. We have toe pick one. In this table we onliy must have one register per customer. So I decided to pick the most recent in creation date. To do that, I ranked those values to find the highest date 
*/

SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
--WHERE cst_id = 29466

--Pick only the most recent input and NOT NULL customer id
SELECT
	*
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) t WHERE flag_last = 1;

/*
 Check for unwanted spaces
 Expect no results
*/

--First Name
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

--(15 rows affected)

-- Last Name
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--(17 rows affected)

--Gender
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

--(0 rows affected) No issues

--Customer Key
SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key)

--(0 rows affected) No issues

/*
   We transform those with issues: First Name and Last Name
*/
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) t WHERE flag_last = 1;


/*
   Data standarization & Consistency
*/

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info

/*
cst_gndr
--------------------------------------------------
NULL
F
M

(3 rows affected)


cst_marital_status
--------------------------------------------------
S
NULL
M

(3 rows affected)
*/

--As a convention, I decided to give more friendly names
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	cst_marital_status = (CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				               WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		                  ELSE 'n/a'
                          END),	
	cst_gndr = (CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		        ELSE 'n/a'
                END),
	cst_create_date
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) t WHERE flag_last = 1;



/*
Since the table has cst_create_date as Date, that ensures that there is no strange values as string or anything else.
In this case, if we have nulls, we leave it as it is. In case we have another convention like stablish a special date like 0001-01-01 for those null, we can tansform then. But in our case it's fine.
*/

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
 AND cst_create_date IS NULL

 --(0 rows affected)


 /*****************************************************************************************************

 Now is time to INSERT into Silver Layer. We use the last complete query with all the transformations

 *******************************************************************************************************/
 INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
 )
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	cst_marital_status = (CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				               WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		                  ELSE 'n/a'
                          END),	
	cst_gndr = (CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		        ELSE 'n/a'
                END),
	cst_create_date
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) t WHERE flag_last = 1;

--(18484 rows affected)

SELECT * FROM silver.crm_cust_info