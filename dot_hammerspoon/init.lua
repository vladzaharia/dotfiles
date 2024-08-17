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

-- Cmd+`
hs.hotkey.bind({ "cmd" }, "`", function()
  openWezTerm()
end)

-- Cmd+Esc
hs.hotkey.bind({ "cmd" }, "escape", function()
  openWezTerm()
end)
