from arcgis.gis import GIS
from arcgis.features import FeatureLayerCollection
import pandas as pd

# Authentication
gis = GIS("", "", "")

# Read the CSV data into a pandas DataFrame
csv_file_path = 'TAK-CoT.csv'
df = pd.read_csv(csv_file_path)

# Define the name and description for the new feature layer
layer_name = "FBI TAKServer CoT"
layer_description = "This is a layer hosts parsed CoT messages from the FBI TAKServer"

# Create a new feature layer
csv_item_properties = {
    'title': layer_name,
    'type': 'CSV',
    'description': layer_description,
    'tags': 'your, tags, here'
}

# Upload the CSV to ArcGIS Online
csv_item = gis.content.add(item_properties=csv_item_properties, data=csv_file_path)

# Publish the CSV as a feature layer
csv_lyr = csv_item.publish()

# Share the feature layer with the public or a specific group
csv_lyr.share(everyone=True)

print(f"Feature layer created: {csv_lyr.url}")
