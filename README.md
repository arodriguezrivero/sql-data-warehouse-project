# 🚀 Modern Data Warehouse Implementation: AeroCycle Global

[![SQL](https://img.shields.io/badge/SQL-MSSQL%20Server-red.svg)]()
[![Architecture](https://img.shields.io/badge/Architecture-Medallion-gold.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()

## 📌 Project Overview
This project demonstrates the end-to-end design and implementation of a **Modern Data Warehouse** for **AeroCycle Global**, a hypothetical bicycle manufacturer. The goal was to consolidate fragmented data from CRM and ERP systems into a unified analytical hub using the **Medallion Architecture**.

## 🏗️ Data Architecture
The pipeline follows the Medallion framework to ensure data quality and lineage:

1. **Bronze Layer:** Raw data ingestion from CRM (Sales, Products, Customers) and ERP (Locations, Categories) sources.
2. **Silver Layer:** Data cleansing, deduplication, and schema standardization.
3. **Gold Layer:** Business-ready dimensional model (Star Schema) optimized for BI and Reporting.

<img width="1101" height="801" alt="Architecture-DWH drawio" src="https://github.com/user-attachments/assets/0f2748cd-a1d6-45b0-ad8b-7b2556523c82" />


## 🛠️ Key Technical Features

### 1. Robust Naming Conventions
To maintain a production-grade environment, I implemented a strict naming policy:
* **Snake_case** for all objects.
* **Layer Prefixes:** `crm_`, `erp_` for Bronze/Silver; `dim_`, `fact_`, `agg_` for Gold.
* **Surrogate Keys:** All dimensions use a `_key` suffix for high-performance joins.
* **Metadata Tracking:** Every record includes `dwh_load_date` for auditability.

### 2. ETL & Orchestration
The data flow is managed via modular **Stored Procedures** (`load_bronze`, `load_silver`, `load_gold`), allowing for:
* Incremental or full refresh strategies.
* Standardized error handling and logging.
* Transformation logic (Mapping, Casting, and Formatting).

### 3. Data Catalog (Gold Layer)
The business layer is fully documented to empower analysts:
* **`dim_customers`**: Enriched customer demographics and geography.
* **`dim_products`**: Full product lifecycle and categorization.
* **`fact_sales`**: Granular transactional data linked to dimensions.

## 📂 Project Structure
```text
├── src/
│   ├── bronze/          # DDL and Load scripts for Raw layer
│   ├── silver/          # Cleansing and normalization scripts
│   └── gold/            # Dimensional modeling (Facts & Dims)
├── docs/
│   ├── naming_convention.md
│   └── data_catalog.md  # Detailed schema definitions
└── tests/               # Data quality validation scripts
```

## 🚀 How to Run
Clone this repository.

1. Execute the init_database.sql script to set up the environment.

2. Run the Stored Procedures in sequence: Bronze -> Silver -> Gold.

##👩‍💻 About Me

I am a Senior Data Engineer focused on building scalable, well-documented data infrastructures. My goal is to transform messy data into strategic business assets.

