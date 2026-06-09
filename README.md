# reagent992.github.io

Личный сайт на Hugo, хостится на GitHub Pages.

- **EN**: [reagent992.github.io](https://reagent992.github.io/) / **RU**: [reagent992.github.io/ru/](https://reagent992.github.io/ru/)
- Деплой: GitHub Actions (пуша в `main`)
- Тема: [risotto](https://github.com/joeroe/risotto) (git submodule, v0.5.1)
- Сборка: `hugo --gc --minify`

## Быстрый старт

```bash
just run       # локальный сервер с черновиками
just new <name> # создать новый пост (leaf bundle, EN + RU)
```

## Двуязычность

Контент в `content/en/` и `content/ru/`. Посты создаются сразу на двух языках — `just new` делает оба файла. Если перевода нет, страница просто не покажет переключатель.

## Для разработчика

- Кастомные изменения темы — в корневых `layouts/` и `static/` (переопределяют файлы темы с тем же путём)
- Front matter: TOML (`+++`), `draft = true` для новых постов
- `public/` в `.gitignore` — билд не коммитить
