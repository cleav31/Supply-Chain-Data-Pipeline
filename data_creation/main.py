from functions import *
from db_loader import *
from sqlalchemy import text

def reset_tables(engine):
    tables = [
        "quality_inspections",
        "production_batches",
        "shipments",
        "order_items",
        "employees",
        "orders",
        "warehouses",
        "customers",
        "suppliers",
        "products"
    ]
    with engine.connect() as conn:
        for table in tables:
            conn.execute(text(f"DELETE FROM {table}"))
        conn.commit()

def run_shipments_only(engine):
    with engine.connect() as conn:
        # Pull orders WITH IDs
        df_orders = get_full_table("orders", engine)
        warehouse_ids = get_ids("warehouses", "warehouse_id", engine)

        print("Loading shipments...")
        insert_table(create_fake_shipments(df_orders, warehouse_ids), "shipments", engine)

def run_order_items_only(engine):
    print("Starting order items pipeline...")
    with engine.connect() as conn:
        # Pull orders WITH IDs
        df_orders = get_full_table("orders", engine)
        print(str(len(df_orders)) + "Length of df_orders")
        order_ids = df_orders["order_id"].tolist()
        print(str(len(order_ids)) + "Length of order ids")
        product_ids = get_ids("products", "product_id", engine)
        print(str(len(product_ids)) + "Length of product ids")

        print("Loading order items...")
        insert_table(create_fake_order_items(5000, order_ids, product_ids), "order_items", engine)

def main(mode="full"):
    engine = get_engine()

    if mode == "shipments":
        run_shipments_only(engine)
    elif mode == "order_items_only":
        run_order_items_only(engine)
    elif mode == "full":
        run_full_pipeline(engine)

def run_full_pipeline(engine):
    # Layer 1: Dimensions ---
    print("Loading products...")
    insert_table(create_fake_products(100), "products", engine)
    print("Loading suppliers...")
    insert_table(create_fake_suppliers(25), "suppliers", engine)
    print("Loading customers...")
    insert_table(create_fake_customers(200), "customers", engine)
    print("Loading warehouses...")
    insert_table(create_fake_warehouses(20), "warehouses", engine)
    
    # Pull IDs after creation to ensure we have the auto-incremented IDs for relationships
    product_ids = get_ids("products", "product_id", engine)
    supplier_ids = get_ids("suppliers", "supplier_id", engine)
    customer_ids = get_ids("customers", "customer_id", engine)
    warehouse_ids = get_ids("warehouses", "warehouse_id", engine)

    #Layer 2 Facts ---
    df_orders = create_fake_orders(1000, customer_ids)
    print("Loading orders...")
    insert_table(df_orders, "orders", engine)

    df_employees = create_fake_employees(50, warehouse_ids)
    print("Loading employees...")
    insert_table(df_employees, "employees", engine)
    
    # Pull order_ids after creation to ensure we have the auto-incremented IDs
    order_ids = get_ids("orders", "order_id", engine)
              
    # Pull orders WITH IDs
    df_orders = get_full_table("orders", engine)
        
    # Layer 3: Derived Facts ---
    print("Loading shipments...")
    insert_table(create_fake_shipments(df_orders, warehouse_ids), "shipments", engine)
    
    print("Loading order items...")
    insert_table(create_fake_order_items(5000, order_ids, product_ids), "order_items", engine)
    
    # Layer 4: Quality Metrics ---
    print("Loading production batches...")
    insert_table(create_fake_production_batches(1000, product_ids, supplier_ids), "production_batches", engine)

    # Pull batch + employee data
    df_batches = get_full_table("production_batches", engine)
    df_employees = get_full_table("employees", engine)

    print("Loading quality inspections...")
    insert_table(create_fake_quality_inspections(df_batches, df_employees, 1000), "quality_inspections", engine)
   
if __name__ == "__main__":
    main("shipments")