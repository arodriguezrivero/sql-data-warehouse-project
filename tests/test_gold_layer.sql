--Check if all dimension tables can succesfully jointo the fact table
--Evaluate: c.customer_key IS NULL and p.product_key IS NULL
--Expect: no results

SELECT *
FROM gold.fact_sales f
  LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
  LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
--WHERE c.customer_key IS NULL
WHERE p.product_key IS NULL