function openBestTerminal()
  -- Check which terminals are installed
  local wezTermExists = hs.fs.displayName("/Applications/WezTerm.app")
  local rioExists = hs.fs.displayName("/Applications/rio.app")
  local iTermExists = hs.fs.displayName("/Applications/iTerm.app")

  if wezTermExists then
    openWezTerm()
  elseif rioExists then
    openRio()
  elseif iTermExists then
    openiTerm()
  else
    openTerminal()
  end
end

function focusBestTerminal()
  -- Check which terminals are installed
  local wezTermExists = hs.fs.displayName("/Applications/WezTerm.app")
  local rioExists = hs.fs.displayName("/Applications/rio.app")
  local iTermExists = hs.fs.displayName("/Applications/iTerm.app")

  -- Check which terminals are running
  local wezTerm = wezTermExists and hs.application.get("com.github.wez.wezterm")
  local rio = rioExists and hs.application.get("com.raphaelamorim.rio")
  local iTerm = itermExists and hs.application.get("com.googlecode.iterm2")
  local terminal = hs.application.get("com.apple.Terminal")

  if wezTerm then
    openWezTerm()
  elseif rio then
    openRio()
  elseif iTerm then
    openiTerm()
  elseif terminal then
    openTerminal()
  else
    openBestTerminal()
  end
end

-- Open WezTerm
function openWezTerm()
  local app = hs.application.get("com.github.wez.wezterm")

  if app then
    if not app:mainWindow() then
      app:selectMenuItem({ "WezTerm", "New OS window" })
    elseif app:isFrontmost() then
      app:hide()
    else
      app:activate()
    end

    app:mainWindow():moveToUnit '[90,80,10,0]'
  else
    hs.application.launchOrFocusByBundleID("com.github.wez.wezterm")
  end
end

-- Open Rio Terminal
function openRio()
  local app = hs.application.get("com.raphaelamorim.rio")

  if app then
    if not app:mainWindow() then
      app:selectMenuItem({ "Rio", "New OS window" })
    elseif app:isFrontmost() then
      app:hide()
    else
      app:activate()
    end

    app:mainWindow():moveToUnit '[90,80,10,0]'
  else
    hs.application.launchOrFocusByBundleID("com.raphaelamorim.rio")
  end
end

-- Open iTerm
function openiTerm()
  local app = hs.application.get("com.googlecode.iterm2")

  if app then
    if not app:mainWindow() then
      app:selectMenuItem({ "iTerm", "New OS window" })
    elseif app:isFrontmost() then
      app:hide()
    else
      app:activate()
    end

    app:mainWindow():moveToUnit '[90,80,10,0]'
  else
    hs.application.launchOrFocusByBundleID("com.googlecode.iterm2")
  end
end

-- Open Terminal
function openTerminal()
  local app = hs.application.get("com.apple.Terminal")

  if app then
    if not app:mainWindow() then
      app:selectMenuItem({ "Terminal", "New OS window" })
    elseif app:isFrontmost() then
      app:hide()
    else
      app:activate()
    end

    app:mainWindow():moveToUnit '[90,80,10,0]'
  else
    hs.application.launchOrFocusByBundleID("com.apple.Terminal")
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
