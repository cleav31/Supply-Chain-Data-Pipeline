# switch to target database
USE supply_chain_db;

CREATE TABLE IF NOT EXISTS products(
	product_id  INT PRIMARY KEY AUTO_INCREMENT,
    category VARCHAR(50),
    standard_cost DECIMAL(10,2),
    standard_price DECIMAL(10,2)
    );
CREATE TABLE IF NOT EXISTS suppliers(
	supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100),
    region VARCHAR(50),
    lead_time_days INT
    );
CREATE TABLE IF NOT EXISTS customers(
	customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(50),
    region VARCHAR(50),
    industry VARCHAR(50)
    );
CREATE TABLE IF NOT EXISTS warehouses(
	warehouse_id INT PRIMARY KEY AUTO_INCREMENT,
    warehouse_name VARCHAR(100),
    location VARCHAR(100),
    capacity INT
    );
CREATE TABLE IF NOT EXISTS employees(
	employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100),
    role VARCHAR(50),
    warehouse_id INT,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) 
    );
CREATE TABLE IF NOT EXISTS orders(
	order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    required_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    );
CREATE TABLE IF NOT EXISTS shipments(
	shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    warehouse_id INT,
    ship_date DATE,
    delivery_date DATE,
    shipping_cost DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
    );
CREATE TABLE IF NOT EXISTS production_batches(
	batch_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    supplier_id INT,
    production_date DATE,
    units_produced INT,
    production_cost DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
    );
CREATE TABLE IF NOT EXISTS quality_inspections(
	inspection_id INT PRIMARY KEY AUTO_INCREMENT,
	batch_id INT,
    inspection_date DATE,
    defective_units INT,
    passed_units INT,
    employee_id INT,
    FOREIGN KEY (batch_id) REFERENCES production_batches(batch_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
    );
CREATE TABLE IF NOT EXISTS order_items(
	order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    );
