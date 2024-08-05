#!/bin/bash

echo ""
echo ""
echo "This script will install the necessary dependencies & format everything for COT-GENERATION from Survey123 Data"
echo ""
echo ""
read -p "Press any key to begin ..."
echo ""
echo ""
clear

echo "Please put in the password for your root user"
sudo su


# Upgrade & update dependancies 
echo "We will now update apt and intstall WGet and Geopandas"
sudo apt upgrade -y
sudo apt update -y
apt install wget -y
apt install python3-geopandas -y 
clear 


# Install apache2 
echo "install apache2 http server"
snap install http
cd /tmp/TeamAwearnessKit-Esri-Integration
rm -rf /etc/ssh/sshd_config
mv sshd_config /etc/ssh
service ssh restart
service ssh status


# Set variables for the feature layer
echo "We will now set variables to personalize the instal"
echo "What is the link of the feature layer you want to use? (i.e. https://services6.arcgis.com/random_string_here/arcgis/rest/services/random_name_here/FeatureServer/0)" 
read -p "Enter the link: " feature_layer_link
echo "What is the name of the feature layer you want to use? (i.e. Survey123)"
read -p "Enter the name: " feature_layer_name
echo "What do you want the csv file to be named? (i.e. survey123.csv)"
read -p "Enter the name: " csv_name


# Double check all variables are set correctly
echo "Are all of these correct?" 
echo "Feature Layer Link: $feature_layer_link"
echo "Feature Layer Name: $feature_layer_name"
echo "CSV Name: $csv_name"
sleep 10
read y/n 


# Check to make sure $feature_layer_link is in the proper format
if [ "$y/n" = "y" ]; then
    read -p "Press any key to continue..."
 else
    echo "Please re-enter the information"
    echo "What is the link of the feature layer you want to use?" 
    read -p "Enter the link: " feature_layer_link
    echo "What is the name of the feature layer you want to use?"
    read -p "Enter the name: " feature_layer_name
    echo "What do you want the csv file to be named?"
    read -p "Enter the name: " csv_name
    fi
    echo "We will now update the python script to use the feature layer link and name"


# Check if the feature_layer_link ends with '/0/query'
if not feature_layer_link.endswith('/0/query'):
    # If it does not end with '/0/query', append it
    feature_layer_link += '/0/query'

cat <<EOF > /opt/TAK-Esri/csv-download.py

import geopandas as gpd

# Access the feature layer URL
url = "$feature_layer_link/query"

# Download the data using geopandas
gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")
gdf.to_csv("$csv_name", index=False)

EOF

# insert code here that will create the csv-cot.py file with the 


# Install & Activate Miniconda  
echo "Installing miniconda..." 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh 
cd /root/miniconda3 
source ./bin/activate


# Create file for pushing the feature layer 
mkdir /opt/TAK-Esri/ArcGIS
cd /opt/TAK-Esri/ArcGIS
cat <<EOF > /opt/TAK-Esri/sArcGIS/push.py


EOF


# Create file for appending the feature layer
cd /opt/TAK-Esri/ArcGIS
cat <<EOF > /opt/TAK-Esri/sArcGIS/push.py


EOF


# Create virtual enviroment in conda 
conda init
conda create -n arcgis_env python=3.9
conda activate arcgis_env
conda install -c esri arcgis


# Start moving all other files around 
echo "----------------------------------------------------"
echo "----------------------------------------------------"
echo "Moving python files to the /opt/TAK-Esri/ directory"
echo "----------------------------------------------------"
echo "----------------------------------------------------"

cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/cot-csv.py /opt/TAK-Esri/cot-csv.py
echo "cot-csv.py moved"
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-cot.py /opt/TAK-Esri/csv-cot.py
echo "csv-cot.py moved"
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-kml.py /opt/TAK-Esri/csv-kml.py
echo "csv-kml.py moved"


clear
echo "----------------------------------------------------"
echo "----------------------------------------------------"
echo "Moving service files to the /etc/systemd/system directory"
echo "----------------------------------------------------"
echo "----------------------------------------------------"

cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/cot-csv.service /etc/systemd/system/cot-csv.service
echo "cot-csv.service moved"
sudo systemctl enable cot-csv.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-cot.service /etc/systemd/system/csv-cot.service
echo "csv-cot.service moved"
sudo systemctl enable csv-cot.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-download.service /etc/systemd/system/csv-download.service
echo "csv-download.service moved"
sudo systemctl enable csv-download.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-kml.service /etc/systemd/system/csv-kml.service
echo "csv-kml.service moved"
sudo systemctl enable csv-kml.service

# Start all of the services
systemctl daemon-reload
sudo systemctl start cot-csv.service
sudo systemctl start csv-cot.service
sudo systemctl start csv-download.service
sudo systemctl start csv-kml.service

echo "----------------------------------------------------"
echo "----------------------------------------------------"
echo "                                                    "
echo "----------------------------------------------------"
echo "----------------------------------------------------"




