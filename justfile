run:
    @echo "Сервер запущен — доступны черновики (draft = true)"
    hugo server -D
new name:
    hugo new content/en/posts/{{name}}/index.md
    hugo new content/ru/posts/{{name}}/index.md
