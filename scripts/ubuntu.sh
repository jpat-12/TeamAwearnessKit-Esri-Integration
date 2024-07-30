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
apt install conda -y
apt install wget -y
clear 

echo "Finalizing miniconda install"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
sudo chmod +x ./
sudo chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
conda install -c esri arcgis
cd /root
cd miniconda3
conda init
source ./bin/activate
conda init

echo "You will be prompted 
conda create -n arcgis_env python=3.9
conda activate arcgis_env
conda install -c esri arcgis
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-download.py /csv-download.sh





cd /tmp/TeamAwearnessKit-Esri-Integration 
$pwd=pwd
echo "We are now in the github folder $pwd"

