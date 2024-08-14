#!/bin/bash

echo -e "\n\nThis script will install the necessary dependencies & format everything for COT-GENERATION from Survey123 Data\n\n"
read -p "Press any key to begin ..."

clear

echo "Please put in the password for your root user"
sudo su

# Upgrade & update dependencies 
echo "We will now update apt and install WGet and Geopandas"
sudo apt update -y
sudo apt upgrade -y
sudo apt install wget -y
sudo apt install python3-geopandas -y 
pip install time
clear 

# Install apache2 
echo "Installing apache2 http server"
sudo snap install http
cd /tmp/TeamAwearnessKit-Esri-Integration
sudo rm -rf /etc/ssh/sshd_config
sudo mv /tmp/TeamAwearnessKit-Esri-Integration/sshd_config /etc/ssh
sudo service ssh restart
sudo service ssh status

# Check and install Node-RED if necessary
read -p "Is Node-RED already installed? (y/n): " node_red_install

if [ "$node_red_install" != "y" ]; then
    cd /root
    npm install -g --unsafe-perm node-red
fi
echo "node-red is now installed" 
clear

echo "What is the Survey123 Feature Layer Link" 
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

# Access the feature layer URL
url = "$survey123_feature_layer_link"

# Download the data using geopandas
gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")
gdf.to_csv("survey.csv", index=False)
EOF

# Move python files to the correct directory
echo "Moving python files to the /opt/TAK-Esri/ directory"
sudo cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/*.py /opt/TAK-Esri/
echo "Python files moved"

# Move service files to the system directory
echo "Moving service files to the /etc/systemd/system directory"
sudo cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/*.service /etc/systemd/system/
echo "Service files moved"

# Enable and start services
sudo systemctl daemon-reload
for service in cot-csv csv-cot csv-download csv-kml; do
    sudo systemctl daemon-reload
    sudo systemctl enable $service.service
    sudo systemctl start $service.service
done

echo "All services started successfully."
