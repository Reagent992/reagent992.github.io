+++
date = '2025-04-19T21:52:25+03:00'
draft = false
title = 'Hyprland советы и хитрости'
author = "Sadykov Miron"
tags = ["hyprland", "linux"]
+++

## Умный запуск приложений

- Я использую `SUPER-O` для запуска Obsidian на workspace 4.
- Этот скрипт позволяет всегда открывать Obsidian одной и той же комбинацией, даже если он уже запущен или перемещён на другой workspace.
- <https://github.com/Reagent992/hyprland_scripts/blob/master/docs/run_or_focus.md> — код и readme.

## Блокировка экрана с переключением на английскую раскладку

- Я использую waylock. Замените на свой locker.

```ini
# .config/hypr/hypridle.conf
$english_layot = hyprctl switchxkblayout keyd-virtual-keyboard 0
general {
    lock_cmd = $english_layot; pidof waylock || $waylock_start
...
```
