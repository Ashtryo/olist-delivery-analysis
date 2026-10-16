# Olist E-Commerce Delivery Delays & Customer Satisfaction Analysis

## Overview
Delivery performance is a critical driver of customer retention and marketplace reputation. This project analyzes **99,441 historical orders** from **Olist** (Brazil's largest e-commerce marketplace) to quantify how delivery delays affect customer review scores and to identify whether delays stem from **seller fulfillment** or **carrier transit**.

Using **Python (`pandas`, `numpy`, `sqlalchemy`)**, raw transactional datasets are cleaned, validated, and transformed into analysis-ready tables exported directly to **MySQL (`olist_db`)** for downstream **SQL** analysis and **Power BI** dashboarding.

---

## Key Analytical Findings (Data Preparation Phase)
- **Analyzable Cohort:** Out of **99,441** raw orders, **97,905** represent valid completed purchases (`is_valid_order = 1`), and **96,203** are verified delivered orders suitable for delay analysis (`in_delay_analysis = 1`).
- **Baseline Late-Delivery Rate:** **8.13%** (**7,822** late orders vs. **88,381** on-time deliveries).
- **Seller vs. Carrier Breakdown:** Across delivered orders, total delivery time averages **12.09 days** (median **10.0 days**), split between:
  - **Seller Handling Time:** Mean **2.75 days** (median **2.0 days**) from purchase to carrier pickup.
  - **Carrier Transit Time:** Mean **8.88 days** (median **7.0 days**) from carrier pickup to customer delivery.

---

## Data Cleaning & Feature Engineering Workflow

1. **Data Quality Inspection:** Audited 8 source datasets (`orders`, `order_items`, `payments`, `reviews`, `customers`, `products`, `sellers`, and `product_category_name_translation`) for schema consistency, missing values, and duplicate records.
2. **Non-Destructive Order Flagging:** Preserved 100% of raw order records for auditability using binary flags instead of row deletion:
   - `is_canceled`: Flagged **625** cancelled orders.
   - `in_date_range`: Isolated core orders between **Jan 2017 and Aug 2018** (flagging **349** boundary orders).
   - `missing_items`: Flagged **775** orders with no matching item records.
   - `is_valid_order` & `in_delay_analysis`: Composite flags isolating valid purchases (**97,905**) and verified delivered orders (**96,203**).
3. **Review Deduplication:** Resolved one-to-many review anomalies (**551** duplicate order reviews) by sorting by `review_answer_timestamp` and retaining only the latest review per order (**98,673** unique reviews).
4. **Product Category Standardization:** Merged English category translations, manually mapped **2** missing categories (`pc_gamer` and `portable_kitchen_food_preparers`), and labeled **610** uncategorized products as `unknown`.
5. **Delivery & Bottleneck Feature Engineering:** Calculated exact timestamp differences to derive `is_late`, `delivery_days`, `delivery_delay_days`, `seller_handling_days`, and `transit_days`.
6. **Timestamp Anomaly Remediation:** Masked **14** contradictory delivery records (`inconsistent_delivery = 1`), **166** negative seller handling durations, and **23** negative carrier transit durations as `NA` to prevent distortion of summary averages.
7. **MySQL Database Export:** Loaded all 7 cleaned tables into `olist_db` via `SQLAlchemy` and `PyMySQL` using interactive credential prompting (`getpass`).

---

## Dataset & Power BI Dashboard Access
- **Raw Dataset:** The raw CSV files are sourced from the [Brazilian E-Commerce Public Dataset by Olist on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
- **Power BI Dashboard (`.pbix`):** Due to GitHub's web file size limits, the interactive Power BI dashboard file is available in the **Releases** section of this repository.

---

## Tech Stack
- **Language & Libraries:** Python 3, `pandas`, `numpy`, `sqlalchemy`, `pymysql`
- **Database:** MySQL (`olist_db`)
- **BI & Visualization:** Power BI

---

## How to Run Locally

1. **Install required Python packages:**
   ```bash
   pip install pandas numpy sqlalchemy pymysql