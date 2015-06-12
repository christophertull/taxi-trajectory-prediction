
import json
import zipfile
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import multivariate_normal


# reading training data
zf_test = zipfile.ZipFile('data/test.csv.zip')
df_test = pd.read_csv(zf_test.open('test.csv'), converters={'POLYLINE': lambda x: json.loads(x)[-1:]})
latlong_test = np.array([[p[0][1], p[0][0]] for p in df_test['POLYLINE'] if len(p)>0])

zf_train = zipfile.ZipFile('data/train.csv.zip')
df_train = pd.read_csv(zf_train.open('train.csv'), converters={'POLYLINE': lambda x: json.loads(x)[-1:]})
latlong_train = np.array([[p[0][1], p[0][0]] for p in df_train['POLYLINE'] if len(p)>0])

# cut off long distance trips
lat_low, lat_hgh = np.percentile(latlong_train[:,0], [2, 98])
lon_low, lon_hgh = np.percentile(latlong_train[:,1], [2, 98])

# create image
bins = 513
lat_bins = np.linspace(lat_low, lat_hgh, bins)
lon_bins = np.linspace(lon_low, lon_hgh, bins)
H2, _, _ = np.histogram2d(latlong_train[:,0], latlong_train[:,1], bins=(lat_bins, lon_bins))

prior = H2/np.sum(H2,dtype=np.float64)


coord_list = []
for i,lat in enumerate(lat_bins):
	for j,lon in enumerate(lon_bins):
		coord_list.append((lat,lon))

dist = multivariate_normal.pdf(coord_list, mean=[latlong_test[0][0],latlong_test[0][1]], cov=[1, 1])
dist_grid = np.reshape(np.array(dist),(bins,bins))  


print H2
print coord_grid


img = np.log(H2[::-1, :] + 1)

plt.figure()
ax = plt.subplot(1,1,1)
plt.imshow(img)
plt.axis('off')
plt.title('Taxi trip end points')
plt.savefig("taxi_trip_end_points.png")