+++
date = '2025-04-17T15:03:16+03:00'
draft = true
title = 'Как сделать obsidian.nvim менее навязчивым'
author = "Sadykov Miron"
+++

Я предпочитаю простой Obsidian и не использую никаких систем заметок.
**obsidian.nvim** — отличный плагин, но по умолчанию он навязывает метод Zettelkasten.
Я потратил около часа на настройку конфигурации, чтобы убрать это и сделать поведение похожим на обычный Obsidian.

Поскольку я использую **LazyVim**, мои файлы плагинов следуют его структуре:

```lua
-- ./lua/plugins/obsidian-nvim.lua
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "/path/to/my_workspace",
      },
    },
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
    },
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title
      else
        suffix = "New_note_"
        for _ = 1, 6 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return suffix
    end,
    disable_frontmatter = true,
  },
}
```

Я также добавил несколько удобных хоткеев:

```lua
-- /lua/config/keymaps.lua
vim.keymap.set("n", "<leader>oo", ":ObsidianOpen<cr>", { desc = "Открыть в приложении" })
vim.keymap.set("n", "<leader>on", ":ObsidianNew<cr>", { desc = "Новая заметка" })
vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks<cr>", { desc = "Обратные ссылки" })
vim.keymap.set("n", "<leader>ot", ":ObsidianTemplate<cr>", { desc = "Шаблон" })
vim.keymap.set("n", "<leader>or", ":ObsidianRename<cr>", { desc = "Переименовать" })
vim.keymap.set("n", "<leader>oc", ":ObsidianTOC<cr>", { desc = "Содержание" })
vim.keymap.set("v", "<leader>oe", ":ObsidianExtractNote<cr>", { desc = "Извлечь выделенное" })
vim.keymap.set("n", "<leader>ol", ":ObsidianLinks<cr>", { desc = "Ссылки" })
```

Если вы используете which-key, назовите группу хоткеев:

```lua
-- /lua/plugins/which-key.lua
return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { "<leader>o", group = "Obsidian", mode = { "n", "x" } },
    },
  },
}
```
