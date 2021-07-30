import os, sys

os.system(f"{sys.executable} -m pip install --upgrade pytd==1.4.0")

def read_td_table(database_name, table_name, limit=1000):
    import pytd
    import pandas as pd

    apikey = os.environ["TD_API_KEY"]
    apiserver = os.environ["TD_API_SERVER"]
    client = pytd.Client(apikey=apikey, endpoint=apiserver, database=database_name)

    res = client.query(f"select * from {table_name} limit {limit}")
    df = pd.DataFrame(**res)
    print(df)

def write_td_table(database_name, table_name):
    import pytd
    import pandas as pd

    apikey = os.environ['TD_API_KEY']
    apiserver = os.environ['TD_API_SERVER']
    client = pytd.Client(apikey=apikey, endpoint=apiserver, database=database_name)

    df = pd.DataFrame(data={"col1": [1, 2, 4], "col2": [1.0, 2.0, 3.0]})

    client.create_database_if_not_exists(database_name)
    client.load_table_from_dataframe(
        df, f"{database_name}.{table_name}", if_exists="overwrite"
    )

if __name__ == "__main__":
    read_td_table("sample_datasets", "nasdaq")
    write_td_table("pandas_test", "my_df")
