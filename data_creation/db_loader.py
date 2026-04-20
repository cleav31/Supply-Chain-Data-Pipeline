import pandas as pd
from sqlalchemy import create_engine

def get_engine():
    return create_engine("mysql+pymysql://root:1GetMoney!@localhost:3306/supply_chain_db")

def insert_table(df, table_name, engine):
    df.to_sql(table_name, con=engine, if_exists="append", index=False)

def get_ids(table_name, id_column, engine):
    query = f"SELECT {id_column} FROM {table_name}"
    return pd.read_sql(query, engine)[id_column].tolist()

def get_full_table(table_name, engine):
    return pd.read_sql(f"SELECT * FROM {table_name}", engine)
    