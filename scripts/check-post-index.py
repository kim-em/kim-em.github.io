#!/usr/bin/env python3
"""Require every RSS post to appear on the landing page and exist on disk."""
from html.parser import HTMLParser
from pathlib import Path
import sys
from urllib.parse import urljoin, urlparse
import xml.etree.ElementTree as ET

root = Path(sys.argv[1] if len(sys.argv) > 1 else '_site')

class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.paths = set()

    def handle_starttag(self, tag, attrs):
        href = dict(attrs).get('href')
        if tag == 'a' and href:
            url = urlparse(urljoin('https://kim-em.github.io/', href))
            if url.netloc == 'kim-em.github.io':
                self.paths.add(url.path.rstrip('/'))

links = Links()
links.feed((root / 'index.html').read_text())
posts = ET.parse(root / 'feed.xml').findall('./channel/item/link')
assert posts, 'No posts found in RSS feed'
for post in posts:
    path = urlparse(post.text).path.rstrip('/')
    assert path in links.paths, f'Landing page is missing {path}'
    assert (root / path.lstrip('/') / 'index.html').is_file(), f'Missing post: {path}'
print(f'Landing page links to all {len(posts)} posts.')
