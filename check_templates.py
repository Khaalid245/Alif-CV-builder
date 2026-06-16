import os, re

templates_dir = r'c:\Users\Khalid\Alif-CV-builder\cvbuilder-backend\templates\cv_templates'
files = ['base_cv.html', 'classic.html', 'modern.html', 'academic.html']

print("=== FILE EXISTENCE & SIZE ===")
for f in files:
    path = os.path.join(templates_dir, f)
    exists = os.path.exists(path)
    size = os.path.getsize(path) if exists else 0
    print(f'{f}: exists={exists}, size={size} bytes')

print()
print("=== TEMPLATE INHERITANCE ===")
for f in ['classic.html', 'modern.html', 'academic.html']:
    path = os.path.join(templates_dir, f)
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()
    if 'base_cv.html' in content:
        print(f'  {f}: extends base_cv.html OK')
    else:
        print(f'  {f}: ERROR - does not extend base_cv.html')

print()
print("=== MAGIC NUMBER CHECK (inline pt values) ===")
for f in ['classic.html', 'modern.html', 'academic.html']:
    path = os.path.join(templates_dir, f)
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()
    # Find style attributes with direct pt values (not using var())
    pattern = re.compile(r'style="[^"]*\d+pt[^"]*"')
    matches = pattern.findall(content)
    if matches:
        print(f'  {f}: inline pt values found:')
        for m in matches:
            print(f'    {m}')
    else:
        print(f'  {f}: CLEAN - no magic numbers')

print()
print("=== CSS VARIABLE USAGE ===")
for f in ['classic.html', 'modern.html', 'academic.html']:
    path = os.path.join(templates_dir, f)
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()
    var_count = content.count('var(--')
    print(f'  {f}: uses var(--...) {var_count} times')

print()
print("=== SECTION PATTERN CHECK ===")
for f in ['classic.html', 'modern.html', 'academic.html']:
    path = os.path.join(templates_dir, f)
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()
    sections = content.count('class="section"')
    section_titles = content.count('class="section-title"')
    entry_headers = content.count('class="entry-header"')
    print(f'  {f}: sections={sections}, section-titles={section_titles}, entry-headers={entry_headers}')

print()
print("=== BASE_CV.HTML DESIGN TOKENS ===")
base_path = os.path.join(templates_dir, 'base_cv.html')
with open(base_path, 'r', encoding='utf-8') as fh:
    base = fh.read()
tokens = ['--font-primary', '--font-secondary', '--fs-name', '--fs-section',
          '--fs-body', '--fs-meta', '--sp-1', '--sp-2', '--sp-3', '--sp-4', '--sp-5',
          '--color-primary', '--color-text', '--color-muted', '--color-rule',
          '--color-header-bg', '--page-margin']
for t in tokens:
    found = t in base
    print(f'  {t}: {"OK" if found else "MISSING"}')
