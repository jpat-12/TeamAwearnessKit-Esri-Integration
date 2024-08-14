import csv
import xml.etree.ElementTree as ET
import time

def extract_lat_long(shape_str):
    """Extract latitude and longitude from the 'geometry' field."""
    try:
        # Extract the coordinates from the 'POINT (lon lat)' format
        coords = shape_str.replace("POINT (", "").replace(")", "").split()
        lon, lat = coords[0], coords[1]
    except (IndexError, ValueError):
        lat, lon = '0', '0'
    return lat, lon

def get_icon_path(waypoint_type):
    """Get the icon URL path for the given waypoint type."""
    icon_paths = {
        "Area Command": "",
        "CAP Unit Position update": "https://github.com/jpat-12/Incident-Icons/blob/main/CAP%20Asset%20Report.png?raw=true",
        "Clue Location": "https://github.com/jpat-12/Incident-Icons/blob/main/CLUE.png?raw=true",
        "ELT Signal": "https://github.com/jpat-12/Incident-Icons/blob/main/ELT.png?raw=true",
        "Flood/Water Level (HWM)": "https://github.com/jpat-12/Incident-Icons/blob/main/Flood.png?raw=true",
        "Hazard, Animal": "https://github.com/jpat-12/Incident-Icons/blob/main/Animal.png?raw=true",
        "Hazard, Electrical": "https://github.com/jpat-12/Incident-Icons/blob/main/Electrical.png?raw=true",
        "Hazard, Fire": "https://github.com/jpat-12/Incident-Icons/blob/main/Fire.png?raw=true",
        "Hazard, Haz Materials": "https://github.com/jpat-12/Incident-Icons/blob/main/Hazard,%20Haz%20Materials.png?raw=true",
        "Hazard, Other": "https://github.com/jpat-12/Incident-Icons/blob/main/Hazard,%20Other.png?raw=true",
        "Helicopter Landing Zone": "https://github.com/jpat-12/Incident-Icons/blob/main/LZHeli.png?raw=true",
        "Incident Command Post": "https://github.com/jpat-12/Incident-Icons/blob/main/Incident%20Command%20Post.png?raw=true",
        "Initial Planning Point": "https://github.com/jpat-12/Incident-Icons/blob/main/Initial%20Planning%20Point.png?raw=true",
        "Initial Planning Point (PLS, LKP)": "https://github.com/jpat-12/Incident-Icons/blob/main/Initial%20Planning%20Point.png?raw=true",
        "Medical Station": "https://github.com/jpat-12/Incident-Icons/blob/main/Medical.png?raw=true",
        "Placeholder Other": "https://github.com/jpat-12/Incident-Icons/blob/main/Placeholder%20Other.png?raw=true",
        "Plane Crash": "https://github.com/jpat-12/Incident-Icons/blob/main/PlaneCrash.png?raw=true",
        "PLT/PLB Signal": "https://github.com/jpat-12/Incident-Icons/blob/main/PLT.png?raw=true",
        "Staging": "https://github.com/jpat-12/Incident-Icons/blob/main/Staging.png?raw=true",
        "Structure, Damaged": "https://github.com/jpat-12/Incident-Icons/blob/main/Structure,%20Damaged.png?raw=true",
        "Structure, Destroyed": "https://github.com/jpat-12/Incident-Icons/blob/main/Destroyed.png?raw=true",
        "Structure, Failed": "https://github.com/jpat-12/Incident-Icons/blob/main/Structure,%20Failed.png?raw=true",
        "Structure, No Damage": "https://github.com/jpat-12/Incident-Icons/blob/main/NoDamage.png?raw=true",
        "Transportation, Route Block": "https://github.com/jpat-12/Incident-Icons/blob/main/Transportation,%20Route%20Block.png?raw=true"
    }
    return icon_paths.get(waypoint_type, "https://github.com/jpat-12/Incident-Icons/blob/main/Placeholder%20Other.png?raw=true")

def create_kml_placemark(data):
    """Create a KML placemark element from CSV data."""
    placemark = ET.Element("Placemark")
    placemark.set("id", str(data['objectid']))

    name = ET.SubElement(placemark, "name")
    name.text = f"{data['team_callsign']}"

    styleUrl = ET.SubElement(placemark, "styleUrl")
    styleUrl.text = f"#{data['select_a_waypoint_of_what_you_a'].replace(' ', '_')}"

    extendedData = ET.SubElement(placemark, "ExtendedData")
    for key, value in data.items():
        if key == 'geometry':
            continue
        data_elem = ET.SubElement(extendedData, "Data")
        data_elem.set("name", key)
        value_elem = ET.SubElement(data_elem, "value")
        value_elem.text = str(value)

    point = ET.SubElement(placemark, "Point")
    shape_value = data.get("geometry", "")
    lat, lon = extract_lat_long(shape_value)
    coordinates = ET.SubElement(point, "coordinates")
    coordinates.text = f"{lon},{lat},0.0"

    return placemark

def create_kml_style(waypoint_type, icon_url):
    """Create a KML style element for the given waypoint type."""
    style = ET.Element("Style")
    style.set("id", waypoint_type.replace(' ', '_'))

    iconStyle = ET.SubElement(style, "IconStyle")
    colorMode = ET.SubElement(iconStyle, "colorMode")
    colorMode.text = "normal"
    scale = ET.SubElement(iconStyle, "scale")
    scale.text = "1"
    heading = ET.SubElement(iconStyle, "heading")
    heading.text = "0"
    icon = ET.SubElement(iconStyle, "Icon")
    href = ET.SubElement(icon, "href")
    href.text = icon_url

    return style

def parse_csv_and_create_kml(csv_file_path, output_file_path):
    """Parse a CSV file and create a KML file."""
    kml = ET.Element("kml", xmlns="http://www.opengis.net/kml/2.2", xmlns_gx="http://www.google.com/kml/ext/2.2")
    document = ET.SubElement(kml, "Document")
    document.set("id", "1")

    waypoint_types = set()

    with open(csv_file_path, mode='r') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            #print(f"Processing row: {row.keys()}")  # Debugging line to print the keys of each row
            waypoint_type = row['select_a_waypoint_of_what_you_a']
            waypoint_types.add(waypoint_type)
            placemark = create_kml_placemark(row)
            document.append(placemark)

    for waypoint_type in waypoint_types:
        icon_url = get_icon_path(waypoint_type)
        style = create_kml_style(waypoint_type, icon_url)
        document.append(style)

    tree = ET.ElementTree(kml)
    tree.write(output_file_path, encoding='utf-8', xml_declaration=True)

# Pull CSV from 'survey.csv' and write to 'survey123.kml'
parse_csv_and_create_kml('survey.csv', '/var/www/html/survey123.kml')

# Continuously update KML file
while True:
    parse_csv_and_create_kml('survey.csv', '/var/www/html/survey123.kml')
    print('parsed')
    time.sleep(5)

