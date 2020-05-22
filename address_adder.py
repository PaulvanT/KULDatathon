import pandas as pd
import time
from geopy.geocoders import Nominatim

def get_rid_of_nonbelgians(csv_file):
    df = pd.read_csv(csv_file)
    #df = df.head(15000)
    df[['X','Y']] = pd.DataFrame(df.coordinates.str.split(',', 1).tolist(), index= df.index)
    df['X'] = df['X'].map(lambda x: x.lstrip('['))
    df['Y'] = df['Y'].map(lambda x: x.rstrip(']'))
    df = df[df['X'].astype(float) > 2.543013]
    df = df[df['X'].astype(float) < 5.616438]
    df = df[df['Y'].astype(float) > 50.735302]
    df = df[df['Y'].astype(float) < 51.548618]
    return df

def make_usable_dataframe(df):
    df = df.groupby(['segment_id']).first()
    df['segment_id'] = df.index
    df = df[['segment_id','coordinates']]
    segment_ids = df['segment_id'].tolist()
    df1 = pd.DataFrame(df.coordinates.str.split(',', 1).tolist(), columns=['X', 'Y'])
    df1['X'] = df1['X'].str.strip('[]')
    df1['Y'] = df1['Y'].str.strip('[]')
    df1["geom"] = df1["Y"].map(str) + ',' + df1['X'].map(str)
    coordinate = df1['geom'].tolist()
    xlist = df1['X'].tolist()
    ylist = df1['Y'].tolist()
    data = {'segment_id' : segment_ids, 'coordinates' : coordinate, 'X' : xlist, 'Y' : ylist}
    df2 = pd.DataFrame(data)
    return df2


def make_adress_df(df):
    locator = Nominatim(user_agent="myGeocoder", timeout=10)
    data = {'segment_id' : [], 'X' : [], 'Y' : [], 'street' : [], 'place' : [], 'province' : []}
    for i in range(len(df)):
        coordinates = df['coordinates'][i]
        location = locator.reverse(coordinates)
        time.sleep(0.001)
        loc_data = location.raw
        try:
            street = (loc_data['address'])['road']
        except:
            street = ''
        try:
            place = (loc_data['address'])['town']
        except:
            try:
                place = (loc_data['address'])['city']
            except:
                place = ''
        try:
            province = (loc_data['address'])['county']
        except:
            province = ''

        data['segment_id'].append(df['segment_id'][i])
        data['X'].append(df['X'][i])
        data['Y'].append(df['Y'][i])
        data['street'].append(street)
        data['place'].append(place)
        data['province'].append(province)
    df_with_adresses = pd.DataFrame(data)
    return df_with_adresses


def map_address_data(big_df, address_df):
    result = pd.merge(big_df, address_df, on ='segment_id')
    return result

df0 = get_rid_of_nonbelgians('ALL_DATA_2.csv')
df1 = make_usable_dataframe(df0)
df2 = make_adress_df(df1)
big_df = pd.read_csv('ALL_DATA_2.csv')
address_df = df2
df_final = map_address_data(big_df, address_df)
df_final.to_csv('COMPLETE_DATA.csv', sep=',')