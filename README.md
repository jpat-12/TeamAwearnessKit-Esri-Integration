[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jpat)

![TAK-Esri](img/TAK-EsriBreakdown.png?raw=true "TAK-Esri")



# Required Prerequisites
1. ArcGIS Online or ArcGIS Enterprise Account 
2. TAKServer with TCP Port 
3. Machine with SSH configured (Can be the same as the machine running the TAKServer)

## Launch Full Setup Scripts
Has only been tested on Ubuntu Server 22.04
#### Step #1 
```bash
cd /tmp && sudo apt install git && sudo git clone https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration.git && cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x initial.sh && ./initial.sh && cd /opt/TAK-Esri && ls -la 
```
#### Step #2 
```bash
cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x arcgis2.sh && ./arcgis2.sh && cd /opt/TAK-Esri && ls -la 
```
<br />

# Survey123 To Team Awearness Kit
1. **[Esri-TAK Group](https://arcg.is/1DyOD80)** <br />
2. **[Survey Template](https://survey123.arcgis.com/surveys)** <br />
3. **[Survey123-Push-Flow](https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration/blob/main/json-flows/Survey123-Push-Flow.json)** <br /><br />
<br />

# TAK To Esri Feature Layer
## 1. Team Location
1. **[CoT-Pull-Flow](https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration/blob/main/json-flows/CoT-Pull-Flow.json)** <br />


## 2. Dropped Data 
THIS IS IN PRODUCTION - COMING SOON
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br />

# Troubleshooting
1. Ensure all services are running 
    a. feature-layer-update.service 
    b. cot-csv.service
    c. csv-cot.service
    d. csv-download.service
    e. csv-kml.service 
    f. node-red.service
2. Ensure Node-Red is running with no errors 
3. ArcGIS - If the Feature layer is not updating do the following 
    a. Make sure that the append.py, push.py, or sign-in.py is bring run from inside the conda env 
    b. To activate the conda env "conda activate arcgis_env" 
    
