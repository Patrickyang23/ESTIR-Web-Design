import os
# Define the special replacement for the hamburger icon
special_replacement = {
    'Â': '', # Unicode for the hamburger menu icon "☰"
    '€': '', # Unicode for the hamburger menu icon "☰"
    'œ': '', # Unicode for the hamburger menu icon "☰"
    '¢': '', # Example of another character to replace, adjust as needed
    'â': ''
    
}

def replace_specific_sequence(file_path):
    with open(file_path, 'r', encoding='utf-8', errors='replace') as file:
        content = file.read()

    # Replace the specific sequence with the hamburger menu icon
    for invalid_seq, valid_char in special_replacement.items():
        content = content.replace(invalid_seq, valid_char)

    # Save the corrected content back to the file with UTF-8 encoding
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)

def process_files_in_directory(directory_path):
    for root, _, files in os.walk(directory_path):
        for file in files:
            if file.endswith('.html'):
                file_path = os.path.join(root, file)
                replace_specific_sequence(file_path)
                print(f"Processed file: {file_path}")

# Replace with the directory containing your HTML files
directory_path = '.'
process_files_in_directory(directory_path)