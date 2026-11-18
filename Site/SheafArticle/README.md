This is a snapshot of the reviewed Verso article in
[kim-em/sheaf-of-rings](https://github.com/kim-em/sheaf-of-rings/tree/main/article/verso).
The blog uses its native document conversion; the article text is unchanged.
`SourceLinks.lean` records the source revision and pins theorem links to it.

To update from a clean checkout, run:

```sh
python3 scripts/sync-sheaf-article.py /path/to/sheaf-of-rings
lake build Site.Blog.Sheaves
```
