#!/usr/bin/env python3
"""Check browser-resolved citation URLs and semantic Lean hovers."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urljoin, urlparse
import sys

root = Path(sys.argv[1] if len(sys.argv) > 1 else '_site')
path, = root.glob('blog/*-an-error-in-the-isabellehol-formalization-of-sheaves/index.html')
page_url = 'https://kim-em.github.io/' + path.parent.relative_to(root).as_posix() + '/'

class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.base = page_url
        self.ids = set()
        self.citations = []
        self.hovered = set()

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'base':
            self.base = urljoin(page_url, attrs['href'])
        if 'id' in attrs:
            self.ids.add(attrs['id'])
        if tag == 'a' and 'sheaf-reference-' in attrs.get('href', ''):
            self.citations.append(attrs['href'])
        if 'data-verso-hover' in attrs:
            self.hovered.add(attrs.get('data-binding', ''))

page = Page()
page.feed(path.read_text())
assert len(page.citations) == 7, page.citations
for href in page.citations:
    resolved = urlparse(urljoin(page.base, href))
    assert resolved.path == urlparse(page_url).path, (href, resolved)
    assert resolved.fragment in page.ids, (href, resolved.fragment)
for name in ['boundedRing', 'discreteSpace', 'IsSheaf']:
    assert any(binding.endswith('.' + name) for binding in page.hovered), name
print('All seven citations resolve to this article; Lean definitions have hover data.')
