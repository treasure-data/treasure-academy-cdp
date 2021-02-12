#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

import pandas as pd

os.system(f"{sys.executable} -m pip install feedparser")
os.system(f"{sys.executable} -m pip install -U pytd==1.4.3")

apikey = os.environ.get("TD_API_KEY")
apiserver = os.environ.get("TD_API_SERVER")


def rss_import(dest_db: str, dest_table: str, rss_url_list):
    import feedparser
    import pytd

    posts = []
    # Fetch RSS data for each URL in `rss_url_list`
    for rss_url in rss_url_list:
        # Parse RSS into Python dictionary
        d = feedparser.parse(rss_url)
        # Get title, description, and link of each entry in an RSS
        for entry in d.entries:
            # You can modify this line to get other fields e.g., summary
            posts.append((entry.title, entry.description, entry.link))

    # Create pandas DataFrame of posts
    # If you want to add other fields, you need to modify `columns` argument
    df = pd.DataFrame(posts, columns=["title", "description", "link"])
    # Create pytd client
    client = pytd.Client(apikey=apikey, endpoint=apiserver, database=dest_db)
    # Create `dest_db` database if not exists
    client.create_database_if_not_exists(dest_db)
    # Upload and append the dataframe to TD as `dest_db`.`dest_table`
    client.load_table_from_dataframe(df, dest_table, if_exists="append")


if __name__ == "__main__":
    feeds = [
        "https://www.vogue.co.jp/rss/vogue",
        "https://feeds.dailyfeed.jp/feed/s/7/887.rss",
    ]
    rss_import("rss_db", "rss_tbl", feeds)
