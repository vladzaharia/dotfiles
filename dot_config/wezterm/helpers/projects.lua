local wezterm = require 'wezterm'
local module = {}

local project_dir = wezterm.home_dir .. "/Documents/Repos"

local function project_dirs()
  local projects = { "default" }

  for _, dir in ipairs(wezterm.glob(project_dir .. '/*')) do
    table.insert(projects, dir)
  end

  return projects
end

function module.choose_project()
  local choices = {}
  for _, value in ipairs(project_dirs()) do
    table.insert(choices, { id = value, label = value:match("([^/]+)$") })
  end

  return wezterm.action.InputSelector {
    title = "Projects",
    description = "Select a project to switch to its workspace:",
    fuzzy_description = "Select or search for a project: ",
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(window, pane, id, label)
      if not label then return end

      window:perform_action(wezterm.action.SwitchToWorkspace{
        name = label,
        spawn = { 
          cwd = id,
          label = label
        },
      }, pane)
    end),
  }
end

return module