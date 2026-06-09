+++
date = '2025-04-19T21:52:25+03:00'
draft = false
title = 'Hyprland tips and tricks'
author = "Sadykov Miron"
+++

## Smart App Opener

- I use `SUPER-O` to launch my Obsidian vault on workspace 4.
- This little script allows me to always open Obsidian with the same key combination, even if it's already running or moved to a different workspace.
- https://github.com/Reagent992/hyprland_scripts/blob/master/docs/run_or_focus.md there is a code and readme.

## Lock screen and enable English layout at the same time.

- I use waylock. Replace it with your desired locker.

```ini
# .config/hypr/hypridle.conf
# Define a command to switch to the English keyboard layout
$english_layot = hyprctl switchxkblayout keyd-virtual-keyboard 0
general {
    lock_cmd = $english_layot; pidof waylock || $waylock_start
...
```
