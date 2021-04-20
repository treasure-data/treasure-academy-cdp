import os
import sys

os.system(f"{sys.executable} -m pip install --upgrade pytd==1.4.3")
apikey = os.environ["TD_API_KEY"]
apiserver = os.environ["TD_API_SERVER"]


def summarize_access(database_name, table_name):
    import pytd
    import pandas as pd

    client = pytd.Client(
        apikey=apikey,
        endpoint=apiserver,
        database=database_name
    )

    client.create_database_if_not_exists(database_name)

    res = client.query("select code, method, count(1) as access_count from sample_datasets.www_access group by 1, 2")
    df = pd.DataFrame(**res)


    client.load_table_from_dataframe(
        df,
        f"{database_name}.{table_name}",
        if_exists="overwrite"
    )

def summarize_access_pandas(database_name, table_name):
    import pytd
    import pandas as pd

    client = pytd.Client(
        apikey=apikey,
        endpoint=apiserver,
        database=database_name
    )

    client.create_database_if_not_exists(database_name)
    
    res = client.query(f"select code, method from  sample_datasets.www_access")
    df = pd.DataFrame(**res)
    df2 = df.groupby(["code", "method"]).size().to_frame("size").reset_index()

    client.load_table_from_dataframe(
        df2,
        f"{database_name}.{table_name}",
        if_exists="overwrite")
