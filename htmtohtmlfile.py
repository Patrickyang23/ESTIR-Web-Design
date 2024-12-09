import chardet

def detect_encoding(file_path):
    with open(file_path, 'rb') as file:
        raw_data = file.read()
    result = chardet.detect(raw_data)
    return result['encoding']

def convert_html(old_html_path, new_html_template_path, output_path):
    # Detect encoding of the old HTML file
    old_file_encoding = detect_encoding(old_html_path)
    print(f"Detected encoding for the old file: {old_file_encoding}")
    
    # Read the files with the detected encoding
    with open(old_html_path, 'r', encoding=old_file_encoding) as old_file:
        old_html = old_file.read()
    with open(new_html_template_path, 'r', encoding='utf-8') as template_file:
        new_template = template_file.read()

    from bs4 import BeautifulSoup

    old_soup = BeautifulSoup(old_html, 'html.parser')
    new_soup = BeautifulSoup(new_template, 'html.parser')

    # Get and set title
    title = old_soup.find('title').text if old_soup.find('title') else "No Title"
    new_soup.title.string = title

    # Get the first <h2> as the main article title
    main_title = old_soup.find('h2')
    if main_title:
        article_section = new_soup.find(id="article")
        if article_section:
            article_section.h1.string = main_title.text
        main_title.decompose()

    # Get author info
    author_info = old_soup.find_all('em')[0] if old_soup.find_all('em') else None
    if author_info:
        author_section = new_soup.find(class_='author-info')
        if author_section:
            author_section.append(author_info)

    # Extract all remaining content
    content = old_soup.find_all(['p', 'table', 'ul', 'li'])
    main_content_section = new_soup.find(id="article")
    for tag in content:
        # Clean inline styles and attributes
        if tag.name in ['table', 'ul', 'p']:
            for attr in list(tag.attrs.keys()):
                del tag[attr]
            main_content_section.append(tag)

    # Extract appendix
    appendix = old_soup.find('h3', text='Appendix')
    if appendix:
        appendix_section = new_soup.find(id="appendix")
        while appendix and appendix.next_sibling:
            appendix_section.append(appendix.next_sibling)
            appendix = appendix.next_sibling

    # Extract bibliography
    bibliography = old_soup.find('h3', text='Bibliography')
    if bibliography:
        bibliography_section = new_soup.find(id="bibliography")
        while bibliography and bibliography.next_sibling:
            bibliography_section.append(bibliography.next_sibling)
            bibliography = bibliography.next_sibling

    # Save the result
    with open(output_path, 'w', encoding='utf-8') as output_file:
        output_file.write(str(new_soup))


if __name__ == '__main__':
    # Input paths
    old_html_path = '._art-a03-analytical.htm'
    new_html_template_path = 'new_template.html'
    output_path = 'converted_file.html'
    
    convert_html(old_html_path, new_html_template_path, output_path)
