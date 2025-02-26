#!/usr/bin/env python3
import re
import os
import glob

def transform_html(file_path):
    # Read the entire HTML file
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # We'll do most transformations in a single pass but store data if needed.
    updated_lines = []

    # Flags and data storage for transformations:
    inside_nav = False
    inserted_hamburger = False
    wrapped_ul_in_div = False
    
    # We will collect <li> items from the old aside to insert later.
    aside_li_items = []

    # For tracking <aside> changes
    in_aside = False
    replaced_aside_class = False
    opened_sidebar_search = False
    saw_search_h3 = False

    # We will insert the navigation-container block after seeing <div class="main-container">
    inserted_navigation_container = False

    # For removing "defer" from analytics scripts
    # (We’ll just do a check when we see lines containing "analytics.js")
    
    # For adding <script src="js/main.js"></script> after </footer> or before </html> if no footer
    seen_footer = False
    inserted_main_js = False

    for line in lines:
        original_line = line
        stripped_line = line.strip()

        # --------------------------------------------------------
        # (9) Remove `defer` from any analytics.js script tags
        #     e.g. <script defer src="analytics.js"></script>
        # --------------------------------------------------------
        if "analytics.js" in stripped_line and "<script" in stripped_line:
            # Remove " defer" or "defer " from that line
            line = re.sub(r'\sdefer\s?', ' ', line)

        # --------------------------------------------------------
        # Track if we've seen <footer> for step 10
        # --------------------------------------------------------
        if re.match(r'^\s*</footer>', stripped_line):
            seen_footer = True

        # --------------------------------------------------------
        # (1) Add <button class="hamburger">☰</button> right after <nav>
        # and begin tracking that we're inside the <nav>
        # --------------------------------------------------------
        if re.match(r'^\s*<nav(\s|>)', stripped_line) and not inserted_hamburger:
            inside_nav = True
            updated_lines.append(line)  # keep the <nav> line
            # Match indentation from <nav> line
            indent_match = re.match(r'^(\s*)<nav', original_line)
            indent = indent_match.group(1) if indent_match else ''
            # Insert the hamburger button (step 1)
            updated_lines.append(f"{indent}    <button class=\"hamburger\">☰</button>\n")
            inserted_hamburger = True
            continue

        # --------------------------------------------------------
        # If we are inside <nav>, look for the <ul> to wrap with <div class="side-menu">
        # (Steps 2 and 3)
        # --------------------------------------------------------
        if inside_nav:
            # (2) If we see <ul>, wrap it with <div class="side-menu">
            if '<ul>' in stripped_line and not wrapped_ul_in_div:
                indent_match = re.match(r'^(\s*)<ul>', original_line)
                indent = indent_match.group(1) if indent_match else '    '
                updated_lines.append(f"{indent}<div class=\"side-menu\">\n")
                updated_lines.append(line)  # the <ul> line itself
                wrapped_ul_in_div = True
                continue

            # If we find </ul> after wrapping, close the .side-menu and add overlay + search container
            if '</ul>' in stripped_line and wrapped_ul_in_div:
                updated_lines.append(line)  # the </ul> line
                # match indentation to the </ul> line
                indent_match = re.match(r'^(\s*)</ul>', original_line)
                indent = indent_match.group(1) if indent_match else '    '
                updated_lines.append(f"{indent}</div>\n")  # close .side-menu

                # (3) Add <div class="overlay"></div> + <div class="search-container">...
                updated_lines.append(f"{indent}<div class=\"overlay\"></div>\n")
                updated_lines.append(f"{indent}<div class=\"search-container\">\n")
                updated_lines.append(f"{indent}    <input type=\"text\" placeholder=\"Search\">\n")
                updated_lines.append(f"{indent}    <button type=\"button\"><i class=\"fas fa-search\"></i></button>\n")
                updated_lines.append(f"{indent}</div>\n")
                continue

            # If we see </nav>, we are done with nav transformations
            if re.match(r'^\s*</nav>', stripped_line):
                inside_nav = False

        # --------------------------------------------------------
        # (4) After <div class="main-container">, add .navigation-container block
        # --------------------------------------------------------
        if 'class="main-container"' in stripped_line and not inserted_navigation_container:
            updated_lines.append(line)
            indent_match = re.match(r'^(\s*)<div class="main-container"', original_line)
            indent = indent_match.group(1) if indent_match else '    '
            updated_lines.append(f"{indent}    <!-- Sidebar Navigation (Row in Mobile, Sidebar in Desktop) -->\n")
            updated_lines.append(f"{indent}    <div class=\"navigation-container\">\n")
            updated_lines.append(f"{indent}        <span>Skip to:</span>\n")
            updated_lines.append(f"{indent}        <ul>\n")
            updated_lines.append(f"{indent}        <!-- Mobile navigation items -->\n")
            updated_lines.append(f"{indent}        </ul>\n")
            updated_lines.append(f"{indent}    </div>\n\n")
            inserted_navigation_container = True
            continue

        # --------------------------------------------------------
        # (5) Rename <aside> to <aside class="sidebar">
        # --------------------------------------------------------
        if re.match(r'^\s*<aside(\s|>)', stripped_line):
            # Replace <aside> with <aside class="sidebar">
            indent_match = re.match(r'^(\s*)<aside', original_line)
            indent = indent_match.group(1) if indent_match else ''
            new_line = re.sub(r'<aside(\s|>)', '<aside class="sidebar">', line)
            updated_lines.append(new_line)
            in_aside = True
            replaced_aside_class = True
            continue

        # If we see </aside>, close that flag
        if re.match(r'^\s*</aside>', stripped_line) and in_aside:
            in_aside = False
            updated_lines.append(line)
            continue

        # --------------------------------------------------------
        # (6) In the aside, wrap the "Search" h3 + search-container
        #     inside <div class="sidebar-search"> ... </div>
        # --------------------------------------------------------
        if in_aside:
            # Detect the <h3 class="subtitle">Search</h3>
            if re.search(r'<h3\s+class="subtitle">\s*Search\s*</h3>', stripped_line) and not opened_sidebar_search:
                indent_match = re.match(r'^(\s*)<h3', original_line)
                indent = indent_match.group(1) if indent_match else ''
                # Insert <div class="sidebar-search">
                updated_lines.append(f"{indent}<div class=\"sidebar-search\">\n")
                updated_lines.append(line)
                opened_sidebar_search = True
                saw_search_h3 = True
                continue

            # Once we see the closing </div> for .search-container after h3, we close .sidebar-search
            if '</div>' in stripped_line and 'search-container' in stripped_line and saw_search_h3:
                # Keep that line
                updated_lines.append(line)
                # Then close the .sidebar-search
                indent_match = re.match(r'^(\s*)</div>', original_line)
                indent = indent_match.group(1) if indent_match else ''
                updated_lines.append(f"{indent}</div>\n")
                opened_sidebar_search = False
                saw_search_h3 = False
                continue

            # --------------------------------------------------------
            # (7) Remove leading "> " or "&gt; " in each <li> text (like ">> Dictionary" -> "Dictionary")
            # (8) Store cleaned <li> for copying to the new .navigation-container block.
            # --------------------------------------------------------
            if '<li>' in stripped_line:
                # Example: <li><a href="#article">&gt; Main Content</a></li>
                # We remove the extra ">" or "&gt;" near the link text.
                # Use regex to target only the text between > and </a>
                li_cleaned = re.sub(r'(<a[^>]*>)(\s*&gt;\s*|\s*>\s*)(.*?)(</a>)', r'\1\3\4', line)
                # Also store the line in aside_li_items
                aside_li_items.append(li_cleaned.strip('\n'))
                updated_lines.append(li_cleaned)
                continue

        # --------------------------------------------------------
        # (10) Right after </footer>, add <script src="js/main.js"></script>
        # If no footer found, we add it before </html>
        # --------------------------------------------------------
        # if re.match(r'^\s*</footer>', stripped_line) and not inserted_main_js:
        #     updated_lines.append(line)
        #     # Insert <script src="js/main.js"></script>
        #     indent_match = re.match(r'^(\s*)</footer>', original_line)
        #     indent = indent_match.group(1) if indent_match else ''
        #     updated_lines.append(f"{indent}<script src=\"../../js/main.js\"></script>\n")
        #     inserted_main_js = True
        #     continue

        # If we see </html> and haven't yet inserted main.js
        if re.match(r'^\s*</body>', stripped_line) and not inserted_main_js:
            # Insert the script just before
            updated_lines.append(f"    <script src=\"../js/main.js\"></script>\n")
            updated_lines.append(line)
            inserted_main_js = True
            continue

        # Otherwise, just copy the line
        updated_lines.append(line)

    # --------------------------------------------------------
    # Now do a second pass to insert the old aside <li> items
    # into the placeholder comment:
    #   <!-- Mobile navigation items -->
    # --------------------------------------------------------
    final_lines = []
    for line in updated_lines:
        if '<!-- Mobile navigation items -->' in line:
            final_lines.append(line)
            # Insert each <li> line beneath the placeholder
            # We'll match indentation
            indent_match = re.match(r'^(\s*)<!--', line)
            indent = indent_match.group(1) if indent_match else '            '
            for li_item in aside_li_items:
                final_lines.append(f"{indent}    {li_item.strip()}\n")
        else:
            final_lines.append(line)

    # Write the final content back to the original file
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(final_lines)

    print(f"Transformation complete. Updated HTML saved to: {file_path}")

def process_all_html_files():
    # Get all HTML files in the current directory
    html_files = glob.glob("*.html")
    
    for html_file in html_files:
        # Transform the HTML file in place
        transform_html(html_file)

if __name__ == "__main__":
    # Process all HTML files in the current directory
    process_all_html_files()