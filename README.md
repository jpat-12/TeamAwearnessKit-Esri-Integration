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

## 1. COT-CSV
### Check Service Logs
```bash
journalctl -u cot-csv.service
```
### Restart Service 
```bash
service cot-csv restart
```

## 2. CSV-COT
### Check Service Logs
```bash
journalctl -u csv-cot.service
```
### Restart Service 
```bash
service csv-cot restart
```
## 3. CSV-Download
### Check Service Logs
```bash
journalctl -u csv-download.service
```
### Restart Service 
```bash
service csv-download restart
```

## 4. CSV-KML
### Check Service Logs
```bash
journalctl -u csv-kml.service
```
### Restart Service 
```bash
service csv-kml restart
```

