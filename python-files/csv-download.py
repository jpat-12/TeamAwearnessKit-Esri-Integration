import geopandas as gpd

# Access the feature layer URL
url = "insert feature layer link here/query"

# Download the data using geopandas
gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")
gdf.to_csv("survey.csv", index=False)