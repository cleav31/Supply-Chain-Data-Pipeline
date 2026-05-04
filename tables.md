# Data Dictionary
## Fact Tables
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
### Shipments
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| shipment_id | INT| Unique shipment identifier |
| order_id | INT | order shipped |
| warehouse_id | INT | warehouse shipping from |
| ship_date | DATE | date shipped |
| delivery_date | DATE | date customer received |
| shipping_cost| DECIMAL(10,2) | cost of shipping |
### Employees
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| employee_id | INT | Unique employee identifier |
| employee_name | VARCHAR(100) | name of employee |
| role | VARCHAR(50) | employee's position |
| warehouse_id | INT | employee's location |
### Warehouses
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| warehouse_id | INT | Unique warehouse identifier |
| warehouse_name | VARCHAR(100) | name of warehouse |
| location | VARCHAR(100) | location of warehouse |
| capacity | INT | warhouse capacity |
### Suppliers Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| supplier_id | INT | Unique supplier identifier |
| supplier_name | VARCHAR(100) | name of supplier |
| region | VARCHAR(50) | supplier's US region |
| lead_time_days | INT | supplier's standard lead time |
## Dimension Tables
### Order Items Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_item_id | INT | Unique item identifier |
| order_id | INT | order item purchased on 
| product_id | INT | product ordered |
| quantity | INT | amount of item ordered |
| unit_price | DECIMAL(10,2) | price of item ordered |
### Production Batches Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| batch_id | INT | Unique batch identfier |
| product_id | INT | product made |
| supplier_id | INT | which supplier made |
| production_date | DATE | date produced |
| units_produced | INT | amount produced |
| production_cost | DECIMAL(10,2) | cost of production |
### Quality Inspections Table
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| inspection_id | INT | Unqiue inspection identifier |
| batch_id | INT | batch associated with |
| inspection_date | DATE | date inspected |
| defective_units | INT | units found defective |
| passed_units | INT | units found acceptable |
| employee_id | INT | employee that produced |