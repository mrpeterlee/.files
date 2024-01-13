# Astro Capital Onsite Interview

Last Update: 2023-12-25

## 背景介绍
Index是由评测机构/投行发布的股票组合， ETF是可以在证券交易所交易的开放式基金，我们提供了一些美国的Index和ETF的数据。

具体的数据文件名和对应的内容如下：

1. US Indices

   - 'index/index-historical-1hour.zip': 美国所有index历史的小时数据
   - 'index/index-20231225-1day.zip': 美国所有index在2023-12-25获得的最新的收盘价数据
   - 'index/README.md': 数据的内容介绍

挑战1 - 请尝试回答以下问题：
   1. 数据库中一共收录了多少个Indices？
   2. 请找出两组相关性最高的indices
   3. 在2023-12-25这天，我们收集了最新的收盘价，请写一个程序来验证我们的数据的准确性。
      有可能历史数据和最新的收盘价数据皆有问题。
   
答案:
   - 'index/index-historical-1hour.zip': Missing DMLV, WPUT, VVIX close wrong.
   - 'index/index-20231225-1day.zip':  Missing LOVOL, W5000, DJCIS close wong, SPSPV close wrong.

2. ETF
   - 'etf/input_data/etf-historical-1day-{TICKER_PREFIX}-adj_split.zip': 美国所有etf的历史数据（daily），为拆股做了处理
   - 'etf/input_data/etf-historical-1day-{TICKER_PREFIX}-UNADJUSTED.zip': 美国所有etf的历史数据（daily），未作处理
   - 'etf/input_data/etf-20231225-1day-UNADJUSTED.zip': 美国所有etf在2023-12-25获得的最新的收盘价数据,未作处理
   - 'etf/input_data/etf-20231225-1day-adj_split.zip': 美国所有etf在2023-12-25获得的最新的收盘价数据，为拆股做了处理
   - 'etf/input_data/etf-split_adjustment_factor.zip': 美国所有etf的拆股因子
   - 'etf/input_data/etf-dividends.zip': 美国所有etf Dividends 【现金分红】
   - 'etf/README.md': 数据的内容介绍

挑战
    1. 请观察etf UNADJUSTED和adj_split两组数据，请尝试使用UNADJUSTED数据和etf-split_adjustment_factor.zip,组合生成adj_split格式的数据。
    2. 请推到如何使用etf UNADJUSTED,adj_split和dividends三组数据，生成Split-Dividend Adjusted格式的数据。
    3. 如果时间允许，请为你的程序写test cases。

