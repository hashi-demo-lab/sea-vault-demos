import os
import requests
import json
import base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

def generate_data_key(vault_addr, vault_token, key_name):
    """ Generate a data key using Vault's Transit Secrets Engine. """
    url = f"{vault_addr}/v1/transit/datakey/plaintext/{key_name}"
    headers = {
        'X-Vault-Token': vault_token,
        'Content-Type': 'application/json'
    }
    response = requests.post(url, headers=headers, verify=False)  # Change verify path or set True for production
    return response.json()

def encrypt_data(plaintext_data, key):
    """ Encrypt data using the generated plaintext key. """
    key_bytes = base64.b64decode(key)
    iv = b'\x00' * 12  # Initialization vector
    encryptor = Cipher(
        algorithms.AES(key_bytes),
        modes.GCM(iv),
        backend=default_backend()
    ).encryptor()

    encrypted_data = encryptor.update(plaintext_data.encode()) + encryptor.finalize()
    return base64.b64encode(encrypted_data).decode(), base64.b64encode(encryptor.tag).decode()

def read_json_file(filepath):
    """ Read JSON data from a file. """
    with open(filepath, 'r') as file:
        return json.load(file)

def save_encrypted_data(encrypted_data, tag, ciphertext_key, filepath):
    """ Save encrypted data into a JSON file. """
    with open(filepath, 'w') as file:
        json.dump({
            'encrypted_data': encrypted_data,
            'tag': tag,
            'ciphertext_key': ciphertext_key
        }, file, indent=4)

# Configuration
vault_addr = os.getenv('VAULT_ADDR') # Vault server
vault_token = os.getenv('VAULT_TOKEN') # Vault token with permissions to access the transit secrets engine
key_name = os.getenv('KEY_NAME') # Name of the Vault encryption key

# Generate a new data key
datakey_response = generate_data_key(vault_addr, vault_token, key_name)
if 'data' in datakey_response:
    plaintext_key = datakey_response['data']['plaintext']
    ciphertext_key = datakey_response['data']['ciphertext']

    # Load JSON data
    data = read_json_file('original_data.json')  # Ensure this file path is correct
    data_json = json.dumps(data)

    # Encrypt the data using the plaintext data key
    encrypted_data, tag = encrypt_data(data_json, plaintext_key)

    # Save the encrypted output to a file
    save_encrypted_data(encrypted_data, tag, ciphertext_key, 'encrypted_data.json')
    print("Encrypted data has been saved to 'encrypted_data.json'")
else:
    print("Error generating data key:", datakey_response.get('errors', 'Unknown error'))