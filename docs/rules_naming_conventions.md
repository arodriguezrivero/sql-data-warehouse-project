## Defining The Naming Conventions

## General Principles

* **Naming Conventions:** Snake Case (lowercase_convention). Lowercase letters and underscores to separarate words.
* **Language:** English
* Avoid reserved words in SQL


## Table Naming Conventions

### Bronze Rules

-	All names must start with the source system name, and table names must match their original names without renaiming.
-	**[sourcesystem]_[entity]**
		- **[soursystem]:** Name of the source system (e.g: crm, erp)
		- **[entity]:** Exact table name from the source system
		- **Example:** crm_customer_info: Customer information from the CRM system.

###Silver Rules
-	All names must start with the source system name, and table names must match their original names without renaiming.
-	**[sourcesystem]_[entity]**
		- **[soursystem]:** Name of the source system (e.g: crm, erp)
		- **[entity]:** Exact table name from the source system
		- **Example:** crm_customer_info: Customer information from the CRM system.

### Gold Rules
-	All names must use meaninful, business-aligned names for tables, starting with the category prefix.
-	**[category]_[entity]**
	- **[category]:** Describes the role of the table, such as dim (dimension) or fact (fact table)
	- **[entity]:** Descriptive name of the table, aligned with the business domain (eg., customers, products, sales)
	- **Examples:**
		- dim_customers : dimension table for customer data
		- fact_sales : fact table containing sales transactions
		
		
### Category Patterns

|Pattern	 |   Meaning           | Example(s)                      |
|------------|---------------------|---------------------------------|
| dim_	     | Dimension Table	   | dim_customer, dim_product       |
| Fact_	Fact | Table	           | fact_sales                      |
| Agg_	     | Aggregated Table	   | agg_customer, agg_sales_monthly |


## Column Naming Conventions

### Surrogate Key
-	All primary keys in dimension tables must use the suffix _key
-	**[table_name]_key**
		- **[table_name]:** refers to the name of the table or entity the key belongs to.
		- **_key:** a suffix indicating that this column is a surrogated key.
		- **Example:** customer_key : surrogate key in the dim_customers table

### Technical Columns
-	All technical columns must start with the prefix dwh_ , followed by a descriptive name indicating the column’s purpouse.
-	**dwh_[columna_name]**
		- **dwh:** prefix exclusively for system-generated metadata
		- **[columna_name]:** descriptive name indicating the column’s purpose.
		- **Example:** dwh_load_date : system-generated columna used yo store the data when the record was loaded.

### Stored Procedure
-	All stored procedures used for loading data must follow the naming pattern: load_[layer]
		- **[layer]:** represents the layer being loaded, such as bronce, silver or gold.
		- **Example:** 
			- load_bronze : stored procedure for loading data into Bronze Layer
			- load_silver : stored procedure for loadin data into the Silver Layer
