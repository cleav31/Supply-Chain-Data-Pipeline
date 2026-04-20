SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM suppliers;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM warehouses;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM shipments;
SELECT COUNT(*) FROM production_batches;
SELECT COUNT(*) FROM quality_inspections;

# Check foreign keys
SELECT 
COUNT(*)
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

# Check shipments only for shipped orders
SELECT
COUNT(*)
FROM shipments s
JOIN orders o ON s.order_id = o.order_id
WHERE o.status != 'Shipped';

# Check valid date flow
SELECT *
FROM shipments
WHERE ship_date < (
	SELECT order_date
    FROM orders 
    WHERE orders.order_id = shipments.order_id
    )
LIMIT 10;

# Check defect rates = ~3.95%
SELECT
AVG(defective_units / (defective_units + passed_units)) AS avg_defect_rate
FROM quality_inspections;

# Check that late deliveries exist
SELECT
COUNT(*)
FROM shipments s
JOIN orders o ON s.order_id = o.order_id
WHERE s.delivery_date > o.required_date;

# Check for warehouse performance differences
SELECT
warehouse_id,
AVG(DATEDIFF(delivery_date, ship_date)) AS avg_delivery_time
FROM shipments
GROUP BY warehouse_id
ORDER BY avg_delivery_time DESC;

# Spot check data
SELECT * FROM orders LIMIT 10;
SELECT * FROM shipments LIMIT 10;
SELECT * FROM production_batches LIMIT 10;