#!/bin/bash




# Set variables for the feature layer
echo -e "${BLUE}We will now set variables to personalize the install${RESET}"
read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
read -p "Enter the username of the enterprise: " e_username
read -p "Enter the password of the enterprise: " e_password
read -p "Enter the name of the feature layer you will create: " feature_layer_name
read -p "Enter the description you want your feature layer to have: " feature_layer_desc
## Double check all variables are set correctly
echo -e "${BLUE}Are all of these correct?${RESET}"
echo -e "${GREEN}Enterprise link: $e_link${RESET}"
echo -e "${BLUE}Enterprise username: $e_username${RESET}"
echo -e "${GREEN}Enterprise password: $e_password${RESET}"
echo -e "${BLUE}Feature Layer Name: $feature_layer_name${RESET}"
echo -e "${GREEN}Feature Layer Description: $feature_layer_desc${RESET}"
read -p "Press y to continue or any other key to re-enter the information: " confirm
## Loop To Correct incorrect variables
while [ "$confirm" != "y" ]; do
    read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
    read -p "Enter the username of the enterprise: " e_username
    read -p "Enter the password of the enterprise: " e_password
    read -p "Enter the name of the feature layer you will create: " feature_layer_name
    read -p "Enter the description you want your feature layer to have: " feature_layer_desc
    echo -e "${BLUE}Are all of these correct?" 
    echo -e "${GREEN}Enterprise link: $e_link${RESET}"
    echo -e "${BLUE}Enterprise username: $e_username${RESET}"
    echo -e "${GREEN}Enterprise password: $e_password${RESET}"
    echo -e "${BLUE}Feature Layer Name: $feature_layer_name${RESET}"
    echo -e "${GREEN}Feature Layer Description: $feature_layer_desc${RESET}"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done





echo -e "${BLUE}We will now update the python script to use the feature layer link and name${RESET}"

sudo rm /opt/TAK-Esri/ArcGIS/push.py
sudo tee /opt/TAK-Esri/ArcGIS/push.py > /dev/null <<EOF
from arcgis.gis import GIS
from arcgis.features import FeatureLayerCollection
import pandas as pd

# Authentication
gis = GIS("$e_link", "$e_username", "$e_password")

# Read the CSV data into a pandas DataFrame
csv_file_path = '/var/www/html/cot-logged.csv'
df = pd.read_csv(csv_file_path)

# Define the name and description for the new feature layer
layer_name = "$feature_layer_name"
layer_description = "$feature_layer_desc"

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
EOF

conda init


current_user=$(whoami)
echo "You are $current_user"

source /home/$current_user/miniconda/bin/activate arcgis_env


python3 /opt/TAK-Esri/ArcGIS/push.py

# Find Layer ID
clear
echo ""
echo -e "${BLUE}STOPPING HERE TEMPORARILY ${RESET}"
echo ""
echo -e "${BLUE}Go find the feature layer we just created${RESET}"
echo ""
echo -e "${BLUE}press enter when you have your feature layer id${RESET}"
read stop 
## Intake F-L-ID
echo -e "${BLUE}Sleeping for 5 seconds${RESET}" 
sleep 5
echo ""
read -p "Enter the Feature layer ID: " file_id
## Double check all variables are set correctly
echo -e "${BLUE}Is this correct? (y/n)${RESET}"
echo -e "${BLUE}Feature layer ID: $file_id${RESET}"
read -p "Press y to continue or any other key to re-enter the information: " confirm
while [ "$confirm" != "y" ]; do
    read -p "Enter the Feature layer ID " file_id
    echo -e "${BLUE}Are all of these correct?${RESET}"
    echo -e "${BLUE}Feature layer ID: $file_id${RESET}"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done





#Print append.py 
sudo rm /opt/TAK-Esri/ArcGIS/append.py
sudo tee /opt/TAK-Esri/ArcGIS/append.py > /dev/null <<EOF
from arcgis import GIS
from arcgis.features import FeatureLayerCollection
import pandas as pd
import time
import os

def overwrite_feature_layer(csv_file_path, existing_layer_item_id):
    try:
        # Authentication
        gis = GIS("${e_link}", "${e_username}", "${e_password}")

        # Read the CSV data into a pandas DataFrame
        df = pd.read_csv(csv_file_path)

        # Find the existing feature layer item
        existing_layer_item = gis.content.get(existing_layer_item_id)

        if existing_layer_item is None:
            print(f"Could not find item with ID: {existing_layer_item_id}")
            return

        # Get the feature layer collection
        feature_layer_collection = FeatureLayerCollection.fromitem(existing_layer_item)

        # Overwrite the feature layer
        overwrite_result = feature_layer_collection.manager.overwrite(csv_file_path)

        if overwrite_result['success']:
            print(f"Feature layer updated successfully: {existing_layer_item.url}")
        else:
            print("Failed to overwrite the feature layer.")
            print(f"Error details: {overwrite_result.get('error', 'No error details available')}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    csv_file_path = "${csv_file_path}"
    existing_layer_item_id = "${file_id}"

    while True:
        overwrite_feature_layer(csv_file_path, existing_layer_item_id)
        print('Waiting before the next overwrite...')
        time.sleep(60)  # Sleep for 60 seconds before the next iteration
EOF



