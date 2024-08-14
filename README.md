[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jpat)

![TAK-Esri](img/TAK-EsriBreakdown.png?raw=true "TAK-Esri")



# Required Prerequisites
1. ArcGIS Online or ArcGIS Enterprise Account 
2. TAKServer with TCP Port 
3. Machine with SSH configured (Can be the same as the machine running the TAKServer)

## Launch Full Setup Scripts
For Ubuntu (not yet tested on CentOS or Rocky)
```bash
cd /tmp && sudo apt install git && sudo git clone https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration.git && cd TeamAwearnessKit-Esri-Integration && cd scripts && chmod +x ubuntu.sh && cd /opt/TAK-Esri && ls -la 
```


# Survey123 To Team Awearness Kit
1. **[Esri-TAK Group](https://arcg.is/1DyOD80)** <br />
2. **[Survey Template](https://survey123.arcgis.com/surveys)** <br />
3. **[Survey123-Push-Flow](https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration/blob/main/json-flows/Survey123-Push-Flow.json)** <br /><br />



# TAK To Esri Feature Layer
## 1. Team Location
1. **[CoT-Pull-Flow](https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration/blob/main/json-flows/CoT-Pull-Flow.json)** <br />

###  Feature Layer Push Service Restart
```bash
service feature-layer-update restart
```

###  Feature Layer Push Service Log
```bash
journalctl -u feature-layer-update.service 
```

## 2. Dropped Data 
THIS IS IN PRODUCTION - COMING SOON
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br />

# Troubleshooting

## Check Service Logs
### cot-csv
```bash
journalctl -u cot-csv.service
``` 
###  csv-cot
```bash
journalctl -u csv-cot.service
```
### csv-download
```bash
journalctl -u csv-download.service
```
### csv-kml
```bash
journalctl -u csv-kml.service
```



## Restart Services
### cot-csv
```bash
service cot-csv restart
```
### csv-cot
```bash
service csv-cot restart
```
### csv-download 
```bash
service csv-download restart
```
### csv-kml 
```bash
service csv-kml restart
```

