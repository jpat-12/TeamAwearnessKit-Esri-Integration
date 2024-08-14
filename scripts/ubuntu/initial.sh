#!/bin/bash

echo -e "\n\nThis script will install the necessary dependencies & format everything for COT-GENERATION from Survey123 Data\n\n"
read -p "Press any key to begin ..."

clear

# Upgrade & update dependencies 
echo "Updating apt and installing dependencies"
sudo apt update -y
sudo apt upgrade -y
sudo apt install wget python3-geopandas -y 

# Install apache2 
echo "Installing apache2 http server"
sudo apt install apache2 -y

# Check and install Node.js and Node-RED if necessary
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Installing Node.js..."
    sudo apt install nodejs npm -y
fi

read -p "Is Node-RED already installed? (y/n): " node_red_install

if [ "$node_red_install" != "y" ]; then
    sudo npm install -g --unsafe-perm node-red
    echo "Node-RED is now installed"
fi
clear

mkdir -p /opt/TAK-Esri
cd /opt/TAK-Esri

echo "What is the Survey123 Feature Layer Link?" 
read survey123_feature_layer_link

echo "Feature Layer Link: $survey123_feature_layer_link"
read -p "Press y to continue or any other key to re-enter the information: " confirm

while [ "$confirm" != "y" ]; do
    read -p "Enter the link of the feature layer you want to use: " survey123_feature_layer_link
    echo "Is this correct?" 
    echo "Feature Layer Link: $survey123_feature_layer_link"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done

# Ensure survey123_feature_layer_link ends with '/0/query'
if [[ ! "$survey123_feature_layer_link" =~ /0/query$ ]]; then
    survey123_feature_layer_link="${survey123_feature_layer_link%/}/0/query"
fi

cat <<EOF > /opt/TAK-Esri/csv-download.py
import geopandas as gpd

url = "$survey123_feature_layer_link"

gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")
gdf.to_csv("survey.csv", index=False)
EOF

# Move python files to the correct directory
echo "Moving python files to the /opt/TAK-Esri/ directory"
sudo cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/*.py /opt/TAK-Esri/ || { echo "Python files copy failed"; exit 1; }
echo "Python files moved"

# Move service files to the system directory
echo "Moving service files to the /etc/systemd/system directory"
sudo cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/*.service /etc/systemd/system/ || { echo "Service files copy failed"; exit 1; }
echo "Service files moved"

# Enable and start services
sudo systemctl daemon-reload
for service in cot-csv csv-cot csv-download csv-kml; do
    sudo systemctl enable $service.service
    sudo systemctl start $service.service || { echo "Failed to start $service"; exit 1; }
done

echo "All services started successfully."

cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu
chmod +x arcgis.sh
./arcgis.sh
