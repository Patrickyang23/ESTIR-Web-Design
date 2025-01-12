import os
from bs4 import BeautifulSoup
import re

# Function to sanitize filenames
def sanitize_filename(filename):
    return re.sub(r'[<>:"/\\|?*]', '_', filename)

# Input and output file names
input_file = 'dict.htm'
main_page = 'dict.html'

# Read and parse the input HTML file
with open(input_file, 'r', encoding='utf-8') as file:
    soup = BeautifulSoup(file, 'html.parser')

# Extract vocabularies and create a mapping of anchor names to filenames
entries = soup.find_all('h2')
anchor_to_file = {}

for entry in entries:
    vocab_tag = entry.find('a', {'name': True})
    if vocab_tag:
        anchor_name = vocab_tag['name']  # Get the value of the "name" attribute
        vocab = vocab_tag.get_text(strip=True)
        filename = f"{sanitize_filename(vocab)}.html"
        anchor_to_file[anchor_name] = filename  # Map anchor name to filename

# Generate pages with updated links
for entry in entries:
    vocab_tag = entry.find('a', {'name': True})
    if vocab_tag:
        vocab = vocab_tag.get_text(strip=True)
        explanation_tag = entry.find_next_sibling('p')
        explanation = explanation_tag.decode_contents() if explanation_tag else ''

        # Update internal links in the explanation
        explanation_soup = BeautifulSoup(explanation, 'html.parser')
        for link in explanation_soup.find_all('a', href=True):
            href = link['href']
            if href.startswith('#'):  # Internal link to another term
                target_name = href[1:]  # Strip "#" to get the anchor name
                if target_name in anchor_to_file:
                    link['href'] = anchor_to_file[target_name]  # Replace with the new file path

        explanation = str(explanation_soup)

        # Create an individual HTML page for the term
        filename = anchor_to_file[vocab_tag['name']]
        with open(filename, 'w', encoding='utf-8') as vocab_file:
            vocab_file.write(f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{vocab}</title>
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="dict.html">Dictionary</a></li>
            </ul>
        </nav>
    </header>
    <main>
        <section>
            <h2>{vocab}</h2>
            {explanation}
        </section>
    </main>
</body>
</html>""")

# Create the main dictionary page
with open(main_page, 'w', encoding='utf-8') as main_file:
    main_file.write("""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dictionary</title>
</head>
<body>
<h1>Dictionary</h1>
<ul>
""")
    for anchor_name, filename in anchor_to_file.items():
        vocab = filename.replace('.html', '').replace('_', ' ').title()
        main_file.write(f'<li><a href="{filename}">{vocab}</a></li>\n')

    main_file.write("""</ul>
</body>
</html>
""")

print("Dictionary website generation complete.")
