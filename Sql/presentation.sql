# Executive KPI Overview
use supply_chain_db;
CREATE VIEW vw_kpi_summary AS
SELECT
    r.total_orders,
    r.total_revenue,
    s.avg_fulfillment_days,
    s.on_time_delivery_rate,
    q.defect_rate
FROM
-- Revenue block
(
    SELECT
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.required_date < CURDATE()
) r
-- Shipping metrics
JOIN
(
    SELECT
        AVG(DATEDIFF(s.ship_date, o.order_date)) AS avg_fulfillment_days,
        AVG(CASE
            WHEN s.delivery_date <= o.required_date THEN 1
            ELSE 0
        END) AS on_time_delivery_rate
    FROM orders o
    JOIN shipments s ON o.order_id = s.order_id
    WHERE o.required_date < CURDATE()
) s

-- Quality metrics
JOIN
(
    SELECT
        AVG(q.defective_units / (q.defective_units + q.passed_units)) AS defect_rate
    FROM production_batches pb
    JOIN quality_inspections q ON pb.batch_id = q.batch_id
) q;

# Operations(Orders & Logistics)
CREATE VIEW vw_operations_orders AS
SELECT
	o.order_id,
    o.order_date,
    o.required_date,
    s.ship_date,
    s.delivery_date,
    s.warehouse_id,
    DATEDIFF(s.ship_date, o.order_date) AS fullfillment_days,
    DATEDIFF(s.delivery_date, s.ship_date) AS delivery_days,
    DATEDIFF(s.delivery_date, o.required_date) AS delivery_delay,
    CASE
		WHEN s.delivery_date <= o.required_date THEN 'On Time'
        ELSE 'Late'
	END AS delivery_status
FROM orders o
JOIN shipments s ON o.order_id = s.order_id;

CREATE VIEW vw_warehouse_performance AS
SELECT
	warehouse_id,
    COUNT(*) AS total_shipments,
    AVG(DATEDIFF(delivery_date, ship_date)) AS avg_delivery_days,
    AVG(CASE
		WHEN delivery_date <= required_date THEN 1
        ELSE 0
	END) AS on_time_rate
FROM shipments s
JOIN orders o ON s.order_id = o.order_id
GROUP BY warehouse_id;

# Quality Analysis
CREATE VIEW vw_quality_batches AS
SELECT
	pb.batch_id,
    pb.product_id,
    pb.supplier_id,
    q.inspection_id,
    s.supplier_name,
    pb.production_date,
    pb.production_cost,
    q.inspection_date,
    q.defective_units,
    q.passed_units,
    (q.defective_units/(q.defective_units + q.passed_units)) AS defect_rate
FROM production_batches pb
JOIN quality_inspections q ON pb.batch_id = q.batch_id
JOIN suppliers s ON pb.supplier_id = s.supplier_id;

CREATE VIEW vw_supplier_quality AS
SELECT
	supplier_id,
    COUNT(*) AS total_batches,
    AVG(q.defective_units/(q.defective_units + q.passed_units)) AS avg_defect_rate
FROM production_batches pb
JOIN quality_inspections q ON q.batch_id = pb.batch_id
GROUP BY supplier_id;

# Sales/ Product Performance
CREATE VIEW vw_product_sales AS
SELECT
	p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name;

CREATE VIEW vw_revenue_trend AS
SELECT
	o.required_date,
	SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.required_date < CURDATE()
GROUP BY o.required_date
ORDER BY o.required_date;

CREATE VIEW vw_customer_sales AS
SELECT
	o.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.required_date < CURDATE()
GROUP BY o.customer_id;
    