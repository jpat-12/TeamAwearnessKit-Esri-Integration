#!/bin/bash
clear
echo "This script will allow you to communicate Survey123 data to TAK & KML-Network accepted clients"
echo ""
echo "If you would like to proceed please press enter"
read enter

echo "We will first start with installing some dependencies"
sudo dnf update -y
sudo dnf install pipenv wget python3-geopandas -y
pip install geopandas
clear
echo "The dependencies are now installed"
sleep 3

#Install python 
## Enable necessary repositories and modules
sudo dnf install -y epel-release
sudo dnf install -y dnf-utils
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module reset python39
sudo dnf module enable python39:3.9
## Install Python 3.9
sudo dnf install -y python39
## Install pip for Python 3.9
sudo dnf install -y python3.9-pip
## Upgrade pip and install geopandas
python3.9 -m pip install --upgrade pip
python3.9 -m pip install geopandas





# Install httpd
echo "We will now install an HTTP server"
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
python3.9 csv-download.py
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
    python3.9 /opt/TAK-Esri/csv-download.py
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
    echo "    # Wait 5 seconds before next download" >> /opt/TAK-Esri/csv-download.py
    echo "    time.sleep(5)" >> /opt/TAK-Esri/csv-download.py
    clear
    echo "Printing while loop to /opt/TAK-Esri/csv-download.py"
    echo "[Unit]" >> /etc/systemd/system/csv-download.service
    echo "Description=CSV Download" >> /etc/systemd/system/csv-download.service
    echo "After=network.target" >> /etc/systemd/system/csv-download.service
    echo "" >> /etc/systemd/system/csv-download.service
    echo "[Service]" >> /etc/systemd/system/csv-download.service
    echo "ExecStart=/usr/bin/python3.9 /opt/TAK-Esri/csv-download.py" >> /etc/systemd/system/csv-download.service
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
    systemctl status csv-download.service
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
python3.9 csv-cot.py
## Double check the output
cat /var/www/html/survey-cot.txt
echo "Does survey-cot.txt have contents (y/n)"
read csvcot
if [ "$csvcot" != "y" ]; then
    echo "CSV-COT HAS FAILED" >> /opt/TAK-Esri/install-log.txt
    echo "We will come back to this later"
    echo "You may need to contact the repo manager to gain assistance with this error"
    exit 1
else
    echo "while True:" >> /opt/TAK-Esri/csv-cot.py
    echo "    parse_csv_and_create_cot('survey.csv', '/var/www/html/survey-cot.txt')" >> /opt/TAK-Esri/csv-cot.py
    echo "    print('Parsed CSV and updated survey-cot.txt')" >> /opt/TAK-Esri/csv-cot.py
    echo "    time.sleep(5)" >> /opt/TAK-Esri/csv-cot.py
    clear
    echo "The output of kml-CoT messages is now in the file /var/www/html/survey-cot.txt"
fi

# Setup CSV-kml.py
echo "We will now set up the CSV-kml.py script for converting CSV data into kml."
## Copy the file from the github repo
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/csv-kml.py /opt/TAK-Esri
## Test The File
python3.9 /opt/TAK-Esri/csv-kml.py
## Double check the output
cat /var/www/html/survey123.kml
echo "Does survey123.kml have contents (y/n)"
read csvkml
if [ "$csvkml" != "y" ]; then
    echo "CSV-kml HAS FAILED" >> /opt/TAK-Esri/install-log.txt
    echo "You may need to contact the repo manager to gain assistance with this error"
    exit 1
else
    echo "while True:" >> /opt/TAK-Esri/csv-kml.py
    echo "    parse_csv_and_create_kml('survey.csv', '/var/www/html/survey123.kml')" >> /opt/TAK-Esri/csv-kml.py
    echo "    print('Parsed CSV and updated survey123.kml')" >> /opt/TAK-Esri/csv-kml.py
    echo "    time.sleep(5)" >> /opt/TAK-Esri/csv-kml.py
    clear
    echo "The output of kml messages is now in the file /var/www/html/survey123.kml"
fi

# Configure httpd for file serving
echo "Configuring HTTP server to serve the kml and TXT files."
sudo bash -c 'cat <<EOF > /etc/httpd/conf.d/survey.conf
<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    <Directory "/var/www/html">
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF'

sudo systemctl restart httpd
clear
echo "The HTTP server is now configured to serve your files."

# Verify Installation
echo "Verifying installation."
echo "Checking if httpd is running..."
sudo systemctl status httpd
echo "Checking if Python scripts are running..."
ps aux | grep python3.9
echo "Checking file contents in /var/www/html/"
ls -l /var/www/html/

echo "Installation is complete!"
echo "You should now be able to access your files via the HTTP server and see updates in the kml and TXT files."
