#!/bin/bash

echo ""
echo ""
echo "This script will install the necessary dependencies & format everything for COT-GENERATION from Survey123 Data"
echo ""
echo ""
read -p "Press any key to begin ..."
echo ""
echo ""
echo "Have you already created your survey? Do you have the file ID?"
echo "If not, do that now, then proceed with the script." 
echo ""
echo ""
read -p "Press any key to begin ..."
clear

echo "Please put in the password for your root user"
sudo su

echo "install apache2 http server"
snap install http
cd /tmp/TeamAwearnessKit-Esri-Integration
rm -rf /etc/ssh/sshd_config
mv sshd_config /etc/ssh
service ssh restart
service ssh status

echo "We will now update apt and intstall both Conda and WGet so we can run the ArcGIS libraries inside of a VM"
sudo apt upgrade -y
sudo apt update -y
apt install wget -y
apt install python3-geopandas -y 
clear 


#add section that will change line 4 in /TeamAwearnessKit-Esri-Integration/python-files/csv-download
#url = "insert feature layer link here/query"


echo "----------------------------------------------------"
echo "----------------------------------------------------"
echo "Moving python files to the /opt/TAK-Esri/ directory"
echo "----------------------------------------------------"
echo "----------------------------------------------------"

cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/cot-csv.py /opt/TAK-Esri/cot-csv.py
echo "cot-csv.py moved"
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-cot.py /opt/TAK-Esri/csv-cot.py
echo "csv-cot.py moved"
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-download.py /opt/TAK-Esri/csv-download.py
echo "csv-download.py moved"
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
###NOT WORKING JUST YET
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-cot.service /etc/systemd/system/csv-cot.service
echo "csv-cot.service moved"
sudo systemctl enable csv-cot.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-download.service /etc/systemd/system/csv-download.service
echo "csv-download.service moved"
sudo systemctl enable csv-download.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-kml.service /etc/systemd/system/csv-kml.service
echo "csv-kml.service moved"
sudo systemctl enable csv-kml.service


sudo systemctl start cot-csv.service
sudo systemctl start csv-cot.service
sudo systemctl start csv-download.service
sudo systemctl start csv-kml.service

echo "----------------------------------------------------"
echo "----------------------------------------------------"
echo "Moving service files to the /etc/systemd/system directory"
echo "----------------------------------------------------"
echo "----------------------------------------------------"


