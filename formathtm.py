import os
import re
from bs4 import BeautifulSoup  # Make sure to import BeautifulSoup correctly

# Define the directory containing the old .htm files
current_directory = os.getcwd()

# List all files in the current directory
files = os.listdir(current_directory)

# Filter for .htm files
html_files = [file for file in files if file.endswith('.htm')]

# Define the new HTML structure
html_template = '''
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
    <link rel="stylesheet" href="../../css/html5reset.css">
    <link rel="stylesheet" href="../../css/main.css">
    <title>{title}</title>
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="../../index.html">Home</a></li>
                <li><a href="../../estir/index.html">ESTIR</a></li>
                <li><a href="../../encycl/index.html">Encyclopedia</a></li>
                <li><a href="../../ed/dict.html">Dictionary</a></li>
                <li><a href="https://www.electrochem.org/" target="_blank">ECS Page</a></li>
            </ul>
        </nav>
        <a href="index.html">
            <img src="../../images/banner_encyclopedia.jpg" alt="Electrochemical Encyclopedia Banner">
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
            <section id="article">
                <h1><i class="fas fa-flask"></i>{article_title}</h1>
                <div class="author-info">
                    <em>{author_info}</em><br>
                    <p>{author_contact}</p>
                </div>
            </section>
            {sections}
            <section>
                <h2><i class="fas fa-flask"></i>Other Resources</h2>
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
'''

def extract_title(content):
    match = re.search(r'<title>(.*?)</title>', content, re.IGNORECASE)
    return match.group(1) if match else 'No Title'

def extract_author_info(content):
    match = re.search(r'<em>(.*?)</em>', content, re.IGNORECASE)
    return match.group(1) if match else 'No Author Info'

def extract_author_contact(content):
    match = re.search(r'<p>(.*?)</p>', content, re.IGNORECASE)
    return match.group(1) if match else ''

def extract_sections(content):
    sections = ''
    soup = BeautifulSoup(content, 'html.parser')
    h3_tags = soup.find_all('h3')
    for tag in h3_tags:
        section_content = ''.join(str(sibling) for sibling in tag.next_siblings if sibling.name != 'h3')
        sections += f'<section>\n<h3>{tag.get_text()}</h3>\n{section_content}</section>\n'
    return sections

def extract_h2_as_h1(content):
    soup = BeautifulSoup(content, 'html.parser')
    h2_tag = soup.find('h2')
    return h2_tag.get_text() if h2_tag else 'No Title'

def remove_duplicate_h3(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        soup = BeautifulSoup(file, 'html.parser')
    
    h3_tags = soup.find_all('h3')
    seen = set()
    for tag in h3_tags:
        if tag.text in seen:
            tag.decompose()
        else:
            seen.add(tag.text)
    
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(str(soup))

def remove_return_to_lines(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    
    with open(file_path, 'w', encoding='utf-8') as file:
        for line in lines:
            if "Return to:" not in line:
                file.write(line)

def process_file(filepath):
    with open(filepath, 'r', encoding='ISO-8859-1') as file:
        content = file.read()
    
    title = extract_title(content)
    article_title = extract_h2_as_h1(content)
    author_info = extract_author_info(content)
    author_contact = extract_author_contact(content)
    sections = extract_sections(content)
    
    new_content = html_template.format(
        title=title,
        article_title=article_title,
        author_info=author_info,
        author_contact=author_contact,
        sections=sections
    )
    
    new_filepath = filepath.replace('.htm', '.html')
    with open(new_filepath, 'w', encoding='utf-8') as file:
        file.write(new_content)
    
    print(f'Processed {filepath} to {new_filepath}')
    
    # Call the new functions to further process the new file
    remove_duplicate_h3(new_filepath)
    remove_return_to_lines(new_filepath)

# Iterate over all .htm files in the directory
for filename in os.listdir(current_directory):
    if filename.endswith('.htm'):
        process_file(os.path.join(current_directory, filename))