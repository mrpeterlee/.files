import json
import threading
import time
from collections import deque
from datetime import datetime

import websocket

# 初始化变量
data_stream = deque()
endpoint = "wss://stream.bybit.com/v5/public/spot"

# 处理接收到的消息
def on_message(ws, message):
    print(message)
    global data_stream
    data = json.loads(message)
    if data.get('topic') == "publicTrade.BTCUSDT":
        data_stream.append(data['data'])
        # 保持数据流中只有最近1分钟的数据
        while data_stream and (datetime.now() - datetime.fromtimestamp(data_stream[0]['trade_time_ms'] / 1000)).total_seconds() > 60:
            data_stream.popleft()

# 发送订阅请求
def on_open(ws):
    sub_request = json.dumps({"op": "subscribe", "args": ["publicTrade.BTCUSDT"]})
    ws.send(sub_request)

# 创建WebSocket连接
def start_websocket():
    ws = websocket.WebSocketApp(endpoint,
                                on_open=on_open,
                                on_message=on_message)
    ws.run_forever()

# 分析数据并展示结果
def analyze_data():
    while True:
        trade_count = len(data_stream)
        total_amount = sum(item['amount'] for item in data_stream)
        print(f"Trades in last minute: {trade_count}, Total amount: {total_amount}")
        time.sleep(10)  # 每10秒刷新一次数据

# 启动客户端
threading.Thread(target=start_websocket).start()
analyze_data()
