import os

# Use the current directory where the script is located
directory = os.path.dirname(os.path.abspath(__file__))

def find_files_with_invalid_char(directory):
    found_files = []  # List to store files containing "�"

    for filename in os.listdir(directory):
        if filename.endswith(".html") or filename.endswith(".htm"):  # Only check HTML files
            file_path = os.path.join(directory, filename)
            
            try:
                with open(file_path, "r", encoding="utf-8") as file:
                    content = file.read()

                    if "¢" or 'œ' or 'Â' or '€'in content:
                        print(f"Found 'Â' in: {filename}")
                        found_files.append(filename)
            
            except Exception as e:
                print(f"Error reading {filename}: {e}")

    # Summary Output
    if found_files:
        print("\nSummary: The following files contain 'Â':")
        for f in found_files:
            print(f"- {f}")
    else:
        print("\nNo files contain 'Â'.")

# Run the function
find_files_with_invalid_char(directory)
