# AGENTS.md — reagent992.github.io

Personal Hugo site deployed to GitHub Pages.

## Important

- Commit after every change with a meaningful message
- Before committing, check `git status` and `git diff` — stage only needed files
- Pre-commit: `prek run -a` (запускает markdownlint и базовые проверки)

## Quick start

```bash
hugo server -D          # dev server with draft pages
hugo --gc --minify      # production build → ./public
```

## Conventions

- Front matter uses TOML (`+++`), new posts default `draft = true`
- Archetype: `archetypes/default.md` — sets `author = "Sadykov Miron"`, `toc = true`
- Posts go in `content/en/posts/` and `content/ru/posts/`; always create both versions when adding a post
- Sections use `_index.md`
- Theme: [risotto](https://github.com/joeroe/risotto) (git submodule, tag v0.5.1)
- Custom overrides live in root `layouts/` and `static/` — they shadow theme files with same paths
- Config: `hugo.toml` (TOML, not YAML)

## Deployment

- CI: `.github/workflows/hugo.yaml` — deploys to GitHub Pages on push to `main`
- `public/` is gitignored — do not commit build output
