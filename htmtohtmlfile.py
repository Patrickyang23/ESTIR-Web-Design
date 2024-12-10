import os
import chardet
from bs4 import BeautifulSoup, Comment



def detect_encoding(file_path):
    with open(file_path, "rb") as file:
        raw_data = file.read()
    result = chardet.detect(raw_data)
    return result["encoding"]


def clean_html_content(soup):
 
    unwanted_html = """
Return to: 
<a href="/encycl/">Encyclopedia Home Page</a> – 
<a href="/encycl#tc">Table of Contents</a> – 
<a href="index-a.html">Author Index</a> – 
<a href="index-s.html">Subject Index</a> – 
<a href="index.html#search">Search</a> – 
<a href="/ed/dict.htm">Dictionary</a> – 
<a href="/estir/">ESTIR Home Page</a> – 
<a href="http://www.electrochem.org/"> ECS Home Page</a>
    """.strip()
    found = False
    for element in soup.find_all():
        element_str = str(element).replace("&#150;","-")
        
        if unwanted_html in element_str:
            found = True
            element.decompose()
            break
        
    if not found:
        title = soup.title.string if soup.title else "title not found"
        print(f"not found {title.strip()}") 

    # Remove comments
    for comment in soup.find_all(string=lambda text: isinstance(text, Comment)):
        comment.extract()

    # Remove <img> tags with src="fig/clear.jpg"
    for img in soup.find_all("img", src="fig/clear.jpg"):
        img.decompose()

    return soup


def convert_html(old_html_path, new_html_template_path, output_path):
    # Detect encoding of the old HTML file
    old_file_encoding = detect_encoding(old_html_path)
    print(f"Detected encoding for the old file: {old_file_encoding}")

    # Read the files with the detected encoding
    with open(old_html_path, "r", encoding=old_file_encoding) as old_file:
        old_html = old_file.read()
    with open(new_html_template_path, "r", encoding="utf-8") as template_file:
        new_template = template_file.read()

  
    old_soup = BeautifulSoup(old_html, "html.parser")
    new_soup = BeautifulSoup(new_template, "html.parser")

    old_soup = clean_html_content(old_soup)

    # Get and set title
    title = old_soup.find("title").text if old_soup.find("title") else "No Title"
    new_soup.title.string = title

    # Get the first <h2> as the main article title
    main_title = old_soup.find("h2")
    if main_title:
        article_section = new_soup.find(id="article")
        if article_section:
            article_section.h1.string = main_title.text
        main_title.decompose()

    # Get author info
    author_info = old_soup.find_all("em")[0] if old_soup.find_all("em") else None
    if author_info:
        author_section = new_soup.find(class_="author-info")
        if author_section:
            author_section.append(author_info)

    # Extract all remaining content
    content = old_soup.find_all(["p", "table", "ul", "li"])
    main_content_section = new_soup.find(id="article")
    for tag in content:
        # Clean inline styles and attributes
        if tag.name in ["table", "ul", "p"]:
            for attr in list(tag.attrs.keys()):
                del tag[attr]
            main_content_section.append(tag)

    # Extract appendix
    appendix = old_soup.find("h3", string="Appendix")
    if appendix:
        appendix_section = new_soup.find(id="appendix")
        while appendix and appendix.next_sibling:
            appendix_section.append(appendix.next_sibling)
            appendix = appendix.next_sibling

    # Extract bibliography
    bibliography = old_soup.find("h3", string="Bibliography")
    if bibliography:
        bibliography_section = new_soup.find(id="bibliography")
        while bibliography and bibliography.next_sibling:
            bibliography_section.append(bibliography.next_sibling)
            bibliography = bibliography.next_sibling

    # Save the result
    with open(output_path, "w", encoding="utf-8") as output_file:
        output_file.write(str(new_soup))


def convert_all_htm_files(input_dir, new_html_template_path, output_dir):
    """Convert all .htm files in the specified directory."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file.lower().endswith(".htm"):
                old_html_path = os.path.join(root, file)
                output_file_name = os.path.splitext(file)[0] + ".html"
                output_path = os.path.join(output_dir, output_file_name)
                convert_html(old_html_path, new_html_template_path, output_path)


if __name__ == "__main__":
    # Set directories
    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_dir = script_dir  # Process all .htm files in the script's directory
    output_dir = os.path.join(script_dir, "output")  # Output directory
    new_html_template_path = os.path.join(
        script_dir, "article_template.html"
    )  # Template file

    if not os.path.isfile(new_html_template_path):
        print(f"Template file does not exist: {new_html_template_path}")
    else:
        convert_all_htm_files(input_dir, new_html_template_path, output_dir)
