+++
date = '2025-04-17T15:03:16+03:00'
draft = true
title = 'How to make obsidian.nvim plugin less opinionated'
author = "Sadykov Miron"
+++

I prefer simple Obsidian and don't use any note taking systems.
**obsidian.nvim** is a great plugin, but it enforces the Zettelkasten method by default.  
I spent about an hour customizing the configuration to remove that and make it behave more like plain Obsidian.

Since I use **LazyVim**, my plugin files follow its structure:

```lua
-- ./lua/plugins/obsidian-nvim.lua
-- https://github.com/obsidian-nvim/obsidian.nvim
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    -- Required.
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
      -- LazyVim uses blink.nvim for completion
      blink = true,
      min_chars = 2,
    },
    -- Custom note ID function to name notes manually
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title
      else
        -- I never create unnamed notes, so it's just a stub
        suffix = "New_note_"
        for _ = 1, 6 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return suffix
    end,
    -- By deafult plugin adds note parameters, there is disabling.
    disable_frontmatter = true,
  },
}
```

I also added some convenient keymaps:

```lua
-- /lua/config/keymaps.lua
vim.keymap.set("n", "<leader>oo", ":ObsidianOpen<cr>", { desc = "Open in app" })
vim.keymap.set("n", "<leader>on", ":ObsidianNew<cr>", { desc = "New note" })
vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks<cr>", { desc = "Backlinks" })
vim.keymap.set("n", "<leader>ot", ":ObsidianTemplate<cr>", { desc = "Template" })
vim.keymap.set("n", "<leader>or", ":ObsidianRename<cr>", { desc = "Rename" })
vim.keymap.set("n", "<leader>oc", ":ObsidianTOC<cr>", { desc = "Content" })
vim.keymap.set("v", "<leader>oe", ":ObsidianExtractNote<cr>", { desc = "Extract selected" })
vim.keymap.set("n", "<leader>ol", ":ObsidianLinks<cr>", { desc = "Links" })
```

If you're using the which-key plugin, name the keymap group:

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
