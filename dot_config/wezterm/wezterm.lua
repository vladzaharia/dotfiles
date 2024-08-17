local wezterm = require 'wezterm'
local action = wezterm.action

-- Local modules
local appearance = require 'helpers/appearance'
local projects = require 'helpers/projects'

local config = wezterm.config_builder()

-- Set color scheme
config.color_scheme = 'Aci (Gogh)'

-- Slightly transparent and blurred background
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30

-- Remove title bar
config.window_decorations = 'RESIZE'

-- Set fonts
config.font = wezterm.font_with_fallback {
  'MonoLisa',
  'Fira Code',
  'Menlo',
  'Monaco',
  'Courier New'
}
config.window_frame = {
  font = wezterm.font({ family = 'MonoLisa', weight = 'Bold' }),
  font_size = 11,
}

-- Add window decoration
wezterm.on('update-status', function(window)
  -- Grab the utf8 character for the "powerline" left facing
  -- solid arrow.
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Grab the current window's configuration, and from it the
  -- palette (this is the combination of your chosen colour scheme
  -- including any overrides).
  local color_scheme = window:effective_config().resolved_palette
  local bg = color_scheme.background
  local fg = color_scheme.foreground

  window:set_right_status(wezterm.format({
    -- Workspace
    { Background = { Color = 'none' } },
    { Foreground = { Color = fg } },
    { Text = SOLID_LEFT_ARROW },

    { Background = { Color = fg } },
    { Foreground = { Color = bg } },
    { Text = ' ' .. window:active_workspace() .. ' ' },

    -- Hostname
    { Background = { Color = fg } },
    { Foreground = { Color = bg } },
    { Text = SOLID_LEFT_ARROW },

    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = ' ' .. wezterm.hostname() .. ' ' },
  }))
end)

-- Add custom hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, { -- PTC-* tickets
  regex = [[(PTC-\d+)]],
  format = 'https://tpci.atlassian.net/browse/$1',
})
-- table.insert(config.hyperlink_rules, { -- mailto links
--   regex = [[\b[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\b]],
--   format = 'mailto:$0',
-- })

-- Add keybindings
config.leader = { key = 'z', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { -- Quick select mode
    key = 'Space',
    mods = 'LEADER',
    action = action.QuickSelect,
  },
  { -- Copy
    key = 'c',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      -- Copy and clear selection
      window:perform_action(action.CopyTo 'ClipboardAndPrimarySelection', pane)
      window:perform_action(action.ClearSelection, pane)
    end),
  },
  { -- Copy or Ctrl+C
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        -- Copy and clear selection
        window:perform_action(action.CopyTo 'ClipboardAndPrimarySelection', pane)
        window:perform_action(action.ClearSelection, pane)
      else
        -- Send key to terminal
        window:perform_action(action.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  },
  { -- Paste
    key = 'p',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        -- Paste and clear selection
        window:perform_action(action.PasteFrom 'PrimarySelection', pane)
        window:perform_action(action.ClearSelection, pane)
      else
        -- Paste from clipboard instead
        window:perform_action(action.PasteFrom 'Clipboard', pane)
      end
    end),
  },
  { -- Jump left
    key = 'LeftArrow',
    mods = 'OPT',
    action = action.SendString '\x1bb',
  },
  { -- Jump right
    key = 'RightArrow',
    mods = 'OPT',
    action = action.SendString '\x1bf',
  },
  { -- Preferences
    key = ',',
    mods = 'SUPER',
    action = action.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      args = { 'code', wezterm.config_dir },
    },
  },
  { -- Project picker
    key = 'p',
    mods = 'LEADER',
    action = projects.choose_project(),
  },
  { -- Workspaces
    key = 'w',
    mods = 'LEADER',
    action = action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
  },
  {  -- Move to previous tab
    key = 'LeftArrow',
    mods = 'SUPER',
    action = action.ActivateTabRelative(-1),
  },
  { -- Move to next tab
    key = 'RightArrow',
    mods = 'SUPER',
    action = action.ActivateTabRelative(1),
  },
}

return config
