import requests
import json
import pandas as pd

def request_segment_by_id(id): #returns dictionary

    url = "https://telraam-api.net/v0/segments/id/" + str(id)
    payload = {}
    headers= {}
    response = requests.request("GET", url, headers=headers, data = payload) #dictionary string
    result = json.loads(response.text) # convert dictionary string to dictionary
    return result

#id = 349547
id = 9000000037
result = request_segment_by_id(id)
print(result)


def extract_properties(dataset):
    features = dataset.get('features')[0] # added '[0]' because features is a one element list for some reason
    properties = features.get('properties')
    return properties

properties = extract_properties(result)
print(properties)


def make_entry(properties):

    entry = {} # make new dictionary in wanted format
    entry['segment_id'] = [properties.get('oidn')]
    time = properties.get('last_data_package')
    year = time[0:4]
    month = time[5:7]
    hour = time[11:13]
    entry['year'] = [year]
    entry['month'] = [month]
    entry['hour'] = [hour]
    entry['max_speed'] = [properties.get('speed')]
    entry['nb_pedestrians'] = [properties.get('pedestrian')]
    entry['nb_bike'] = [properties.get('bike')]
    entry['nb_car'] = [properties.get('car')]
    entry['nb_lorry'] = [properties.get('lorry')]
    for i in range(0,8): # iterate over the buckets and add them to our entry
        entry['bucket' + str(i)] = [properties.get('speed_histogram')[i]]
    return entry

print(make_entry(properties))

result = make_entry(properties)
df = pd.DataFrame(result)
print(df)


