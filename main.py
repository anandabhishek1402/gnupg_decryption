import os
import base64
import io
import json
import gnupg
from datetime import datetime
from google.cloud import secretmanager
from google.cloud import storage
from google.cloud import kms

from cloudevents.http import from_http

from flask import Flask, request

def decrypt_key(project_id, location, keyring_id, key_id, ciphertext):
    client = kms.KeyManagementServiceClient()
    name = f"projects/{project_id}/locations/{location}/keyRings/{keyring_id}/cryptoKeys/{key_id}"
    response = client.decrypt(name=name, ciphertext=ciphertext)
    return response.plaintext


def access_secret_version(project_id, secret_id, version_id):
    try:
        # Access the secret version
        client = secretmanager.SecretManagerServiceClient()
    
        # Build the resource name of the secret version
        name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"

        response = client.access_secret_version(request={"name": name})

        # Get the secret payload as a string
        # secret_data = response.payload.data.decode("UTF-8")
        #print({"Secret Data :{}".format(secret_data)})
        return response.payload.data
        
    except Exception as e:
        print(f"Error accessing secret version: {e}")
        return None
        
# def access_secret_version1(project_id, secret_id, version_id):
#     try:
#         # Access the secret version
#         client = secretmanager.SecretManagerServiceClient()
    
#         # Build the resource name of the secret version
#         name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"

#         response = client.access_secret_version(request={"name": name})

#         # Get the secret payload as a string
#         secret_data = response.payload.data.decode("UTF-8")
#         print({"Secret Data :{}".format(secret_data)})
#         return secret_data
        
#     except Exception as e:
#         print(f"Error during accessing secret key from secret manager: {e}")
#         return None
        
def read_gcs_file_to_string(bucket_name, source_blob_name):
    try:
        # Initialize the GCS client
        storage_client = storage.Client()

        # Get the bucket
        bucket = storage_client.bucket(bucket_name)

        # Get the blob (file) from the bucket
        blob = bucket.blob(source_blob_name)

        # Read the file content as a string
        file_content = blob.download_as_text()

        return file_content
    
    except Exception as e:
        print(f"Error reading GCS file: {e}")
        return None

def decrypt_from_gcs(bucket_name, source_blob_name):
    try:
        # Read encrypted data from GCS
        encrypted_data = read_gcs_file_to_string(bucket_name, source_blob_name)
        print("Inside Decrypt from GCS")
        print("Encrypted data:")
        # Print the length of encrypted data
        print("Length of encrypted data:", len(encrypted_data))

        # Ensure encrypted_data is bytes
        # encrypted_bytes = bytes(encrypted_data, 'utf-8')
        #pp = os.getenv(os.getenv("PASPPHRASE_SECRET_ID"))  # Use environment variable for passphrase
        pp1 = access_secret_version(
            os.getenv("PROJECT_ID"),
            os.getenv("PASPPHRASE_SECRET_ID"),
            "latest"
            )
        pp = decrypt_key(os.getenv("PROJECT_ID"), "global", "gnupg_passphrase", "clidemo", pp1)
        print("Passphrase: {}".format(pp))
        # Decrypt the data
        # decrypted_data = gpg.decrypt(encrypted_bytes, passphrase=pp)
        decrypted_data = gpg.decrypt(encrypted_data, passphrase=pp)
        print("Decrypted Data")
        print(decrypted_data)
        # Check if the decryption was successful
        if not decrypted_data.ok:
            print("Decryption failed:", decrypted_data.status)
            return None

        # Write the decrypted data to a file
        with open('/tmp/decrypted_data.txt', 'wb') as f:
            f.write(decrypted_data.data)

        print("Decrypted data written to /tmp/decrypted_data.txt")
    except Exception as e:
        print(f"Error during decryption from GCS: {e}")
        return None

def upload_decrypted_to_gcs(destination_bucket, source_blob_name):
    try:
        storage_client = storage.Client()
        destination_bucket_name = destination_bucket  # Use environment variable for destination bucket
        destination_blob_name = f'decrypted/{source_blob_name}'  # Modify as needed for the destination path
        destination_bucket = storage_client.bucket(destination_bucket_name)
        destination_blob = destination_bucket.blob(destination_blob_name)
    
        with open('/tmp/decrypted_data.txt', 'rb') as f:
            destination_blob.upload_from_file(f)
    
        return 'OK', 200
    except Exception as e:
        print(f"Error during uploading decrypted file to GCS: {e}")
    

app = Flask(__name__)

# Set up GnuPG instance
gpg = gnupg.GPG()
encrypted_private_key = access_secret_version(
    os.getenv("PROJECT_ID"),
    os.getenv("GPG_SECRET_ID"),
    "latest"
)
# decoded_key = base64.b64decode(encrypted_private_key)
private_key = decrypt_key(os.getenv("PROJECT_ID"), "global", "gnupg_passphrase", "clidemo", encrypted_private_key)
gpg.import_keys(key_data=private_key)
@app.route("/", methods=["POST"])
def index():
    try:
        print("Event received!")
        body = dict(request.json)
        print("Event data:", body)

        source_bucket_name = body.get('bucket', '')
        source_blob_name = body.get('name', '')

        print(f"Processing file: {source_blob_name}")
        print(f"Bucket Name: {source_bucket_name}")

        decrypt_from_gcs(source_bucket_name, source_blob_name)
        upload_decrypted_to_gcs(os.getenv("DESTINATION_BUCKET"), source_blob_name )
        return 'OK', 200
        
    except Exception as e:
        print(f"Error during request handling: {e}")
        return 'Internal Server Error', 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)
