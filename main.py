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
    #client = secretmanager_v1.SecretManagerServiceClient()

    # Build the resource name of the secret version
    name = f"projects/mm-etl-poc/secrets/gnupg-pvt/versions/latest"

    # Access the secret version
    response = client.access_secret_version(request={"name": name})

    # Get the secret payload as a string
    secret_data = response.payload.data.decode("UTF-8")

    return secret_data


def read_gcs_file_to_string(bucket_name, source_blob_name):
    # Initialize the GCS client
    storage_client = storage.Client(project='mm-etl-poc')

    # Get the bucket
    bucket = storage_client.bucket(bucket_name)

    # Get the blob (file) from the bucket
    blob = bucket.blob(source_blob_name)

    # Read the file content as a string
    file_content = blob.download_as_text()

    return file_content

def decrypt_from_gcs(bucket_name, source_blob_name):
    encrypted_data = read_gcs_file_to_string(bucket_name, source_blob_name)
    print("Inside Decrypt from GCS")
    print("Encrypted data:")
    # Print the length of encrypted data
    print("Length of encrypted data:", len(encrypted_data))

    # Ensure encrypted_data is bytes
    encrypted_bytes = bytes(encrypted_data, 'utf-8')

    # Decrypt the data
    decrypted_data = gpg.decrypt(encrypted_bytes)#, passphrase='Fossil.4')
    print("Decruptted Data")
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
# [END eventarc_audit_storage_server]
# [END eventarc_http_quickstart_server]
# app = Flask(__name__)
# Initialize the GnuPG instance
gpg = gnupg.GPG()
# get private key from secret manager
private_key = access_secret_version(project_id='mm-etl-poc', secret_id='gnupg-pvt', version_id='latest')
gpg.import_keys(key_data=private_key)
# trusting imported key is important, or it will return an empty string as encrypted data
#gpg.trust_keys(fingerprints="81B7D836220A71C731DADAEF44803D875F3CFB84", trustlevel='TRUST_ULTIMATE')
# set recipient which is required to decrypt
#recipient = 'abhishekanand.78@hotmail.com'
print("Private Key")
#print(private_key)

# [START eventarc_http_quickstart_handler]
# [START eventarc_audit_storage_handler]
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


    # upload_stringio_to_gcs(destination_bucket_name, destination_blob_name_with_timestamp, str(decrypted_data))
    storage_client = storage.Client()
    destination_bucket_name = 'ver_dec_file'  # Replace with the actual destination bucket name
    destination_blob_name = f'decrypted/{source_blob_name}'  # Modify as needed for the destination path
    destination_bucket = storage_client.bucket(destination_bucket_name)
    destination_blob = destination_bucket.blob(destination_blob_name)

    with open('/tmp/decrypted_data.txt', 'rb') as f:
        destination_blob.upload_from_file(f)

    return 'OK', 200



# [END eventarc_audit_storage_handler]
# [END eventarc_http_quickstart_handler]


# [START eventarc_http_quickstart_server]
# [START eventarc_audit_storage_server]
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)
# [END eventarc_audit_storage_server]
# [END eventarc_http_quickstart_server]