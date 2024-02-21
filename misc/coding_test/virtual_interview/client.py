"""
id:            Peter Lee (peter.lee@astrocapital.net)
last_update:   2024-Feb-16 23:27:32
type:          lib
sensitivity:   datalab@astrocapital.net
platform:      any
description:   Client side for Online Coding Test 1
"""
import json
import time
from threading import Thread

import pandas as pd
from websocket import create_connection


class BybitClient:
    def __init__(self):
        self.ws_url = "wss://stream.bybit.com/v5/public/spot"
        # self.ws_url = "ws://127.0.0.1:51001/v5/public/spot"
        self.symbol = "BTCUSDT"
        self.trade_data = []

    def connect(self):
        self.ws = create_connection(self.ws_url)
        sub_message = json.dumps(
            {"op": "subscribe", "args": [f"publicTrade.{self.symbol}"]}
        )
        self.ws.send(sub_message)
        Thread(target=self.receive_data).start()

    def receive_data(self):
        while True:
            data = self.ws.recv()
            trade_info = json.loads(data)
            # 这里假设trade_info包含交易数据，具体结构取决于API返回的数据
            self.trade_data.append(trade_info)

    def run(self):
        while True:
            self.process_data()
            time.sleep(1)  # 每1秒刷新一次数据

    def process_data(self):
        # Preserve memory
        if len(self.trade_data) > 1000:
            self.trade_data = self.trade_data[-1000:]

        df = self.extract_df(self.trade_data)

        if len(df) == 0:
            print("No trade data")
            return

        # Ensure that there is at least 1 trade that happens before a minute ago
        now = pd.Timestamp.utcnow()
        mask = df["datetime"] < (now - pd.Timedelta(minutes=1)).tz_localize(None)

        if mask.sum()==0:
            print(f"Not yet a minute. Waiting for more data...")
            return

        if mask.all():
            print(f"\n[{now}] 过去1分钟内没有交易")
            return

        # Filter for trades that happpens in the last 1 minute
        now = pd.Timestamp.utcnow()
        mask = df["datetime"] > (now - pd.Timedelta(minutes=1)).tz_localize(None)
        df = df[mask]

        total_amount = df["notional"].sum()
        print(f"\n[{now}] 过去1分钟内的交易数量: {len(df):,}, 交易总额: USDT {total_amount:,.02f}")
        print(df.tail())

    def extract_df(self, trade_data) -> pd.DataFrame:
        """Extract df from self.trade_data"""
        if len(trade_data) == 0:
            return pd.DataFrame()

        data = []
        for x in list(self.trade_data):
            if "data" not in x:
                continue
            data += x["data"]
        df = pd.DataFrame(data)

        if len(df) == 0:
            return df

        df = df.rename(
            columns={
                "T": "datetime",
                "s": "symbol",
                "S": "side",
                "v": "qty",
                "p": "price",
                "i": "trade_id",
                "BT": "block_trade",
            }
        )

        df["qty"] = pd.to_numeric(df["qty"])
        df["price"] = pd.to_numeric(df["price"])

        df["datetime"] = pd.to_numeric(df["datetime"])
        df["datetime"] = pd.to_datetime(df["datetime"], unit="ms")
        df["notional"] = df["qty"] * df["price"]
        return df


if __name__ == "__main__":
    client = BybitClient()
    client.connect()
    client.run()
