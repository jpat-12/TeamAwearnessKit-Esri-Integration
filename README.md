[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jpat)

## Launch Full Setup Scripts
For Ubuntu (not yet tested on CentOS or Rocky)
```bash
cd /tmp && sudo apt install git && sudo git clone https://github.com/jpat-12/TeamAwearnessKit-Esri-Integration.git && cd TeamAwearnessKit-Esri-Integration && cd scripts && chmod +x ubuntu.sh && cd /opt/TAK-Esri && ls -la 
```


# Survey123 To Team Awearness Kit



# TAK To Esri Feature Layer
## 1. Team Location


## 2. Dropped Data 


# Linux Services

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

