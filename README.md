# Olist Delivery Delays & Customer Satisfaction Analysis

## About This Project
When an online order arrives late, how much does it actually hurt customer ratings—and who is responsible for the delay: the seller packing the box or the shipping carrier delivering it?

This project looks at **99,441 real orders** from **Olist**, Brazil's largest online marketplace, from January 2017 to August 2018. The goal is simple: clean up the raw data, measure how late deliveries affect customer review scores, find out where delays happen in the shipping journey, and turn the findings into a clear Power BI dashboard.

---

## Key Numbers at a Glance
- **Total Raw Orders Checked:** 99,441
- **Valid, Delivered Orders Analyzed:** 96,203
- **On-Time Orders:** 88,381 (91.87%)
- **Late Orders:** 7,822 (**8.13% late delivery rate**)
- **Average Delivery Journey:** ~12.1 days total
  - **Seller Handling Time:** ~2.8 days on average (from purchase to carrier pickup)
  - **Carrier Transit Time:** ~8.9 days on average (from carrier pickup to customer doorstep)

---

## Project Workflow

### 1. Data Cleaning & Preparation (Python)
The raw Olist data comes as 8 separate CSV files (`orders`, `order_items`, `payments`, `reviews`, `customers`, `products`, `sellers`, and `product_category_name_translation`). Before running any analysis, the data was cleaned in Python (`pandas` and `numpy`):

- **Converted dates properly:** Turned text timestamps into real date formats so delivery times could be calculated accurately.
- **Flagged orders instead of deleting them:** Rather than deleting rows and losing track of what was removed, simple `1/0` flag columns were added:
  - `is_canceled`: 625 cancelled orders.
  - `in_date_range`: 349 orders placed outside the main Jan 2017 – Aug 2018 window.
  - `missing_items`: 775 orders with no product rows in the items table.
  - `is_valid_order = 1`: 97,905 real orders that passed all three checks above.
  - `in_delay_analysis = 1`: 96,203 valid orders that were actually delivered and have reliable delivery dates.
- **Removed duplicate reviews:** Some orders had multiple reviews (551 extra rows). The data was sorted by answer time to keep only the latest review per order (98,673 unique reviews) and unused text columns were dropped.
- **Translated product categories:** Merged English category names into the products table, manually added 2 missing translations (`pc_gamer` and `portable_kitchen_food_preparers`), and labeled 610 products without a category as `unknown`.
- **Built delivery metrics:** Created `delivery_days`, `delivery_delay_days`, and `is_late` (calculated from exact timestamps before rounding). Also split the delivery timeline into `seller_handling_days` and `transit_days`.
- **Cleaned impossible dates:** Blanked out delivery metrics for 14 contradictory records (such as orders marked "delivered" with no delivery date, or cancelled orders with a delivery date) and removed 189 impossible negative durations (166 negative seller handling times and 23 negative carrier transit times).
- **Saved to MySQL:** Exported all 7 cleaned tables directly into a MySQL database (`olist_db`).

---

### 2. Business Questions Answered (MySQL)
Using the cleaned database (`in_delay_analysis = 1`), the SQL script (`olist business questions.sql`) answers 8 core business questions:

1. **Overall Late Rate:** Out of all analyzable delivered orders, what percentage arrived late?
2. **Impact on Review Scores:** Do late orders get lower review scores than on-time orders, and how much does the share of 1-star reviews jump?
3. **Monthly Trends & Seasonality:** How do order volume, late delivery rates, and average delivery times change month by month?
4. **State-by-State Performance:** Which customer states experience the highest late delivery rates, and how do customers in those states rate their orders?
5. **Delay Severity Buckets:** How badly do review scores drop as delays get longer (`on_time`, `1-3 days late`, `4-7 days late`, vs. `8+ days late`)?
6. **1-Star Review Breakdown:** Among all 1-star reviews, what percentage belong to orders that were delivered late?
7. **Seller vs. Carrier Bottlenecks:** When an order is late, which part of the journey takes longer—the seller preparing the parcel or the carrier delivering it?
8. **Problem Product Categories:** Which product categories have the highest late delivery rates (looking at categories with at least 300 orders)?

---

### 3. Interactive Dashboard (Power BI)
The cleaned data is connected to Power BI (`olist_dashboard.pbix`) to visualize:
- Overall delivery KPIs (total orders, late rate, average delivery time, and review score).
- Customer satisfaction comparisons between on-time and delayed orders across delay buckets.
- Monthly order trends and seasonal spikes in late deliveries.
- Geographic and product category breakdowns to spot where delays happen most.

---

## Tools Used
- **Python (`pandas`, `numpy`, `sqlalchemy`, `pymysql`):** Data cleaning, feature creation, and database upload.
- **MySQL:** Storing cleaned tables and running business analysis queries.
- **Power BI:** Building the final interactive report.

---

## Files in This Repository
- `Olist_Delivery_Delays_Data_Cleaning.ipynb` — Jupyter Notebook with the full Python cleaning and preparation steps.
- `olist business questions.sql` — SQL queries answering the 8 business questions.
- `olist_dashboard.pbix` — Interactive Power BI dashboard built on the cleaned data.
- Raw Olist CSV files — Source datasets used by the notebook.

---

## How to Run This Project

1. **Clone or download this repository** to your computer.
2. **Install the required Python libraries:** `pip install pandas numpy sqlalchemy pymysql`
3. **In MySQL, create an empty database:** `CREATE DATABASE olist_db;`
4. **Run the notebook from top to bottom.** It cleans the data and saves it to the database. It will ask for your MySQL password.
5. **Run the queries** in the SQL file (`olist business questions.sql`).
6. **Open the dashboard file (`olist_dashboard.pbix`) in Power BI Desktop.** It already contains the data, so it opens without MySQL.
