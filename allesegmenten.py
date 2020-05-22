# -*- coding: utf-8 -*-
"""
Created on Mon Feb 17 14:33:17 2020

@author: J
"""

import requests
import json
import pandas as pd

url = "https://telraam-api.net/v0/reports"

payload = "{\n    \"time_start\": \"2020-01-01 13:00\",\n    \"time_end\": \"2020-01-01 17:00\",\n    \"level\": \"segments\",\n    \"format\":\"per-hour\"\n}"
headers = {
  'Content-Type': 'application/json'
}

response = requests.request("POST", url, headers=headers, data = payload)

result = json.loads(response.text)

result2 = result.get('report')


df = pd.DataFrame(result2)

print(response.text.encode('utf8'))
