import json
import random

# Basic JSON file reading
def read_json_basic(file_path):
    try:
        with open(file_path, 'r') as file:
            data = json.load(file)
        return data
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        return None
    except json.JSONDecodeError:
        print("Error: Invalid JSON format")
        return None
    except Exception as e:
        print(f"Error: {str(e)}")
        return None


# Update specific values by measurement name
def update_tags_by_measurement(file_path, tag_updates):
    try:
        # Read the JSON file
        with open(file_path, 'r') as file:
            data = json.load(file)
        
        # Update values for matching measurements
        for item in data:
            measurement = item.get('measurement')
            if measurement in tag_updates:
                # Update all specified fields for this measurement
                for key, value in tag_updates[measurement].items():
                    if key in item:
                        item[key] = value
        
        # Write updated data back to file
        with open(file_path, 'w') as file:
            json.dump(data, file, indent=4)
            
        print("JSON file updated successfully!")
        return True
        
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        return False
    except json.JSONDecodeError:
        print("Error: Invalid JSON format")
        return False
    except Exception as e:
        print(f"Error: {str(e)}")
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
    rv = read_json_basic(fp)
    print(rv)
    ran =random.randint(23,150)
    update_tags_random_value(fp, ran)