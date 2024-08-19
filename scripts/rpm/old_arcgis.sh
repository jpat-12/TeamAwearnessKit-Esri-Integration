#!/bin/bash

# Prompt user for enterprise and feature layer details
echo "We will now set variables to personalize the install"
read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
read -p "Enter the username of the enterprise: " e_username
read -sp "Enter the password of the enterprise: " e_password
echo ""
read -p "Enter the name of the feature layer you will create: " feature_layer_name
read -p "Enter the description you want your feature layer to have: " feature_layer_desc

# Confirm the entered details
echo "Are all of these correct?" 
echo "Enterprise link: $e_link"
echo "Enterprise username: $e_username"
echo "Enterprise password: $e_password"
echo "Feature Layer Name: $feature_layer_name"
echo "Feature Layer Description: $feature_layer_desc"
read -p "Press y to continue or any other key to re-enter the information: " confirm

# Loop to correct incorrect variables
while [ "$confirm" != "y" ]; do
    read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
    read -p "Enter the username of the enterprise: " e_username
    read -sp "Enter the password of the enterprise: " e_password
    echo ""
    read -p "Enter the name of the feature layer you will create: " feature_layer_name
    read -p "Enter the description you want your feature layer to have: " feature_layer_desc
    echo "Are all of these correct?" 
    echo "Enterprise link: $e_link"
    echo "Enterprise username: $e_username"
    echo "Enterprise password: $e_password"
    echo "Feature Layer Name: $feature_layer_name"
    echo "Feature Layer Description: $feature_layer_desc"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done

# Initialize Conda and set up environment for ArcGIS
echo "Initializing Conda and setting up environment for ArcGIS"
conda init
source /root/miniconda/bin/activate arcgis_env

# Verify environment activation
if [ "$(basename $(which python))" = "python" ] && [[ $(conda info --envs | grep '*') =~ "arcgis_env" ]]; then
    echo "Environment 'arcgis_env' is active."
else
    echo "Failed to activate 'arcgis_env'."
    exit 1
fi

# Install required packages
conda install -c esri arcgis -y
pip install arcgis

# Create necessary directories
mkdir -p /opt/TAK-Esri/ArcGIS

# Test connection to Esri servers
echo "Testing connection to Esri servers"

# Create sign-in script
cat <<EOF > /opt/TAK-Esri/ArcGIS/sign-in.py
from arcgis.gis import GIS

gis = GIS("$e_link", "$e_username", "$e_password")
print("Logged in as: " + gis.properties.user.username)
EOF

# Run the sign-in script and check the output
cd /opt/TAK-Esri/ArcGIS
python3.9 sign-in.py > output.log
cat output.log

# Extract and verify username from the output
output_username=$(grep "Logged in as:" output.log | awk -F": " '{print $2}')
if [ "$output_username" = "$e_username" ]; then
    echo "Username matches: $e_username"
else
    echo "Username does not match. Expected: $e_username, Found: $output_username"
    echo ""
    echo "Would you like to try entering your credentials again? (y/n)"
    read credentials
    if [ "$credentials" = "y" ]; then
        # Credential re-entry loop
        while true; do
            read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
            read -p "Enter the username of the enterprise: " e_username
            read -sp "Enter the password of the enterprise: " e_password
            echo ""
            echo "Are all of these correct?"
            echo "Enterprise link: $e_link"
            echo "Enterprise username: $e_username"
            echo "Enterprise password: $e_password"
            read -p "Press y to continue or any other key to re-enter the information: " confirm
            if [ "$confirm" = "y" ]; then
                echo "You either need to restart the script or contact the repo owner for help"
                exit 1
            fi
        done
    else
        echo "You need to restart the script or contact the repo owner for help"
        exit 1
    fi
fi

# Create test data file
echo "Now printing test data to /var/www/html/cot-logged.csv"
cat <<EOF > /var/www/html/cot-logged.csv
uid,type,how,time,start,stale,lat,long,hae,ce,le,contactcallsign,parent_callsign,production_time,iconpath,group_name,group_role,battery,device,platform,os,version,speed,course,droid_uid
e5a1cb4e-4736-4315-b216-bd30c3104456,a-u-G,h-g-i-g-o,2024-08-03T01:16:24Z,2024-08-03T01:16:24Z,2024-08-10T01:16:24Z,39.5001089390719,-88.8520772875137,168.398757195526,9999999.0,9999999.0,CAP Repeater 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:29Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/CAP Repeater.png,,,,,,,,,,
60f0fac0-0afd-4bf1-b3e1-7ba3379b5fff,a-u-G,h-g-i-g-o,2024-08-03T01:16:28Z,2024-08-03T01:16:29Z,2024-08-10T01:16:29Z,39.4997953384667,-89.061567867324,162.449553796715,9999999.0,9999999.0,Area Command Post 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:25Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Area Command Post.png,,,,,,,,,,
EOF

# Update and create push.py script
echo "We will now update the python script to use the feature layer link and name"
cat <<EOF > /opt/TAK-Esri/ArcGIS/push.py
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

# Create additional test data
echo "Now printing more test data to /var/www/html/cot-logged.csv"
cat <<EOF >> /var/www/html/cot-logged.csv
uid,type,how,time,start,stale,lat,long,hae,ce,le,contactcallsign,parent_callsign,production_time,iconpath,group_name,group_role,battery,device,platform,os,version,speed,course,droid_uid
d7fa3907-72df-4bb7-8e13-52d7f98f008b,a-u-G,h-g-i-g-o,2024-08-03T01:16:34Z,2024-08-03T01:16:32Z,2024-08-10T01:16:32Z,39.5053068473791,-88.9654113543475,159.721576169111,9999999.0,9999999.0,CAP Asset Report 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:25Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/CAP Asset Report.png,,,,,,,,,,
EOF

# Run the push.py script to upload the CSV data as a feature layer
cd /opt/TAK-Esri/ArcGIS
python3.9 push.py


# Check if push.py ran successfully and handle errors
echo "Checking if the push.py script ran successfully"
if grep -q "Feature layer created" output.log; then
    echo "Feature layer successfully created and published."
else
    echo "Failed to create or publish the feature layer. Please check the logs for details."
    exit 1
fi

# Optional: Clean up or finalize setup
echo "Would you like to clean up temporary files and finalize the setup? (y/n)"
read cleanup
if [ "$cleanup" = "y" ]; then
    echo "Cleaning up temporary files..."
    rm /opt/TAK-Esri/ArcGIS/sign-in.py
    rm /opt/TAK-Esri/ArcGIS/push.py
    echo "Temporary files removed."
else
    echo "Temporary files have been left in place for review."
fi

# End of script
echo "Setup complete. Your feature layer has been created and published."
echo "Remember to review the output logs for any additional information."
exit 0
