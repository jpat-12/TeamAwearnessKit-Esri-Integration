import xml.etree.ElementTree as ET
import csv
import re
import time

def parse_cot_messages(xml_content):
    """ Parse COT messages from the given XML content and return a list of dictionaries """
    # Remove multiple XML declarations
    xml_content = re.sub(r'<\?xml.*?\?>', '', xml_content)
    root = ET.fromstring(f"<root>{xml_content}</root>")
    events = root.findall('event')
    messages = []
    for event in reversed(events):  # Reverse the order of events
        uid = event.get('uid')
        if "GT" in uid:
            continue

        point = event.find('point')
        detail = event.find('detail')
        contact = detail.find('contact')
        link = detail.find('link')
        usericon = detail.find('usericon')

        # Extract additional fields if present
        group = detail.find('__group')
        status = detail.find('status')
        takv = detail.find('takv')
        track = detail.find('track')
        uid_droid = detail.find('uid')

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
            'iconpath': usericon.get('iconsetpath') if usericon is not None else '',
            'group_name': group.get('name') if group is not None else '',
            'group_role': group.get('role') if group is not None else '',
            'battery': status.get('battery') if status is not None else '',
            'device': takv.get('device') if takv is not None else '',
            'platform': takv.get('platform') if takv is not None else '',
            'os': takv.get('os') if takv is not None else '',
            'version': takv.get('version') if takv is not None else '',
            'speed': track.get('speed') if track is not None else '',
            'course': track.get('course') if track is not None else '',
            'droid_uid': uid_droid.get('Droid') if uid_droid is not None else ''
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
                  'contactcallsign', 'parent_callsign', 'production_time', 'iconpath',
                  'group_name', 'group_role', 'battery', 'device', 'platform', 'os', 'version', 'speed', 'course', 'droid_uid']
    with open(csv_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for message in messages:
            writer.writerow(message)

def main(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    # Reverse the order of lines
    xml_content = ''.join(reversed(lines))
    
    messages = parse_cot_messages(xml_content)
    unique_messages = remove_duplicates(messages)
    write_csv(unique_messages, output_file)

if __name__ == "__main__":
    input_file = '/var/www/html/cot-logged.txt'
    output_file = '/var/www/html/cot-logged.csv'
    main(input_file, output_file)
    print('parsed')
    time.sleep(4)  # Sleep for 4 seconds before the next iteration