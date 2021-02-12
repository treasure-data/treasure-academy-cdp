import os
import sys

import pandas as pd

os.system(f"{sys.executable} -m pip install -U pytd==1.4.3")


# This function will upload an example CSV for retail sales data
def upload_dataset(database, table):
    import pytd

    apikey = os.environ["TD_API_KEY"]
    apiserver = os.environ["TD_API_SERVER"]
    client = pytd.Client(database=database, apikey=apikey, endpoint=apiserver)

    if client.exists(database, table):
        print("Target database and table exist. Skip")
        return True

    target_url = "https://raw.githubusercontent.com/facebook/prophet/master/examples/example_retail_sales.csv"

    df = pd.read_csv(target_url)
    client.create_database_if_not_exists(database)
    client.load_table_from_dataframe(df, table, if_exists="overwrite")

    return True
