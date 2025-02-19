import os
import re
from bs4 import BeautifulSoup

# Use the current directory where the script is located
directory = os.path.dirname(os.path.abspath(__file__))

# Regular expressions
# pattern_htm = re.compile(r'\.htm$', re.IGNORECASE)  
pattern_article = re.compile(r'^../encycl/article/', re.IGNORECASE)  # Match "/encycl/article/"

def convert_links(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".html") or filename.endswith(".htm"):  # Only check HTML files
            file_path = os.path.join(directory, filename)
            
            with open(file_path, "r", encoding="utf-8") as file:
                soup = BeautifulSoup(file, "html.parser")
            
            modified = False  # Track if file needs to be updated

            # Find all <a> tags
            for a_tag in soup.find_all("a", href=True):
                href_value = a_tag["href"].strip()

                # 1. Replace ".htm" with ".html"
                # if pattern_htm.search(href_value):
                #     href_value = pattern_htm.sub(".html", href_value)  # Replace .htm with .html
                #     modified = True  # Mark as modified
                
                # 2. Change "/encycl/article/..." to "../encycl/article/..."
                if pattern_article.match(href_value):
                    href_value = href_value.replace("../encycl/article/", "../encycl/articles/", 1)
                    modified = True  # Mark as modified

                # Update the <a> tag if changes were made
                if modified:
                    print(f"Updating in {filename}: {a_tag['href']}  →  {href_value}")
                    a_tag["href"] = href_value
            
            # Save the updated file only if modifications were made
            if modified:
                with open(file_path, "w", encoding="utf-8") as updated_file:
                    updated_file.write(str(soup))

# Run the function
convert_links(directory)
