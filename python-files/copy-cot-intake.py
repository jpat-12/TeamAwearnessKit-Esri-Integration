import shutil
import os
from datetime import datetime

# Define source and base destination directories
source_file = '/var/www/html/cot-pulled.txt'
base_destination_dir = '/var/www/html/cot-messages-pulled/'

# Get current UTC date and time
current_utc_time = datetime.utcnow()
date_folder = current_utc_time.strftime('%d-%B-%Y')
formatted_time = current_utc_time.strftime('%H:%M:%S')

# Create destination directory path for the current day
destination_dir = os.path.join(base_destination_dir, date_folder)
os.makedirs(destination_dir, exist_ok=True)

# Create destination file path
destination_file = os.path.join(destination_dir, f'cot-messages-pulled-{formatted_time}.txt')

# Copy the file
shutil.copy2(source_file, destination_file)

print(f'File copied to {destination_file}')
