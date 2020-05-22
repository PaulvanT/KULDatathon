import requests

url = "https://telraam-api.net/v0/reports/349547"

payload = "{\n    \"time_start\": \"2020-01-01 00:00\",\n    \"time_end\": \"2020-04-01 23:59\",\n    \"level\": \"segments\",\n    \"format\":\"per-hour\"\n}"
headers = {
  'Content-Type': 'application/json'
}

response = requests.request("POST", url, headers=headers, data = payload)

print(response.text.encode('utf8'))
