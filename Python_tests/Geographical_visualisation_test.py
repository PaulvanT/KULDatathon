# Import necessary packages
import pandas
import gmplot

# Read the dataset
leuvenair = pandas.read_csv('LEUVENAIRfulldump2020.csv')

# Extract the data we're interested in
lat = leuvenair['LAT'].values
lon = leuvenair['LON'].values
temp = leuvenair['TEMPERATURE'].values

gmap2 = gmplot.GoogleMapPlotter(50.87959, 4.70093, 13 )


gmap2.scatter( lat[0:10000], lon[0:10000], '# FF5500', size = 40, marker = False )


gmap2.draw( "map13.html" )