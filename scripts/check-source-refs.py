#!/usr/bin/env python3
"""Check local Markdown destinations and citation keys in published source pages."""
from pathlib import Path
import re
import json
from urllib.parse import unquote, urlsplit

root = Path(__file__).resolve().parents[1]
pages = list(root.glob('*.qmd'))
for folder in ('courses', 'tutorials', 'shiny', 'appendices', 'decision-tree'):
    pages += [p for p in (root / folder).rglob('*.qmd')
              if not any(part.startswith(('_', '.')) for part in p.relative_to(root).parts)]
keys = set(re.findall(r'@\w+\s*\{\s*([^,\s]+)', (root / 'references.bib').read_text()))
errors = []
links = 0
for page in sorted(pages):
    # Code examples can intentionally show hypothetical paths and citation syntax.
    text = re.sub(r'^(`{3,}|~{3,})[^\n]*\n.*?^\1\s*$', '', page.read_text(), flags=re.M | re.S)
    for ref in re.findall(r'\]\(([^\s)]+)(?:\s+"[^"]*")?\)', text):
        u = urlsplit(ref)
        if u.scheme or u.netloc or not u.path:
            continue
        links += 1
        dest = (root / unquote(u.path).lstrip('/') if u.path.startswith('/')
                else page.parent / unquote(u.path))
        if not dest.exists() and not (dest.suffix == '.html' and dest.with_suffix('.qmd').exists()):
            errors.append(f'{page.relative_to(root)}: missing local target {ref}')
        elif dest.is_dir() and not any((dest / name).exists() for name in ('index.qmd','index.html')):
            errors.append(f'{page.relative_to(root)}: no index page in {ref}')
    for key in re.findall(r'(?<![\w/])@([A-Za-z][A-Za-z0-9_:.+-]*)', text):
        key = key.rstrip(':.')
        if key.startswith(('fig-', 'tbl-', 'eq-', 'sec-', 'lst-')):
            continue
        if key not in keys:
            errors.append(f'{page.relative_to(root)}: missing bibliography key {key}')
# Dynamic navigation is not visible to a static HTML href scan.
def check_destination(link, origin):
    dest = root / link
    if dest.is_dir():
        dest = dest / 'index.qmd'
    if dest.suffix == '.html':
        dest = dest.with_suffix('.qmd')
    if not dest.exists():
        errors.append(f'{origin}: missing tutorial {link}')

graph = json.loads((root / 'artifacts/graph.json').read_text())
for node in graph['nodes']:
    check_destination(node['url'], 'artifacts/graph.json')
tree = json.loads((root / 'artifacts/decision-tree.json').read_text())
nodes = [tree, *tree['nodes']]
ids = {node['id'] for node in nodes}
for node in nodes:
    for option in node.get('options', []):
        if option['next_id'] not in ids:
            errors.append(f"Decision tree: missing node {option['next_id']}")
    for link in node.get('tutorials', []):
        check_destination(link, 'artifacts/decision-tree.json')

print(f'{len(pages)} source pages, {links} local links, {len(keys)} bibliography entries')
if errors:
    raise SystemExit('\n'.join(errors))
print('Source navigation and citation keys passed')
