+++
date = '2025-06-29T13:27:35+03:00'
draft = false
title = 'Everforest'
author = "Sadykov Miron"
toc = true
description = 'How I use the Everforest theme'
+++

> It's a color scheme for various applications.

- [Original Everforest GitHub repo](https://github.com/sainnhe/everforest)

## palette

- I use only **medium dark** so there will be only medium dark colors.

![Color palette](./colors.png)

```
bg_dim #232a2e;
bg0 #2d353b;
bg1 #343f44;
bg2 #3d484d;
bg3 #475258;
bg4 #4f585e;
bg5 #56635f;
bg_visual #543a48;
bg_red #514045;
bg_green #425047;
bg_blue #3a515d;
bg_yellow #4d4c43;
fg #d3c6aa;
red #e67e80;
orange #e69875;
yellow #dbbc7f;
green #a7c080;
aqua #83c092;
blue #7fbbb3;
purple #d699b6;
grey0 #7a8478;
grey1 #859289;
grey2 #9da9a0;
statusline1 #a7c080;
statusline2 #d3c6aa;
statusline3 #e67e80;
```

## My configs

- My main font is: [FiraCode](https://github.com/tonsky/FiraCode) with [nerd font icons](https://www.nerdfonts.com/font-downloads)
- One thing I don't like in Everforest is the bright green. I prefer to dim it a little bit.

My workspace example:
![Everforest_example](hyprland_workspace_everforest.png)

<!-- ### sddm -->
<!---->
<!-- ![sddm_everforest_example](sddm_everforest.png) -->

### lockscreen

#### waylock

> it's a simple one-color screen locker.

```
waylock -init-color 0x232A2E -input-color 0x2D353B -fail-color 0x543A48 -input-alt-color 0x232A2E -ignore-empty-password -fork-on-lock
```

<!-- #### hyprlock -->
<!---->
<!-- TODO: -->

### hyprland

```ini
$bg_dim = rgb(232a2e)
$bg0 = rgb(2d353b)
$bg1 = rgb(343f44)
$bg2 = rgb(3d484d)
$bg3 = rgb(475258)
$bg4 = rgb(4f585e)
$bg5 = rgb(56635f)
$bg_visual = rgb(543a48)
$bg_red = rgb(514045)
$bg_green = rgb(425047)
$bg_blue = rgb(3a515d)
$bg_yellow = rgb(4d4c43)
$fg = rgb(d3c6aa)
$red = rgb(e67e80)
$orange = rgb(e69875)
$yellow = rgb(dbbc7f)
$yellow_quiet = rgba(219,188,127,0.6)
$green = rgb(a7c080)
$green_quiet = rgba(167,192,128,0.6)
$aqua = rgb(83c092)
$blue = rgb(7fbbb3)
$purple = rgb(d699b6)
$grey0 = rgb(7a8478)
$grey1 = rgb(859289)
$grey2 = rgb(9da9a0)
$statusline1 = rgb(a7c080)
$statusline2 = rgb(d3c6aa)
$statusline3 = rgb(e67e80)

```

- Bar on top of window is a group, and yellow is a locked group
- I use `#232a2e` as the background (wallpaper) color. It's bg_dim.

```ini
misc {
    background_color = $bg_dim
}
```

#### default everforest

![everforest_default_1](./hyprland_imgs/hyprland_default_1.png)
![everforest_default_2](./hyprland_imgs/hyprland_default_2.png)
![everforest_default_3](./hyprland_imgs/hyprland_default_3.png)

```ini
general {
    col.active_border = $green
    col.inactive_border = $bg_green
}
group {
    col.border_active = $green
    col.border_inactive = $bg_green
    col.border_locked_active = $yellow
    col.border_locked_inactive = $bg_yellow
    groupbar {
      text_color = $fg
      col.active = $green
      col.inactive = $bg_green
      col.locked_active = $yellow
      col.locked_inactive = $bg_yellow
    }
}
```

#### my flavor

I found the default Everforest too bright for me. so i dim it little bit and turn off inactive border due to i use matched backround(wallpaper) color.

![everforest_flavor_1](./hyprland_imgs/hyprland_flavor_1.png)
![everforest_flavor_2](./hyprland_imgs/hyprland_flavor_2.png)
![everforest_flavor_3](./hyprland_imgs/hyprland_flavor_3.png)

```ini
general {
    col.active_border = $green_quiet
    col.inactive_border = $bg_dim
}
group {
    col.border_active = $green_quiet
    col.border_inactive = $bg_dim
    col.border_locked_active = $yellow_quiet
    col.border_locked_inactive = $bg_dim
    groupbar {
      text_color = $fg
      col.active = $green_quiet
      col.inactive = $bg_green
      col.locked_active = $yellow_quiet
      col.locked_inactive = $bg_yellow
    }
}

```

### ncspot

> It's a Spotify TUI player.

- [ncspot github](https://github.com/hrkfdn/ncspot)

![result](ncspot_everforest.png)

Config file path: `~/.config/ncspot/config.toml`

```toml
[theme]
background = "#2D353B"
primary = "#D3C6AA"
secondary = "#D3C6AA"
title = "#D3C6AA"
playing = "#A7C080"
playing_selected = "#A7C080"
playing_bg = "#2D353B"
highlight = "#D3C6AA"
highlight_bg = "#343F44"
error = "#E67E80"
error_bg = "#514045"
statusbar = "#D3C6AA"
statusbar_progress = "#A7C080"
statusbar_bg = "#2D353B"
cmdline = "#2D353B"
cmdline_bg = "#D3C6AA"
```

### Waybar

> It's a bar on the side of the screen that displays the time/date, language, volume, etc.

- [waybar github](https://github.com/Alexays/Waybar)

```css
/* https://github.com/Alexays/Waybar/wiki/Styling */
/* Everforest medium-dark color scheme */
@define-color bg_dim #232a2e;
@define-color bg0 #2d353b;
@define-color bg1 #343f44;
@define-color bg2 #3d484d;
@define-color bg3 #475258;
@define-color bg4 #4f585e;
@define-color bg5 #56635f;
@define-color bg_visual #543a48;
@define-color bg_red #514045;
@define-color bg_green #425047;
@define-color bg_blue #3a515d;
@define-color bg_yellow #4d4c43;
@define-color fg #d3c6aa;
@define-color red #e67e80;
@define-color orange #e69875;
@define-color yellow #dbbc7f;
@define-color green #a7c080;
@define-color aqua #83c092;
@define-color blue #7fbbb3;
@define-color purple #d699b6;
@define-color grey0 #7a8478;
@define-color grey1 #859289;
@define-color grey2 #9da9a0;
@define-color statusline1 #a7c080;
@define-color statusline2 #d3c6aa;
@define-color statusline3 #e67e80;

* {
  font-family: "FiraCode Nerd Font";
  font-size: 14px;
  font-weight: 500;
  color: @fg;
}

#waybar {
  background: @bg_dim;
}

/* basic style for all modules */
/* add all your custom modules here */
#workspaces,
#clock,
#battery,
#pulseaudio,
#network,
#language,
#backlight,
#tray,
#custom-power,
#custom-date,
#cpu,
#memory,
#disk,
#temperature,
#custom-weather,
#custom-docker,
#bluetooth,
#custom-docker-micro,
#privacy,
#systemd-failed-units,
#custom-notifications,
#custom-swaync {
  background-color: @bg0;
  padding: 0px 10px 0px;
  margin: 5px;
  border-radius: 5px;
  min-width: 20px;
}

#workspaces {
  background-color: @bg_dim;
}

#workspaces button {
  color: @fg;
  background: transparent;
}

#workspaces button.active {
  background: @bg0;
}

/* blink animation */
@keyframes urgent-blink {
  0% {
    background-color: @red;
  }

  50% {
    background-color: transparent;
  }

  100% {
    background-color: @red;
  }
}

#workspaces button.urgent {
  animation: urgent-blink 2s infinite;
  color: @statusline3;
}
```

<!-- ## Community links -->
<!---->
<!-- ### Obsidian -->
<!---->
<!-- i use [Obsidian Everforest Enchanted - github](https://github.com/FireIsGood/obsidian-everforest-enchanted/tree/main) -->
<!-- but it use Everforest dark sort, so i change it littel bit to fit Everforest dark medium. -->
<!-- file: `.obsidian/themes/Everforest Enchanted/theme.css` -->
<!---->
<!-- ```css -->
<!-- /** Dark Theme (medium) **/ -->
<!-- :root .theme-dark { -->
<!--   --bg-dim-rgb: 35, 42, 46; -->
<!--   --bg-dim: #232a2e; -->
<!--   --bg0: #2d353b; -->
<!--   --bg1: #343f44; -->
<!--   --bg2: #3d484d; -->
<!--   --bg3: #475258; -->
<!--   --bg4: #4f585e; -->
<!--   --bg5: #56635f; -->
<!---->
<!--   --bg-visual: #543a48; -->
<!--   --bg-red: #514045; -->
<!--   --bg-green: #425047; -->
<!--   --bg-blue: #3a515d; -->
<!--   --bg-yellow: #4d4c43; -->
<!---->
<!--   --fg: #d3c6aa; -->
<!---->
<!--   --fg-red: #e67e80; -->
<!--   --fg-orange: #e69875; -->
<!--   --fg-yellow: #dbbc7f; -->
<!--   --fg-green: #a7c080; -->
<!--   --fg-aqua: #83c092; -->
<!--   --fg-blue: #7fbbb3; -->
<!--   --fg-purple: #d699b6; -->
<!---->
<!--   --header-red: #e67e80; -->
<!--   --header-orange: #e69875; -->
<!--   --header-yellow: #dbbc7f; -->
<!--   --header-green: #a7c080; -->
<!--   --header-aqua: #83c092; -->
<!--   --header-blue: #7fbbb3; -->
<!--   --header-purple: #d699b6; -->
<!---->
<!--   --grey0: #7a8478; -->
<!--   --grey1: #859289; -->
<!--   --grey2: #9da9a0; -->
<!---->
<!--   --statusline0: #a7c080; -->
<!--   --statusline1: #d3c6aa; -->
<!--   --statusline2: #e67e80; -->
<!---->
<!--   --bg0-rgb: 45, 53, 59; -->
<!--   --background-embed-transparent: rgba(62, 75, 80, 0.7); -->
<!--   --tag-color-hsl: 254, 80%, 68%; -->
<!-- } -->
<!-- ``` -->
<!---->
<!-- ### swaync -->
<!---->
<!-- There is public repo with good everforest css [here](https://github.com/mirzmu/Hyprland-Dots-Ethan/blob/main/.config/swaync/Everforest.css) -->
<!-- But -->
<!---->
<!-- ### ANKI -->
<!---->
<!-- TODO: -->
<!---->
<!-- ### Firefox and Betterbird -->
<!---->
<!-- > Betterbird is a Thunderbird fork with improvements for Linux. -->
<!---->
<!-- ### qutebrowser -->
