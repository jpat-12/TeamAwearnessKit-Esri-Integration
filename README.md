[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jpat)

![TAK-Esri](img/TAK-EsriBreakdown.png?raw=true "TAK-Esri")
### What this repo does 
1. Takes Survey123 data and sends them as a CoT Message to a TAKServer/TAKClients 
2. Logges CoT Messages from the TAKServer and sends them to a feature layer in ArcGIS Online. 
    - This only will pull Unit & Point Messages. We have some range & bearing handeling in production. 

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
cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x arcgis.sh && ./arcgis.sh && cd /opt/TAK-Esri && ls -la 
```
<br />

# Survey123 To Team Awearness Kit
1. **[Esri-TAK Group](https://arcg.is/1DyOD80)** <br />
2. **[Survey Template](https://survey123.arcgis.com/surveys)** <br />
3. **[Survey123-Push-Flow](https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration/blob/main/json-flows/Survey123-Push-Flow.json)** <br />
4. **[CoT-Pull-Flow](https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration/blob/main/json-flows/CoT-Pull-Flow.json)** <br />

# Troubleshooting
1. Ensure all services are running 
    - `feature-layer-update.service`
    - `cot-csv.service`
    - `csv-cot.service`
    - `csv-download.service`
    - `csv-kml.service`
    - `node-red.service`

2. Ensure Node-RED is running with no errors 

3. ArcGIS - If the Feature layer is not updating do the following 
    - Make sure that the `append.py`, `push.py`, or `sign-in.py` is being run from inside the Conda environment 
    - To activate the Conda environment: `conda activate arcgis_env`
