# AGENTS.md — reagent992.github.io

Personal Hugo site deployed to GitHub Pages.

## Important

- Commit after every change with a meaningful message
- Before committing, check `git status` and `git diff` — stage only needed files

## Quick start

```bash
hugo server -D          # dev server with draft pages
hugo --gc --minify      # production build → ./public
```

## Conventions

- Front matter uses TOML (`+++`), new posts default `draft = true`
- Archetype: `archetypes/default.md` — sets `author = "Sadykov Miron"`, `toc = true`
- Posts go in `content/posts/`; sections use `_index.md`
- Theme: [risotto](https://github.com/joeroe/risotto) (vendored in `themes/risotto/`, no submodule)
- Config: `hugo.toml` (TOML, not YAML)

## Deployment

- CI: `.github/workflows/hugo.yaml` — deploys to GitHub Pages on push to `main`
- `public/` is gitignored — do not commit build output
