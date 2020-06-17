# Time series analysis with sales_prediction

This example introduces time series for sales data prediction using [Facebook sales_prediction](https://facebook.github.io/sales_prediction).
Details are described in [the official document](https://facebook.github.io/sales_prediction/docs/non-daily_data.html#monthly-data).

This workflow will:

1. Fetch past sales data from Treasure Data
2. Build a model with sales_prediction
3. Predict future sales and write back to Treasure Data
4. Upload predicted figures to S3

## Workflow

There are two workflow examples:

1. uploads prediction results to TD.
2. uploads prediction results to TD, with uploading predicted graphs to Amazon S3 and sends a notification to Slack

* [predict_sales_with_graph.dig](predict_sales_with_graph.dig)

### A basic example

```bash
$ td workflow push sales_prediction
$ td workflow secrets \
  --project sales_prediction \
  --set td.apikey \
  --set td.apiserver
# Set secrets from STDIN like: td.apikey=1234/xxxxx, td.apiserver=https://api.treasuredata.com
# Run before running predict_sales first time
$ td workflow start sales_prediction ingest --session now
$ td workflow start sales_prediction predict_sales --session now
```

* [predict_sales.dig](predict_sales.dig)

### An example working with Amazon S3 and Slack

```bash
$ td workflow push sales_prediction
$ td workflow secrets \
 --project sales_prediction \
  --set td.apikey \
  --set td.apiserver \
  --set s3.bucket \
  --set s3.access_key_id \
  --set s3.secret_access_key
# Set secrets from STDIN like: td.apikey=1234/xxxxx, td.apiserver=https://api.treasuredata.com, s3.bucket=$S3_BUCKET,
#              s3.access_key_id=AAAAAAAAAA, s3.secret_access_key=XXXXXXXXX
# Run before running predict_sales first time
$ td workflow start sales_prediction ingest --session now
$ td workflow start sales_prediction predict_sales_with_graph --session now
```
