#!/bin/bash
GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'
#reset csv-download 
clear
rm -rf /etc/systemd/system/csv-download.service
echo "[Unit]" >> /etc/systemd/system/csv-download.service
echo "Description=CSV Download" >> /etc/systemd/system/csv-download.service
echo "After=network.target" >> /etc/systemd/system/csv-download.service
echo "" >> /etc/systemd/system/csv-download.service
echo "[Service]" >> /etc/systemd/system/csv-download.service
echo "ExecStart=/usr/bin/python3.12 /opt/TAK-Esri/csv-download.py" >> /etc/systemd/system/csv-download.service
echo "WorkingDirectory=/opt/TAK-Esri" >> /etc/systemd/system/csv-download.service
echo "StandardOutput=file:/var/log/csv-download.log" >> /etc/systemd/system/csv-download.service
echo "StandardError=file:/var/log/csv-download_error.log" >> /etc/systemd/system/csv-download.service
echo "Restart=always" >> /etc/systemd/system/csv-download.service
echo "User=root" >> /etc/systemd/system/csv-download.service
echo "" >> /etc/systemd/system/csv-download.service
echo "[Install]" >> /etc/systemd/system/csv-download.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/csv-download.service
sudo systemctl daemon-reload
systemctl enable csv-download.service
systemctl start csv-download.service


# Set variables for the feature layer
echo -e "${BLUE}We will now set variables to personalize the install${RESET}"
read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
read -p "Enter the username of the enterprise: " e_username
read -p "Enter the password of the enterprise: " e_password
read -p "Enter the name of the feature layer you will create: " feature_layer_name
read -p "Enter the description you want your feature layer to have: " feature_layer_desc
## Double check all variables are set correctly
echo -e "${BLUE}Are all of these correct?${RESET}"
echo -e "${GREEN}Enterprise link: $e_link${RESET}"
echo -e "${BLUE}Enterprise username: $e_username${RESET}"
echo -e "${GREEN}Enterprise password: $e_password${RESET}"
echo -e "${BLUE}Feature Layer Name: $feature_layer_name${RESET}"
echo -e "${GREEN}Feature Layer Description: $feature_layer_desc${RESET}"
read -p "Press y to continue or any other key to re-enter the information: " confirm
## Loop To Correct incorrect variables
while [ "$confirm" != "y" ]; do
    read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
    read -p "Enter the username of the enterprise: " e_username
    read -p "Enter the password of the enterprise: " e_password
    read -p "Enter the name of the feature layer you will create: " feature_layer_name
    read -p "Enter the description you want your feature layer to have: " feature_layer_desc
    echo -e "${BLUE}Are all of these correct?" 
    echo -e "${GREEN}Enterprise link: $e_link${RESET}"
    echo -e "${BLUE}Enterprise username: $e_username${RESET}"
    echo -e "${GREEN}Enterprise password: $e_password${RESET}"
    echo -e "${BLUE}Feature Layer Name: $feature_layer_name${RESET}"
    echo -e "${GREEN}Feature Layer Description: $feature_layer_desc${RESET}"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done

# Start Conda & Setup for ArcGIS Push & Ammend Files
## Initialize Conda
conda init
## Activate the Conda environment
source /root/miniconda/bin/activate arcgis_env
## Check if the environment activation was successful
if [ "$(basename $(which python))" = "python" ] && [[ $(conda info --envs | grep '*') =~ "arcgis_env" ]]; then
    echo -e "${BLUE}Environment 'arcgis_env' is active.${RESET}"
else
    echo -e "${BLUE}Failed to activate 'arcgis_env'.${RESET}"
    exit 1
fi
## Install required packages
conda install -c esri arcgis -y
pip install arcgis
## Create necessary directories and files
mkdir -p /opt/TAK-Esri/ArcGIS

# Test connection to Esri servers
echo -e "${BLUE}Testing connection to Esri servers${RESET}"
## Print to sign in file

# Create the sign-in.py script
cat <<EOF > /opt/TAK-Esri/ArcGIS/sign-in.py
from arcgis.gis import GIS
from arcgis.features import FeatureLayer
#
gis = GIS("$e_link", "$e_username", "$e_password")
print("Logged in as: " + gis.properties.user.username)
EOF
## Navigate to the directory
cd /opt/TAK-Esri/ArcGIS
## Run the sign-in.py script and capture its output
python3 sign-in.py > output.log
## Display the contents of the output file
cat output.log
## Extract the username from the output file
output_username=$(grep "Logged in as:" output.log | awk -F": " '{print $2}')
## Compare the extracted username to the expected username
if [ "$output_username" = "$e_username" ]; then
    echo -e "${GREEN}Username matches: $e_username${RESET}"
else
    echo -e "${RED}Username does not match. Expected: $e_username, Found: $output_username${RESET}"
    echo ""
    echo ""
    echo -e "${BLUE}Would you like to try entering your credentials again? (y/n)${RESET}"
    read credentials
    if [ "$credentials" = "y" ]; then
        # Credential re-entry loop
        while true; do
            read -p "Enter the link of the enterprise you want to use (i.e. https://cap-gis.maps.arcgis.com): " e_link
            read -p "Enter the username of the enterprise: " e_username
            read -sp "Enter the password of the enterprise: " e_password
            echo ""
            echo ""
            echo -e "${GREEN}Are all of these correct?${RESET}"
            echo -e "${BLUE}Enterprise link: $e_link${RESET}"
            echo -e "${GREEN}Enterprise username: $e_username${RESET}"
            echo -e "${BLUE}Enterprise password: $e_password${RESET}"
            read -p "Press y to continue or any other key to re-enter the information: " confirm
            if [ "$confirm" = "y" ]; then
                echo -e "${RED}You either need to restart the script or contact the repo owner for help${RESET}"
                exit 1
            fi
        done
    else
        echo -e "${RED}You need to restart the script or contact the repo owner for help${RESET}"
        exit 1
    fi
fi

# Making test data in /var/www/html/cot-logged.csv
clear 
echo -e "${BLUE}Now printing test data to /var/www/html/cot-logged.csv${RESET}"
cat <<EOF > /var/www/html/cot-logged.csv
uid,type,how,time,start,stale,lat,long,hae,ce,le,contactcallsign,parent_callsign,production_time,iconpath,group_name,group_role,battery,device,platform,os,version,speed,course,droid_uid
e5a1cb4e-4736-4315-b216-bd30c3104456,a-u-G,h-g-i-g-o,2024-08-03T01:16:24Z,2024-08-03T01:16:24Z,2024-08-10T01:16:24Z,39.5001089390719,-88.8520772875137,168.398757195526,9999999.0,9999999.0,CAP Repeater 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:29Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/CAP Repeater.png,,,,,,,,,,
60f0fac0-0afd-4bf1-b3e1-7ba3379b5fff,a-u-G,h-g-i-g-o,2024-08-03T01:16:28Z,2024-08-03T01:16:29Z,2024-08-10T01:16:29Z,39.4997953384667,-89.061567867324,162.449553796715,9999999.0,9999999.0,Area Command Post 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:25Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Area Command Post.png,,,,,,,,,,
EOF

# Create push.py file
echo -e "${BLUE}We will now update the python script to use the feature layer link and name${RESET}"
cat <<EOF > /opt/TAK-Esri/ArcGIS/push.py
from arcgis.gis import GIS
from arcgis.features import FeatureLayerCollection
import pandas as pd

# Authentication
gis = GIS("$e_link", "$e_username", "$e_password")

# Read the CSV data into a pandas DataFrame
csv_file_path = '/var/www/html/cot-logged.csv'
df = pd.read_csv(csv_file_path)

# Define the name and description for the new feature layer
layer_name = "$feature_layer_name"
layer_description = "$feature_layer_desc"

# Create a new feature layer
csv_item_properties = {
    'title': layer_name,
    'type': 'CSV',
    'description': layer_description,
    'tags': 'your, tags, here'
}

# Upload the CSV to ArcGIS Online
csv_item = gis.content.add(item_properties=csv_item_properties, data=csv_file_path)

# Publish the CSV as a feature layer
csv_lyr = csv_item.publish()

# Share the feature layer with the public or a specific group
csv_lyr.share(everyone=True)

print(f"Feature layer created: {csv_lyr.url}")
EOF

# Making test data in /var/www/html/cot-logged.csv
clear 
echo -e "${BLUE}Now printing more test data to /var/www/html/cot-logged.csv${RESET}"
cat <<EOF > /var/www/html/cot-logged.csv
uid,type,how,time,start,stale,lat,long,hae,ce,le,contactcallsign,parent_callsign,production_time,iconpath,group_name,group_role,battery,device,platform,os,version,speed,course,droid_uid
e5a1cb4e-4736-4315-b216-bd30c3104456,a-u-G,h-g-i-g-o,2024-08-03T01:16:24Z,2024-08-03T01:16:24Z,2024-08-10T01:16:24Z,39.5001089390719,-88.8520772875137,168.398757195526,9999999.0,9999999.0,CAP Repeater 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:29Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/CAP Repeater.png,,,,,,,,,,
60f0fac0-0afd-4bf1-b3e1-7ba3379b5fff,a-u-G,h-g-i-g-o,2024-08-03T01:16:28Z,2024-08-03T01:16:29Z,2024-08-10T01:16:29Z,39.4997953384667,-89.061567867324,162.449553796715,9999999.0,9999999.0,Area Command Post 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:25Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Area Command Post.png,,,,,,,,,,
d7fa3907-72df-4bb7-8e13-52d7f98f008b,a-u-G,h-g-i-g-o,2024-08-03T01:16:34Z,2024-08-03T01:16:32Z,2024-08-10T01:16:32Z,39.5053068473791,-88.9654113543475,159.721576169111,9999999.0,9999999.0,CAP Asset Report 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:27Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/CAP Asset Report.png,,,,,,,,,,
1c29f325-bea8-4391-be44-f8585c60a269,a-u-G,h-g-i-g-o,2024-08-03T01:16:38Z,2024-08-03T01:16:38Z,2024-08-10T01:16:38Z,39.5081022704918,-88.7421958875144,170.33378239137,9999999.0,9999999.0,CLUE 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:32Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/CLUE.png,,,,,,,,,,
3e1e6089-adcb-445b-ada2-14a65c66c86c,a-u-G,h-g-i-g-o,2024-08-03T01:16:41Z,2024-08-03T01:16:41Z,2024-08-10T01:16:41Z,39.5000395250022,-88.6391864154783,167.447904316197,9999999.0,9999999.0,Command Post 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:34Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Command Post.png,,,,,,,,,,
15497dc2-2423-45b4-9256-2aed615d4234,a-u-G,h-g-i-g-o,2024-08-03T01:16:44Z,2024-08-03T01:16:45Z,2024-08-10T01:16:45Z,39.4382788701721,-89.1711785917053,162.896211907284,9999999.0,9999999.0,Crash Site 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:37Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Crash Site.png,,,,,,,,,,
dc2f05ac-e141-4541-bb61-61fcc490621e,a-u-G,h-g-i-g-o,2024-08-03T01:16:48Z,2024-08-03T01:16:48Z,2024-08-10T01:16:48Z,39.4199436243011,-89.0749823952634,172.911658292791,9999999.0,9999999.0,Electrical 2,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:39Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Electrical.png,,,,,,,,,,
a640ddee-9cc2-4a28-8b8e-d8681f24f081,a-u-G,h-g-i-g-o,2024-08-03T01:16:52Z,2024-08-03T01:16:52Z,2024-08-10T01:16:52Z,39.4228192874086,-88.9754925450747,184.64377148127,9999999.0,9999999.0,ELT Signal 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:46Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/ELT Signal.png,,,,,,,,,,
f9c32261-1069-442a-8feb-d3e9a29b9aac,a-u-G,h-g-i-g-o,2024-08-03T01:16:54Z,2024-08-03T01:16:55Z,2024-08-10T01:16:55Z,39.4309479918631,-88.8451498655995,154.871989002074,9999999.0,9999999.0,Emergency Operations Center 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:49Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Emergency Operations Center.png,,,,,,,,,,
f7fe0412-c91c-4bda-8ce7-4708ae503cef,a-u-G,h-g-i-g-o,2024-08-03T01:16:58Z,2024-08-03T01:16:58Z,2024-08-10T01:16:58Z,39.4229798160323,-88.752534939865,152.435897499528,9999999.0,9999999.0,EMS 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:52Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/EMS.png,,,,,,,,,,
5fe4d625-7216-47df-a96c-5a27707feae3,a-u-G,h-g-i-g-o,2024-08-03T01:17:00Z,2024-08-03T01:17:01Z,2024-08-10T01:17:01Z,39.4335536139519,-88.6564749980821,177.301585002189,9999999.0,9999999.0,Fire 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:55Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Fire.png,,,,,,,,,,
ea07dd01-f254-49e4-a9cb-8d6c302f639a,a-u-G,h-g-i-g-o,2024-08-03T01:17:04Z,2024-08-03T01:17:05Z,2024-08-10T01:17:05Z,39.3717257819872,-89.1776878957571,185.463327948284,9999999.0,9999999.0,Flood 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:11:59Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Flood.png,,,,,,,,,,
5964faf2-39dc-4c53-b5f0-87b85baedce9,a-u-G,h-g-i-g-o,2024-08-03T01:17:09Z,2024-08-03T01:17:09Z,2024-08-10T01:17:09Z,39.3720008689225,-89.0919393101242,173.35448530001,9999999.0,9999999.0,"Hazard, Haz Materials 1",AFAUX-IL-Pattara.J.w,2024-07-29T21:12:02Z,"412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Hazard, Haz Materials.png",,,,,,,,,,
4854a97f-18c7-4c31-b962-046d276f54cd,a-u-G,h-g-i-g-o,2024-08-03T01:17:12Z,2024-08-03T01:17:13Z,2024-08-10T01:17:13Z,39.3695548325274,-89.0027798299576,169.234220828881,9999999.0,9999999.0,"Hazard, Other 1",AFAUX-IL-Pattara.J.w,2024-07-29T21:12:05Z,"412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Hazard, Other.png",,,,,,,,,,
f6545cb6-a202-4b98-8fb8-7236454f9f13,a-u-G,h-g-i-g-o,2024-08-03T01:17:15Z,2024-08-03T01:17:16Z,2024-08-10T01:17:16Z,39.3537480762252,-88.8999151665657,154.603442903556,9999999.0,9999999.0,Helicopter Landing Zone 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:08Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Helicopter Landing Zone.png,,,,,,,,,,
87d5e450-d304-4f39-993e-0e660d264e29,a-u-G,h-g-i-g-o,2024-08-03T01:17:18Z,2024-08-03T01:17:18Z,2024-08-10T01:17:18Z,39.3644533765164,-88.786831399911,149.962864088494,9999999.0,9999999.0,Incident Command Post 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:10Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Incident Command Post.png,,,,,,,,,,
5657d3b8-7042-43e0-b480-34401087b6f3,a-u-G,h-g-i-g-o,2024-08-03T01:17:21Z,2024-08-03T01:17:21Z,2024-08-10T01:17:21Z,39.3670555773683,-88.6703001493591,164.552540496976,9999999.0,9999999.0,Initial Planning Point 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:13Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Initial Planning Point.png,,,,,,,,,,
2bff82b1-db8f-47b0-96a6-7430828a9500,a-u-G,h-g-i-g-o,2024-08-03T01:17:25Z,2024-08-03T01:17:25Z,2024-08-10T01:17:25Z,39.2891989750038,-89.1806877255254,165.500611716461,9999999.0,9999999.0,Joint Operations Center 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:18Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Joint Operations Center.png,,,,,,,,,,
7314e7c6-dcef-4b42-83b6-3c4ebca166cf,a-u-G,h-g-i-g-o,2024-08-03T01:17:28Z,2024-08-03T01:17:28Z,2024-08-10T01:17:28Z,39.2948680744981,-89.0744972616552,158.066751876594,9999999.0,9999999.0,Multi-Agency Coordination Center 3,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:21Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Multi-Agency Coordination Center.png,,,,,,,,,,
a2859439-98e9-461c-924c-f045758ad2a8,a-u-G,h-g-i-g-o,2024-08-03T01:17:31Z,2024-08-03T01:17:32Z,2024-08-10T01:17:32Z,39.2977234342694,-88.9922973904239,151.661048181697,9999999.0,9999999.0,No Cellular Connection 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:24Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/No Cellular Connection.png,,,,,,,,,,
5bcbef54-91c2-4c8c-a447-5c22f2dbafb9,a-u-G,h-g-i-g-o,2024-08-03T01:17:38Z,2024-08-03T01:17:39Z,2024-08-10T01:17:39Z,39.3005187669343,-88.9066831090927,145.469143189719,9999999.0,9999999.0,Placeholder Other 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:27Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Placeholder Other.png,,,,,,,,,,
f3c5332f-11cf-4c86-849c-b6c94d695b40,a-u-G,h-g-i-g-o,2024-08-03T01:17:43Z,2024-08-03T01:17:43Z,2024-08-10T01:17:43Z,39.3059034756053,-88.8279235553011,141.613509134448,9999999.0,9999999.0,PLT SIgnal 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:30Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/PLT SIgnal.png,,,,,,,,,,
425fafbb-f999-4770-8c39-dbd6cf9d7b4c,a-u-G,h-g-i-g-o,2024-08-03T01:17:47Z,2024-08-03T01:17:47Z,2024-08-10T01:17:47Z,39.311203524537,-88.7012082313586,149.048731192688,9999999.0,9999999.0,Reporting-Party 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:32Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Reporting-Party.png,,,,,,,,,,
89513d6d-e801-46b3-9379-5e813616b437,a-u-G,h-g-i-g-o,2024-08-03T01:17:54Z,2024-08-03T01:17:55Z,2024-08-10T01:17:55Z,39.2065870357729,-89.1973929243436,158.792235818523,9999999.0,9999999.0,Staging Area 1,AFAUX-IL-Pattara.J.w,2024-07-29T21:12:35Z,412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Staging Area.png,,,,,,,,,,
1134b3f3-e380-4368-9f0a-a463c6348b44,a-u-G,h-g-i-g-o,2024-08-03T01:17:59Z,2024-08-03T01:18:00Z,2024-08-10T01:18:00Z,39.2122873799955,-89.0913057068442,157.886157723506,9999999.0,9999999.0,"Structure, Damaged 1",AFAUX-IL-Pattara.J.w,2024-07-29T21:12:38Z,"412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Structure, Damaged.png",,,,,,,,,,
11e08d66-c03e-4afd-b52c-f71050c441be,a-u-G,h-g-i-g-o,2024-08-03T01:18:02Z,2024-08-03T01:18:02Z,2024-08-10T01:18:02Z,39.2231807512069,-88.9955222681693,148.81516625972,9999999.0,9999999.0,"Structure, Destroyed 1",AFAUX-IL-Pattara.J.w,2024-07-29T21:12:40Z,"412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Structure, Destroyed.png",,,,,,,,,,
daef36e9-e38e-4b8a-8dba-889f492c7ede,a-u-G,h-g-i-g-o,2024-08-03T01:18:05Z,2024-08-03T01:18:05Z,2024-08-10T01:18:05Z,39.2286139441077,-88.9339432633274,137.557580807376,9999999.0,9999999.0,"Structure, Failed 1",AFAUX-IL-Pattara.J.w,2024-07-29T21:12:43Z,"412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Structure, Failed.png",,,,,,,,,,
d24de9ab-08d8-4a37-9e17-e1c8bd7612d6,a-u-G,h-g-i-g-o,2024-08-03T01:18:08Z,2024-08-03T01:18:08Z,2024-08-10T01:18:08Z,39.2286937646352,-88.8620926502788,139.401808298702,9999999.0,9999999.0,"Structure, No-Damage 1",AFAUX-IL-Pattara.J.w,2024-07-29T21:12:45Z,"412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Structure, No-Damage.png",,,,,,,,,,
102eb8ca-7952-44a0-8127-101e87747309,a-u-G,h-g-i-g-o,2024-08-03T01:18:10Z,2024-08-03T01:18:11Z,2024-08-10T01:18:11Z,39.2420297511309,-88.7526082639553,144.994110481402,9999999.0,9999999.0,"Transportation, Route Block 1",AFAUX-IL-Pattara.J.w,2024-07-29T21:12:48Z,"412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Transportation, Route Block.png",,,,,,,,,,
EOF

# Run push.py
cd /opt/TAK-Esri/ArcGIS
python3 push.py >> output.log

# Find Layer ID
clear
echo ""
echo -e "${BLUE}STOPPING HERE TEMPORARILY ${RESET}"
echo ""
echo -e "${BLUE}Go find the feature layer we just created${RESET}"
echo ""
echo -e "${BLUE}press enter when you have your feature layer id${RESET}"
read stop 
## Intake F-L-ID
echo -e "${BLUE}Sleeping for 5 seconds${RESET}" 
sleep 5
echo ""
read -p "Enter the Feature layer ID: " file_id
## Double check all variables are set correctly
echo -e "${BLUE}Is this correct? (y/n)${RESET}"
echo -e "${BLUE}Feature layer ID: $file_id${RESET}"
read -p "Press y to continue or any other key to re-enter the information: " confirm
while [ "$confirm" != "y" ]; do
    read -p "Enter the Feature layer ID " file_id
    echo -e "${BLUE}Are all of these correct?${RESET}"
    echo -e "${BLUE}Feature layer ID: $file_id${RESET}"
    read -p "Press y to continue or any other key to re-enter the information: " confirm
done

#Print append.py
cat <<EOF > /opt/TAK-Esri/ArcGIS/append.py
from arcgis import GIS
from arcgis.features import FeatureLayerCollection
import pandas as pd
import time

def overwrite_feature_layer(csv_file_path, existing_layer_item_id):
    try:
        # Authentication
        gis = GIS("$e_link", "$e_username", "$e_password")

        # Read the CSV data into a pandas DataFrame
        df = pd.read_csv(csv_file_path)

        # Find the existing feature layer item
        existing_layer_item = gis.content.get(existing_layer_item_id)

        # Update the CSV data item
        item_update = existing_layer_item.update(data=csv_file_path)

        if item_update:
            # Get the feature layer collection
            feature_layer_collection = FeatureLayerCollection.fromitem(existing_layer_item)

            # Overwrite the feature layer
            overwrite_result = feature_layer_collection.manager.overwrite(csv_file_path)

            if overwrite_result['success']:
                print(f"Feature layer updated successfully: {existing_layer_item.url}")
            else:
                print("Failed to overwrite the feature layer.")
        else:
            print("Failed to update the CSV data item.")
    
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    csv_file_path = '/var/www/html/cot-logged.csv'
    existing_layer_item_id = "$file_id"  # Replace with your existing layer item ID

    while True:
        overwrite_feature_layer(csv_file_path, existing_layer_item_id)
        print('Waiting before the next overwrite...')
        time.sleep(60)  # Sleep for 60 seconds before the next iteration
EOF

# Create shell script to be run from a service  
cd /opt/TAK-Esri/ArcGIS 
cat <<EOF > /opt/TAK-Esri/ArcGIS/append.sh
#!/bin/bash
# Source the conda.sh script
source /root/miniconda/etc/profile.d/conda.sh

#conda init
conda activate arcgis_env
cd /opt/TAK-Esri/ArcGIS
python3 append.py
# Change to the correct directory
#mkdir -p /opt/TAK-Esri/ArcGIS
#cd /opt/TAK-Esri/ArcGIS

# Loop to run the Python script and wait for 5 seconds
#while true; do
#    python3 append.py
#    echo 'Pushed To ArcGIS'
#   sleep 5
#done
EOF
sudo chmod +x /opt/TAK-Esri/ArcGIS/append.sh

# Create service file to run /opt/TAK-Esri/ArcGIS/append.sh
cat <<EOF > /etc/systemd/system/feature-layer-update.service
[Unit]
Description=feature-layer-update
After=network.target

[Service]
ExecStart=/bin/bash /opt/TAK-Esri/ArcGIS/append.sh
WorkingDirectory=/opt/TAK-Esri/ArcGIS
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Setup cot-csv.py 
## Copy the file from the github repo
cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/cot-csv.py /opt/TAK-Esri 
## Test The File 
cd /opt/TAK-Esri
python3 cot-csv.py
## Double check the output
cat /var/www/html/cot-logged.csv
echo -e "${BLUE}Does cot-logged.csv have contents (y/n)${RESET}" 
read cotcsv
if [ "$csvcot" = "n" ]; then
     echo "COT-CSV HAS FAILED" >> /opt/TAK-Esri/install-log.txt
     echo -e "${RED}We will come back to this later${RESET}"
     echo -e "${RED}You may need to contact the rego manager to gain assistance with this error${RESET}"
     exit 1
else 
    echo "" >> /opt/TAK-Esri/cot-csv.py
    echo "while True:" >> /opt/TAK-Esri/cot-csv.py
    echo "    main(input_file, output_file)" >> /opt/TAK-Esri/cot-csv.py
    echo "    print('CoT-CSV parsed')" >> /opt/TAK-Esri/cot-csv.py
    echo "    time.sleep(5)" >> /opt/TAK-Esri/cot-csv.py
    clear
    echo -e "${BLUE}The parsed CoT messages are now in the file /var/www/html/cot-logged.csv${RESET}"
    echo "" 
    echo "" 
    echo "" 
    echo -e "${BLUE}We will now install the service file so csv-cot.py will run automatically${RESET}"
    echo "[Unit]" >> /etc/systemd/system/cot-csv.service
    echo "Description=cot - csv" >> /etc/systemd/system/cot-csv.service
    echo "After=network.target" >> /etc/systemd/system/cot-csv.service
    echo "" >> /etc/systemd/system/cot-csv.service
    echo "[Service]" >> /etc/systemd/system/cot-csv.service
    echo "ExecStart=/usr/bin/python3 /opt/TAK-Esri/cot-csv.py" >> /etc/systemd/system/cot-csv.service
    echo "WorkingDirectory=/opt/TAK-Esri" >> /etc/systemd/system/cot-csv.service
    echo "StandardOutput=inherit" >> /etc/systemd/system/cot-csv.service
    echo "StandardError=inherit" >> /etc/systemd/system/cot-csv.service
    echo "Restart=always" >> /etc/systemd/system/cot-csv.service
    echo "User=root" >> /etc/systemd/system/cot-csv.service
    echo "" >> /etc/systemd/system/cot-csv.service
    echo "[Install]" >> /etc/systemd/system/cot-csv.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/cot-csv.service
    sudo systemctl daemon-reload
    systemctl enable cot-csv.service
    systemctl start cot-csv.service
    service cot-csv status 
    echo -e "${BLUE}Is the cot-csv service enabled and running? (y/n)${RESET}"
    read cot_csv_status
    if [ "$cot_csv_status" != "y" ]; then
        echo -e "${RED}cot-csv service is not enabled or running${RESET}"
        echo -e "${RED}Please contact the repo admin and they will assist you${RESET}"
        exit 1
    fi
fi 

# Add Logging capabilities for /var/www/html/cot-logged.txt
echo -e "${BLUE}Adding logging capabilities for the /var/www/html/cot-logged.txt file${RESET}"
cat <<EOF > /opt/TAK-Esri/copy-cot-intake.py 
import shutil
import os
from datetime import datetime

# Define source and base destination directories
source_file = '/var/www/html/cot-logged.txt'
base_destination_dir = '/var/www/html/cot-messages-logged/'

# Get current UTC date and time
current_utc_time = datetime.utcnow()
date_folder = current_utc_time.strftime('%d-%B-%Y')
formatted_time = current_utc_time.strftime('%H:%M:%S')

# Create destination directory path for the current day
destination_dir = os.path.join(base_destination_dir, date_folder)
os.makedirs(destination_dir, exist_ok=True)

# Create destination file path
destination_file = os.path.join(destination_dir, f'cot-messages-pulled-{formatted_time}.txt')

# Copy the file
shutil.copy2(source_file, destination_file)

print(f'File copied to {destination_file}')
EOF
## Add the cron job
# Define the cron job schedule and command
CRON_SCHEDULE="0 * * * *"
CRON_COMMAND="/opt/TAK-Esri/ArcGIS/append.sh"
## Full cron job entry
CRON_JOB="$CRON_SCHEDULE $CRON_COMMAND"
## Check if the cron job already exists
(crontab -l 2>/dev/null | grep -F "$CRON_COMMAND") || {
    # Add the cron job if it doesn't exist
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job added: $CRON_JOB"
}

# Reload the daemon and start the service
conda deactivate 
#pip3 install geopandas
sudo systemctl daemon-reload
sudo systemctl enable feature-layer-update.service
sudo systemctl enable cot-csv.service
sudo systemctl daemon-reload
sudo systemctl start feature-layer-update.service
sudo systemctl start cot-csv.service
sudo systemctl start node-red.service 
sudo systemctl start csv-cot.service
sudo systemctl start csv-kml.service 
sudo service csv-download restart
clear
echo -e "${BLUE}You should be good to go${RESET}"
echo -e "${BLUE}It looks like everything has installed properly${RESET}"
echo -e "${BLUE}If this is not the case please let the repo owner know${RESET}"