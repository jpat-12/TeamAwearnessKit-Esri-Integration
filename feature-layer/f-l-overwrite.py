from arcgis.gis import GIS
from arcgis.features import FeatureLayerCollection
import pandas as pd
import time

def overwrite_feature_layer(csv_file_path, existing_layer_item_id):
    try:
        # Authentication
        gis = GIS("link", "username", "password")

        # Read the CSV data into a pandas DataFrame
        df = pd.read_csv(csv_file_path)

        # Find the existing feature layer item
        existing_layer_item = gis.content.get(existing_layer_item_id)

        # Update the CSV data item
        item_update = existing_layer_item.update(data=csv_file_path)

        if item_update:
            # Get the feature layer collection
            feature_layer_collection = FeatureLayerCollection.fromitem(existing_layer_item)

            # Overwrite the feature layer
            overwrite_result = feature_layer_collection.manager.overwrite(csv_file_path)

            if overwrite_result['success']:
                print(f"Feature layer updated successfully: {existing_layer_item.url}")
            else:
                print("Failed to overwrite the feature layer.")
        else:
            print("Failed to update the CSV data item.")
    
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    csv_file_path = '/var/www/html/file_name.csv'
    existing_layer_item_id = "file_id"  # Replace with your existing layer item ID

    while True:
        overwrite_feature_layer(csv_file_path, existing_layer_item_id)
        print('Waiting before the next overwrite...')
        time.sleep(60)  # Sleep for 60 seconds before the next iteration
