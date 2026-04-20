# 1. Orders & Customers
# Which customer have placed the most orders in the last 6 months?
SELECT
	c.customer_name,
	COUNT(o.order_id) AS num_sales,
	DENSE_RANK() OVER(ORDER BY COUNT(o.order_id) DESC) as num_sales_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE DATEDIFF(order_date, CURDATE()) < 180
GROUP BY c.customer_name;
#------------------------------------------------------------
/* Rank customer by total revenue, showing their cumulative contribution to total revenue */
WITH OrderRevenue AS (
# Calculate total revenue for every unique order
	SELECT
		o.customer_id,
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_total
	FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id,order_id
),
CustomerTotal AS (
# Calculate the Lifetime Total Value per customer for ranking
    SELECT
		customer_id,
        SUM(order_total) AS ltv
	FROM OrderRevenue
    GROUP BY customer_id
)
SELECT
	customer_id,
    ROUND(ltv,2),
    -- Rank customers by total spend
    DENSE_RANK() OVER(ORDER BY ltv DESC) AS ltv_rank,
    ROUND(SUM(ltv) OVER(ORDER BY ltv DESC, customer_id ASC),2) 
		AS running_total_revenue
FROM CustomerTotal
ORDER BY ltv_rank;
#------------------------------------------------------------
/* Identify customers with delayed shipments 
(shipment_date > required_date) and total delay in days */
SELECT
	c.customer_name AS name,
    COUNT(shipment_id) AS num_delayed_shipments,
    SUM(DATEDIFF(s.delivery_date, o.required_date)) AS total_delay 
FROM shipments s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE s.delivery_date > o.required_date
GROUP BY c.customer_name;
#-----------------------------------------------------------
# 2. Products & Suppliers
# For each product, show the top 3 suppliers by units supplied
WITH supplier_totals AS(
	SELECT
		pb.product_id,
		s.supplier_name,
		SUM(pb.units_produced) AS total_units,
		DENSE_RANK()OVER(PARTITION BY pb.product_id
			ORDER BY SUM(pb.units_produced) DESC) AS ranking
	FROM suppliers s
	JOIN production_batches pb ON s.supplier_id = pb.supplier_id
	GROUP BY pb.product_id, s.supplier_name
)
SELECT *
FROM supplier_totals
WHERE ranking <= 3
ORDER BY product_id, ranking;
#-----------------------------------------------------------
#Find the supplier with the highest average quality score from inspections
SELECT
	s.supplier_id,
	s.supplier_name,
    SUM(qi.passed_units) AS total_passed,
    SUM(qi.defective_units) AS total_defective,
    SUM(qi.passed_units) / 
    (SUM(qi.passed_units + qi.defective_units)) AS avg_quality_score
FROM suppliers s
JOIN production_batches pb ON s.supplier_id = pb.supplier_id
JOIN quality_inspections qi ON pb.batch_id = qi.batch_id 
GROUP BY s.supplier_id, s.supplier_name
ORDER BY avg_quality_score DESC;       
#----------------------------------------------------------
/*Identify products with inconsistent supply(different supplier 
supplying same product at different cost)*/
SELECT *
FROM(
	SELECT
		s.supplier_name,
		pb.product_id,
		ROUND(AVG(pb.production_cost/pb.units_produced),2) 
			AS avg_cost_per_pc,
		RANK() OVER(
			PARTITION BY pb.product_id
			ORDER BY AVG(pb.production_cost/pb.units_produced) ASC
		) AS cost_rank
	FROM production_batches pb
	JOIN suppliers s ON pb.supplier_id = s.supplier_id
	GROUP BY pb.product_id, s.supplier_name
	) t
    WHERE cost_rank <= 3
    ORDER BY product_id, cost_rank;
#-------------------------------------------------------------
# 3. Shipments & Warehouses
/* Which warehouses ship the most orders, and what is the average
shipping time per warehouse*/
SELECT
	w.warehouse_name,
    COUNT(DISTINCT s.order_id) AS num_orders,
    AVG(DATEDIFF(s.delivery_date, s.ship_date)) AS avg_shipping_days
FROM shipments s
JOIN warehouses w ON s.warehouse_id = w.warehouse_id
JOIN orders o ON o.order_id = s.order_id
WHERE o.status = 'Shipped'
GROUP BY w.warehouse_name
ORDER BY num_orders DESC;
#-----------------------------------------------------------------
# Find top 5 warehouses causing delays(average shipment delay in days)
SELECT
	w.warehouse_name,
    ROUND(AVG(DATEDIFF(s.delivery_date, o.required_date)),2) 
		AS avg_shipment_delay
FROM orders o 
JOIN shipments s ON o.order_id = s.order_id
JOIN warehouses w ON s.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name
ORDER BY avg_shipment_delay DESC
LIMIT 5;
#---------------------------------------------------------------
# Show a running total of shipments(by ship_date) per month across the year
WITH monthly_summary AS(
	SELECT
		DATE_FORMAT(ship_date, '%Y-%m') as month_val,
		COUNT(shipment_id) as monthly_total
	FROM shipments
	WHERE ship_date >= CURDATE() - INTERVAL 1 YEAR
    GROUP BY month_val
    )
SELECT
	month_val,
    monthly_total,
    SUM(monthly_total) OVER(ORDER BY month_val) AS running_total
FROM monthly_summary
ORDER BY month_val;
#---------------------------------------------------------------
# 4. Order Items & Revenue
# Identify the top 5 products generating revenue per month
WITH month_val AS (
SELECT
	DATE_FORMAT(o.required_date, '%Y-%m') AS order_month,
    oi.product_id AS product,
    SUM(oi.quantity * oi.unit_price) AS product_revenue,
	ROW_NUMBER() OVER( 
		PARTITION BY DATE_FORMAT(o.required_date, '%Y-%m')
        ORDER BY SUM(oi.quantity * oi.unit_price) DESC
        ) AS revenue_rank
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY order_month, oi.product_id
)
SELECT
	*
FROM month_val
WHERE revenue_rank <= 5
ORDER BY order_month;
# -----------------------------------------------------------------
# Find products that frequently appear together in orders 
SELECT
	a.product_id AS product_a,
    b.product_id AS product_b,
    COUNT(*) AS times_bought_together
FROM order_items a
JOIN order_items b
	ON a.order_id = b.order_id
    AND a.product_id < b.product_id
GROUP BY product_a, product_b
HAVING times_bought_together > 5
ORDER BY times_bought_together DESC;
# Show the average order value per customer and rank them
WITH order_val AS (
SELECT
	c.customer_name AS customer_name,
    ROUND(AVG(oi.quantity * oi.unit_price),2) AS avg_order_value
FROM  order_items oi
JOIN orders o
	ON oi.order_id = o.order_id
JOIN customers c
	ON o.customer_id = c.customer_id
GROUP BY customer_name
)
SELECT
	*,
    ROW_NUMBER() OVER(
    ORDER BY avg_order_value DESC) AS order_value_rank
FROM order_val;
#-------------------------------------------------------------
# 5. Quality Metrics
/* Identify production batches with the highest number
 of failed inspections*/
WITH fail_rate As (
SELECT
	batch_id,
    defective_units,
    SUM(defective_units + passed_units) AS total_units_per_batch,
    ROUND(SUM(defective_units) * 100.0 / 
		SUM(defective_units + passed_units),2)
		AS fail_rate_pct
FROM quality_inspections
GROUP BY batch_id, defective_units
)
SELECT 
	*,
    RANK() OVER(ORDER BY fail_rate_pct DESC) AS fail_rate_rank
FROM fail_rate
LIMIT 10;
#-------------------------------------------------------
# Compute the pass rate per product across all batches
WITH batch_pass_rate AS (
SELECT
	batch_id,
    defective_units,
    passed_units,
    SUM(defective_units + passed_units) AS batch_total,
    ROUND(passed_units * 100.0 /
		SUM(passed_units + defective_units),2) 
		AS pass_rate
FROM quality_inspections
GROUP BY batch_id, defective_units, passed_units
)
SELECT
	pb.product_id,
    AVG(pass_rate) AS product_pass_rate
FROM batch_pass_rate bpr
JOIN production_batches pb
	ON bpr.batch_id = pb.batch_id
GROUP BY pb.product_id
ORDER BY product_pass_rate;
/* Find suppliers whose batches fail inspections(95% > pass rate) 
more than 20% of the time */
SELECT 
    pb.supplier_id,
    COUNT(*) AS num_insp,
    SUM(CASE WHEN (qi.passed_units * 100.0 / 
		(qi.passed_units + qi.defective_units)) 
			< 95 THEN 1 ELSE 0 END) AS failed_count,
    ROUND(AVG(CASE WHEN (qi.passed_units * 100.0 / 
		(qi.passed_units + qi.defective_units)) < 95 
        THEN 100.0 ELSE 0.0 END), 2) AS pct_fail_insp
FROM quality_inspections qi
JOIN production_batches pb ON qi.batch_id = pb.batch_id
GROUP BY pb.supplier_id
HAVING (SUM(CASE WHEN (qi.passed_units * 100.0 / 
	(qi.passed_units + qi.defective_units)) < 95 THEN 1 ELSE 0 END)
		* 1.0 / COUNT(*)) >= 0.20;
#-------------------------------------------------------------
# Combined Analytical Insight
/* For each month, show total revenue, total shipments, and total
number of delayed shipments */
WITH monthly_revenue AS (
SELECT
	DATE_FORMAT(o.required_date, '%Y-%m') AS calendar_month,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY calendar_month
), 
monthly_shipments AS (
SELECT
	DATE_FORMAT(o.required_date, '%Y-%m') AS calendar_month,
    COUNT(s.shipment_id) AS total_shipments,
    SUM(CASE
		WHEN s.delivery_date > o.required_date
			THEN 1 ELSE 0 END) AS delayed_shipments
FROM shipments s
JOIN orders o ON s.order_id = o.order_id
GROUP BY calendar_month
)
SELECT
	mr.calendar_month,
    mr.total_revenue,
    ms.total_shipments,
    ms.delayed_shipments
FROM monthly_revenue mr
JOIN monthly_shipments ms ON mr.calendar_month = ms.calendar_month
ORDER BY mr.calendar_month ASC;
#------------------------------------------------------------
/* Identify the top 3 suppliers for each product by lead time
and quality score */
WITH supplier_metrics AS (
SELECT
	pb.product_id,
    s.supplier_name,
    s.lead_time_days,
    # Caluclate avg quality across all batches fpr supplier/product
    ROUND(AVG(qi.passed_units * 100.0 / 
		(qi.defective_units + qi.passed_units)),2) 
			AS avg_quality_score,
	# Rank Quality(High to Low) & Lead Time (Low to High)
    DENSE_RANK() OVER(
		PARTITION BY pb.product_id
        ORDER BY AVG(qi.passed_units * 100.0 /
			(qi.defective_units + qi.passed_units)) DESC,
				s.lead_time_days ASC
	) AS supplier_rank
FROM quality_inspections qi
JOIN production_batches pb ON qi.batch_id = pb.batch_id
JOIN suppliers s ON pb.supplier_id = s.supplier_id
GROUP BY pb.product_id, s.supplier_id, s.lead_time_days 
)
SELECT
	product_id,
    supplier_name,
    avg_quality_score,
    lead_time_days
FROM supplier_metrics
WHERE supplier_rank <= 3
ORDER BY product_id, supplier_rank;

/* For each warehouse, show monthly shipment trend and 
cumulative revenue handled */
WITH monthly_metric AS (
SELECT
	DATE_FORMAT(s.ship_date, '%Y-%m') AS calendar_month,
    s.warehouse_id,
    COUNT(s.shipment_id) AS num_shipments,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM shipments s
JOIN order_items oi ON s.order_id = oi.order_id
GROUP BY calendar_month, s.warehouse_id
)
SELECT
	calendar_month,
    warehouse_id,
    num_shipments,
    monthly_revenue,
    # Calculate cumulative revenue per warehouse
    SUM(monthly_revenue) OVER (
		PARTITION BY calendar_month ORDER BY monthly_revenue)
	AS cumulative_revenue
FROM monthly_metric
ORDER BY calendar_month,monthly_revenue ASC;
    