#!/bin/bash

echo -e "\n\nThis script will install the necessary dependencies & format everything for COT-GENERATION from Survey123 Data\n\n"
read -p "Press any key to begin ..."

clear

echo "Please put in the password for your root user"
sudo -v

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
sudo mv sshd_config /etc/ssh
sudo service ssh restart
sudo service ssh status

# Set variables for the feature layer
echo "We will now set variables to personalize the install"
read -p "Enter the link of the feature layer you want to use: " feature_layer_link
read -p "Enter the name of the feature layer you want to use: " feature_layer_name
read -p "Enter the name of the CSV file: " csv_name

# Double check all variables are set correctly
echo "Are all of these correct?" 
echo "Feature Layer Link: $feature_layer_link"
echo "Feature Layer Name: $feature_layer_name"
echo "CSV Name: $csv_name"
read -p "Press y to continue or any other key to re-enter the information: " confirm

if [ "$confirm" != "y" ]; then
    read -p "Enter the link of the feature layer you want to use: " feature_layer_link
    read -p "Enter the name of the feature layer you want to use: " feature_layer_name
    read -p "Enter the name of the CSV file: " csv_name
fi

echo "We will now update the python script to use the feature layer link and name"

# Ensure feature_layer_link ends with '/0/query'
if [[ ! "$feature_layer_link" =~ /0/query$ ]]; then
    feature_layer_link="${feature_layer_link%/}/0/query"
fi

cat <<EOF > /opt/TAK-Esri/csv-download.py
import geopandas as gpd

# Access the feature layer URL
url = "$feature_layer_link"

# Download the data using geopandas
gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")
gdf.to_csv("$csv_name", index=False)
EOF

# Install & Activate Miniconda  
echo "Installing Miniconda..." 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
source $HOME/miniconda3/bin/activate

# Create necessary directories and files
mkdir -p /opt/TAK-Esri/ArcGIS

cat <<EOF > /opt/TAK-Esri/ArcGIS/push.py
EOF

cat <<EOF > /opt/TAK-Esri/ArcGIS/append.py
EOF

# Create virtual environment in conda 
conda init
conda create -n arcgis_env python=3.9 -y
conda activate arcgis_env
conda install -c esri arcgis -y

# Check and install Node-RED if necessary
read -p "Is Node-RED already installed? (y/n): " node_red_install

if [ "$node_red_install" != "y" ]; then
    npm install -g --unsafe-perm node-red
fi

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
    sudo systemctl enable $service.service
    sudo systemctl start $service.service
done

echo "All services started successfully."
