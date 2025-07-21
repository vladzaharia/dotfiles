# ZSH Custom Library

This directory contains shared library files used across multiple ZSH plugins.

## Files

### `colors.zsh`
Shared color definitions and utilities for consistent terminal output across all plugins.

**Features:**
- ANSI color constants with modern ZSH best practices
- Semantic color aliases (success, warning, error, etc.)
- Color availability detection
- Color testing function
- Prevents duplicate loading

**Usage:**
```zsh
# Load colors (usually done by plugin files)
source ~/.zsh_custom/lib/colors.zsh

# Use colors in scripts
print "${_COLOR_SUCCESS}Operation completed successfully${_RESET}"
print "${_COLOR_ERROR}An error occurred${_RESET}"

# Test color support
colors_Test
```

**Available Colors:**
- Basic: `_COLOR_RED`, `_COLOR_GREEN`, `_COLOR_YELLOW`, `_COLOR_BLUE`, `_COLOR_MAGENTA`, `_COLOR_CYAN`, `_COLOR_WHITE`, `_COLOR_BLACK`
- Extended: `_COLOR_ORANGE`, `_COLOR_PURPLE`, `_COLOR_PINK`, `_COLOR_LIME`
- Semantic: `_COLOR_SUCCESS`, `_COLOR_WARNING`, `_COLOR_ERROR`, `_COLOR_INFO`, `_COLOR_DEBUG`, `_COLOR_HIGHLIGHT`
- Formatting: `_BOLD`, `_DIM`, `_ITALIC`, `_UNDERLINE`, `_REVERSE`, `_STRIKETHROUGH`
- Reset: `_RESET`

## Plugin Integration

Plugins should load shared libraries in their main plugin file:

```zsh
# In your-plugin.plugin.zsh
if [[ -f "${0:A:h}/../lib/colors.zsh" ]]; then
    source "${0:A:h}/../lib/colors.zsh"
else
    # Fallback definitions
    typeset -g _COLOR_RED='\033[1;31m'
    # ... other fallbacks
fi
```

## Best Practices

1. **Always provide fallbacks** when loading shared libraries
2. **Use semantic colors** when possible (`_COLOR_SUCCESS` vs `_COLOR_GREEN`)
3. **Check color availability** with `colors_Available` for conditional coloring
4. **Use `typeset -gr`** for read-only global constants
5. **Follow ZSH naming conventions** with underscores and descriptive names
