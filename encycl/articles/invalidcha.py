import re
import sys
import os
import codecs

LOG_FILE = "invalid_chars.log"

def detect_invalid_chars(file_path, encoding='utf-8'):
    try:
        with codecs.open(file_path, 'r', encoding=encoding, errors='replace') as f:
            content = f.read()
    except UnicodeDecodeError as e:
        log_message(f"[ERROR] Encoding issue detected in {file_path}: {e}")
        return
    
    # Define a pattern for non-printable ASCII characters (excluding space, tab, newline)
    invalid_pattern = re.compile(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]')

    # Find non-printable characters
    matches = invalid_pattern.findall(content)
    
    # Check for Unicode replacement character (�)
    if "�" in content:
        matches.append("�")

    if matches:
        log_message(f"[WARNING] Invalid characters found in {file_path}:")
        for match in set(matches):
            log_message(f"  Character: {repr(match)} (ASCII: {ord(match) if match != '�' else 'Replacement'})")
    # else:
    #     log_message(f"[INFO] No invalid characters found in {file_path}.")

def log_message(message):
    """Logs messages to both console and a file."""
    print(message)
    with open(LOG_FILE, "a", encoding="utf-8") as log:
        log.write(message + "\n")

def scan_directory(directory):
    log_message(f"Scanning directory: {directory}\n{'-'*40}")
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".html"):
                file_path = os.path.join(root, file)
                detect_invalid_chars(file_path)
    log_message("Scan complete. Check invalid_chars.log for results.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python check_invalid_html.py <file_or_directory>")
        sys.exit(1)
    
    # Clear log file before each run
    open(LOG_FILE, "w").close()

    target = sys.argv[1]
    if os.path.isdir(target):
        scan_directory(target)
    elif os.path.isfile(target):
        detect_invalid_chars(target)
    else:
        print("Invalid input. Please provide a valid file or directory path.")
