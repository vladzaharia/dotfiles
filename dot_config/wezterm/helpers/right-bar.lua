local wezterm = require 'wezterm'
local module = {}

function get_segments(window)
  local base_segments = {
    wezterm.hostname(),
  }
  
  local idx = 0
  
  -- Insert workspace if it's not default
  if window:active_workspace() ~= "default" then
    table.insert(base_segments, 1, "󱂬 " .. window:active_workspace())
    idx = idx + 1
  end
  
  -- Insert domain if it's not local
  local domain = window:active_pane():get_domain_name()
  if domain ~= "local" then
    local icon = " "
    
    if string.find(domain, "WSL") ~= nil then
      icon = "󰌽 "
      domain = domain:gsub("WSL:", "")
    end

    if string.find(domain, "SSH") ~= nil then
      icon = "󰢩 "
      domain = domain:gsub("SSH:", "")
    end

    table.insert(base_segments, 1, icon .. domain)
    idx = idx + 1
  end
  
  -- Insert battery percentage if it's low
  local battery = wezterm.battery_info()
  local battery_percentage = 100
  
  if battery and battery[1] and battery[1].state_of_charge < 0.30 and battery[1].state ~= "Charging" then
    battery_percentage = battery[1].state_of_charge * 100
    table.insert(base_segments, idx + 1, string.format("󰂃 %.0f%%", battery_percentage))
  end
  
  return base_segments
end

function module.update_status(window, _)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local segments = get_segments(window)

  local color_scheme = window:effective_config().resolved_palette
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground

  -- Create progressive color hops based on the system appearance
  local gradient_to, gradient_from = bg
  gradient_from = gradient_to:lighten(0.2)
  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )

  -- Build up elements based on segments
  local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1
    local current_color = gradient[i]

    -- Show battery specific colorway instead of default bg
    if string.find(seg, "󰂃") ~= nil then
      local battery_percentage = tonumber(string.match(seg, "(%d+)%%"))
      if battery_percentage and battery_percentage < 10 then
        current_color = "#8a164a"
      else 
        current_color = "#993f00"
      end
    end

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = current_color } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = current_color } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end

return module