[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jpat)

![TAK-Esri](img/'TAK-Esri Breakdown.png?raw=true' "TAK-Esri")



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
**[Esri-TAK Group](https://arcg.is/1DyOD80)** <br /><br />
**[Survey123 Template](https://survey123.arcgis.com/surveys)** <br /><br />


# TAK To Esri Feature Layer
## 1. Team Location


## 2. Dropped Data 


# Services Commands

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

