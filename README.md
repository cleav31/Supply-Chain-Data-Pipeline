# Supply-Chain-Data-Pipeline

## Executive Summary
This project builds an end-to-end supply chain analytics pipeline using SQL and BI tools to transform raw operational data into actionable insights.

The pipeline integrates data across orders, shipments, production, and quality to deliver key business metrics including revenue, fulfillment performance, and defect rates. The final output enables stakeholders to monitor operational efficiency and identify areas for cost reduction and process improvement.

## Business Problem
Supply chain data is often fragmented across multiple systems (sales, logistics, production), making it difficult to:

- Accurately track revenue and order performance
- Measure fulfillment efficiency and on-time delivery
- Monitor product quality and defect rates
- Create a single source of truth for decision-making

Without a structured data model, reporting becomes inconsistent and prone to errors (e.g., double counting due to improper joins).
## Methodology
### 1. Data Generation/Collection
- Created synthetic datasets using Python (Faker) to simulate:
  - Orders
  - Order Items
  - Customers
  - Shipments
  - Production Batches
  - Quality Inspections
### 2. Data Modeling
- Designed a relational schema with proper normalization:
  - Established primary & foreign relationships
  - Ensured referential integrity across tables
### 3. Data Cleaning & Transformation
- Handled:
  - Missing & inconsistent values
  - Duplicate records
  - Invalid relationships
- Created clean analytical views to:
  - Standardize metrics
  - Prevent aggregation errors (grain alignment)
### 4. Feature Engineering (SQL Views)
Developed business-facing views
  - vw_customer_sales -> customer-level revenue
  - vw_revenue_trend -> time_series_revenue
  - vw_product_sales -> product performance
  - vw_kpi_summary -> executive KPIs
### 5. Visulaization
- Built dashboards in:
  - Power BI
- Included:
  - KPI cards(Revenue, Orders, Defect Rate)
  - Trend analysis
  - Product and customer breakdowns

## Skills
### Technical
- SQL (Joins, Aggregation, Window Functions, Views)
- Data Modeling (Normalization, Grain Management)
- Data Cleaning & Transformation
- Python (Faker for data genereation)
- Power BI
### Analytical
- KPI Development
- Data validation & debugging ( e.g. resolving revenue discrepancies)
- Business translation of data insights

## Data Dictionary
### Products Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_id  | INT       | Unique product identifier |
| category    | VARCHAR(50) | categorize by industry |
| product_name | VARCHAR(50) | name of product |
| standard_cost | DECIMAL(10,2) | cost of product |
| standard_price | DECIMAL(10,2) | price of product |
### Customers Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_id | INT       | Unique customer identifier |
| customer_name | VARCHAR(50) | name of customer |
| region      | VARCHAR(50) | customer's US region |
| industry | VARCHAR(50) | customers primary industry |
### Orders Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_id    | INT       | Unique order identifier |
| customer_id | INT       | customer of order |
| order_date  | DATE      | date order is entered |
| required_date | DATE    | date order is expected |
| status      | VARCHAR(50) | delivery status of order | 
## Entity Relationship Diagram

## Results & Business Recommendations
### Key Findings
- Revenue trends show seasonal fluctuations tied to order volume
- Certain products contribute disproportionately to total revenue
- Defect rates vary significantly by production batch
- On-time delivery performance highlights bottlenecks in fulfillment
### Recommendations
- Focus on high-revenue products for inventory optimization
- Investigate batches with high defect rates to reduce waste
- Improve logistics processes to increase on-time delivery rate
- Standardize reporting using validated SQL views to avoid metric inconsistencies

## Next Steps
- Implement a star schema for scalable analytics
- Add a date dimension table for inconsistent time filtering
- Introduce incremental data loading for pipeline efficiency
- Expand analysis with:
  - Supplier performance metrics
  - Cost & profit margin analysis
- Deploy dashboards to a cloud platform for stakeholder access