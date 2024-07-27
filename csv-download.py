from arcgis.gis import GIS
from arcgis.features import FeatureLayer

# Connect to the GIS
gis = GIS()

# Access the feature layer
url = " INSERT FEATURE SERVER LINK HERE"
layer = FeatureLayer(url)

# Query and download data
features = layer.query(where="1=1", return_geometry=True, out_fields="*").sdf
features.to_csv("survey.csv", index=False)
