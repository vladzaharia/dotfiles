local wezterm = require 'wezterm'

local module = {}

local function project_dirs()
  local projects = { "default" }

  -- Import projects.json file 
  local file = io.open(wezterm.home_dir .. "/.config/wezterm/projects.json", "r")
  if file then
    -- Read the content of the file
    local content = file:read("*all")
    file:close()

    -- Parse JSON
    local parsed_content = wezterm.json_parse(content)
    
    -- Load projectDirs from the projects.json file 
    if parsed_content.projectDirs then
      for _, dir in ipairs(parsed_content.projectDirs) do
        local normalized_dir = normalize_path(dir)
        -- Check if the directory exists on disk
        if #wezterm.glob(normalized_dir) == 1 then
          table.insert(projects, dir)
        end
      end
    end
    
    -- Load scanDirs from the projects.json file and add all subdirectories
    if parsed_content.scanDirs then
      for _, scan_dir in ipairs(parsed_content.scanDirs) do
        -- Check if the directory exists on disk
        local normalized_dir = normalize_path(scan_dir)
        if #wezterm.glob(normalized_dir) == 1 then
          for _, dir in ipairs(wezterm.glob(normalized_dir .. '/*')) do
            table.insert(projects, dir)
          end
        end
      end
    end
  end

  return projects
end

function normalize_path(path)
  return path:gsub("~", wezterm.home_dir)
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