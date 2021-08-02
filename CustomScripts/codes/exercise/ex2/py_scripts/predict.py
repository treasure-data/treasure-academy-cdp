import io
import os
import sys

os.system(f"{sys.executable} -m pip install -U pytd==1.4.0")


class TimeSeriesPredictor(object):
    def _upload_graph(self, model, forecast):
        import boto3
        import matplotlib as mlp

        # Need to plot graph for Prophet
        mlp.use("agg")
        from matplotlib import pyplot as plt  # noqa

        # Plot prediction results
        fig1 = model.plot(forecast)
        fig2 = model.plot_components(forecast)
        predict_fig_data = io.BytesIO()
        component_fig_data = io.BytesIO()
        fig1.savefig(predict_fig_data, format="png")
        fig2.savefig(component_fig_data, format="png")
        predict_fig_data.seek(0)
        component_fig_data.seek(0)

        # Upload figures to S3
        # boto3 assuming environment variables "AWS_ACCESS_KEY_ID" and "AWS_SECRET_ACCESS_KEY":
        # http://boto3.readthedocs.io/en/latest/guide/configuration.html#environment-variables
        s3 = boto3.resource("s3")

        predicted_fig_file = "predicted.png"
        component_fig_file = "component.png"

        # ACL should be chosen with your purpose
        s3.Object(os.environ["S3_BUCKET"], predicted_fig_file).put(
            ACL="public-read", Body=predict_fig_data, ContentType="image/png"
        )
        s3.Object(os.environ["S3_BUCKET"], component_fig_file).put(
            ACL="public-read", Body=component_fig_data, ContentType="image/png"
        )

    def run(
        self,
        database="timeseries",
        source_table="retail_sales",
        target_table="predicted_sales",
        start_date="1993-01-01",
        end_date="2016-05-31",
        period=365,
        with_aws=False,
    ):
        """Train Prophet model and predict future sales

        :param database: Target DB name, defaults to "timeseries"
        :type database: str
        :param source_table: Source table for past sales, defaults to "retail_sales"
        :type source_table: str
        :param target_table: Table name for storing future sales prediction, defaults
          to "predicted_sales"
        :type target_table: str
        :param start_date: Beginning date for training data, defaults to "1993-01-01"
        :type start_date: str
        :param end_date: Last date for training data, defaults to "2016-05-31"
        :type end_date: str
        :param period: Duration for prediction, defaults to 365
        :type period: int
        :param with_aws: If True, upload prediction graphs to AWS, defaults to False
        :type with_aws: bool
        """

        import pytd
        import pandas as pd
        from fbprophet import Prophet

        # Ensure type of period is integer
        period = int(period)

        # Create TD connection
        apikey = os.getenv("TD_API_KEY")
        endpoint = os.getenv("TD_API_SERVER")
        client = pytd.Client(apikey=apikey, endpoint=endpoint, database=database)

        # Fetch past sales data from Treasure Data
        # Note: Prophet requires `ds` column as date string and `y` column as target
        #       value
        res = client.query(
            f"""
            select ds, y
            from {source_table}
            where ds between '{start_date}' and '{end_date}'
            """
        )
        df = pd.DataFrame(**res)

        # Train Prophet model
        model = Prophet(seasonality_mode="multiplicative")
        model.fit(df)

        # Predict future sales data
        future = model.make_future_dataframe(periods=period)
        forecast = model.predict(future)

        # If True, upload prediction graph to S3
        if with_aws:
            self._upload_graph(model, forecast)

        # To avoid TypeError: can't serialize Timestamp, convert
        # `pandas._libs.tslibs.timestamps.Timestamp` to `str`
        forecast.ds = forecast.ds.apply(str)

        # Store prediction results
        client.load_table_from_dataframe(forecast, target_table, if_exists="overwrite", fmt='msgpack')


if __name__ == "__main__":
    TimeSeriesPredictor().run()
