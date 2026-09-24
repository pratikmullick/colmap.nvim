# colmap.nvim - A Colorscheme Mapper for Neovim
A colorscheme-mapping plugin for Neovim colorscheme where chosen directories
have their own colorschemes set through a CSV file.

## Contents
- [Features](#features)
- [Installation](#installation)
  - [lazy.nvim](#lazynvim)
  - [packer.nvim](#packernvim)
- [Configuration](#configuration)
  - [CSV Format](#csv-format)
- [Limitations](#limitations)
- [License](#license)
- [How to Contribute](#how-to-contribute)
- [Support](#support)

## Features
- Automatically apply colorschemes when:
  - Loading a new file
  - Navigating to a new directory
  - Switching between buffers with different working directories
- Supports custom mappings using a simple CSV file
- Supports both absolute and relative directory paths
- Lightweight and designed to minimize system resource calls
- Maintains persistent theme setting across buffers

## Installation
Install `colmap.nvim` using your preferred package manager and call the `setup`
function, with an optional configuration table to override default settings.

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
return {
  {
    "pratikmullick/colmap.nvim",
    opts = {
    -- Optional Configuration Overrides
    default_theme = "zellner",
    -- csv_path = "/path/to/custom/theme_map.csv"
    },
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use({
  "pratikmullick/colmap.nvim",
  config = function()
    require("colmap").setup({
      -- Optional Configuration Overrides
      default_theme = "zellner",
      -- csv_path = "/path/to/custom/theme_map.csv"
    })
  end,
})
```

## Configuration
Directory mappings are configured using a plain text CSV file, located at the
base of the Neovim configuration directory named `theme_map.csv` by default.
Otherwise, the plugin can be configured to use a different CSV file at a custom
location during installation, with examples shown above.

### CSV Format
The CSV file should contain entries in the format:
```
directory_path,colorscheme_name
```

Supported directory path formats are:
| Operating System | Directory Structure           |
|------------------|-------------------------------|
| UNIX             | `/absolute/path/to/directory` |
| UNIX             | `~/relative/path/`            |
| Windows          | `C:\Users\Username\`          |

The plugin ignores lines starting with the `#` character, allowing for comments
to be embedded within the file, which might break its use with other common
programs that use CSV as a data storage medium.

## Limitations
- Ignores parent directory mappings if exact sub-directory match exists
- Case-sensitive matching (currently no case-insensitivity)

## License
(C) 2026, Pratik Mullick
This project is licensed under the Apache License 2.0 - see the
[LICENSE](LICENSE) file for details.

## How to Contribute
1. Fork the repository and "Star" It (⭐)
2. Create a pull request with your changes
3. Update the documentation if you add new features
4. Translate the documentation to your language
5. Test across various operating systems

## Support
Please open an [issue](https://github.com/pratikmullick/colmap.nvim/issues) on
GitHub for general queries, or if you have encountered a bug.

