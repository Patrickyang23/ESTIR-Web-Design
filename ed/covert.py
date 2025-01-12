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
            vocab_file.write(f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Many thousands of electrochemistry information items: Encyclopedia, Dictionary, website links, books, reviews, graduate schools, definitions, popular-science style articles, meetings, etc.">
    <meta name="keywords" content="popular science, K-12, homeschooling, educational outreach, battery, fuel cell, energy storage, electrolysis, electroanalysis, corrosion, bioelectrochemistry, electrosynthesis, electrowinning, electrorefining, electroforming, electromachining, photoelectrochemistry, electroplating, electrode kinetics, electrokinetics, electrochemical engineering, electrochemical double layer, electrodialysis, electrophoresis, spectroelectrochemistry, electrochemical sensors, charge transfer, electron transfer, voltammetry, potentiometry, amperometry, electroanalytical chemistry">
    <meta name="robots" content="index, follow, noodp, noydir">
    <link rel="canonical" href="https://knowledge.electrochem.org/">
    <link rel="icon" href="https://knowledge.electrochem.org/favicon.ico" type="image/x-icon">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/html5reset.css">
    <link rel="stylesheet" href="../css/main.css">
    <title>{vocab}</title>
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="../index.html">Home</a></li>
                <li><a href="../estir/index.html">ESTIR</a></li>
                <li><a href="../encycl/index.html">Encyclopedia</a></li>
                <li><a href="../ed/dict.html">Dictionary</a></li>
                <li><a href="https://www.electrochem.org/" target="_blank">ECS Page</a></li>
            </ul>
        </nav>
        <a href="index.html">
            <img src="../images/banner_encyclopedia.jpg" alt="Electrochemical Encyclopedia Banner">
        </a>
    </header>

    <!-- Main content container -->
    <div class="main-container">
        <aside>
            <div class="fixed-sidebar">
                <h3 class="subtitle">Search</h3>
                <div class="search-container">
                    <input type="text" placeholder="Search">
                    <button type="button"><i class="fas fa-search"></i></button>
                </div>

                <!-- Navigation menu for sections -->
                <h3 class="subtitle">Navigation</h3>
                <ul>
                    <li><a href="#article">> Main Content</a></li>
                    <li><a href="#appendix">> Appendix</a></li>
                    <li><a href="#acknowledgements">> Acknowledgements</a></li>
                    <li><a href="#bibliography">> Bibliography</a></li>
                    <li><a href="#other-resources">> Other Resources</a></li>
                </ul>
            </div>
        </aside>
        <main>
            <section>
            <h2>{vocab}</h2>
            {explanation}
        </section>
            <section>
                <h2><i class="fas fa-flask"></i>
                    Other Resources
                </h2>
                <p>
                    Listings of electrochemistry <a href="../../estir/books.html"> books</a>, <a href="../../estir/chap.html"> review chapters</a>, <a href="/estir/proc.html"> proceedings volumes</a>, and full text of some <a href="/estir/history.html"> historical publications</a> are also available in the <a href="/estir/"> Electrochemistry Science and Technology Information Resource (ESTIR)</a>. (http://knowledge.electrochem.org/estir/)
                </p>
            </section>

        </main>
    </div>

    <!-- END OF CONTENT -->

    <!-- DO NOT EDIT BELOW THIS LINE -->

    <!-- FOOTER CODE -->

    <footer>
        <img src="../../images/ECS_Logo-removebg.png" alt="ECS Logo">
        <div class="footer-text">
            <p>
                Hosted by: <a href="http://www.electrochem.org/" target="_blank">The Electrochemical Society, Inc. (ECS)</a> | 
                <a href="/copyright.html">Copyright Notice</a>
            </p>
            <p>
                Edited by: <a href="/estir/editor.html">Zoltan Nagy</a> <a href="mailto:nagyz@email.unc.edu">(nagyz@email.unc.edu)</a> | 
                <a href="http://www.chem.unc.edu/" target="_blank">Dept. of Chemistry</a> | 
                <a href="http://www.unc.edu/" target="_blank">UNC at Chapel Hill</a></p>
            <p>
                <a href="http://www.electrochem.org/" target="_blank">ECS</a> | 
                <a href="http://www.ecsblog.org/" target="_blank">Redcat Blog</a> | 
                <a href="http://ecsdl.org/" target="_blank">ECS Digital Library</a>
            </p>
        </div>
    </footer>
    <script async src="https://www.googletagmanager.com/gtag/js?id=G-YW5FGNQDL2"></script>
    <script src="../../js/analytics.js" defer></script>
</body>
</html>
""")

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
