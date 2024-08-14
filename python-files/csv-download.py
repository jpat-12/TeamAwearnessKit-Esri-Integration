import geopandas as gpd
import time

# Access the feature layer URL
url = "/query"

while True:
    try:
        # Download the data using geopandas
        gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")
        gdf.to_csv("survey.csv", index=False)
        print('Feature Layer downloaded')
    except Exception as e:
        print(f"Error: {e}")

#while True:
 #   gdf.to_csv("survey.csv", index=False)
  #  print('Feature Layer downloaded')
   # time.sleep(2)

#gdf.to_csv("survey.csv", index=False)
