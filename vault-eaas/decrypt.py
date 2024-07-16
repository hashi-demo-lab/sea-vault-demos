import os
import requests
import json
import base64
import boto3
import logging
from botocore.exceptions import ClientError
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def decrypt_data_key(vault_url, vault_token, key_name, ciphertext):
    """ Call Vault to decrypt the data key. """
    url = f"{vault_url}/v1/transit/decrypt/{key_name}"
    headers = {'X-Vault-Token': vault_token, 'Content-Type': 'application/json'}
    payload = {'ciphertext': ciphertext}
    response = requests.post(url, headers=headers, json=payload, verify=False)  # Change for production
    return response.json()

def download_file_from_s3(s3_bucket_name, s3_file_key, local_file_name):
    """ Download a file from S3 to a local file. """
    s3 = boto3.client('s3')
    try:
        s3.download_file(s3_bucket_name, s3_file_key, local_file_name)
        logger.info("File downloaded successfully from S3.")
    except ClientError as e:
        logger.error(f"An error occurred: {e}")
        raise

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

def upload_file_to_s3(s3_bucket_name, s3_file_key, local_file_path):
    """ Upload a file to S3. """
    s3 = boto3.client('s3')
    try:
        s3.upload_file(local_file_path, s3_bucket_name, s3_file_key)
        logger.info("File uploaded successfully to S3.")
    except ClientError as e:
        logger.error(f"An error occurred: {e}")
        raise

# Configuration from environment variables
vault_url = os.getenv('VAULT_ADDR')
vault_token = os.getenv('VAULT_TOKEN')
key_name = os.getenv('KEY_NAME')
s3_bucket_name = os.getenv('S3_BUCKET_NAME')
s3_file_key = os.getenv('S3_FILE_KEY')
local_encrypted_file_name = 'encrypted_data.json'
local_decrypted_file_name = 'decrypted_data.json'

# Download the encrypted file from S3
download_file_from_s3(s3_bucket_name, s3_file_key, local_encrypted_file_name)

# Load encrypted data
encrypted_data_base64, tag_base64, ciphertext_key = load_encrypted_data(local_encrypted_file_name)
logger.info("Ciphertext Key being used for decryption: " + ciphertext_key)

# Decrypt the data key using Vault
decrypted_key_response = decrypt_data_key(vault_url, vault_token, key_name, ciphertext_key)
if 'data' in decrypted_key_response and 'plaintext' in decrypted_key_response['data']:
    decrypted_data_key = base64.b64decode(decrypted_key_response['data']['plaintext'])
    encrypted_data = base64.b64decode(encrypted_data_base64)
    tag = base64.b64decode(tag_base64)
    iv = b'\x00' * 12  # This should match the IV used during encryption

    # Decrypt the data
    decrypted_data_bytes = decrypt_data(encrypted_data, decrypted_data_key, iv, tag)
    decrypted_data = json.loads(decrypted_data_bytes.decode('utf-8'))

    # Save the decrypted data to a new JSON file
    save_decrypted_data(decrypted_data, local_decrypted_file_name)

    # Upload decrypted file back to S3 under a new key
    decrypted_s3_file_key = s3_file_key.replace('encrypted', 'decrypted')
    upload_file_to_s3(s3_bucket_name, decrypted_s3_file_key, local_decrypted_file_name)

    logger.info("Decryption completed. Data is saved to '" + local_decrypted_file_name + "' and uploaded back to S3.")
else:
    logger.error("Failed to decrypt the data key: " + str(decrypted_key_response.get('errors', 'Unknown error')))
