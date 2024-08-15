#!/bin/bash
# Set variables for the feature layer
echo "We will now set variables to personalize the install"
read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
read -p "Enter the username of the enterprise: " e_username
read -p "Enter the password of the enterprise: " e_password
read -p "Enter the name of the feature layer you will create: " feature_layer_name
read -p "Enter the description you want your feature layer to have: " feature_layer_desc

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
    read -p "Enter the description you want your feature layer to have: " feature_layer_desc
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

echo "At this point you will need to close your current terminal/cmd prompt and start a new one."
echo "We will continue the install by running the command below in the new terminal instance"
echo "cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x arcgis2.sh && ./arcgis2.sh && cd /opt/TAK-Esri && ls -la"

