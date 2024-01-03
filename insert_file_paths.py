import os
import json

def update_sql_file(sql_file_path, tsv_directory):
    # Read the content of the SQL file
    with open(sql_file_path, 'r') as file:
        sql_content = file.read()

    # Replace the placeholder with the actual directory path
    updated_sql_content = sql_content.replace('{{user_provided_directory}}', tsv_directory)

    # Write the updated content back to the SQL file
    with open(sql_file_path, 'w') as file:
        file.write(updated_sql_content)
    print("SQL file updated.")

# Read the JSON file to get the extract paths
with open('extract_paths.json', 'r') as file:
    extract_paths = json.load(file)

# Get the directory of the TSV files from any of the paths in extract_paths
tsv_directory = os.path.dirname(list(extract_paths.values())[0])

# Path to the SQL file, assuming it is in the same directory as this script
sql_file_path = os.path.join(os.getcwd(), 'create_tables_insert_data_imdb.sql')

# Update the SQL file with the path to the TSV files
update_sql_file(sql_file_path, tsv_directory)
