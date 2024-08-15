#!/bin/bash

echo -e "\n\nThis script will install the necessary dependencies & format everything for COT-GENERATION from Survey123 Data\n\n"
read -p "Press any key to begin ..."

clear

# Upgrade & update dependencies 
echo "Updating apt and installing dependencies"
sudo apt update -y
sudo apt upgrade -y
sudo apt install pipenv -y
sudo apt install wget python3-geopandas -y 

# Install apache2 
echo "Installing apache2 http server"
sudo apt install apache2 -y

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


# Check and install Node.js and Node-RED if necessary
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Installing Node.js..."
    sudo apt install nodejs npm -y
fi

read -p "Is Node-RED already installed? (y/n): " node_red_install

if [ "$node_red_install" != "y" ]; then
    sudo npm install -g --unsafe-perm node-red
    echo "Node-RED is now installed"
fi
clear

echo "we will now test the node-red install" 
echo "Exit node-red at any point to continue with the install" 
node-red


mkdir -p /opt/TAK-Esri
cd /opt/TAK-Esri

echo "What is the Survey123 Feature Layer Link?" 
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

url = "$survey123_feature_layer_link"

gdf = gpd.read_file(url + "?where=1%3D1&outFields=*&f=geojson")
gdf.to_csv("survey.csv", index=False)
EOF

# Move python files to the correct directory
echo "Moving python files to the /opt/TAK-Esri/ directory"
sudo cp /tmp/TeamAwearnessKit-Esri-Integration/python-files/*.py /opt/TAK-Esri/ || { echo "Python files copy failed"; exit 1; }
echo "Python files moved"

# Move service files to the system directory
echo "Moving service files to the /etc/systemd/system directory"

cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/node-red.service /etc/systemd/system/node-red.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/cot-csv.service /etc/systemd/system/cot-csv.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-cot.service /etc/systemd/system/csv-cot.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-download.service /etc/systemd/system/csv-download.service
cp /tmp/TeamAwearnessKit-Esri-Integration/service-files/csv-kml.service /etc/systemd/system/csv-kml.service
echo "Service files moved"

# Enable and start services

sudo systemctl daemon-reload

systemctl enable node-red.service 
systemctl enable cot-csv.service
systemctl enable csv-cot.service
systemctl enable csv-download.service
systemctl enable csv-kml.service 

sudo systemctl daemon-reload

systemctl start csv-download.service
echo "waiting 10 seconds to allow changes to be made"
sleep 10

systemctl start node-red.service 
systemctl start cot-csv.service
systemctl start csv-cot.service
systemctl start csv-kml.service 

echo "All services started successfully."

cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu
chmod +x arcgis.sh
./arcgis.sh
