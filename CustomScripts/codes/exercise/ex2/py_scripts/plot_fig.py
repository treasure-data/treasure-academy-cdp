import logging
import matplotlib as mlp

mlp.use("agg")
logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.INFO)


# Equivalent code with model.plot()
# https://github.com/facebook/prophet/blob/ca9a49d328ab1f2a991f246a3ebc37a7f9c896c5/python/fbprophet/plot.py#L41-L88
def plot(df, df_prev, xlabel="ds", ylabel="y"):
    from matplotlib import pyplot as plt
    from matplotlib.dates import (
        AutoDateLocator,
        AutoDateFormatter,
    )

    fig = plt.figure(facecolor="w", figsize=(10, 6))
    ax = fig.add_subplot(111)

    fcst_t = pd.to_datetime(df["ds"])
    ax.plot(pd.to_datetime(df_prev["ds"]), df_prev["y"], "k.")
    ax.plot(fcst_t, df["yhat"], ls="-", c="#0072B2")
    if "cap" in df:
        ax.plot(fcst_t, df["cap"], ls="--", c="k")

    if "floor" in df:
        ax.plot(fcst_t, df["floor"], ls="--", c="k")

    ax.fill_between(
        fcst_t, df["yhat_lower"], df["yhat_upper"], color="#0072B2", alpha=0.2
    )
    locator = AutoDateLocator(interval_multiples=False)
    formatter = AutoDateFormatter(locator)
    ax.xaxis.set_major_locator(locator)
    ax.xaxis.set_major_formatter(formatter)
    ax.grid(True, which="major", c="gray", ls="-", lw=1, alpha=0.2)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    fig.tight_layout()

    return fig


if __name__ == "__main__":
    import os
    import pytd
    import sys

    import pandas as pd

    if len(sys.argv) < 3:
        logger.error("You need to pass database name and output figure name")
        logger.error("plot_fig.py <dbname> <figurename>.png")
        exit(-1)

    dbname = sys.argv[1]
    figname = sys.argv[2]
    logger.info(f"Target database: {dbname}\nOutput file: {figname}")
    client = pytd.Client(
        apikey=os.environ["TD_API_KEY"],
        endpoint=os.environ["TD_API_SERVER"],
        database=dbname,
    )
    df = pd.DataFrame(**client.query("select * from predicted_sales order by ds"))
    df_prev = pd.DataFrame(**client.query("select * from retail_sales order by ds"))
    fig = plot(df, df_prev)
    fig.savefig(figname)
    logger.info("Plot succeeded")