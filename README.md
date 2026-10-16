# Olist E-Commerce Delivery Delays & Customer Satisfaction Analysis

## Overview
Delivery performance is a key driver of customer satisfaction and marketplace reputation. This project analyzes **99,441 historical orders** from **Olist**, a Brazilian e-commerce marketplace platform, to quantify how delivery delays affect customer review scores and to identify whether delays stem from **seller fulfillment** or **carrier transit**.

Using **Python (`pandas`, `numpy`, `sqlalchemy`)**, the raw transactional datasets are cleaned, validated, and transformed into analysis-ready tables exported to **MySQL (`olist_db`)**. The analysis is then done in **SQL**, and the results are presented in a 4-page **Power BI** dashboard with recommendations.

---

## Key Findings

| # | Finding | Source |
|---|---|---|
| 1 | **8.13%** of orders arrive late (7,822 late vs. 88,381 on time) | SQL Q1 |
| 2 | Late orders average **2.57 stars** against **4.29** for on-time orders, a gap of about **1.7 stars** | SQL Q2 |
| 3 | Reviews hold up for delays of 1 to 3 days (3.77 stars), then **collapse after 4 days** (2.32 stars). **69%** of orders delayed 8+ days get a 1-star review | SQL Q5 |
| 4 | Late orders are only 8% of orders but account for **38%** of all 1-star reviews | SQL Q6 |
| 5 | Late orders spend about **25 days with the carrier** against 7 for on-time orders, but only about **3 more days** with the seller | SQL Q7 |
| 6 | **Northeast states** (AL, MA, PI, CE, SE) are 15% to 24% late, against 5.9% in São Paulo | SQL Q4 |
| 7 | Late rates spike in **Nov 2017** (14.3%) and **Feb to Mar 2018** (16.0% and 21.4%) | SQL Q3 |
| 8 | Product category matters little: only `audio` stands out (13.0%), the rest are within 1 to 2 points of the average | SQL Q8 |

### Data preparation summary
- **Analyzable cohort:** out of **99,441** raw orders, **97,905** are valid completed purchases (`is_valid_order = 1`), and **96,203** are verified delivered orders suitable for delay analysis (`in_delay_analysis = 1`).
- **Delivery time (analyzed orders):** averages **12.07 days** (median 10), split between:
  - **Seller handling time:** mean **2.71 days** (median 2) from purchase to carrier pickup.
  - **Carrier transit time:** mean **8.89 days** (median 7) from carrier pickup to customer delivery.

---

## Dashboard

| Executive Summary | Delay Impact |
|---|---|
| ![Executive Summary](images/page1_executive_summary.png) | ![Delay Impact](images/page2_delay_impact.png) |

| Root Causes | Recommendations |
|---|---|
| ![Root Causes](images/page3_root_causes.png) | ![Recommendations](images/page4_recommendations.png) |

The interactive Power BI file (`.pbix`) is available in the **Releases** section of this repository, because of GitHub's file size limits.

| Page | Question it answers |
|---|---|
| Executive Summary | How big is the problem? KPIs, monthly late rate, on-time vs late review score |
| Delay Impact | How much do delays hurt reviews? Review score and 1-star share by delay bucket |
| Root Causes | Where do delays come from? Late rate by state, seller vs carrier time, category |
| Recommendations | What should Olist do? Four actions, each backed by a number from the pages before |

All dashboard measures filter on `in_delay_analysis = 1`, so the totals match the SQL results (96,203 orders, 8.13% late).

---

## Data Cleaning & Feature Engineering Workflow

1. **Data quality inspection:** audited 8 source datasets (`orders`, `order_items`, `payments`, `reviews`, `customers`, `products`, `sellers`, and `product_category_name_translation`) for schema consistency, missing values, and duplicate records.
2. **Non-destructive order flagging:** preserved 100% of raw order records for auditability using binary flags instead of row deletion:
   - `is_canceled`: flagged **625** cancelled orders.
   - `in_date_range`: isolated core orders between **Jan 2017 and Aug 2018** (flagging **349** boundary orders).
   - `missing_items`: flagged **775** orders with no matching item records.
   - `is_valid_order` and `in_delay_analysis`: composite flags isolating valid purchases (**97,905**) and verified delivered orders (**96,203**).
3. **Review deduplication:** resolved one-to-many review anomalies (**551** duplicate order reviews) by sorting by `review_answer_timestamp` and keeping only the latest review per order (**98,673** unique reviews).
4. **Product category standardization:** merged English category translations, manually mapped **2** missing categories (`pc_gamer` and `portable_kitchen_food_preparers`), and labeled **610** uncategorized products as `unknown`.
5. **Delivery and bottleneck feature engineering:** calculated exact timestamp differences to derive `is_late`, `delivery_days`, `delivery_delay_days`, `seller_handling_days`, and `transit_days`.
6. **Timestamp anomaly remediation:** set **14** contradictory delivery records (`inconsistent_delivery = 1`), **166** negative seller handling durations, and **23** negative carrier transit durations to `NA`, to prevent distortion of summary averages.
7. **MySQL export:** loaded 7 cleaned tables into `olist_db` via `SQLAlchemy` and `PyMySQL`, with interactive credential prompting (`getpass`).

---

## SQL Analysis
Eight business questions in `sql/olist_business_questions.sql`. Every delay query filters on `in_delay_analysis = 1`.

1. Overall late-delivery rate
2. Review score, on time vs late
3. Late rate and delivery time by month
4. Late rate and review score by customer state
5. Review score by delay bucket (On time, 1-3, 4-7, 8+ days late)
6. Share of 1-star reviews that came from late orders
7. Seller handling time vs carrier transit time
8. Product categories with the highest late rate (300+ orders)

Techniques used: multi-table joins, `CASE` bucketing, CTEs, `GROUP BY` with `HAVING`, and aggregate functions. The category query uses a CTE of distinct (order, category) pairs, so an order with several items is counted once per category.

---

## Recommendations

| Action | Evidence |
|---|---|
| **Warn customers before reviews collapse:** send delay messages and offer compensation once an order is about 3 days past its promised date | Reviews fall from 3.77 to 2.32 stars after 4 days late |
| **Review carrier performance first** | Late orders lose about 18 extra days in transit, but only about 3 with the seller |
| **Fix the northeast:** more realistic delivery estimates, and test regional hubs or closer stock | AL, MA, PI, CE and SE are 15% to 24% late, against 5.9% in SP |
| **Plan for peak months:** add carrier capacity and set cautious delivery promises | Late rate spikes in Nov 2017 and Feb to Mar 2018 |

---

## Limitations and Next Steps
- **Association, not proof of cause.** Late orders score lower, but they also differ in other ways, such as distance and region.
- **Not yet analyzed:** distance between seller and customer, same-state vs cross-state shipping, seller-level performance, and product weight. The geolocation table and product size columns were left out of this version to keep the scope focused. The northeast and carrier findings suggest distance as a likely driver, so it is the first thing to test next.
- **Small differences between SQL and the dashboard.** SQL queries that join reviews drop orders with no review (for example, 87,902 on-time orders in Q2), while the dashboard counts every order in the analysis (88,381). The rankings and conclusions are the same.
- **Analysis window:** purchases from Jan 2017 to Aug 2018.

---

## Dataset
The raw CSV files come from the [Brazilian E-Commerce Public Dataset by Olist on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). They are not included in this repository.

## Tech Stack
- **Language and libraries:** Python 3, `pandas`, `numpy`, `sqlalchemy`, `pymysql`
- **Database:** MySQL (`olist_db`)
- **BI and visualization:** Power BI

---

## Repository Structure

```
olist-delivery-analysis/
├── notebooks/
│   └── Olist_Delivery_Delays_Data_Cleaning.ipynb
├── sql/
│   └── olist_business_questions.sql
├── images/                # dashboard screenshots
└── README.md
```
The Power BI file (`olist_dashboard.pbix`) is in the **Releases** section.

## How to Run Locally

1. **Install the required Python packages:**
   ```bash
   pip install pandas numpy sqlalchemy pymysql
   ```
2. **Download the dataset** from Kaggle and place the CSV files in the **same folder as the notebook**. The notebook reads them by file name from its working directory.
3. **Create the database** in MySQL:
   ```sql
   CREATE DATABASE olist_db;
   ```
4. **Run the notebook** top to bottom. It cleans the data and writes 7 tables to `olist_db`, asking for your MySQL password when it runs.
5. **Run the queries** in `sql/olist_business_questions.sql`.
6. **Open the dashboard:** download `olist_dashboard.pbix` from the Releases section, and open it in Power BI Desktop. The file contains the imported data, so it opens without MySQL. To refresh it, point the data source to your own `olist_db`.

---

## Author
**[ANSH BANSAL]** 
