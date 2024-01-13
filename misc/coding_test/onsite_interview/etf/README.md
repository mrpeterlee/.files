Complete ETF Historical Dataset
================================== 

NOTE: Only intraday-bars with trading volume are included. Bars with zero volume are excluded.

Timeframes : 1-minute, 5-minutes, 30-minutes, 1-hour, 1-day


Adjustments
------------

We provide three types of data:
Unadjusted - actual historic traded prices with no adjustments (only the 1-minute and 1-day timeframes are available for unadjusted data)
Split Adjusted - prices adjusted for stock splits and reverse splits only
Split+Dividend Adjusted - prices adjusted for both splits and dividends



Format
-------
Data is in the format : { DateTime (yyyy-MM-dd HH:mm:ss), Open, High, Low, Close, Volume}  

- Volume Numbers are in individual shares
- Timestamps run from the start of the period (eg 1min bars stamped 09:30 run from 09:30.00 to 09:30.59)
- Times with zero volume are omitted (thus gaps in the data sequence are when there have been no trades)


Updates
-------
This dataset is updated daily (update files are available by 11.45pm US Eastern time and 3am the following day for the full historical archive files)*. 
New tickers are added every two weeks (tickers of over 500M market cap or > $8M in daily trading volume are added).

 

Notes
-----
 
- Timezone is US Eastern Time    
- Excel will usually fail to open large files directly. 
  To use the data in Excel, open the files using notepad and then break into smaller files or copy/paste into Excel 
 
  
Price Adjustment
----------------

Stocks / ETFs
All stock and ETF datasets include both unadjusted data, split-only adjusted data, and split and dividend adjusted data.


Split Adjustments
For stock splits (and reverse splits) the prior data is adjusted by the split ratio. For example, on Aug 31 2020 Apple's stock was split 4:1 resulting in the below price data:

{Timestamp, Open, High, Low, Close, Volume}
2020-08-28 19:59:00,501.8000,502.0000,501.7100,501.9800,5786
2020-08-31 09:30:00,127.6200,128.0000,126.9100,127.1300,7250228

To avoid the price drop from the split the prior data is adjusted by the split ratio:

{Timestamp, Open, High, Low, Close, Volume}
2020-08-28 19:59:00,125.2333,125.2832,125.2109,125.2782,23144
2020-08-31 09:30:00,127.6200,128.0000,126.9100,127.1300,7250228 2020-08-31 09:30:00,127.6200,128.0000,126.9100,127.1300,7250228

Note the volume is also adjusted by the split ratio (except volumes are adjusted for by multiplying by the split ratio).


Dividend Adjustments
Dividends also have a distorting effect on prices and are adjusted for. On the ex-dividend date, stock holders are no longer entitiled to receive the dividend and as such the price should be adjusted since it no longer includes the cash payment of the dividend.

The adjustment for dividends is a little more complex since the dividend is a cash amount and not a ratio as with splits. The adjustment factor is:

1 - (Dividend Amount / Prior Day's Close Price)

For example, on Nov-6-2020 Apple stock went ex-dividend and shareholders were no longer entitled to the $0.205 per share dividend (note this is the ex-dividend date, the actual payment date of Nov-12-2020 has no price impact).

The unadjusted price data is :

{Timestamp, Open, High, Low, Close, Volume}
2020-11-05 19:59:00,118.0500,118.0500,118.0000,118.0000,15203
2020-11-06 04:00:00,117.7700,117.7700,117.0700,117.0800,4692
The adjustment factor is :

1 - (.205 / 118.00) = 0.99826

This factor is then multiplied to all the prior price data. Note, for dividend adjustments the volumes are not adjusted. Thus the dividend adjusted data is:

{Timestamp, Open, High, Low, Close, Volume}
2020-11-05 19:59:00,117.8449,117.8449,117.795,117.795,15203
2020-11-06 04:00:00,117.7700,117.7700,117.0700,117.0800,4692
The dividend adjustment is applied to all prior prices in the series from the first of the series to the last date before the ex-dividend date.
Note that if the price has been adjusted for a split then the dividend should be adjusted by the same ratio in the adjustment factor calcuation.

Dividend adjustments can lead to differences between prices between different data vendors. The most common cause is some data vendors use the price at the close of regular trading hours to calculate the adjustment factor. At FirstRate Data we use the last available traded price on the day prior to the ex-dividend date to calculate the adjustment factor. This gives a slightly more accurate estimate of the price impact of the stock going ex-dividend.

 
 
