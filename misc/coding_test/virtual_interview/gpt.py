import json
import threading
import time
from datetime import datetime, timedelta

import websocket


class BybitStreamer:
    def __init__(self):
        self.ws_url = "wss://stream.bybit.com/v5/public/spot"
        self.trade_data = []

    def on_message(self, ws, message):
        message = json.loads(message)
        if 'topic' in message and message['topic'] == 'publicTrade.BTCUSDT':
            self.trade_data.append(message['data'])

            # 清除超过1分钟的旧数据
            one_minute_ago = datetime.utcnow() - timedelta(minutes=1)
            self.trade_data = [data for data in self.trade_data if datetime.fromtimestamp(data['trade_time_ms'] / 1000) > one_minute_ago]

            # 计算和打印统计信息
            trade_count = len(self.trade_data)
            total_amount = sum(float(data['qty']) for data in self.trade_data)
            print(f"Trades in last minute: {trade_count}, Total Amount: {total_amount}")

    def on_error(self, ws, error):
        print(f"Error: {error}")

    def on_close(self, ws, close_status_code, close_msg):
        print("### Connection Closed ###")

    def on_open(self, ws):
        # 发送订阅请求
        subscribe_message = json.dumps({"op": "subscribe", "args": ["publicTrade.BTCUSDT"]})
        ws.send(subscribe_message)

    def run(self):
        websocket.enableTrace(True)
        ws = websocket.WebSocketApp(self.ws_url,
                                    on_open=self.on_open,
                                    on_message=self.on_message,
                                    on_error=self.on_error,
                                    on_close=self.on_close)

        wst = threading.Thread(target=ws.run_forever)
        wst.start()

# 运行程序
streamer = BybitStreamer()
streamer.run()
