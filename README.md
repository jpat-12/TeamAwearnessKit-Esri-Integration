[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jpat)

![TAK-Esri](img/TAK-EsriBreakdown1.png?raw=true "TAK-Esri")
# Survey123 To Team Awearness Kit

## What this repo does 
1. Takes Survey123 data and sends them as a CoT Message to a TAKServer/TAKClients 
2. Logs CoT Messages from the TAKServer and sends them to a feature layer in ArcGIS Online. 
    - This only will pull Unit & Point Messages. We have some range & bearing handeling in production. 

# Required Prerequisites
1. ArcGIS Online or ArcGIS Enterprise Account 
2. TAKServer with TCP Port 
3. Machine with SSH configured (Can be the same as the machine running the TAKServer)

## Launch Full Setup Scripts

1. **[Youtube Walkthrough](https://youtu.be/H09OvsmY5X0)** <br />
2. **[Esri-TAK Group](https://arcg.is/1DyOD80)** <br />
3. **[Survey Template](https://survey123.arcgis.com/surveys)** <br />
4. **[Node-Red-Flow](https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration/blob/main/json-flows/One-Flow.json)** <br />


### Ubuntu 24.04 (Does not support Ubuntu 20.04 or 22.04)
#### Step #1 
```bash
cd /tmp && sudo apt install git -y && sudo git clone https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration.git && cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x initial.sh && ./initial.sh && cd /opt/TAK-Esri && ls -la 
```
#### Step #2 
```bash
cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/ubuntu && chmod +x arcgis.sh && systemctl restart csv-download.service --no-pager && ./arcgis.sh && cd /opt/TAK-Esri && ls -la 
```

### Rocky 8 & Rocky 9
#### Step #1
```bash
cd /tmp && sudo dnf install git -y && sudo git clone https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration.git && cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/rpm && chmod +x initial.sh && ./initial.sh && cd /opt/TAK-Esri && ls -la 
```
#### Step #2 
```bash
cd /tmp/TeamAwearnessKit-Esri-Integration/scripts/rpm && chmod +x arcgis.sh && ./arcgis.sh && systemctl restart csv-download.service --no-pager && cd /opt/TAK-Esri && ls -la 
```


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
    - Check that the append.py, push.py, or sign-in.py files contain the correct Enterprise Link, Account Username, and Account Password.
