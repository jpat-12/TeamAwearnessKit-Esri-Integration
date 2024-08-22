import csv
import time
from datetime import datetime, timezone, timedelta

def extract_lat_long(point_str):
    point_str = point_str.replace("POINT (", "").replace(")", "")
    lon, lat = point_str.split()
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

#def create_cot_event(data):
#    lat, lon = extract_lat_long(data["geometry"])
#    icon_path = get_icon_path(data['select_a_waypoint_of_what_you_a'])
#    remarks = f"Mission Number: {data['mission_number']}, Sortie Number: {data['sortie_number']}, Team Leader Name: {data['team_leader_name']}, Team Leader CAPID: {data['team_leader_capid']}, Callsign: {data['team_callsign']}, Latitude: {lat}, Longitude: {lon}, TimeSubmitted: {datetime.fromtimestamp(int(data['CreationDate']) / 1000, timezone.utc).strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}, ObjectID: {data['objectid']}"
#
#    current_time = datetime.now(timezone.utc)
#    start_time = current_time
#    stale_time = start_time + timedelta(minutes=5)  # Ensure timedelta is correctly imported
#
#    event_time_str = start_time.strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + "Z"
#    stale_time_str = stale_time.strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + "Z"
#
#    #V1 event = f'<event version="2.0" uid="{data["team_callsign"]}_{data["objectid"]}"  type="a-h-G" time="{event_time_str}" start="{event_time_str}" stale="{stale_time_str}" how="m-g"><point lat="{lat}" lon="{lon}" hae="0" ce="10.0" le="2.0" /><detail><UID Droid="{data["team_callsign"],datetime.fromtimestamp(int(data['CreationDate']) / 1000, timezone.utc).strftime('%Y-%m-%d %H:%M:%S.%f')[:-3] }" /><usericon iconsetpath="{icon_path}" /><remarks>{remarks}</remarks><contact callsign="{data["team_callsign"]}" /><track speed="0" course="0" /></detail></event>'
#    event = f'<event version="2.0" uid="Survey123_{data["objectid"]}"  type="a-h-G" time="{event_time_str}" start="{event_time_str}" stale="{stale_time_str}" how="m-g"><point lat="{lat}" lon="{lon}" hae="0" ce="10.0" le="2.0" /><detail><UID Droid="Survey123_{data["team_callsign"]} {datetime.fromtimestamp(int(data['CreationDate']) / 1000, timezone.utc).strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}," /><usericon iconsetpath="{icon_path}" /><remarks>{remarks}</remarks><contact callsign="{data["team_callsign"]}" /><track speed="0" course="0" /></detail></event>'
#    #V2event = f'<event version="2.0" uid="Survey123_{data["objectid"]}"  type="a-h-G" time="{event_time_str}" start="{event_time_str}" stale="{stale_time_str}" how="m-g"><point lat="{lat}" lon="{lon}" hae="0" ce="10.0" le="2.0" /><detail><UID Droid="Survey123_{data["team_callsign"],datetime.fromtimestamp(int(data['CreationDate']) / 1000, timezone.utc).strftime('%Y-%m-%d %H:%M:%S.%f')[:-3] }" /><usericon iconsetpath="{icon_path}" /><remarks>{remarks}</remarks><contact callsign="{data["team_callsign"]}" /><track speed="0" course="0" /></detail></event>'
#    return event

def create_cot_event(data):
    lat, lon = extract_lat_long(data["geometry"])
    icon_path = get_icon_path(data['select_a_waypoint_of_what_you_a'])
    remarks = (f"Mission Number: {data['mission_number']}, Sortie Number: {data['sortie_number']}, "
               f"Team Leader Name: {data['team_leader_name']}, Team Leader CAPID: {data['team_leader_capid']}, "
               f"Callsign: {data['team_callsign']}, Latitude: {lat}, Longitude: {lon}, "
               f"TimeSubmitted: {datetime.fromtimestamp(int(data['CreationDate']) / 1000, timezone.utc).strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}, "
               f"ObjectID: {data['objectid']}")

    current_time = datetime.now(timezone.utc)
    start_time = current_time
    stale_time = start_time + timedelta(minutes=5)

    event_time_str = start_time.strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + "Z"
    stale_time_str = stale_time.strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + "Z"

    event = (f'<event version="2.0" uid="Survey123_{data["objectid"]}"  type="a-h-G" time="{event_time_str}" '
             f'start="{event_time_str}" stale="{stale_time_str}" how="m-g">'
             f'<point lat="{lat}" lon="{lon}" hae="0" ce="10.0" le="2.0" />'
             f'<detail><UID Droid="Survey123_{data["team_callsign"]} {datetime.fromtimestamp(int(data["CreationDate"]) / 1000, timezone.utc).strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]}",'
             f' /><usericon iconsetpath="{icon_path}" /><remarks>{remarks}</remarks>'
             f'<contact callsign="{data["team_callsign"]}" /><track speed="0" course="0" /></detail></event>')
    
    return event


def parse_csv_and_create_cot(csv_file_path, output_file_path):
    events = []
    with open(csv_file_path, mode='r') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            event = create_cot_event(row)
            events.append(event)

    with open(output_file_path, 'w') as file:
        for event in events:
            file.write(event + '\n')

parse_csv_and_create_cot('survey.csv', '/var/www/html/survey-cot.txt')

