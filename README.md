# 🔗 Supply Chain Data Pipeline — End-to-End ETL & Analytics

> A full ETL pipeline that generates, stores, transforms, and visualizes supply chain data using Python, MySQL, and Power BI.

---

## 📋 Table of Contents
- [Executive Summary](#executive-summary)
- [Business Problem](#business-problem)
- [Tech Stack](#tech-stack)
- [Methodology](#methodology)
- [SQL Views (Feature Engineering)](#sql-views-feature-engineering)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Data Dictionary](#data-dictionary)
- [Results & Business Recommendations](#results--business-recommendations)
- [Next Steps](#next-steps)
- [Skills Demonstrated](#skills-demonstrated)

---

## Executive Summary

This project builds an end-to-end supply chain analytics pipeline that transforms raw operational data into actionable business insights. Synthetic data was generated using Python's Faker library and loaded into a MySQL relational database. SQL views were engineered to support key business metrics, and the final results were visualized in an interactive Power BI dashboard.

The pipeline integrates data across orders, shipments, production batches, and quality inspections to deliver KPIs covering revenue performance, fulfillment efficiency, and product defect rates — enabling stakeholders to monitor operations and identify opportunities for cost reduction and process improvement.

---

## Business Problem

Supply chain data is typically fragmented across multiple systems — sales, logistics, and production — making it difficult to:

- Accurately track revenue and order performance
- Measure fulfillment efficiency and on-time delivery rates
- Monitor product quality and defect rates across production batches
- Establish a single, reliable source of truth for decision-making

Without a structured data model, reporting becomes inconsistent and prone to errors such as double-counting from improper table joins. This project addresses those challenges with a normalized relational schema, validated SQL views, and a governed reporting layer.

---

## Tech Stack

| Layer | Tool / Technology |
|---|---|
| Data Generation | Python (Faker library) |
| Database | MySQL |
| Transformation | SQL (Views, Joins, Window Functions) |
| Visualization | Power BI |

---

## Methodology

### 1. Data Generation
Synthetic datasets were created using Python's `Faker` library to simulate realistic supply chain entities:

- Customers
- Products
- Orders & Order Items
- Shipments
- Production Batches
- Quality Inspections

Data was generated programmatically and pushed directly to a MySQL database.

### 2. Data Modeling
A normalized relational schema was designed with:

- Defined primary and foreign key relationships
- Referential integrity enforced across all tables
- Grain alignment to prevent aggregation errors in reporting

### 3. Data Cleaning & Transformation
The raw data was cleaned to handle:

- Missing and inconsistent values
- Duplicate records
- Invalid foreign key relationships

Clean analytical views were created to standardize metrics and serve as a reliable layer between raw data and reporting.

### 4. Feature Engineering (SQL Views)
Business-facing SQL views were developed to abstract complex logic and make metrics reusable. See the [SQL Views](#sql-views-feature-engineering) section for details.

### 5. Visualization
An interactive dashboard was built in Power BI, featuring:

- KPI cards (Total Revenue, Total Orders, Defect Rate)
- Revenue trend analysis over time
- Product and customer performance breakdowns

---

## SQL Views (Feature Engineering)

| View Name | Description |
|---|---|
| `vw_customer_sales` | Customer-level revenue aggregation |
| `vw_revenue_trend` | Time-series revenue analysis |
| `vw_product_sales` | Product performance metrics |
| `vw_kpi_summary` | Executive-level KPI summary |

---

## Entity Relationship Diagram
<img width="778" height="735" alt="Screenshot 2026-05-04 131829" src="https://github.com/user-attachments/assets/61f7195d-3fe2-4a5c-837d-2b73c03d6bed" />

<img width="778" height="735" alt="ERD - Supply Chain Data Pipeline" src="https://github.com/user-attachments/assets/61f7195d-3fe2-4a5c-837d-2b73c03d6bed" />

---

## Data Dictionary

### `products`
| Column | Data Type | Description |
|---|---|---|
| `product_id` | INT | Primary key — unique product identifier |
| `product_name` | VARCHAR(50) | Name of the product |
| `category` | VARCHAR(50) | Product category |
| `standard_cost` | DECIMAL(10,2) | Internal cost of the product |
| `standard_price` | DECIMAL(10,2) | Listed selling price |

### `customers`
| Column | Data Type | Description |
|---|---|---|
| `customer_id` | INT | Primary key — unique customer identifier |
| `customer_name` | VARCHAR(50) | Full name of the customer |
| `region` | VARCHAR(50) | U.S. geographic region |
| `industry` | VARCHAR(50) | Customer's primary industry |

### `orders`
| Column | Data Type | Description |
|---|---|---|
| `order_id` | INT | Primary key — unique order identifier |
| `customer_id` | INT | Foreign key referencing `customers` |
| `order_date` | DATE | Date the order was placed |
| `required_date` | DATE | Expected fulfillment date |
| `status` | VARCHAR(50) | Current delivery status |

---

## Results & Business Recommendations

### Key Findings

- **Revenue trends** show seasonal fluctuations closely tied to order volume spikes.
- **Product concentration risk** — a small subset of products drives a disproportionate share of total revenue.
- **Defect rate variability** — quality inspection results vary significantly across production batches.
- **Fulfillment bottlenecks** — on-time delivery performance reveals systemic delays in the logistics process.

### Recommendations

| Finding | Recommendation |
|---|---|
| Revenue concentration | Prioritize high-revenue products for inventory planning and safety stock management |
| High defect batches | Investigate root causes in flagged production runs to reduce waste and rework costs |
| Fulfillment delays | Audit logistics workflows and carrier SLAs to improve on-time delivery rates |
| Reporting inconsistencies | Standardize all KPI reporting through validated SQL views to prevent metric drift |

---

## Next Steps
<<<<<<< HEAD

- [ ] Implement a star schema for more scalable and flexible analytics
- [ ] Add a date dimension table to support consistent time-based filtering
- [ ] Introduce incremental data loading to improve pipeline efficiency
- [ ] Expand analysis to include supplier performance metrics and profit margin analysis
- [ ] Deploy the Power BI dashboard to a cloud platform for broader stakeholder access

---

## Skills Demonstrated

**Technical**
- Python — data generation with the `Faker` library, scripted MySQL ingestion
- SQL — joins, aggregations, window functions, and analytical views
- Data modeling — normalization, grain management, referential integrity
- Data cleaning & transformation
- Power BI — dashboard design, KPI visualization, trend analysis

**Analytical**
- KPI development aligned to business objectives
- Data validation and debugging (e.g., resolving revenue discrepancies caused by join grain mismatches)
- Translating raw data findings into concrete business recommendations
=======
- Implement a star schema for scalable analytics
- Add a date dimension table for inconsistent time filtering
- Introduce incremental data loading for pipeline efficiency
- Expand analysis with:
  - Supplier performance metrics
  - Cost & profit margin analysis
- Deploy dashboards to a cloud platform for stakeholder access
>>>>>>> 4d3b8aff2eedc29a3354fc54978ef752043ad44e
