import os
import sys
from bs4 import BeautifulSoup
from jinja2 import Environment, FileSystemLoader

def load_template(template_path):
    env = Environment(loader=FileSystemLoader(searchpath=os.path.dirname(template_path)))
    template = env.get_template(os.path.basename(template_path))
    return template

def extract_body_content(htm_content):
    soup = BeautifulSoup(htm_content, 'html.parser')
    body = soup.find('body')
    if body:
        # You can modify this to extract specific sections if needed
        return body.decode_contents()
    else:
        print("No <body> tag found in the .htm file.")
        return ""

def convert_file(htm_file_path, template, output_dir):
    try:
        with open(htm_file_path, 'r', encoding='utf-8') as file:
            htm_content = file.read()
    except Exception as e:
        print(f"Error reading {htm_file_path}: {e}")
        return

    body_content = extract_body_content(htm_content)
    if not body_content:
        print(f"No content extracted from {htm_file_path}. Skipping.")
        return

    # Render the template with the extracted body content
    rendered_html = template.render(body_content=body_content)

    # Define the output .html file path
    base_name = os.path.splitext(os.path.basename(htm_file_path))[0]
    html_file_name = f"{base_name}.html"
    html_file_path = os.path.join(output_dir, html_file_name)

    try:
        with open(html_file_path, 'w', encoding='utf-8') as file:
            file.write(rendered_html)
        print(f"Converted {htm_file_path} to {html_file_path}")
    except Exception as e:
        print(f"Error writing {html_file_path}: {e}")

def convert_all_htm_files(input_dir, template_path, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    template = load_template(template_path)

    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file.lower().endswith('.htm'):
                htm_file_path = os.path.join(root, file)
                convert_file(htm_file_path, template, output_dir)

def main():
    if len(sys.argv) != 4:
        print("Usage: python convert_htm_to_html.py <input_directory> <template.html> <output_directory>")
        sys.exit(1)

    input_dir = sys.argv[1]
    template_path = sys.argv[2]
    output_dir = sys.argv[3]

    if not os.path.exists(input_dir):
        print(f"Input directory does not exist: {input_dir}")
        sys.exit(1)

    if not os.path.isfile(template_path):
        print(f"Template file does not exist: {template_path}")
        sys.exit(1)

    convert_all_htm_files(input_dir, template_path, output_dir)

if __name__ == "__main__":
    main()
