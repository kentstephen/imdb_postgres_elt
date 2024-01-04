import requests
import gzip
import shutil
import os
import json
# update!!
user_provided_directory = "path/to/where/you/cloned/the/git/using/forward/slashes"  # REPLACE with the actual path
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

save_directory = os.path.join(user_provided_directory, 'tsvs_from_imdb')
if not os.path.exists(save_directory):
    os.makedirs(save_directory)

extract_paths = {}  # Dictionary to store extract paths

for file_url in gz_file_urls:
    print(f"Downloading file from: {file_url}")
    download_path = os.path.join(save_directory, os.path.basename(file_url))

    with requests.get(file_url, stream=True) as response:
        with open(download_path, 'wb') as file:
            shutil.copyfileobj(response.raw, file)

    extract_path = download_path.replace('.gz', '')
    extract_paths[os.path.basename(file_url).replace('.gz', '')] = extract_path

    with gzip.open(download_path, 'rb') as f_in:
        with open(extract_path, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)

    os.remove(download_path)
    print(f"Downloaded and extracted to: {extract_path}")

# Write extract paths to a JSON file
with open('extract_paths.json', 'w') as f:
    json.dump(extract_paths, f)

print("All files downloaded, extracted, and paths saved.")