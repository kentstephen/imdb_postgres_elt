import requests
import gzip
import shutil
import os
import json

# Get the current working directory of where you have the files
current_directory = os.getcwd()

# Subdirectory for storing the .tsv files
save_directory = os.path.join(current_directory, 'tsvs_from_imdb') + os.sep

# Create the subdirectory if it doesn't exist
if not os.path.exists(save_directory):
    os.makedirs(save_directory)

# List of direct download URLs for the .gz files
gz_file_urls = [
    "https://datasets.imdbws.com/title.ratings.tsv.gz",
    "https://datasets.imdbws.com/title.principals.tsv.gz",
    "https://datasets.imdbws.com/title.episode.tsv.gz",
    "https://datasets.imdbws.com/title.crew.tsv.gz",
    "https://datasets.imdbws.com/title.basics.tsv.gz",
    "https://datasets.imdbws.com/title.akas.tsv.gz",
    "https://datasets.imdbws.com/name.basics.tsv.gz",
]

for file_url in gz_file_urls:
    print(f"Downloading file from: {file_url}")
    download_path = os.path.join(save_directory, os.path.basename(file_url))

    # Download and write the .gz file
    with requests.get(file_url, stream=True) as response:
        with open(download_path, 'wb') as file:
            shutil.copyfileobj(response.raw, file)

    # Extract the .gz file
    extract_path = download_path.replace('.gz', '')
    with gzip.open(download_path, 'rb') as f_in:
        with open(extract_path, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)

    # Remove the downloaded .gz file
    os.remove(download_path)
    print(f"Downloaded and extracted to: {extract_path}")

# Write the subdirectory path to a JSON file
with open('save_directory.json', 'w') as f:
    json.dump({"tsv_files_directory": save_directory}, f)

print("All files downloaded, extracted, and path saved.")
