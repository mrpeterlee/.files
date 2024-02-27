"""
platform:      any
description:   Onsite Coding Test - Challenge 2
"""

from typing import Optional
from pathlib import Path
import pandas as pd
from pprint import pprint


path_hourly_data = "hour"
path_daily_data = "daily"


def load_data(subfolder: str) -> dict:
    """Load data from the given subfolder and return a dictionary of dataframes"""
    dfs = {}
    files = sorted(list(Path(Path.cwd() / subfolder).glob("*.txt")))
    for i, _file in enumerate(files):
        ticker = _file.stem.split("_")[0]
        df = pd.read_csv(_file, sep=",")
        df.columns = [ "date", "open", "high", "low", "close", ]
        df["date"] = pd.to_datetime(df["date"], format="%Y-%m-%d %H:%M:%S")
        df.set_index("date", inplace=True)
        dfs[ticker] = df
        # if i>5: break
    return dfs


def challenge_2(dfs, verbose_tickers: Optional[list] = None) -> dict:
    """Find the pair of stocks that have the highest correlation between their closing prices."""
    if verbose_tickers is None:
        verbose_tickers = []
    corr = {}

    i = 1
    for ticker1, df1 in dfs.items():
        for ticker2, df2 in dfs.items():

            if i % 1000 == 0:
                print(i)

            if ticker1 == ticker2:
                continue
            if f"{ticker2}-{ticker1}" in corr:
                continue

            common_index = df1.index.intersection(df2.index)

            if len(common_index) <= 1:
                continue

            # if len(common_index) <=10:
            # print(f"Skipping {ticker1}-{ticker2} due to insufficient data {len(common_index)}")
            # continue

            df1 = df1.loc[common_index].sort_index(ascending=True)
            df2 = df2.loc[common_index].sort_index(ascending=True)

            _corr = df1.close.corr(df2.close)
            corr[f"{ticker1}-{ticker2}"] = _corr

            if f"{ticker1}-{ticker2}" in verbose_tickers:
                print(f"\n{ticker1}-{ticker2}: {_corr}")
                print(pd.concat([df1.close, df2.close], axis=1))

            i += 1

    # convert dict to Series and show all rows that match the max value
    s = pd.Series(corr)
    pprint(s[s == s.max()].to_dict())
    return corr


if __name__ == "__main__":
    dfs = load_data(path_hourly_data)

    challenge_2(dfs, verbose_tickers=["SET-SKEW", "DUX-UTIL", "OEX-XEO"])

    print("Done..")
