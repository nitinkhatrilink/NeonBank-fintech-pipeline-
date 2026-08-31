# NeoBank Analytics: End-to-End Fintech Data Pipeline

This repository contains an end-to-end data engineering and BI pipeline built to simulate a real-world fintech environment. It covers raw data ingestion, dbt transformations, Kimball dimensional modeling, data governance, and Power BI reporting with Row-Level Security (RLS).

I built this to practice modern data stack patterns, optimize SQL/DAX performance, and demonstrate how to handle messy, real-world data securely.

---

## 🛠️ Tech Stack
- **Data Warehouse**: Snowflake (Enterprise Edition)
- **Transformation & Modeling**: dbt Core
- **Orchestration & CI/CD**: GitHub Actions
- **Business Intelligence**: Power BI (Import mode, DAX time intelligence, RLS)
- **Data Generation**: Python (Standard Library)

---

## 📊 The Scenario
NeoBank operates with six disparate source systems. To test pipeline resilience, I wrote a Python script to generate synthetic datasets with intentional, real-world data quality issues: duplicates, mixed date formats, embedded JSON, and missing values.

**Sources**:
- `customers.csv` (CRM)
- `accounts.csv` (Core Banking)
- `transactions.csv` (Ledger, contains embedded JSON metadata)
- `loans.csv` (Lending)
- `kyc_events.csv` (Compliance event log)
- `fx_rates.json` (Semi-structured, nested arrays)

---

## 🚀 Pipeline Architecture (Medallion)

### 1. Bronze Layer (Raw Ingestion)
- Data lands via Snowflake internal stages (`@NEOBANK_STAGE`) using `COPY INTO`.
- Full fidelity: Columns load as `VARCHAR` or `VARIANT` (for JSON), with an appended `_loaded_at` audit timestamp.

### 2. Silver Layer (Staging & Wrangling)
- Built as dbt staging views (one per source).
- **Transformations**: Deduplication (`ROW_NUMBER` + `QUALIFY`), safe type casting (`TRY_TO_DATE`), boolean normalization, null handling, and flattening nested JSON via `LATERAL FLATTEN`.

### 3. Gold Layer (Dimensional Modeling)
- Reshaped into a Star Schema optimized for Power BI.
- **Conformed Dimensions**: `dim_customer`, `dim_account`, `dim_date`.
- **Fact Tables**: `fct_transactions`, `fct_loans`.
- **Advanced dbt**: 
  - Incremental materialization for `fct_transactions` to optimize compute.
  - SCD Type 2 tracking for KYC statuses using `dbt snapshots`.
  - Pre-aggregated marts (`agg_customer_360`, `agg_daily_volume`) to speed up dashboard rendering.

---

## 🛡️ Governance & Security
Fintech data requires strict access control. This pipeline enforces:
- **RBAC**: Strict functional roles (`FT_LOADER`, `FT_TRANSFORMER`, `FT_ANALYST`, `FT_ANALYST_PII`) following least-privilege principles.
- **Dynamic Data Masking**: PII (emails, DOB, full names) is masked at query time via Snowflake policies (e.g., analysts see `***@example.com`). Re-applied automatically via dbt post-hooks.
- **Cost Control**: X-SMALL virtual warehouses with 60-second auto-suspend, guarded by account-level Resource Monitors

---

## 📈 Power BI Integration
The Gold tables connect to Power BI Desktop via Import mode.

- **Dashboards**: Executive Overview, Transaction Analysis, Lending Risk, and Customer 360.
- **DAX Measures**: Custom KPIs including Total Spend USD, Default Rate %, MoM Growth % (using time intelligence), and International Spend %.
- **Security**: Snowflake Dynamic Data Masking complements Power BI Row-Level Security (RLS) based on user principal roles, ensuring baseline analysts see masked data while privileged teams see plaintext, all transparent to the dashboard layer.

---


---
*Built to refine hands-on skills in Snowflake, dbt, and Power BI. Feedback and PRs are welcome.*
