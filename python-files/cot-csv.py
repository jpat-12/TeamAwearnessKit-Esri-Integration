import xml.etree.ElementTree as ET
import csv
import re
import time

def parse_cot_messages(file_path):
    """ Parse COT messages from the given file and return a list of dictionaries """
    messages = []
    with open(file_path, 'r') as f:
        content = f.read()
        # Split the content into individual event strings
        event_strings = re.findall(r'<event.*?</event>', content, re.DOTALL)

    for event_string in reversed(event_strings):  # Process events from bottom to top
        try:
            event = ET.fromstring(event_string)
            uid = event.get('uid')
            if "GT" in uid:
                continue

            point = event.find('point')
            detail = event.find('detail')
            contact = detail.find('contact') if detail is not None else None
            link = detail.find('link') if detail is not None else None
            usericon = detail.find('usericon') if detail is not None else None

            # Extract additional fields if present
            group = detail.find('__group') if detail is not None else None
            status = detail.find('status') if detail is not None else None
            takv = detail.find('takv') if detail is not None else None
            track = detail.find('track') if detail is not None else None
            uid_droid = detail.find('uid') if detail is not None else None

            message = {
                'uid': uid,
                'type': event.get('type'),
                'how': event.get('how'),
                'time': event.get('time'),
                'start': event.get('start'),
                'stale': event.get('stale'),
                'lat': point.get('lat') if point is not None else '',
                'long': point.get('lon') if point is not None else '',
                'hae': point.get('hae') if point is not None else '',
                'ce': point.get('ce') if point is not None else '',
                'le': point.get('le') if point is not None else '',
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
        except ET.ParseError:
            print(f"Skipping malformed XML: {event_string[:100]}...")  # Print first 100 chars of problematic XML
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
    messages = parse_cot_messages(input_file)
    unique_messages = remove_duplicates(messages)
    write_csv(unique_messages, output_file)

if __name__ == "__main__":
    input_file = '/var/www/html/cot-logged.txt'
    output_file = '/var/www/html/cot-logged.csv'
    main(input_file, output_file)
    print('parsed')
    time.sleep(4)  # Sleep for 4 seconds before the next iteration