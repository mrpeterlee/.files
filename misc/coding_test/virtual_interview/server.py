"""
id:            Peter Lee (peter.lee@astrocapital.net)
last_update:   2023-Dec-14 16:42:13
type:          lib
sensitivity:   datalab@astrocapital.net
platform:      any
description:   Server side
"""
import asyncio
import json
import random

import acap_gateway.dt
import uvicorn
from fastapi import FastAPI, WebSocket

app = FastAPI()


@app.websocket("/v5/public/spot")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    while True:
        response = {}

        response["data"] = []

        # 生成模拟的交易数据
        simulated_trade = {
            "T": str(acap_gateway.dt.get_unix_timestamp()),
            "s": "BTCUSDT",
            "S": "BUY",
            "v": str(random.randint(1, 100)),
            "p": str(random.randint(12000, 10000)),
            "i": str(random.randint(100000, 1000000)),
            "BT": str(False),
        }
        response["data"].append(simulated_trade)
        await websocket.send_json(response)

        # 每秒发送一次模拟数据
        await asyncio.sleep(1)


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
