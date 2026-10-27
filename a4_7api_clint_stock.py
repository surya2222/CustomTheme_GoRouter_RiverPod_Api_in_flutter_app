# Start the server first, then run:
# python a4_7api_clint_stock.py

import json
import time

import requests

# SIGNAL_URL = "http://127.0.0.1:8081/api1"
SIGNAL_URL = "http://niftybee.in/api1"
HEADERS = {"Authorization": "Bearer suryaji"}

while True:
    try:
        response = requests.get(SIGNAL_URL, headers=HEADERS, timeout=10)
        response.raise_for_status()
        payload = response.json()
        print(json.dumps(payload, indent=2))
    except requests.exceptions.RequestException as error:
        print("API ERROR:", error)
    except ValueError as error:
        print("INVALID JSON RESPONSE:", error)

    time.sleep(5)
