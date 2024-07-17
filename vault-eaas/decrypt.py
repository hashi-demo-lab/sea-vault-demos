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
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def decrypt_data_key(VAULT_ADDR, VAULT_TOKEN, KEY_NAME, ciphertext):
    """ Call Vault to decrypt the data key. """
    url = f"{VAULT_ADDR}/v1/transit/decrypt/{KEY_NAME}"
    headers = {'X-Vault-Token': VAULT_TOKEN, 'Content-Type': 'application/json'}
    payload = {'ciphertext': ciphertext}
    response = requests.post(url, headers=headers, json=payload, verify=False)  # Change for production
    if response.status_code == 200:
        logger.info("Vault data key decrypted successfully.")
    else:
        logger.error(f"Failed to decrypt data key: {response.text}")
    return response.json()

def download_file_from_s3(S3_BUCKET_NAME, S3_FILE_KEY, local_file_name):
    """ Download a file from S3 to a local file. """
    s3 = boto3.client('s3')
    try:
        s3.download_file(S3_BUCKET_NAME, S3_FILE_KEY, local_file_name)
        logger.info("File downloaded successfully from S3.")
    except ClientError as e:
        logger.error(f"Failed to download file from S3: {e}")
        raise

def decrypt_data(encrypted_data, key, iv, tag):
    """ Decrypt data using AES GCM. """
    try:
        decryptor = Cipher(algorithms.AES(key), modes.GCM(iv, tag), backend=default_backend()).decryptor()
        decrypted_data = decryptor.update(encrypted_data) + decryptor.finalize()
        logger.info("Data decrypted successfully.")
        return decrypted_data
    except Exception as e:
        logger.error(f"Decryption failed: {str(e)}")
        raise

def save_decrypted_data(data, filepath):
    """ Save decrypted data to a JSON file. """
    try:
        with open(filepath, 'w') as file:
            file.write(data)
        logger.info("Decrypted data saved to file successfully.")
    except Exception as e:
        logger.error(f"Failed to save decrypted data to file: {str(e)}")
        raise

def upload_file_to_s3(S3_BUCKET_NAME, S3_FILE_KEY, local_file_path):
    """ Upload a file to S3. """
    s3 = boto3.client('s3')
    try:
        s3.upload_file(local_file_path, S3_BUCKET_NAME, S3_FILE_KEY)
        logger.info("File uploaded successfully to S3.")
    except ClientError as e:
        logger.error(f"Failed to upload file to S3: {e}")
        raise

# Configuration from environment variables
VAULT_ADDR = os.getenv('VAULT_ADDR')
VAULT_TOKEN = os.getenv('VAULT_TOKEN')
KEY_NAME = os.getenv('KEY_NAME')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
ENCRYPTED_S3_FILE_KEY = os.getenv('ENCRYPTED_S3_FILE_KEY')
DECRYPTED_S3_FILE_KEY = os.getenv('DECRYPTED_S3_FILE_KEY')
LOCAL_FILE_NAME = 'downloaded_encrypted_data.json'
DECRYPTED_FILE_PATH = 'decrypted_data.json'

# Main logic
try:
    download_file_from_s3(S3_BUCKET_NAME, ENCRYPTED_S3_FILE_KEY, LOCAL_FILE_NAME)
    data = json.load(open(LOCAL_FILE_NAME))
    encrypted_data = base64.b64decode(data['encrypted_data'])
    tag = base64.b64decode(data['tag'])

    decrypted_key_response = decrypt_data_key(VAULT_ADDR, VAULT_TOKEN, KEY_NAME, data['ciphertext_key'])
    if 'data' in decrypted_key_response and 'plaintext' in decrypted_key_response['data']:
        decrypted_key = base64.b64decode(decrypted_key_response['data']['plaintext'])
        decrypted_data = decrypt_data(encrypted_data, decrypted_key, b'\x00' * 12, tag)  # IV should be the same as in encryption
        save_decrypted_data(decrypted_data.decode('utf-8'), DECRYPTED_FILE_PATH)
        upload_file_to_s3(S3_BUCKET_NAME, DECRYPTED_S3_FILE_KEY, DECRYPTED_FILE_PATH)
    else:
        logger.error("Failed to decrypt data key.")
except Exception as e:
    logger.error(f"An error occurred: {str(e)}")
