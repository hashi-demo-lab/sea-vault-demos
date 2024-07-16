import os
import requests
import boto3
import json
import base64
import logging
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

# Configure logging more comprehensively
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

logger = logging.getLogger(__name__)

def generate_data_key(VAULT_ADDR, VAULT_TOKEN, KEY_NAME):
    """Generate a data key using Vault's Transit Secrets Engine."""
    url = f"{VAULT_ADDR}/v1/transit/datakey/plaintext/{KEY_NAME}"
    headers = {
        'X-Vault-Token': VAULT_TOKEN,
        'Content-Type': 'application/json'
    }
    response = requests.post(url, headers=headers, verify=False)  # Insecure, change in production
    if response.status_code == 200:
        logger.info("Vault data key generated successfully.")
    else:
        logger.error(f"Failed to generate data key from Vault: {response.text}")
    return response.json()

def encrypt_data(plaintext_data, key):
    """Encrypt data using the generated plaintext key."""
    try:
        key_bytes = base64.b64decode(key)
        iv = b'\x00' * 12  # Initialization vector
        encryptor = Cipher(algorithms.AES(key_bytes), modes.GCM(iv), backend=default_backend()).encryptor()
        encrypted_data = encryptor.update(plaintext_data.encode()) + encryptor.finalize()
        logger.info("Data encrypted successfully.")
        return base64.b64encode(encrypted_data).decode(), base64.b64encode(encryptor.tag).decode()
    except Exception as e:
        logger.error(f"Encryption failed: {str(e)}")
        raise

def download_file_from_s3(S3_BUCKET_NAME, S3_FILE_KEY, LOCAL_FILE_NAME):
    """Download a file from S3 to a local file."""
    s3 = boto3.client('s3')
    try:
        s3.download_file(S3_BUCKET_NAME, S3_FILE_KEY, LOCAL_FILE_NAME)
        logger.info("File downloaded successfully from S3.")
    except ClientError as e:
        logger.error(f"Failed to download file from S3: {e}")
        raise

def save_encrypted_data(encrypted_data, tag, ciphertext_key, filepath):
    """Save encrypted data into a JSON file."""
    try:
        with open(filepath, 'w') as file:
            json.dump({'encrypted_data': encrypted_data, 'tag': tag, 'ciphertext_key': ciphertext_key}, file, indent=4)
        logger.info("Encrypted data saved to file successfully.")
    except Exception as e:
        logger.error(f"Failed to save encrypted data to file: {str(e)}")
        raise

def upload_file_to_s3(S3_BUCKET_NAME, S3_FILE_KEY, LOCAL_FILE_PATH):
    """Upload a file to S3."""
    s3 = boto3.client('s3')
    try:
        s3.upload_file(LOCAL_FILE_PATH, S3_BUCKET_NAME, S3_FILE_KEY)
        logger.info("File uploaded successfully to S3.")
    except ClientError as e:
        logger.error(f"Failed to upload file to S3: {e}")
        raise

# Configuration from environment variables
VAULT_ADDR = os.getenv('VAULT_ADDR')
VAULT_TOKEN = os.getenv('VAULT_TOKEN')
KEY_NAME = os.getenv('KEY_NAME')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
ORIGINAL_S3_FILE_KEY = os.getenv('ORIGINAL_S3_FILE_KEY')
ENCRYPTED_S3_FILE_KEY = os.getenv('ENCRYPTED_S3_FILE_KEY')
LOCAL_FILE_NAME = os.getenv('LOCAL_FILE_NAME')
ENCRYPTED_FILE_PATH = 'encrypted_data.json'  # Filepath to save the encrypted file

# Main logic
try:
    datakey_response = generate_data_key(VAULT_ADDR, VAULT_TOKEN, KEY_NAME)
    if 'data' in datakey_response:
        plaintext_key = datakey_response['data']['plaintext']
        ciphertext_key = datakey_response['data']['ciphertext']

        download_file_from_s3(S3_BUCKET_NAME, ORIGINAL_S3_FILE_KEY, LOCAL_FILE_NAME)
        data = json.load(open(LOCAL_FILE_NAME))
        data_json = json.dumps(data)

        encrypted_data, tag = encrypt_data(data_json, plaintext_key)
        save_encrypted_data(encrypted_data, tag, ciphertext_key, ENCRYPTED_FILE_PATH)
        upload_file_to_s3(S3_BUCKET_NAME, ENCRYPTED_S3_FILE_KEY, ENCRYPTED_FILE_PATH)

    else:
        logger.error(f"Error in data key response from Vault: {datakey_response.get('errors', 'Unknown error')}")
except Exception as e:
    logger.error(f"An error occurred: {str(e)}")