# Set execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

###
### Install packages using winget
###

# Apps
winget install AgileBits.1Password

# Productivity tools
winget install clink starship tailscale.tailscale wazuh.wazuhagent wez.wezterm

# Dev tools
winget install docker.dockerdesktop git.git Microsoft.VisualStudioCode Microsoft.WindowsTerminal

# Customization tools
winget install steelseries.gg

exit 0
