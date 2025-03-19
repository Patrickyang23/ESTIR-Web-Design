import os

# Define mapping of invalid to valid characters
# \x91 and \x92 are single quotes, \x93 and \x94 are double quotes
invalid_to_valid = {
    '\x91': "'",  # Opening single quote
    '\x92': "'",  # Closing single quote
    '\x93': '"',  # Opening double quote
    '\x94': '"',  # Closing double quote
    '�': ''      # Remove the replacement character if needed, otherwise replace with intended character
}

def replace_invalid_characters(file_path):
    with open(file_path, 'r', encoding='windows-1252', errors='replace') as file:
        content = file.read()

    # Replace invalid characters with valid ones
    for invalid_char, valid_char in invalid_to_valid.items():
        content = content.replace(invalid_char, valid_char)

    # Save the corrected content back to the file with UTF-8 encoding
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)

def process_files_in_directory(directory_path):
    for root, _, files in os.walk(directory_path):
        for file in files:
            if file.endswith('.html'):
                file_path = os.path.join(root, file)
                replace_invalid_characters(file_path)
                print(f"Processed file: {file_path}")

# Replace with the directory containing your HTML files
directory_path = '.'
process_files_in_directory(directory_path)