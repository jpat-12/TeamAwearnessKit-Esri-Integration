#!/bin/bash
clear
echo "This script will allow you to communicate Survey123 data to TAK & KML-Network accepted clients" 
echo ""
echo "If you would like to procceed please press enter" 
read enter 

echo "We will first start with installing some dependancies" 
sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install pipenv -y
sudo dnf install wget python3-geopandas -y 
pip install geopandas
clear
echo "The dependancies are now installed" 
sleep 3

# Install httpd 
echo "We will now install an http server" 
sudo dnf install httpd -y
sudo systemctl start httpd 
clear 

# Make /opt/TAK-Esri directory, and write csv-download.py 
echo "Take this time and enter a few records into your new survey."
echo "Press enter when ready" 
read enter
clear
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
clear
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
    echo "import geopandas as gpd" >> /opt/TAK-Esri/csv-download.py
    echo "import time" >> /opt/TAK-Esri/csv-download.py
    echo "url = \"$survey123_feature_layer_link\"" >> /opt/TAK-Esri/csv-download.py
    echo 'gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")' >> /opt/TAK-Esri/csv-download.py
    echo 'gdf.to_csv("survey.csv", index=False)' >> /opt/TAK-Esri/csv-download.py
    echo "csv-download.py file has been written"
    ## Check csv-download works 
    python3 /opt/TAK-Esri/csv-download.py 
    clear
    echo "The survey data should be downloaded"
    cat /opt/TAK-Esri/survey.csv 
    echo "This loop will continue until it does have the proper data"
    echo "Does survey.csv have contents (y/n)"
    read s123
fi
if [ "$s123" = "y" ]; then 
    
    echo "while True:" >> /opt/TAK-Esri/csv-download.py
    echo "    try:" >> /opt/TAK-Esri/csv-download.py
    echo "        # Download the data using geopandas" >> /opt/TAK-Esri/csv-download.py
    echo "        gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")" >> /opt/TAK-Esri/csv-download.py
    echo "        gdf.to_csv("survey.csv", index=False)" >> /opt/TAK-Esri/csv-download.py
    echo "        print('Feature Layer downloaded')" >> /opt/TAK-Esri/csv-download.py
    echo "    except Exception as e:" >> /opt/TAK-Esri/csv-download.py
    echo "        print(f"Error: {e}")" >> /opt/TAK-Esri/csv-download.py
    echo "    # Wait 5 seconds b4 next download" >> /opt/TAK-Esri/csv-download.py
    echo "    time.sleep(5)" >> /opt/TAK-Esri/csv-download.py
    clear     
    echo "Printing while loop to /opt/TAK-Esri/csv-download.py"
    echo "[Unit]" >> /etc/systemd/system/csv-download.service
    echo "Description=CSV Download" >> /etc/systemd/system/csv-download.service
    echo "After=network.target" >> /etc/systemd/system/csv-download.service
    echo "" >> /etc/systemd/system/csv-download.service
    echo "[Service]" >> /etc/systemd/system/csv-download.service
    echo "ExecStart=/usr/bin/python3 /opt/TAK-Esri/csv-download.py" >> /etc/systemd/system/csv-download.service
    echo "WorkingDirectory=/opt/TAK-Esri" >> /etc/systemd/system/csv-download.service
    echo "StandardOutput=file:/var/log/csv-download.log" >> /etc/systemd/system/csv-download.service
    echo "StandardError=file:/var/log/csv-download_error.log" >> /etc/systemd/system/csv-download.service
    echo "Restart=on-failure" >> /etc/systemd/system/csv-download.service
    echo "User=root" >> /etc/systemd/system/csv-download.service
    echo "" >> /etc/systemd/system/csv-download.service
    echo "[Install]" >> /etc/systemd/system/csv-download.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/csv-download.service
    sudo systemctl daemon-reload
    systemctl enable csv-download.service
    systemctl start csv-download.service
    service csv-download status 
    echo "Is the csv-download service enabled and running? (y/n)" 
    read csv_download_status
    if [ "$csv_download_status" != "y" ]; then
        echo "csv-download service is not enabled or running"
        echo "Please contact the repo admin and they will assist you" 
        exit 1
    fi
fi 
clear 

# Setup CSV-CoT.py 
## Copy the file from the github repo
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-cot.py /opt/TAK-Esri 
## Test The File 
cd /opt/TAK-Esri
python3 csv-cot.py
## Double check the output
cat /var/www/html/survey-cot.txt
echo "Does survey-cot.txt have contents (y/n)" 
read csvcot
if [ "$csvcot" != "y" ]; then
     echo "CSV-COT HAS FAILED" >> /opt/TAK-Esri/install-log.txt
     echo "We will come back to this later"
     echo "You may need to contact the rego manager to gain assistance with this error"
     exit 1
else 
    echo "while True:" >> /opt/TAK-Esri/csv-cot.py
    echo "    parse_csv_and_create_cot('survey.csv', '/var/www/html/survey-cot.txt')" >> /opt/TAK-Esri/csv-cot.py
    echo "    print('Parsed CSV and updated survey-cot.txt')" >> /opt/TAK-Esri/csv-cot.py
    echo "    time.sleep(5)" >> /opt/TAK-Esri/csv-cot.py
    clear
    echo "The output of XML-CoT messages is now in the file /var/www/html/survey-cot.txt"
    echo "" 
    echo "" 
    echo "" 
    echo "We will now install the service file so csv-cot.py will run automatically"
    echo "[Unit]" >> /etc/systemd/system/csv-cot.service
    echo "Description=CSV To COT" >> /etc/systemd/system/csv-cot.service
    echo "After=network.target" >> /etc/systemd/system/csv-cot.service
    echo "" >> /etc/systemd/system/csv-cot.service
    echo "[Service]" >> /etc/systemd/system/csv-cot.service
    echo "ExecStart=/usr/bin/python3 /opt/TAK-Esri/csv-cot.py" >> /etc/systemd/system/csv-cot.service
    echo "WorkingDirectory=/opt/TAK-Esri" >> /etc/systemd/system/csv-cot.service
    echo "StandardOutput=inherit" >> /etc/systemd/system/csv-cot.service
    echo "StandardError=inherit" >> /etc/systemd/system/csv-cot.service
    echo "Restart=always" >> /etc/systemd/system/csv-cot.service
    echo "User=root" >> /etc/systemd/system/csv-cot.service
    echo "" >> /etc/systemd/system/csv-cot.service
    echo "[Install]" >> /etc/systemd/system/csv-cot.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/csv-cot.service
    sudo systemctl daemon-reload
    systemctl enable csv-cot.service
    systemctl start csv-cot.service
    service csv-cot status 
    echo "Is the csv-cot service enabled and running? (y/n)" 
    read csv_cot_status
    if [ "$csv_cot_status" != "y" ]; then
        echo "csv-cot service is not enabled or running"
        echo "Please contact the repo admin and they will assist you" 
        exit 1
    fi
fi 

# Setup CSV-KML.py 
## Copy the file from the github repo
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-kml.py /opt/TAK-Esri 
## Test The File 
cd /opt/TAK-Esri
python3 csv-kml.py
clear
## Double check the output
cat /var/www/html/survey123.kml
echo "Does survey123.kml have contents (y/n)" 
read csvkml
if [ "$csvkml" != "y" ]; then
     echo "CSV-KML HAS FAILED" >> /opt/TAK-Esri/install-log.txt
     echo "We will come back to this later"
     echo "You may need to contact the rego manager to gain assistance with this error"
     exit 1
else 
    echo "The output of XML-CoT messages is now in the file /var/www/html/survey123.kml"
    echo "" 
    echo "while True:" >> /opt/TAK-Esri/csv-cot.py
    echo "    parse_csv_and_create_kml('survey.csv', '/var/www/html/survey123.kml')" >> /opt/TAK-Esri/csv-kml.py
    echo "    print('Parsed CSV and updated /var/www/html/survey123.kml')" >> /opt/TAK-Esri/csv-kml.py
    echo "    time.sleep(5)" >> /opt/TAK-Esri/csv-kml.py
    clear
    echo "" 
    echo "" 
    echo "We will now install the service file so csv-cot.py will run automatically"
    echo "[Unit]" >> /etc/systemd/system/csv-kml.service
    echo "Description=CSV To kml" >> /etc/systemd/system/csv-kml.service
    echo "After=network.target" >> /etc/systemd/system/csv-kml.service
    echo "" >> /etc/systemd/system/csv-kml.service
    echo "[Service]" >> /etc/systemd/system/csv-kml.service
    echo "ExecStart=/usr/bin/python3 /opt/TAK-Esri/csv-kml.py" >> /etc/systemd/system/csv-kml.service
    echo "WorkingDirectory=/opt/TAK-Esri" >> /etc/systemd/system/csv-kml.service
    echo "StandardOutput=inherit" >> /etc/systemd/system/csv-kml.service
    echo "StandardError=inherit" >> /etc/systemd/system/csv-kml.service
    echo "Restart=always" >> /etc/systemd/system/csv-kml.service
    echo "User=root" >> /etc/systemd/system/csv-kml.service
    echo "" >> /etc/systemd/system/csv-kml.service
    echo "[Install]" >> /etc/systemd/system/csv-kml.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/csv-kml.service
    sudo systemctl daemon-reload
    systemctl enable csv-kml.service
    systemctl start csv-kml.service
    service csv-kml status 
    echo "Is the csv-kml service enabled and running? (y/n)" 
    read csv_kml_status
    if [ "$csv_kml_status" != "y" ]; then
        echo "csv-kml service is not enabled or running"
        echo "Please contact the repo admin and they will assist you" 
        exit 1
    fi
fi 

# Check and install Node.js and Node-RED if necessary
if ! command -v node &> /dev/null; then
    echo ""
    echo "" 
    echo "" 
    echo "Node.js is not installed. Installing Node.js..."
    sleep 3 
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo dnf install -y nodejs

fi
## Double check install
read -p "Is Node-RED already installed? (y/n): " node_red_install
if [ "$node_red_install" != "y" ]; then
    sudo npm install -g --unsafe-perm node-red
    echo "Node-RED is now installed"
fi
clear
## Start Node-Red
echo "" 
echo "" 
echo "" 
echo "we will now test the node-red install" 
echo ""
echo "Exit node-red at any point to continue with the install" 
echo ""
echo ""
sleep 4
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
echo "Is Node-RED now installed and running as a service? (y/n)"
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
service csv-cot restart
clear 
echo "Now please go to http://127.0.0.1:1880 to continue the node-red setup"
sleep 40 
echo "Press enter when ready to move on" 
read enter 

# We will now install miniconda and create the arcgis_env
##Install & Activate Miniconda  
#!/bin/bash

# Install & Activate Miniconda
echo "Installing Miniconda..."
## Navigate to /root
cd /root
## Download Miniconda installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
## Make the installer executable
chmod +x Miniconda3-latest-Linux-x86_64.sh
## Run the installer silently (-b) and specify the installation directory
./Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda
## Navigate to Miniconda installation directory
cd /root/miniconda
## Initialize conda
## NOTE: Use 'conda init' to set up the shell for conda
## This requires a new shell session to take effect
source /root/miniconda/etc/profile.d/conda.sh
conda init bash
## Create a new conda environment named 'arcgis_env' with Python 3.9
conda create -n arcgis_env python=3.9 -y
## Optionally activate the new environment
conda activate arcgis_env
conda install -c esri arcgis
echo "Miniconda installation and environment setup complete."
echo "You may need to restart your terminal or run 'source ~/.bashrc' to apply conda changes."


## Instructions to continue the install 
echo ""
echo "" 
echo "At this point you will need to close your current terminal/cmd prompt and start a new one."
echo ""
echo "We will continue the install by running the command below in the new terminal instance"
echo ""
echo "cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x arcgis.sh && ./arcgis.sh && cd /opt/TAK-Esri && ls -la"
echo ""
echo ""
echo ""
echo ""