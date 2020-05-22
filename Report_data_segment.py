import requests
import pandas as pd
import json

def request_data_reports(id):
  url = "https://telraam-api.net/v0/reports/" + str(id)
  payload = "{\n    \"time_start\": \"2020-01-01 00:00\",\n    \"time_end\": \"2020-01-15 23:59\",\n    \"level\": \"segments\",\n    \"format\":\"per-hour\"\n}"
  headers = {'Content-Type': 'application/json'}
  response = requests.request("POST", url, headers=headers, data = payload)
  result = json.loads(response.text).get('report')
  return result


# Code to get the first coordinates of an id
def request_data_segment_by_id(id):
  url = "https://telraam-api.net/v0/segments/id/" + str(id)
  payload = {}
  headers = {}
  response = requests.request("GET", url, headers=headers, data=payload)  # dictionary string
  result = json.loads(response.text)  # convert dictionary string to dictionary
  return result

def extract_coordinates(dataset):
    features = dataset.get('features')[0]  # added '[0]' because features is a one element list for some reason
    geometry = features.get('geometry')
    coordinates = geometry.get('coordinates')
    first_coordinate = (coordinates[0])[0]
    return first_coordinate

def extract_max_speed(dataset):
    features = dataset.get('features')[0]  # added '[0]' because features is a one element list for some reason
    properties = features.get('properties')
    max_speed = properties.get('speed')
    return max_speed

def get_first_coordinate(id):
  data = request_data_segment_by_id(id)
  return extract_coordinates(data)

def get_max_speed(id):
  data = request_data_segment_by_id(id)
  return extract_max_speed(data)



def make_dataframe(data):

  df = pd.DataFrame(data)
  df['year'] = 0
  df['month'] = 0
  df['day'] = 0
  df['hour'] = 0

  for i in range(0,len(df)):
      df.loc[i,'year'] = df.loc[i,'date'][0:4]
      df.loc[i,'month'] = df.loc[i,'date'][5:7]
      df.loc[i,'day']= df.loc[i,'date'][8:10]
      df.loc[i,'hour'] = df.loc[i,'date'][11:13]

  for i in range(0, 8):
    df['bucket' + str(i)] = 0

  for i in range(0,len(df)):
    if df.loc[i,'car_speed_bucket'] != None:
        for j in range(0,len(df.loc[i,'car_speed_bucket'])):
          if df.loc[i,'car_speed_bucket'][j] == 0:
            df.loc[i,'bucket0'] = df.loc[i,'car_speed_histogram'][j]
          elif df.loc[i,'car_speed_bucket'][j] == 1:
            df.loc[i,'bucket1'] = df.loc[i,'car_speed_histogram'][j]
          elif df.loc[i,'car_speed_bucket'][j] == 2:
            df.loc[i,'bucket2'] = df.loc[i,'car_speed_histogram'][j]
          elif df.loc[i,'car_speed_bucket'][j] == 3:
            df.loc[i,'bucket3'] = df.loc[i,'car_speed_histogram'][j]
          elif df.loc[i,'car_speed_bucket'][j] == 4:
            df.loc[i,'bucket4'] = df.loc[i,'car_speed_histogram'][j]
          elif df.loc[i,'car_speed_bucket'][j] == 5:
            df.loc[i,'bucket5'] = df.loc[i,'car_speed_histogram'][j]
          elif df.loc[i,'car_speed_bucket'][j] == 6:
            df.loc[i,'bucket6'] = df.loc[i,'car_speed_histogram'][j]
          else:
            df.loc[i,'bucket7'] = df.loc[i,'car_speed_histogram'][j]

  max_speeds = [get_max_speed(id)] * len(df)
  coordinates = [get_first_coordinate(id)] * len(df)
  df['max_speed'] = max_speeds
  df['coordinates'] = coordinates

  df1 = df[['segment_id','date','year','month','day','hour','max_speed',
            'coordinates', 'bike','lorry','pedestrian','car','pct_up','bucket0',
            'bucket1','bucket2','bucket3','bucket4','bucket5','bucket6','bucket7']].copy()

  return df1

def export_to_csv(id, df):
  df.to_csv('segment_'+ str(id) +'.csv', sep=',')

id = 349547
data = request_data_reports(id)
df = make_dataframe(data)
export_to_csv(id, df)

def make_usable_dataframe(id):
  data = request_data_reports(id)
  df = make_dataframe(data)
  return df

def get_all_ids():
  url = "https://telraam-api.net/v0/segments/all"
  payload = {}
  headers = {}
  response = requests.request("GET", url, headers=headers, data=payload)
  dataset = json.loads(response.text)
  features = (dataset.get('features'))
  id_list = []
  for i in range(len(features)):
    feature = features[i]
    properties = feature.get('properties')
    id = properties.get('oidn')
    # if request_data_reports(id) != []:
    #   id_list.append(id)
    id_list.append(id)
  return id_list


def get_all_data(id_list):
  dataframes = []
  for id in id_list:
    if request_data_reports(id) != []:
      dataframes.append(make_usable_dataframe(id))
    else:
      print('Skipped id ',id,' because there was no data')
  if len(dataframes) > 1:
    return pd.concat(dataframes)
  elif len(dataframes) == 1:
    return dataframes[0]
  else:
    print("NO DATA")

#id_list = get_all_ids() ==> LET OP, VEEEEEL DATA
#id_list = [24948, 26408, 26940, 27009, 27387, 27665, 27672, 27740, 27742, 27749, 1003103614, 1003073699, 1003073617, 1003073557, 1003073538]
#id_list = [9000000037]
id_list = [349547]
df_test = get_all_data(id_list)
df_test.to_csv('Test_data.csv', sep=',')

