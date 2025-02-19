import os
import re
from bs4 import BeautifulSoup

# Use the current directory where the script is located
directory = os.path.dirname(os.path.abspath(__file__))

# Regular expression to match "/encycl/art-" at the correct position and ensure it ends with ".htm.html"
pattern = re.compile(r'^(.*?)/encycl/article/art-([^/]+).htm.html$', re.IGNORECASE)

def check_and_modify_files(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".html") or filename.endswith(".htm"):  # Only check HTML files
            file_path = os.path.join(directory, filename)
            
            with open(file_path, "r", encoding="utf-8") as file:
                soup = BeautifulSoup(file, "html.parser")
            
            modified = False  # Track if file needs to be updated

            # Find all <a> tags
            for a_tag in soup.find_all("a", href=True):
                href_value = a_tag["href"].strip()

                # Check if it matches the pattern
                match = pattern.match(href_value)
                if match:
                    # Remove only the ".htm" part if it appears before ".html"
                    corrected_filename = href_value.replace('.htm.html', '.html')

                    print(f"Fixing in {filename}: {href_value}  →  {corrected_filename}")
                    a_tag["href"] = corrected_filename
                    modified = True  # Mark as modified
            
            # Save the updated file only if modifications were made
            if modified:
                with open(file_path, "w", encoding="utf-8") as updated_file:
                    updated_file.write(str(soup))
                    

# Run the function
check_and_modify_files(directory)
