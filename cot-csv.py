import xml.etree.ElementTree as ET
import csv
import re

def parse_cot_messages(xml_content):
    """ Parse COT messages from the given XML content and return a list of dictionaries """
    # Remove multiple XML declarations
    xml_content = re.sub(r'<\?xml.*?\?>', '', xml_content)
    root = ET.fromstring(f"<root>{xml_content}</root>")
    events = root.findall('event')
    messages = []
    for event in events:
        uid = event.get('uid')
        if "GT" in uid:
            continue

        point = event.find('point')
        detail = event.find('detail')
        contact = detail.find('contact')
        link = detail.find('link')
        usericon = detail.find('usericon')

        message = {
            'uid': uid,
            'type': event.get('type'),
            'how': event.get('how'),
            'time': event.get('time'),
            'start': event.get('start'),
            'stale': event.get('stale'),
            'lat': point.get('lat'),
            'long': point.get('lon'),
            'hae': point.get('hae'),
            'ce': point.get('ce'),
            'le': point.get('le'),
            'contactcallsign': contact.get('callsign') if contact is not None else '',
            'parent_callsign': link.get('parent_callsign') if link is not None else '',
            'production_time': link.get('production_time') if link is not None else '',
            'iconpath': usericon.get('iconsetpath') if usericon is not None else ''
        }
        messages.append(message)
    return messages

def remove_duplicates(messages):
    """ Remove duplicate messages based on UID """
    seen_uids = set()
    unique_messages = []
    for message in messages:
        if message['uid'] not in seen_uids:
            unique_messages.append(message)
            seen_uids.add(message['uid'])
    return unique_messages

def write_csv(messages, csv_file):
    """ Write messages to a CSV file """
    fieldnames = ['uid', 'type', 'how', 'time', 'start', 'stale', 'lat', 'long', 'hae', 'ce', 'le',
                  'contactcallsign', 'parent_callsign', 'production_time', 'iconpath']
    with open(csv_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for message in messages:
            writer.writerow(message)

def main(input_file, output_file):
    with open(input_file, 'r') as f:
        xml_content = f.read()
    
    messages = parse_cot_messages(xml_content)
    unique_messages = remove_duplicates(messages)
    write_csv(unique_messages, output_file)

if __name__ == "__main__":
    input_file = 'cot-pulled.txt'
    output_file = 'cot-parsed.csv'
    main(input_file, output_file)
    print('parsed')
