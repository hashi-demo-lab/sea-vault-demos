import json
import random
import string

def generate_random_data(size=1024):
    """Generates a random string of specified size in bytes."""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=size))

def enlarge_json(input_file, output_file, num_entries=1000, entry_size=1024):
    """Enlarges a JSON file by adding more entries."""
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Ensure the 'result' key exists and is a list
    if 'result' not in data or not isinstance(data['result'], list):
        data['result'] = []

    # Add random data to the 'result' array
    for _ in range(num_entries):
        entry = {"data": generate_random_data(entry_size)}
        data['result'].append(entry)

    with open(output_file, 'w') as f:
        json.dump(data, f, indent=2)

# Usage example
input_file = 'input.json'   # Your original JSON file
output_file = 'output.json' # Output JSON file
num_entries = 900000         # Number of new entries to add
entry_size = 4096           # Size of each entry in bytes

enlarge_json(input_file, output_file, num_entries, entry_size)
