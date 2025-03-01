import json
import random

import time
from datetime import datetime as dt
import logging
import os
import signal
import sys

logging.basicConfig(
    filename="rmg_app.log", 
    filemode="a", 
    format="%(asctime)s - %(name)s - %(levelname)s - %(funcName)s - %(message)s", 
    datefmt="%Y-%m-%d %H:%M:%S",
    level=logging.INFO)

logging.info("#### Starting script ####") # all logging will be logged to app.log
CUR = dt.now()

print(str(CUR), " Starting Cron job") # this will be logged to cron log
MAIN_PID = None

# get full path
def get_full_file_path(file_path):
    try:
        absolute_path = os.path.realpath(file_path)
        logging.info("File path: " + str(absolute_path))
        pass
    except FileNotFoundError:
        logging.error("File not found")
    except Exception as ex:
        logging.error(ex)

# Basic JSON file reading
def read_json_basic(file_path):
    logging.info("Try read json file " + str(file_path))
    try:
        with open(file_path, "r") as file:
            data = json.load(file)
        return data
    except FileNotFoundError:
        logging.error("File not found")
        return None
    except json.JSONDecodeError:
        logging.error(" Invalid JSON format")
        return None
    except Exception as ex:
        logging.error(ex)
        return None


# Update specific values by measurement name
def update_tags_by_measurement(file_path, tag_updates):
    try:
        logging.info("Try read json file " + str(file_path))
        # Read the JSON file
        with open(file_path, "r") as file:
            data = json.load(file)
        
        # Update values for matching measurements
        for item in data:
            measurement = item.get("measurement")
            if measurement in tag_updates:
                # Update all specified fields for this measurement
                for key, value in tag_updates[measurement].items():
                    if key in item:
                        item[key] = value
        
        # Write updated data back to file
        with open(file_path, "w") as file:
            json.dump(data, file, indent=4)
            
        print("JSON file updated successfully!")
        return True
        
    except FileNotFoundError:
        logging.error("File not found")
        return None
    except json.JSONDecodeError:
        logging.error(" Invalid JSON format")
        return None
    except Exception as ex:
        logging.error(ex)
        return False

# Update json values by with random values
def update_tags_random_value(file_path, val):

    # Example 1: Update specific values for tag1 and tag2
    tag_updates = {
        "tag1": {
            "value": val,        # Update value
            "active": 1,         # Update active status
            "quality": "good"     # Update quality
        },
        "tag2": {
            "value": (val+12),         # Update value
            "state": 1,          # Update state
            "quality": "good"    # Keep quality same
        }
    }
    update_tags_by_measurement(file_path, tag_updates)


if __name__ == "__main__":
    fp= "metric.in.json"
    get_full_file_path(fp)
    ran =random.randint(23,150)
    update_tags_random_value(fp, ran)
    rv = read_json_basic(fp)
    print(rv)