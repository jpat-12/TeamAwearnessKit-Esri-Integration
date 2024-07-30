import csv
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
import json
import time

def extract_lat_long(shape_str):
    try:
        lat_long_dict = json.loads(shape_str.replace("'", '"'))
        lat = str(lat_long_dict.get('y', '0'))
        lon = str(lat_long_dict.get('x', '0'))
    except json.JSONDecodeError:
        lat, lon = '0', '0'
    return lat, lon

def get_icon_path(waypoint_type):
    icon_paths = {
        "Area Command": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Area Command Post.png",
        "CAP Unit Position update": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/CAP Asset Report.png",
        "Clue Location": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/CLUE.png",
        "ELT Signal": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/ELT Signal.png",
        "Flood/Water Level (HWM)": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Flood.png",
        "Hazard, Animal": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Animal.png",
        "Hazard, Electrical": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Electrical.png",
        "Hazard, Fire": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Fire.png",
        "Hazard, Haz Materials": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Hazard, Haz Materials.png",
        "Hazard, Other": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Hazard, Other.png",
        "Helicopter Landing Zone": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Helicopter Landing Zone.png",
        "Incident Command Post": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Incident Command Post.png",
        "Initial Planning Point": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Initial Planning Point.png",
        "Initial Planning Point (PLS, LKP)": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Initial Planning Point.png",
        "Medical Station": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/EMS.png",
        "Placeholder Other": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Placeholder Other.png",
        "Plane Crash": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Crash Site.png",
        "PLT/PLB Signal": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/PLT Signal.png",
        "Staging": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Staging Area.png",
        "Structure, Damaged": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Structure, Damaged.png",
        "Structure, Destroyed": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Structure, Destroyed.png",
        "Structure, Failed": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Structure, Failed.png",
        "Structure, No Damage": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Structure, No-Damage.png",
        "Transportation, Route Block": "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Transportation, Route Block.png"
    }
    return icon_paths.get(waypoint_type, "412c43f948b1664a3a0b513336b6c32382b13289a6ed2e91dd31e23d9d52a683/Incident Icons/Placeholder Other.png")

def create_cot_message(data):
    event = ET.Element("event")
    event.set("version", "2.0")
    event.set("uid", f"{data['team_callsign']}_{data['objectid']}")
    
    if data.get('select_a_waypoint_of_what_you_a') in ["Plane Crash", "Structure, Destroyed", "Flood/Water Level (HWM)"]:
        event.set("type", "a-f-G-U-C")
    else:
        event.set("type", "a-h-G")
    event.set("time", (datetime.utcnow()).strftime("%Y-%m-%dT%H:%M:%S.%fZ")[:-3] + "Z")
    event.set("start", (datetime.utcnow()).strftime("%Y-%m-%dT%H:%M:%S.%fZ")[:-3] + "Z")
    event.set("stale", (datetime.utcnow() + timedelta(minutes=5)).strftime("%Y-%m-%dT%H:%M:%S.%fZ")[:-3] + "Z")
    if data.get('select_a_waypoint_of_what_you_a') in ["Plane Crash", "Structure, Destroyed", "Flood/Water Level (HWM)"]:
        event.set("how", "a-f-G-U-C")
    else:
        event.set("how", "a-h-G")

    point = ET.SubElement(event, "point")
    lat, lon = extract_lat_long(data["SHAPE"])
    point.set("lat", lat)
    point.set("lon", lon)
    point.set("hae", "0")
    point.set("ce", "10.0")
    point.set("le", "2.0")

    detail = ET.SubElement(event, "detail")

    uid = ET.SubElement(detail, "UID")
    uid.set("Droid", f"{data['team_callsign']}")

    usericon = ET.SubElement(detail, "usericon")
    icon_path = get_icon_path(data["select_a_waypoint_of_what_you_a"])
    usericon.set("iconsetpath", icon_path)

    remarks = ET.SubElement(detail, "remarks")
    remarks.text = f"Mission Number: {data['mission_number']}, Sortie Number: {data['sortie_number']}, Team Leader Name: {data['team_leader_name']}, Team Leader CAPID: {data['team_leader_capid']}, Callsign: {data['team_callsign']}, Latitude: {lat}, Longitude: {lon}, TimeSubmitted: {data['CreationDate']}, ObjectID: {data['objectid']}"

    contact = ET.SubElement(detail, "contact")
    contact.set("callsign", f"{data['team_callsign'], data['select_a_waypoint_of_what_you_a']}")

    track = ET.SubElement(detail, "track")
    track.set("speed", "0")
    track.set("course", "0")

    return ET.tostring(event, encoding='unicode', method='xml')

def parse_csv_and_create_cot(csv_file_path, output_file_path):
    with open(csv_file_path, mode='r') as file, open(output_file_path, mode='w') as output_file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            cot_message = create_cot_message(row)
            output_file.write(cot_message + "\n")

# Pull CSV from 'survey.csv' and write to '/var/www/html/cot.txt'
parse_csv_and_create_cot('survey.csv', 'cot.txt')

while True: 
    parse_csv_and_create_cot('survey.csv', '/var/www/html/cot.txt')
    print('parsed')
    time.sleep(5)
