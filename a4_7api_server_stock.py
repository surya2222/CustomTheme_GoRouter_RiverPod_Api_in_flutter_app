# ==================================================
# 🔹 Imports
# ===============================================

# Start with:
# python -m uvicorn a4_7api_server_stock:app --host 127.0.0.1 --port 8501 --reload
# python -m uvicorn a4_7api_server_stock:app --host 0.0.0.0 --port 8501 --reload

import random
from datetime import datetime

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel

# ==================================================
# 🔹 FastAPI App
# ==================================================

app = FastAPI(title="Stock API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["Authorization"],
)


# ==================================================
# 🔹 Security
# ==================================================

security = HTTPBearer()

API_TOKEN = "suryaji"


# ==================================================
# 🔹 Response Schema
# ==================================================


class CandleDataResponse(BaseModel):
    time: datetime
    open: float
    high: float
    low: float
    close: float


# ==================================================
# 🔹 Candle Data API
# ==================================================
@app.get("/api1", response_model=CandleDataResponse)
# Generates a new random candle on every request.
def get_random_candle(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if credentials.credentials != API_TOKEN:
        raise HTTPException(status_code=401, detail="Unauthorized")

    close = round(random.uniform(100, 150), 2)
    open_price = close + random.randint(-15, 15)
    high = max(open_price, close) + random.randint(1, 5)
    low = min(open_price, close) - random.randint(1, 5)
    return {
        "time": datetime.now(),
        "open": round(open_price, 2),
        "high": round(high, 2),
        "low": round(low, 2),
        "close": close,
    }


# ==================================================
# 🔹 Root
# ==================================================


@app.get("/")
# Purpose: Executes the root workflow.
def root():

    return {
        "status": "online",
        "message": "stock API Server is running",
        "endpoints": ["/api1"],
    }
