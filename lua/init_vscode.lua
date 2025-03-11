-- https://github.com/vscode-neovim/vscode-neovim?tab=readme-ov-file#multiple-cursors

-- vim.cmd [[set runtimepath^=$HOME/.config/nvim2_jelly_lzmigrate]]

-- PUT BELOW INSIDE init.lua
-- # FIX: if this has less change of error check if only load this is more stable
-- if vim.g.vscode then
--   vim.notify("In VSCODE only run from init.vscode.lua", vim.log.levels.INFO)
--   require("init_vscode")
--   return
-- end

-- vim.notify("In Neovim only run from init.lua", vim.log.levels.INFO)
-- print(" LAZYYYYYYYYYYYYYYYYYYYYYY ")
-- require else rsolution not working
-- check runtime path print out
-- print(vim.o.runtimepath)
-- currentfiledir = vim.fn.expand("<sfile>:p:h")
-- print("cwd" .. vim.fn.getcwd())
-- print("currentfiledir" .. currentfiledir)
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- full path require
-- local function requiref(module)
--     modulePath = currentfiledir .. "/lua/" .. module:gsub("%.", "/") .. ".lua"
--     print("requiref" .. modulePath)
--   local ok, m = pcall(require, modulePath)
--   if not ok then
--     print("Error loading " .. module .. "\n" .. m)
--   end
--   return m
-- end

require("config.lazy").load("options")

if vim.g.deprecation_warnings == false then
  vim.deprecate = function() end
end

-- Set LSP servers to be ignored when used with `util.root.detectors.lsp`
-- for detecting the LSP root
vim.g.root_lsp_ignore = { "copilot" }

local project_setting = vim.fn.getcwd() .. "/.nvim-config.lua"
-- Check if the file exists and load it
if vim.loop.fs_stat(project_setting) then
  -- Read the file and run it with pcall to catch any errors
  local ok, err = pcall(dofile, project_setting)
  if not ok then
    vim.notify("Error loading project setting: " .. err, vim.log.levels.ERROR)
  end
end

local enable_extra_plugins = {}

local enable_extra_langs = vim.g.enable_langs or {
  go = "yes",
  rust = "yes",
  python = "no",
  ruby = "no",
}

-- Core spec
local spec = {
  -- { import = "core.editor" },
  -- { import = "core.coding" },
  -- { import = "core.colorscheme" },
  -- { import = "core.lspconfig" },
  -- { import = "core.treesitter" },
  -- { import = "plugins" },
  -- { import = "langs" },
  -- { import = "core.myEditor" },
  -- { import = "plugins.vscode" }
  { import = "plugins.vscode" },
}

-- Enable extra plugins and languages
-- for plugin_name, enabled in pairs(enable_extra_plugins) do
--   if enabled == "yes" then
--     table.insert(spec, { import = "plugins.extras." .. plugin_name })
--   end
-- end
-- for lang_name, enabled in pairs(enable_extra_langs) do
--   if enabled == "yes" then
--     table.insert(spec, { import = "langs.extras." .. lang_name })
--   end
-- end

require("lazy").setup({
  spec = spec,
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Do not set colorscheme if using vscode
require("config.lazy").setup(not vim.g.vscode and require("themer").selectColorSchemeByTime() or "")
