-- Cache terminal preferences on startup (much faster than repeated file system checks)
local terminals = {}
local preferredTerminal = nil
local lastActiveApp = nil -- Cache last active terminal for even faster switching

local function initializeTerminals()
  -- Define terminals in order of preference with correct bundle IDs
  local terminalConfigs = {
    { name = "Warp", bundleId = "dev.warp.Warp-Stable", path = "/Applications/Warp.app" },
    { name = "WezTerm", bundleId = "com.github.wez.wezterm", path = "/Applications/WezTerm.app" },
    { name = "Rio", bundleId = "com.raphaelamorim.rio", path = "/Applications/rio.app" },
    { name = "iTerm", bundleId = "com.googlecode.iterm2", path = "/Applications/iTerm.app" },
    { name = "Terminal", bundleId = "com.apple.Terminal", path = "/Applications/Utilities/Terminal.app" }
  }

  -- Cache which terminals are installed (only check once on startup)
  for _, config in ipairs(terminalConfigs) do
    if hs.fs.displayName(config.path) then
      terminals[config.bundleId] = config -- Use hash table for O(1) lookup
      if not preferredTerminal then
        preferredTerminal = config
      end
    end
  end

  -- Fallback to Terminal if nothing else is found
  if not preferredTerminal then
    preferredTerminal = { name = "Terminal", bundleId = "com.apple.Terminal" }
    terminals[preferredTerminal.bundleId] = preferredTerminal
  end
end

local function positionWindow(app)
  -- Immediate positioning without timer for better responsiveness
  local window = app:mainWindow()
  if window then
    window:moveToUnit('[90,80,10,0]')
  end
end

local function toggleTerminal()
  -- Fast path: Check if last active terminal is still running and frontmost
  if lastActiveApp and lastActiveApp:isRunning() then
    if lastActiveApp:isFrontmost() then
      lastActiveApp:hide()
      return
    else
      lastActiveApp:activate()
      positionWindow(lastActiveApp)
      return
    end
  end

  -- Find any running terminal (check in preference order)
  local runningApps = hs.application.runningApplications()
  for _, app in ipairs(runningApps) do
    local bundleId = app:bundleID()
    if terminals[bundleId] then -- O(1) hash table lookup
      lastActiveApp = app -- Cache for next time
      if app:isFrontmost() then
        app:hide()
      else
        app:activate()
        positionWindow(app)
      end
      return
    end
  end

  -- No terminal is running, launch the preferred one
  hs.application.launchOrFocusByBundleID(preferredTerminal.bundleId)
  -- Set up a watcher to cache the app once it launches
  hs.timer.doAfter(0.5, function()
    lastActiveApp = hs.application.get(preferredTerminal.bundleId)
  end)
end

-- Initialize terminal cache on startup
initializeTerminals()

-- Cmd+` - Toggle terminal
hs.hotkey.bind({ "cmd" }, "`", toggleTerminal)

-- Cmd+Esc - Toggle terminal
hs.hotkey.bind({ "cmd" }, "escape", toggleTerminal)
