








# Set variables for the feature layer
echo "We will now set variables to personalize the install"
read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
read -p "Enter the username of the enterprise: " e_username
read -p "Enter the password of the enterprise: " e_password
read -p "Enter the name of the feature layer you will create: " feature_layer_name
read -p "Enter the description you want your feature layer to have" feature_layer_desc

## Double check all variables are set correctly
echo "Are all of these correct?" 
echo "Enterprise link: $e_link"
echo "Enterprise username: $e_username"
echo "Enterprise password: $e_password"
echo "Feature Layer Name: $feature_layer_name"
echo "Feature Layer Description: $feature_layer_desc"
read -p "Press y to continue or any other key to re-enter the information: " confirm

while [ "$confirm" != "y" ]; do
    read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
    read -p "Enter the username of the enterprise: " e_username
    read -p "Enter the password of the enterprise: " e_password
    read -p "Enter the name of the feature layer you will create: " feature_layer_name
    read -p "Enter the description you want your feature layer to have" feature_layer_desc
    echo "Are all of these correct?" 
    echo "Enterprise link: $e_link"
    echo "Enterprise username: $e_username"
    echo "Enterprise password: $e_password"
    echo "Feature Layer Name: $feature_layer_name"
    echo "Feature Layer Description: $feature_layer_desc"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done

echo "We will now update the python script to use the feature layer link and name"


# Install & Activate Miniconda  
echo "Installing Miniconda..." 
cd /root
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda
cd /root/miniconda 
source /root/miniconda/bin/activate
conda init 
conda create -n arcgis_env python=3.9 
conda activate arcgis_env 
conda install -c esri arcgis


# Create necessary directories and files
mkdir -p /opt/TAK-Esri/ArcGIS

cat <<EOF > /opt/TAK-Esri/ArcGIS/push.py
from arcgis.gis import GIS
from arcgis.features import FeatureLayerCollection
import pandas as pd

# Authentication
gis = GIS("$e_link", "$e_username", "$e_password")

# Read the CSV data into a pandas DataFrame
csv_file_path = 'cot-pulled.csv'
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

echo "STOPPING HERE TEMPORARILY " 
echo "Go find the feature layer we just created" 
echo "press enter when you have your feature layer id" 
read stop 

read -p "Enter the Feature layer ID " file_id

## Double check all variables are set correctly
echo "Are all of these correct?" 
echo "Feature layer ID: $file_id"
read -p "Press y to continue or any other key to re-enter the information: " confirm

while [ "$confirm" != "y" ]; do
    read -p "Enter the Feature layer ID " file_id
    echo "Are all of these correct?" 
    echo "Feature layer ID: $file_id"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done


cat <<EOF > /opt/TAK-Esri/ArcGIS/append.py
from arcgis.gis import GIS
from arcgis.features import FeatureLayerCollection
import pandas as pd
import time

def overwrite_feature_layer(csv_file_path, existing_layer_item_id):
    try:
        # Authentication
        gis = GIS("$e_link", "$e_username", "$e_password")

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
    csv_file_path = '/var/www/html/TAK-CoT.csv'
    existing_layer_item_id = "$file_id"  # Replace with your existing layer item ID

    while True:
        overwrite_feature_layer(csv_file_path, existing_layer_item_id)
        print('Waiting before the next overwrite...')
        time.sleep(60)  # Sleep for 60 seconds before the next iteration
EOF

# Create virtual environment in conda 
cd /opt/TAK-Esri/arcgis 
cat <<EOF > /opt/TAK-Esri/arcGIS/append.sh
#!/bin/bash
# Source the conda.sh script
source /root/miniconda3/etc/profile.d/conda.sh

# Activate the Conda environment
conda activate arcgis_env

# Change to the correct directory
mkdir -p /opt/TAK-Esri/arcgis
cd /opt/TAK-Esri/arcgis

# Loop to run the Python script and wait for 30 seconds
while true; do
    /root/miniconda/bin/python3 append.py
    echo 'Pushed To ArcGIS'
    sleep 30
done
EOF

cat <<EOF > /etc/systemd/system/feature-layer-update.service
[Unit]
Description=feature-layer-update
After=network.target

[Service]
ExecStart=/bin/bash /opt/TAK-Esri/arcgis/append.sh
WorkingDirectory=/opt/TAK-Esri/arcgis
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable feature-layer-update.service
sudo systemctl start feature-layer-update.service
