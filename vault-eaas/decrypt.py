import requests
import json
import base64
import sys
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

def decrypt_data_key(vault_url, vault_token, key_name, ciphertext):
    """ Call Vault to decrypt the data key. """
    url = f"{vault_url}/v1/transit/decrypt/{key_name}"
    headers = {'X-Vault-Token': vault_token, 'Content-Type': 'application/json'}
    payload = {'ciphertext': ciphertext}
    response = requests.post(url, headers=headers, json=payload, verify="../vault-in-kubernetes/cert/kubernetes_ca.crt")
    return response.json()

def load_encrypted_data(filepath):
    """ Load encrypted data from a JSON file. """
    with open(filepath, 'r') as file:
        data = json.load(file)
    return data['encrypted_data'], data['tag'], data['ciphertext_key']

def decrypt_data(encrypted_data, key, iv, tag):
    """ Decrypt data using AES GCM. """
    decryptor = Cipher(
        algorithms.AES(key),
        modes.GCM(iv, tag),
        backend=default_backend()
    ).decryptor()
    return decryptor.update(encrypted_data) + decryptor.finalize()

def save_decrypted_data(data, filepath):
    """ Save decrypted data to a JSON file. """
    with open(filepath, 'w') as file:
        json.dump(data, file, indent=4)

if len(sys.argv) != 2:
    print("Usage: python3 decrypt.py <path_to_encrypted_data_json>")
    sys.exit(1)

input_file = sys.argv[1]
encrypted_data_base64, tag_base64, ciphertext_key = load_encrypted_data(input_file)
print("Ciphertext Key being used for decryption:", ciphertext_key)  # Print the ciphertext key

# Configuration for Vault
vault_url = 'https://vault-dc1.hashibank.com:443'
vault_token = ''
key_name = 'my_key'

# Decrypt the data key using Vault
decrypted_key_response = decrypt_data_key(vault_url, vault_token, key_name, ciphertext_key)
if 'data' in decrypted_key_response and 'plaintext' in decrypted_key_response['data']:
    decrypted_data_key = base64.b64decode(decrypted_key_response['data']['plaintext'])
    print("Decrypted Data Key (Base64):", decrypted_key_response['data']['plaintext'])  # Print the plaintext key

    encrypted_data = base64.b64decode(encrypted_data_base64)
    tag = base64.b64decode(tag_base64)
    iv = b'\x00' * 12  # This should match the IV used during encryption

    # Decrypt the data
    decrypted_data_bytes = decrypt_data(encrypted_data, decrypted_data_key, iv, tag)
    decrypted_data = json.loads(decrypted_data_bytes.decode('utf-8'))

    # Save the decrypted data to a new JSON file
    save_decrypted_data(decrypted_data, 'decrypted_data.json')
    print("Decryption completed. Data is saved to 'decrypted_data.json'.")
else:
    print("Failed to decrypt the data key:", decrypted_key_response.get('errors', 'Unknown error'))
