# -*- coding: utf-8 -*-
"""
Created on Mon Feb 17 13:18:31 2020

@author: J
"""

import requests
import pandas as pd
import json


url = "https://telraam-api.net/v0/reports/349547"

payload = "{\n    \"time_start\": \"2020-01-01 00:00\",\n    \"time_end\": \"2020-04-01 23:59\",\n    \"level\": \"segments\",\n    \"format\":\"per-hour\"\n}"
headers = {
  'Content-Type': 'application/json'
}

response = requests.request("POST", url, headers=headers, data = payload)

result = json.loads(response.text)

result2 = result.get('report')

df = pd.DataFrame(result2)

print(list(df))

df['bucket0'] = 0
df['bucket1'] = 0
df['bucket2'] = 0
df['bucket3'] = 0
df['bucket4'] = 0
df['bucket5'] = 0
df['bucket6'] = 0
df['bucket7'] = 0


for i in range(0,len(df)):
  for j in range(0,len(df['car_speed_bucket'][i])):
    if df['car_speed_bucket'][i][j] == 0:
      df['bucket0'][i] = df['car_speed_histogram'][i][j]
    elif df['car_speed_bucket'][i][j] == 1:
      df['bucket1'][i] = df['car_speed_histogram'][i][j]
    elif df['car_speed_bucket'][i][j] == 2:
      df['bucket2'][i] = df['car_speed_histogram'][i][j]
    elif df['car_speed_bucket'][i][j] == 3:
      df['bucket3'][i] = df['car_speed_histogram'][i][j]
    elif df['car_speed_bucket'][i][j] == 4:
      df['bucket4'][i] = df['car_speed_histogram'][i][j]
    elif df['car_speed_bucket'][i][j] == 5:
      df['bucket5'][i] = df['car_speed_histogram'][i][j]
    elif df['car_speed_bucket'][i][j] == 6:
      df['bucket6'][i] = df['car_speed_histogram'][i][j]
    else:
      df['bucket7'][i] = df['car_speed_histogram'][i][j]
print(df['bucket7'])

#print(len(dataframe['car_speed_bucket'][152]))
df.to_csv(r'C:\Users\Harol\Documents\GitHub\Datathon\results4_test.csv', sep=',')