+++
date = '2025-04-19T21:52:25+03:00'
draft = false
title = 'Hyprland tips and tricks'
author = "Sadykov Miron"
+++

## Smart App Opener
- I use `SUPER-O` to launch my Obsidian vault on workspace 4.
- This little script allows me to always open Obsidian with the same key combination, even if it's already running or moved to a different workspace.

### Create the script
1. `nvim ~/.config/hypr/scripts/open.sh`

```bash
#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  exit 1
fi

PROGRAM="$1"
TARGET_WORKSPACE="$2"

IS_RUNNING=$(hyprctl clients -j | jq -e \
  --arg prog "$PROGRAM" \
  '.[] | select(.class == $prog)' >/dev/null && echo yes)

if [ "$IS_RUNNING" != "yes" ]; then
  hyprctl dispatch exec "[workspace $TARGET_WORKSPACE] $PROGRAM"
  exit 0
fi

WORKSPACE=$(hyprctl clients -j | jq -r \
  --arg prog "$PROGRAM" \
  '.[] | select(.class == $prog) | .workspace.id' | head -n 1)

[ -n "$WORKSPACE" ] && hyprctl dispatch workspace "$WORKSPACE"
```
### Make it executable
2. `chmod +x ~/.config/hypr/scripts/open.sh`

### Bind the script in `hyprland.conf`
3. `nvim ~/.config/hypr/hyprland.conf`
- You can use this script with any application. Just pass the app and the desired workspace number.
```bash
$open = ~/.config/hypr/scripts/open.sh
bind = SUPER, O, exec, $open obsidian 4
bind = SUPER, A, exec, $open anki     5
```

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

