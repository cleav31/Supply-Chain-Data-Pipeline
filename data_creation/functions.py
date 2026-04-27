from faker import Faker
import numpy as np
import pandas as pd
import random
from datetime import date, timedelta

# --- Set seeds for reproducibility ---
random.seed(42)     # Python's random module
fake = Faker()
Faker.seed(42)      # Faker library
fake = Faker()
# -------------------------
# Data generation functions
# -------------------------
# Create products table
def create_fake_products(num_products):
    products = []
    category_generators = {
                    "Electronics": gen_electronic,
                    "Mechanical": gen_mechanical,
                    "Hydraulic": gen_hydraulic,
                    "Pneumatic": gen_pneumatic
                }
    for _ in range(num_products):
        category = random.choice(list(category_generators.keys()))
        product_name = category_generators[category]()
        products.append({
            "category": category,
            "product_name": product_name,
            "standard_cost": round(random.uniform(10,500),2),
            "standard_price": round(random.uniform(20,800),2)
        })
    return pd.DataFrame(products)

def gen_electronic():
    electronic_products = [
        "Programmable Logic Controller(PLC)",
        "Human Machine Interface(HMI)",
        "Industrial Sensor",
        "Proximity Switch",
        "Power Supply Unit",
        "Circuit Breaker",
        "Relay Module",
        "Variable Frequency Drive",
        "Control Panel",
        "Wiring Harness"   
    ]
    return random.choice(electronic_products)

def gen_mechanical():
    hydraulic_products = [
        "Ball Bearing",
        "Roller Bearing",
        "Gear Shaft",
        "Coupling",
        "Linear Actuator",
        "Pulley",
        "Conveyor Roller",
        "Mounting Bracket",
        "Fastener Kit",
        "Spring Assembly"
    ]
    return random.choice(hydraulic_products)

def gen_hydraulic():
    hydraulic_products = [
        "Hydraulic Pump",
        "Hydraulic Cylinder",
        "Hydraulic Valve",
        "Hydraulic Hose",
        "Hydraulic Pressure Regulator",
        "Flow Control Valve",
        "Hydraulic Reservoir",
        "Seal Kit",
        "Manifold Block",
        "Hydraulic Filter"
    ]
    return random.choice(hydraulic_products)

def gen_pneumatic():
    pneumatic_products = [
        "Air Compressor",
        "Pneumatic Cylinder",
        "Solenoid Valve",
        "Air Filter Regulator",
        "Tubing Hose",
        "Air Dryer",
        "Pressure Gauge",
        "Air Flow Control Valve",
        "Quick Disconnect Coupler"
    ]
    return random.choice(pneumatic_products)

# Create suppliers table
def create_fake_suppliers(num_suppliers):
    suppliers = []
    for _ in range(num_suppliers):
        suppliers.append({
            "supplier_name": fake.company(),
            "region": random.choice(["Northern","Southern","Eastern","Western","Canada","Mexico"]),
            "lead_time_days": random.choices(
                [5,10,15,20,25,30],
                weights = [0.15,0.3,0.3,0.15,0.05,0.05]
            )[0]
        })
    return pd.DataFrame(suppliers)

# Create customers table
def create_fake_customers(num_customers):
    customers = []
    for _ in range(num_customers):
        customers.append({
            "customer_name": fake.name(),
            "region": random.choice(["Northern","Southern","Eastern","Western","Canada","Mexico"]),
            "industry": random.choice(["Electronics","Mechanical","Hydraulic","Pneumatic"])
        })
    return pd.DataFrame(customers)

# Create warehouses table
def create_fake_warehouses(num_warehouses):
    warehouses = []
    for _ in range(num_warehouses):
        warehouses.append({
            "warehouse_name": fake.company() + " Warehouse",
            "location": fake.city(),
            "capacity": random.randint(1000,10000)
        })
    return pd.DataFrame(warehouses)

# Create employees table
def create_fake_employees(num_employees, warehouse_ids):
    employees = []
    for _ in range(num_employees):
        employees.append({
            "employee_name": fake.name(),
            "role": random.choices(
                ["Manager","Sales","Warehouse","Procurement","Production"],
                weights = [0.1,0.2,0.5,0.2,0.5]
                )[0],
            "warehouse_id": random.choice(warehouse_ids)
        })
    return pd.DataFrame(employees)

# Create orders table
def create_fake_orders(num_orders,customer_ids):
    orders = []
    today = date.today()
    for _ in range(num_orders):
        customer_id = random.choice(customer_ids)
        order_date = fake.date_between(start_date='-3y', end_date='today')
        required_date = fake.date_between(start_date=order_date,end_date='+180d')

        # Holiday spike
        if order_date.month in [11,12]:
            extra_delay = random.randint(5,15)
            required_date += timedelta(days=extra_delay)
        
        #status logic based on order and required dates
        if required_date < today:
            status = random.choices(
                ["Shipped", "Delayed", "Cancelled"],
                 weights=[0.85,0.10,0.05],
                 k=1
            )[0]
        elif order_date <= today <= required_date:
            status = random.choices(
                ["Pending", "Processing", "Delayed"],
                weights=[0.6, 0.3, 0.1],
                k=1
            )[0]
        else:
            status = "Pending"
        orders.append({
            "customer_id": customer_id,
            "order_date": order_date,
            "required_date": required_date,
            "status": status
        })       
    return pd.DataFrame(orders)

# Create order_items table
def create_fake_order_items(num_items,order_ids, product_ids):
    order_items = []
    # Allow some products to be more popular (20% of products) to create variability in demand
    popular_products = set(random.sample(product_ids, int(len(product_ids) * 0.2)))

    for _ in range(num_items):
        product_id = random.choice(product_ids)
        if product_id in popular_products:
            quantity = random.randint(50,200)
        else:
            quantity = random.randint(1,50)
        order_items.append({
            "order_id": random.choice(order_ids),
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": round(random.uniform(10.00, 500.00),2)
        })
    return pd.DataFrame(order_items)

# Create shipments table
def create_fake_shipments(df_orders, warehouse_ids):
    shipments = []
    # Inject underperforming warehouses by making them more likely to have late deliveries
    slow_warehouses = set(random.sample(warehouse_ids, int(len(warehouse_ids) * 0.3)))
    # Only shipped orders should have shipments
    shipped_orders = df_orders[df_orders["status"] == "Shipped"]

    # Iterate through shipped orders to create realistic ship and delivery dates                           
    for _, row in shipped_orders.iterrows():
        order_id = row["order_id"]
        order_date = row["order_date"]
        required_date = row["required_date"]
        warehouse_id = random.choice(warehouse_ids)
               
        # Ship date AFTER order date
        ship_advance = random.randint(1,10) # shipped 1-10 days before required date
        ship_date = required_date - timedelta(days=ship_advance)

        # Ensure ship date is not before order_date
        if ship_date < order_date:
            ship_date = order_date
        # Delivery date AFTER ship date
        delivery_delay = random.randint(1,5)

        if warehouse_id in slow_warehouses:
            delivery_delay += random.randint(2,20) # slower delivery for underperforming warehouses
        
        delivery_date = ship_date +  timedelta(days=delivery_delay)
    
         # Cost Logic
        distance_factor = random.uniform(1,3)
        shipping_cost = 100 * distance_factor + (delivery_delay * 10)
        shipments.append({
            "order_id": order_id,
            "warehouse_id": warehouse_id,
            "ship_date": ship_date,
            "delivery_date": delivery_date,
            "shipping_cost": shipping_cost
        })
    return pd.DataFrame(shipments)

# Create production_batches table
def create_fake_production_batches(num_batches, product_ids, supplier_ids):
    batches = []
    # Assign 'bad suppliers'
    bad_suppliers = set(random.sample(supplier_ids, int(len(supplier_ids) * 0.2)))

    for _ in range(num_batches):
        product_id = random.choice(product_ids)
        supplier_id = random.choice(supplier_ids)
        production_date = fake.date_between(start_date='-3y', end_date='today')
        units_produced = random.randint(100,5000)
        # base production cost
        production_cost = round(random.uniform(1000,50000),2)
        # Worse yield for bad suppliers
        if supplier_id in bad_suppliers:
           production_cost *= random.uniform(1.1,1.3) # higher cost

        batches.append({
           "product_id": product_id,
           "supplier_id": supplier_id,
           "production_date": production_date,
           "units_produced": units_produced,
           "production_cost": round(production_cost, 2)
        })
    return pd.DataFrame(batches)

# Create quality_inspections table
def create_fake_quality_inspections(df_batches,df_employees,num_inspections):
    inspections = []
    prod_employees = df_employees[df_employees["role"] == "Production"] # Only production employees do inspections

    for _ in range(num_inspections):
        # Grab a random row from batches to get linked data
        batch_row = df_batches.sample(n=1).iloc[0]
        total_units = batch_row["units_produced"]

        # Simulate process drift and variability in quality
        if random.random() < 0.1:
            defect_rate = random.uniform(0.08, 0.15) # bad batch
        else:
            defect_rate = random.uniform(0.01, 0.05) # normal batch

        # Passed units is the remainder
        passed_units = total_units - int(total_units * defect_rate)
        defective_units = total_units - passed_units

        inspections.append({
            "batch_id": batch_row["batch_id"],
            "inspection_date": batch_row["production_date"] + timedelta(days=random.randint(0,3)),
            "defective_units": defective_units,
            "passed_units": passed_units,
            "employee_id": random.choice(prod_employees["employee_id"].tolist())
        })
    return pd.DataFrame(inspections)

   