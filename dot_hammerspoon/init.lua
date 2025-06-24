local function openTerminal(name, bundleId)
  local app = hs.application.get(bundleId)

  if app then
    if not app:mainWindow() then
      app:selectMenuItem({ name, "New OS window" })
    elseif app:isFrontmost() then
      app:hide()
    else
      app:activate()
    end

    app:mainWindow():moveToUnit '[90,80,10,0]'
  else
    hs.application.launchOrFocusByBundleID(bundleId)
  end
end

local function openBestTerminal()
  -- Check which terminals are installed
  local warpExists = hs.fs.displayName("/Applications/Warp.app")
  local wezTermExists = (not warpExists) and hs.fs.displayName("/Applications/WezTerm.app")
  local rioExists = (not wezTermExists) and hs.fs.displayName("/Applications/rio.app")
  local iTermExists = (not rioExists) and hs.fs.displayName("/Applications/iTerm.app")

  if warpExists then
    openTerminal("Warp", "dev.warp.Warp-Stable")
  elseif wezTermExists then
    openTerminal("WezTerm", "com.github.wez.wezterm")
  elseif rioExists then
    openTerminal("Rio", "com.github.wez.wezterm")
  elseif iTermExists then
    openTerminal("iTerm", "com.googlecode.iterm2")
  else
    openTerminal("Terminal", "com.apple.Terminal")
  end
end

local function focusBestTerminal()
  -- Check which terminals are installed
  local warpExists = hs.fs.displayName("/Applications/Warp.app")
  local wezTermExists = (not warpExists) and hs.fs.displayName("/Applications/WezTerm.app")
  local rioExists = (not wezTermExists) and hs.fs.displayName("/Applications/rio.app")
  local iTermExists = (not rioExists) and hs.fs.displayName("/Applications/iTerm.app")

  -- Check which terminals are running
  local warp = warpExists and hs.application.get("dev.warp.Warp-Stable")
  local wezTerm = wezTermExists and hs.application.get("com.github.wez.wezterm")
  local rio = rioExists and hs.application.get("com.raphaelamorim.rio")
  local iTerm = iTermExists and hs.application.get("com.googlecode.iterm2")
  local terminal = hs.application.get("com.apple.Terminal")

  if warp then
    openTerminal("Warp", "dev.warp.Warp-Stable")
  elseif wezTerm then
    openTerminal("WezTerm", "com.github.wez.wezterm")
  elseif rio then
    openTerminal("Rio", "com.raphaelamorim.rio")
  elseif iTerm then
    openTerminal("iTerm", "com.googlecode.iterm2")
  elseif terminal then
    openTerminal("Terminal", "com.apple.Terminal")
  else
    openBestTerminal()
  end
end

-- Cmd+`
hs.hotkey.bind({ "cmd" }, "`", function()
  focusBestTerminal()
end)

-- Cmd+Esc
hs.hotkey.bind({ "cmd" }, "escape", function()
  focusBestTerminal()
end)
