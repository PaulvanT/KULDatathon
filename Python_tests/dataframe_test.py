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
print(list(df))

#df.to_csv(r'C:\Users\Harol\Documents\GitHub\Datathon\results2_test.csv', sep=',')
dataframe = df.copy()

# create bucket columns
'''
for row in dataframe:
  i = 0
  for element1 in dataframe['car_speed_bucket']:
    string = 'bucket' + str(element1)
    dataframe[string] = dataframe['car_speed_histogram'][i]
    i = i + 1
'''
for obs in dataframe['car_speed_histogram']:
  print(obs[1])


#dataframe.to_csv(r'C:\Users\Harol\Documents\GitHub\Datathon\results3_test.csv', sep=',')