"""
id:            Peter Lee (peter.lee@astrocapital.net)
last_update:   2024-Jan-12 23:16:35
type:          lib
sensitivity:   datalab@astrocapital.net
platform:      any
description:   Fetch both US Indices and ETF datasets.

Historical Data Requests
This function returns historical data archives (.txt files in csv format which are grouped into zip archives)

    - Url EndPoint : https://firstratedata.com/api/data_file
    - Requires Authentication : YES. All requests must include the parameter userid with your userid given to you in your signup email. Also available from your Customer Download Page.
    - Data Details : Full details on the data format, timezone, as well as available tickers and date ranges can be viewed on the bundle ReadMe Page
    - Parameters : The below parameters are used with the URL Endpoint to use the Historical Data Requests function:

# Parameter : type
    Accepted Values : stock , etf, futures, crypto, index, fx

    Description : Specifies the type of instrument that is being requested.

    Example :
    https://firstratedata.com/api/data_file?type=etf&period=week&timeframe=1day&adjustment=adj_split&userid=hpNFhxyWgkKWc2XI9sOY-g

# Parameter : period
    Accepted Values : full , month , week , day

    Description : Specifies the period to request data for. 'full' requests the entire historical archive, 'month' requests the last 30 days, 'week' requests the current trading week (starting on Monday), 'day' requests the last trading day.

    To request the full historical archive you also need to specify a ticker_range parameter (see below).

    Example : https://firstratedata.com/api/data_file?type=etf&period=full&ticker_range=A&adjustment=adj_split&timeframe=1hour&userid=hpNFhxyWgkKWc2XI9sOY-g

# Parameter : ticker_range
    Accepted Values : A-Z (one letter of the alphabet)

    Description : Only to be used when requested the full historical dataset (ie 'period=full'). This parameter specifies the first letter of the ticker, for example 'ticker_range=C' will request all tickers beginning with the letter C

    This parameter can only be used when requested the full historical archive (ie 'period=full')

    Example :
    https://firstratedata.com/api/data_file?type=etf&period=full&ticker_range=C&timeframe=1day&adjustment=adj_split&userid=hpNFhxyWgkKWc2XI9sOY-g

# Parameter : timeframe
    Accepted Values : 1min , 5min , 30min , 1hour , 1day

    Description : Specifies the period the timeframe of the data. '1min' will request 1-minute intraday bars, '5min' requests 5-minute bars etc.
    Note : bars with zero volumes are not included

    Example :
    https://firstratedata.com/api/data_file?type=etf&period=week&adjustment=adj_split&timeframe=1min&userid=hpNFhxyWgkKWc2XI9sOY-g

# Parameter : adjustment
    Accepted Values : adj_split , adj_splitdiv , UNADJUSTED

    Description : Specifies the type of adjustment. 'adj_split' is data adjusted for splits only, 'adj_splitdiv' is data adjusted for both splits and dividends, 'UNADJUSTED' is raw data without any splits or dividend adjustments. UNADJUSTED data is only available in the 1min timeframe.

    Example :
    https://firstratedata.com/api/data_file?type=etf&period=week&timeframe=1day&adjustment=adj_split&userid=hpNFhxyWgkKWc2XI9sOY-g
"""

import os
import subprocess
import sys
import time
from itertools import product
from pathlib import Path

import pandas as pd

now = pd.Timestamp.utcnow()


def download_url_as_filename(url, filename):
    print(f"{url}\n  -->'{filename}'")
    p = subprocess.Popen(
        [
            "wget",
            "-O",
            f"{filename}",
            f"{url}",
        ],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    out, err = p.communicate()
    print(out)

    filepath = Path(Path.cwd(), filename)
    if filepath.is_file():
        filesize = filepath.stat().st_size / 1000
        print(f"Exported as filename {filename} filesize {filesize}")
    else:
        print(f"Download for {filename} FAILED!!!")


def should_redownload(filename) -> bool:
    filepath = Path(Path.cwd(), filename)

    if not filepath.is_file():
        return True

    if filepath.stat().st_size / 1000 <= 100:
        print()
        print(f"{filename} filesize is {filepath.stat().st_size/1000} kb")

        return True

    return False


# Download Index data
request_types = ["index"]
periods = ["full", "day"]
timeframes = ["1day"]
ticker_ranges = [""]
adjustments = [""]

for d_type, period, timeframe, ticker_range, adjustment in product(
    request_types, periods, timeframes, ticker_ranges, adjustments
):
    url = f"https://firstratedata.com/api/data_file?type={d_type}&period={period}&timeframe={timeframe}&userid=hpNFhxyWgkKWc2XI9sOY-g"

    if period == "full":
        filename = f"{d_type}-historical-{timeframe}.zip"
    else:
        filename = f'{d_type}-{now.strftime("%Y%m%d")}-{timeframe}.zip'

    if not should_redownload(filename):
        continue

    download_url_as_filename(url, filename)


# Download ETF FULL data
request_types = ["etf"]
periods = ["full"]
timeframes = ["1hour", "1day"]
ticker_ranges = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
adjustments = ["adj_split", "adj_splitdiv", "UNADJUSTED"]

for d_type, period, timeframe, ticker_range, adjustment in product(
    request_types, periods, timeframes, ticker_ranges, adjustments
):
    data_path = f"{d_type}_data"
    url = f"https://firstratedata.com/api/data_file?type={d_type}&period={period}&timeframe={timeframe}&ticker_range={ticker_range}&adjustment={adjustment}&userid=hpNFhxyWgkKWc2XI9sOY-g"

    if period == "full":
        filename = f"{d_type}-historical-{timeframe}-{ticker_range}-{adjustment}.zip"
    else:
        filename = f'{d_type}-{now.strftime("%Y%m%d")}-{timeframe}-{adjustment}.zip'

    if timeframe == "1hour" and adjustment == "UNADJUSTED":
        # Stock and ETF UNADJUSTED data is only available in the 1min and 1day timeframes
        continue

    if not should_redownload(filename):
        continue

    download_url_as_filename(url, filename)


# Download ETF 1day data
request_types = ["etf"]
periods = ["day"]
timeframes = ["1hour", "1day"]
ticker_ranges = [""]
adjustments = ["adj_split", "adj_splitdiv", "UNADJUSTED"]

for d_type, period, timeframe, ticker_range, adjustment in product(
    request_types, periods, timeframes, ticker_ranges, adjustments
):
    data_path = f"{d_type}_data"
    url = f"https://firstratedata.com/api/data_file?type={d_type}&period={period}&timeframe={timeframe}&adjustment={adjustment}&userid=hpNFhxyWgkKWc2XI9sOY-g"

    if period == "full":
        filename = f"{d_type}-historical-{timeframe}-{ticker_range}-{adjustment}.zip"
    else:
        filename = f'{d_type}-{now.strftime("%Y%m%d")}-{timeframe}-{adjustment}.zip'

    if not should_redownload(filename):
        continue

    download_url_as_filename(url, filename)
