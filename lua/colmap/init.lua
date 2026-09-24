-- colmap.nvim: Custom Theme Mapping for Neovim
-- This script lets users use custom colorschemes for specific directories set
-- in an external CSV file named `theme_map.csv` stored in configuration path.
-- (C) 2026 Pratik Mullick. Licensed under the Apache License 2.0.

local M = {}
-- Define default options
local default_opts = {
  default_theme = "zellner",
  csv_path = vim.fs.joinpath(vim.fn.stdpath("config"), "theme_map.csv")
}

-- Expose setup function
function M.setup(user_opts)
  local opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})
  local mapfile = io.open(opts.csv_path, "r")

  -- If file does not exist, apply default theme and halt
  if not mapfile then
    local ok = pcall(vim.cmd.colorscheme, opts.default_theme)
    if not ok then
      vim.notify("colmap.nvim: Default theme not found -> " .. opts.default_theme, vim.log.levels.WARN)
    end
    return
  end

  -- Read CSV File once into an indexed array and sort by path length
  local group = vim.api.nvim_create_augroup("ColMap", { clear = true })
  local theme_list = {}


  for line in mapfile:lines() do
    -- Ignore blank lines and comments
    if not line:match("^%s*#") and line:match("%S") then
      local folder_path, colorscheme = line:match("^(.+),([^,]+)$")
      if folder_path and colorscheme then
        -- Trim whitespace
        local dp = folder_path:match("^%s*(.-)%s*$") or folder_path
        local cs = colorscheme:match("^%s*(.-)%s*$") or colorscheme
        -- Strip single or double quotes
        dp = dp:match('^"(.*)"$') or dp:match("^'(.*)'$") or dp
        cs = cs:match('^"(.*)"$') or cs:match("^'(.*)'$") or cs
        if type(dp) == "string" and dp ~= "" and type(cs) == "string" and cs ~= "" then
          -- Normalize path to handle trailing slashes and OS differences
          table.insert(theme_list, { path = vim.fs.normalize(dp), theme = cs })
        end
      end
    end
  end
  mapfile:close()

  -- Sort by path length to check sub-folders ahead of parent directories
  table.sort(theme_list, function(a, b)
    local len_a = a.path and string.len(a.path) or 0
    local len_b = b.path and string.len(b.path) or 0
    return len_a > len_b
  end)

  -- Buffer persistence outside autocmd
  local last_checked_dir = nil
  -- Helper function to load theme without crashing
  local function apply_theme(theme_name)
    if vim.g.colors_name ~= theme_name then
      local ok = pcall(vim.cmd.colorscheme, theme_name)
      if not ok then
        vim.notify("DirColorscheme: Theme not found -> " .. theme_name, vim.log.levels.WARN)
      end
    end
  end


  -- Register Autocmd via Callback
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function()
      local current_file = vim.fn.expand("%:p")
      -- Get current directory for opened file, fallback to getcwd for empty buffer
      local current_dir = current_file == "" and vim.fn.getcwd() or vim.fs.dirname(current_file)
      current_dir = vim.fs.normalize(current_dir)

      -- Within the same folder where BufEnter fired, update cache
      if current_dir == last_checked_dir then
        return
      end
      last_checked_dir = current_dir

      -- Loop through pre-sorted list
      local matched = false
      for _, entry in ipairs(theme_list) do
        if type(entry.path) == "string" then
          -- Strict matching (exact directory, or nested sub-directory)
          if current_dir == entry.path or vim.startswith(current_dir, entry.path .. "/") then
            apply_theme(entry.theme)
            matched = true
            break
          end
        end
      end

      if not matched then
        apply_theme(default_theme)
      end
    end,
  })
end

return M
