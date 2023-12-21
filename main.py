import os
import base64
import io
import json
import gnupg
from datetime import datetime
from google.cloud import secretmanager
from google.cloud import storage

from cloudevents.http import from_http

from flask import Flask, request

def access_secret_version(project_id, secret_id, version_id):
    # Create the Secret Manager client
    client = secretmanager.SecretManagerServiceClient()

    # Build the resource name of the secret version
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"

    # Access the secret version
    response = client.access_secret_version(request={"name": name})

    # Get the secret payload as a string
    secret_data = response.payload.data.decode("UTF-8")

    return secret_data

def read_gcs_file_to_string(bucket_name, source_blob_name):
    # Initialize the GCS client
    storage_client = storage.Client()

    # Get the bucket
    bucket = storage_client.bucket(bucket_name)

    # Get the blob (file) from the bucket
    blob = bucket.blob(source_blob_name)

    # Read the file content as a string
    file_content = blob.download_as_text()

    return file_content

def decrypt_from_gcs(bucket_name, source_blob_name):
    # Read encrypted data from GCS
    encrypted_data = read_gcs_file_to_string(bucket_name, source_blob_name)
    print("Inside Decrypt from GCS")
    print("Encrypted data:")
    # Print the length of encrypted data
    print("Length of encrypted data:", len(encrypted_data))

    # Ensure encrypted_data is bytes
    encrypted_bytes = bytes(encrypted_data, 'utf-8')

    # Decrypt the data
    decrypted_data = gpg.decrypt(encrypted_bytes)
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

app = Flask(__name__)

# Initialize the GnuPG instance
gpg = gnupg.GPG()

# Get private key from Secret Manager
private_key = access_secret_version(
    project_id=os.getenv('SECRET_MANAGER_PROJECT_ID'),
    secret_id=os.getenv('SECRET_MANAGER_SECRET_ID'),
    version_id=os.getenv('SECRET_MANAGER_VERSION_ID')
)
gpg.import_keys(key_data=private_key)

# [START eventarc_http_quickstart_handler]
@app.route("/", methods=["POST"])
def index():
    print("Event received!")
    body = dict(request.json)
    print("Event data:", body)

    source_bucket_name = body.get('bucket', '')
    source_blob_name = body.get('name', '')

    print(f"Processing file: {source_blob_name}")
    print(f"Bucket Name: {source_bucket_name}")

    decrypt_from_gcs(source_bucket_name, source_blob_name)

    storage_client = storage.Client()
    destination_bucket_name = 'ver_dec_file'  # Replace with the actual destination bucket name
    destination_blob_name = f'decrypted/{source_blob_name}'  # Modify as needed for the destination path
    destination_bucket = storage_client.bucket(destination_bucket_name)
    destination_blob = destination_bucket.blob(destination_blob_name)

    with open('/tmp/decrypted_data.txt', 'rb') as f:
        destination_blob.upload_from_file(f)

    return 'OK', 200

if __name__ == "__main__":
    # Run the Flask app
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get('PORT', 8080)))
