import os
import requests
import boto3
import json
import base64
import logging
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

print("Vault Address:", os.getenv("VAULT_ADDR"))
print("Vault Token:", os.getenv("VAULT_TOKEN"))
print("Key Name:", os.getenv("KEY_NAME"))

def generate_data_key(VAULT_ADDR, VAULT_TOKEN, KEY_NAME):
    """ Generate a data key using Vault's Transit Secrets Engine. """
    url = f"{VAULT_ADDR}/v1/transit/datakey/plaintext/{KEY_NAME}"
    headers = {
        'X-Vault-Token': VAULT_TOKEN,
        'Content-Type': 'application/json'
    }
    response = requests.post(url, headers=headers, verify=False)  # Insecure, change in production
    return response.json()

def encrypt_data(plaintext_data, key):
    """ Encrypt data using the generated plaintext key. """
    key_bytes = base64.b64decode(key)
    iv = b'\x00' * 12  # Initialization vector
    encryptor = Cipher(algorithms.AES(key_bytes), modes.GCM(iv), backend=default_backend()).encryptor()
    encrypted_data = encryptor.update(plaintext_data.encode()) + encryptor.finalize()
    return base64.b64encode(encrypted_data).decode(), base64.b64encode(encryptor.tag).decode()

def download_file_from_s3(S3_BUCKET_NAME, S3_FILE_KEY, LOCAL_FILE_NAME):
    """ Download a file from S3 to a local file. """
    s3 = boto3.client('s3')
    try:
        s3.download_file(S3_BUCKET_NAME, S3_FILE_KEY, LOCAL_FILE_NAME)
        logger.info("File downloaded successfully from S3.")
    except ClientError as e:
        logger.error(f"An error occurred: {e}")
        if e.response['Error']['Code'] == '404':
            logger.error("The object does not exist at this location.")
        else:
            raise

def save_encrypted_data(encrypted_data, tag, ciphertext_key, filepath):
    """ Save encrypted data into a JSON file. """
    with open(filepath, 'w') as file:
        json.dump({'encrypted_data': encrypted_data, 'tag': tag, 'ciphertext_key': ciphertext_key}, file, indent=4)

def upload_file_to_s3(S3_BUCKET_NAME, S3_FILE_KEY, LOCAL_FILE_PATH):
    """ Upload a file to S3. """
    s3 = boto3.client('s3')
    try:
        s3.upload_file(LOCAL_FILE_PATH, S3_BUCKET_NAME, S3_FILE_KEY)
        logger.info("File uploaded successfully to S3.")
    except ClientError as e:
        logger.error(f"An error occurred: {e}")
        raise

# Configuration from environment variables
VAULT_ADDR = os.getenv('VAULT_ADDR')
VAULT_TOKEN = os.getenv('VAULT_TOKEN')
KEY_NAME = os.getenv('KEY_NAME')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
S3_FILE_KEY = os.getenv('S3_FILE_KEY')
LOCAL_FILE_NAME = os.getenv('LOCAL_FILE_NAME')
ENCRYPTED_FILE_PATH = 'encrypted_data.json'  # Filepath to save the encrypted file

# Generate a new data key
datakey_response = generate_data_key(VAULT_ADDR, VAULT_TOKEN, KEY_NAME)
if 'data' in datakey_response:
    plaintext_key = datakey_response['data']['plaintext']
    ciphertext_key = datakey_response['data']['ciphertext']

    # Download and load JSON data
    download_file_from_s3(S3_BUCKET_NAME, S3_FILE_KEY, LOCAL_FILE_NAME)
    data = json.load(open(LOCAL_FILE_NAME))
    data_json = json.dumps(data)

    # Encrypt the data using the plaintext data key
    encrypted_data, tag = encrypt_data(data_json, plaintext_key)

    # Save the encrypted output to a file
    save_encrypted_data(encrypted_data, tag, ciphertext_key, ENCRYPTED_FILE_PATH)
    logger.info("Encrypted data has been saved to 'encrypted_data.json'")

    # Upload encrypted file back to S3
    upload_file_to_s3(S3_BUCKET_NAME, S3_FILE_KEY.replace('.json', '_encrypted.json'), ENCRYPTED_FILE_PATH)

else:
    logger.error("Error generating data key:", datakey_response.get('errors', 'Unknown error'))
