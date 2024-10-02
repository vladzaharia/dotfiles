local wezterm = require 'wezterm'
local module = {}

module.color_scheme = 'Aci (Gogh)'

local bg = wezterm.color.parse(wezterm.color.get_builtin_schemes()[module.color_scheme].background)
local fg = wezterm.color.parse(wezterm.color.get_builtin_schemes()[module.color_scheme].foreground)

module.colors = {
    base = {
        bg = bg,
        fg = fg,
    },

    titlebar = {
        active = bg:darken(0.2),
        inactive = bg:darken(0.4),
    },

    active_tab = {
        bg = bg:lighten(0.2),
        fg = fg,
    },

    inactive_tab = {
        bg = bg:darken(0.4),
        fg = fg:darken(0.4):desaturate(0.5),
    },

    inactive_tab_hover = {
        bg = bg:darken(0.4),
        fg = fg,
    },

    new_tab = {
        bg = bg:darken(0.2),
        fg = fg,
    },

    new_tab_hover = {
        bg = bg:darken(0.2),
        fg = fg,
    },
}

return module