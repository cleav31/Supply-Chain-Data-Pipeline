# Data Dictionary
## Fact Tables
### Products Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_id  | INT       | Primary key — Unique product identifier |
| category    | VARCHAR(50) | categorize by industry |
| product_name | VARCHAR(50) | name of product |
| standard_cost | DECIMAL(10,2) | cost of product |
| standard_price | DECIMAL(10,2) | price of product |
### Customers Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_id | INT       | Primary key — Unique customer identifier |
| customer_name | VARCHAR(50) | name of customer |
| region      | VARCHAR(50) | customer's US region |
| industry | VARCHAR(50) | customers primary industry |
### Orders Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_id    | INT       | Primary key — Unique order identifier |
| customer_id | INT       | Foreign key referencing `customers` |
| order_date  | DATE      | date order is entered |
| required_date | DATE    | date order is expected |
| status      | VARCHAR(50) | delivery status of order | 
### Shipments
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| shipment_id | INT| Primary key — Unique shipment identifier |
| order_id | INT | Foreign key referencing `orders` |
| warehouse_id | INT | Foreign key referencing `warehouses` |
| ship_date | DATE | date shipped |
| delivery_date | DATE | date customer received |
| shipping_cost| DECIMAL(10,2) | cost of shipping |
### Employees
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| employee_id | INT | Primary key — Unique employee identifier |
| employee_name | VARCHAR(100) | name of employee |
| role | VARCHAR(50) | employee's position |
| warehouse_id | INT | employee's location |
### Warehouses
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| warehouse_id | INT | Primary key — Unique warehouse identifier |
| warehouse_name | VARCHAR(100) | name of warehouse |
| location | VARCHAR(100) | location of warehouse |
| capacity | INT | warhouse capacity |
### Suppliers Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| supplier_id | INT | Primary key — Unique supplier identifier |
| supplier_name | VARCHAR(100) | name of supplier |
| region | VARCHAR(50) | supplier's US region |
| lead_time_days | INT | supplier's standard lead time |
## Dimension Tables
### Order Items Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_item_id | INT | Primary key — Unique item identifier |
| order_id | INT | Foreign key referencing `order_items` | 
| product_id | INT | Foreign key referencing `products` |
| quantity | INT | amount of item ordered |
| unit_price | DECIMAL(10,2) | price of item ordered |
### Production Batches Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| batch_id | INT | Primary key — Unique batch identfier |
| product_id | INT | Foreign key referencing `products` |
| supplier_id | INT | Foreign key referencing `suppliers` |
| production_date | DATE | date produced |
| units_produced | INT | amount produced |
| production_cost | DECIMAL(10,2) | cost of production |
### Quality Inspections Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| inspection_id | INT | Primary key — Unqiue inspection identifier |
| batch_id | INT | Foreign key referencing `production_batches` |
| inspection_date | DATE | date inspected |
| defective_units | INT | units found defective |
| passed_units | INT | units found acceptable |
| employee_id | INT | Foreign key referencing `employees` |
------------------
## Views
### Customer Sales
| Column Name | 
|-------------|
| customer_id |
| customer_name |
| total_orders |
| total_spent |
### KPI Summary
| Column Name | 
|-------------|
| total_orders |
| total_revenue |
| avg_fulfillment_days |
| on_time_delivery_rate |
| defect_rate |
### Operations Orders
| Column Name | 
|-------------|
| order_id |
| order_date |
| required_date |
| ship_date |
| delivery_date |
| warehouse_id |
| fulfillment_days |
| delivery_days |
| delivery_delay |
| delivery_status |
### Product Sales
| Column Name | 
|-------------|
| product_id |
| product_name |
| total_units_sold |
| total_revenue |
### Quality Batches
| Column Name | 
|-------------|
| batch_id |
| product_id |
| supplier_id |
| inspection_id |
| supplier_name |
| production_date |
| production_cost |
| inspection_date |
| defective_units |
| passed_units |
| defect_rate |
### Revenue Trend
| Column Name | 
|-------------|
| required_date |
| revenue |
### Supplier Quality
| Column Name | 
|-------------|
| supplier_id |
| total_batches |
| avg_defect_rate |
### Warehouse Performance
| Column Name | 
|-------------|
| warehouse_id |
| total_shipments |
| avg_delivery_days |
| on_time_rate |