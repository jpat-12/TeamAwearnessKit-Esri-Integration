#!/bin/bash



echo "This script will allow you to communicate Survey123 data to TAK & KML-Network accepted clients" 

echo "If you would like to procceed please press enter" 
read enter 

echo "We will first start with installing some dependancies" 
sudo apt update -y
sudo apt upgrade -y
sudo apt install pipenv -y
sudo apt install wget python3-geopandas -y 
pip install geopandas
echo "The dependancies are now installed" 


# Install apache2 
echo "We will now install an http server" 
sudo apt install apache2 -y
echo "We will"

# Make /opt/TAK-Esri directory, and write csv-download.py 
echo "Take this time and enter a few records into your new survey."
echo "Press enter when ready" 
read enter
echo "We will now write to the csv-download.py file & pull down the survey data"
## Making directory 
mkdir -p /opt/TAK-Esri
cd /opt/TAK-Esri
## Writing to csv-download
echo "What is the Survey123 Feature Layer Link?" 
read survey123_feature_layer_link
## Confirm Feature Layer Link 
echo "Feature Layer Link: $survey123_feature_layer_link"
read -p "Press y to continue or any other key to re-enter the information: " confirm
while [ "$confirm" != "y" ]; do
    read -p "Enter the link of the feature layer you want to use: " survey123_feature_layer_link
    echo "Is this correct?" 
    echo "Feature Layer Link: $survey123_feature_layer_link"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done
## Ensure survey123_feature_layer_link ends with '/0/query'
if [[ ! "$survey123_feature_layer_link" =~ /0/query$ ]]; then
    survey123_feature_layer_link="${survey123_feature_layer_link%/}/0/query"
fi
## Write to the csv-download.py file
cat <<EOF > /opt/TAK-Esri/csv-download.py
import geopandas as gpd
url = "$survey123_feature_layer_link"
gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")
gdf.to_csv("survey.csv", index=False)
EOF
echo "csv-download.py file has been written"
## Check csv-download works 
python3 csv-download.py 
echo "The survey data should be downloaded"
cat /opt/TAK-Esri/survey.csv 
echo "Does survey.csv have contents (y/n)"
read s123 
## Verifying csv-download downloads survey123 data
if [ "$s123" != "y" ]; then
    echo "What is the Survey123 Feature Layer Link?" 
    read survey123_feature_layer_link
    ## Confirm Feature Layer Link 
    echo "Feature Layer Link: $survey123_feature_layer_link"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
    while [ "$confirm" != "y" ]; do
        read -p "Enter the link of the feature layer you want to use: " survey123_feature_layer_link
        echo "Is this correct?" 
        echo "Feature Layer Link: $survey123_feature_layer_link"
        read -p "Press y to continue or any other key to re-enter the information: " confirm
    done
    ## Ensure survey123_feature_layer_link ends with '/0/query'
    if [[ ! "$survey123_feature_layer_link" =~ /0/query$ ]]; then
        survey123_feature_layer_link="${survey123_feature_layer_link%/}/0/query"
    fi
    ## Write to the csv-download.py file
    echo "import geopandas as gpd" > /opt/TAK-Esri/csv-download.py
    echo "url = \"$survey123_feature_layer_link\"" >> /opt/TAK-Esri/csv-download.py
    echo 'gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")' >> /opt/TAK-Esri/csv-download.py
    echo 'gdf.to_csv("survey.csv", index=False)' >> /opt/TAK-Esri/csv-download.py

    echo "csv-download.py file has been written"
    ## Check csv-download works 
    python3 /opt/TAK-Esri/csv-download.py 
    echo "The survey data should be downloaded"
    cat /opt/TAK-Esri/survey.csv 
    echo "This loop will continue until it does have the proper data"
    echo "Does survey.csv have contents (y/n)"
    read s123
fi

# Setup CSV-CoT.py 
## Copy the file from the github repo
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-cot.py /opt/TAK-Esri 
## Test The File 
cd /opt/TAK-Esri
python3 csv-cot.py
## double check the output
cat /var/www/html/survey-cot.txt
echo "Does survey-cot.txt have contents (y/n)" 
read csvcot
if [ "$csvcot" != "y" ]; then
     echo "CSV-COT HAS FAILED" > /opt/TAK-Esri/install-log.txt
     echo "We will come back to this later"
     echo "You may need to contact the rego manager to gain assistance with this error"

else 
echo "The output of XML-CoT messages is now in the file /var/www/html/survey-cot.txt" 
fi 

# Check and install Node.js and Node-RED if necessary
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Installing Node.js..."
    sudo apt install nodejs npm -y
fi
## Double check install
read -p "Is Node-RED already installed? (y/n): " node_red_install
if [ "$node_red_install" != "y" ]; then
    sudo npm install -g --unsafe-perm node-red
    echo "Node-RED is now installed"
fi
clear
## Start Node-Red
echo "we will now test the node-red install" 
echo "Exit node-red at any point to continue with the install" 
node-red
clear
## Install service file for node-red 
echo "We will now setup node-red as a service" 
echo "" 
echo "This way it will run automatically on boot" 
## Move the service file 
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/node-red.service /etc/systemd/system/node-red.service
sudo systemctl daemon-reload
systemctl enable node-red.service 
sudo systemctl daemon-reload
systemctl start node-red.service 
service node-red status 
echo "Is Node-RED now installed and running as a service"
read node_red 
## Troubleshoot bad install
if [ "$node_red" != "y" ]; then
    echo "Node-RED has failed to install as a service"
    ls -la /root/.node-red
    cat /etc/systemd/system/node-red.service
    echo "Open a new terminal and investigate" 
    echo "Come back to this terminal when it is fixed" 
    echo "press enter when you are ready to proceed" 
    read enter
else
    echo "You can now access Node-RED at http://your-IP:1880"
fi
## Move into online node-red setup 
clear 
echo "Now please go to http://127.0.0.1:1880 to continue the node-red setup"
sleep 40 
echo "Press enter when ready to move on" 
read enter 

# We will now install miniconda and create the arcgis_env
##Install & Activate Miniconda  
echo "Installing Miniconda..." 
cd /root
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda
cd /root/miniconda 
source /root/miniconda/bin/activate
conda init 
conda create -n arcgis_env python=3.9 

## Instructions to continue the install 
echo ""
echo "" 
echo "At this point you will need to close your current terminal/cmd prompt and start a new one."
echo ""
echo "We will continue the install by running the command below in the new terminal instance"
echo ""
echo "cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x arcgis2.sh && ./arcgis2.sh && cd /opt/TAK-Esri && ls -la"