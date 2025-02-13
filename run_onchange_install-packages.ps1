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

# Neovim
winget install Neovim.Neovim JesseDuffield.lazygit BurntSushi.ripgrep.MSVC sharkdp.fd
winget install -i llvm

exit 0
