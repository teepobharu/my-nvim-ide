-- @class telescope-lazy
-- source: https://www.lazyvim.org/extras/editor/telescope
-- https://github.com/LazyVim/LazyVim/blob/0e2eaa3fbad1519e9f4fb29235e13374f297ff00/lua/lazyvim/plugins/extras/editor/telescope.lua#L7
local LazyUtil = require("utils.lazyutils")
local Path = require("utils.path")
local have_make = vim.fn.executable("make") == 1
local have_cmake = vim.fn.executable("cmake") == 1

---@class telescope-lazy.Inputo.Opts: table<string, any>
---@field root? boolean
---@field git? boolean
---@field cwd? string
---@field filed? boolean
---@field pwd? boolean
---@field cmd? "find_files" | "live_grep" | "git_files" | "grep_string"
---@field opts? any

---@param inputo? telescope-lazy.Inputo.Opts
function telescope_builtins_wrapper(inputo)
  inputo = inputo or {}
  local opts = inputo.opts or {}

  -- find current pwd
  if inputo.filed then
    opts.cwd = vim.fn.expand("%:p:h")
  elseif inputo.pwd or inputo.root then
    opts.cwd = vim.fn.getcwd()
    -- try
    -- opts.cwd = Path.get_root_directory()
    -- telescope : utils.buffer_dir() = vim.fn.expand "%:p:h"
  elseif inputo.cwd then
    opts.cwd = inputo.cwd
  end

  if (not opts.cwd or inputo.git) and Path.is_git_repo() then
    opts.cwd = Path.get_git_root_dotgit()
  end
  -- opts to telescope: https://github.com/nvim-telescope/telescope.nvim/blob/bfcc7d5c6f12209139f175e6123a7b7de6d9c18a/lua/telescope/builtin/init.lua#L68
  inputo.cmd = inputo.cmd or "find_files"

  local opts_string = inputo.cmd .. vim.inspect(opts):gsub("\n", ""):gsub(" ", "")
  opts.prompt_title = opts_string
  return function()
    require("telescope.builtin")[inputo.cmd](opts)
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = have_make and "make"
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = have_make or have_cmake,
        config = function(plugin)
          LazyUtil.on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf." .. (LazyUtil.is_win() and "dll" or "so")
              if not vim.uv.fs_stat(lib) then
                vim.notify("`telescope-fzf-native.nvim` not built. Rebuilding...", vim.log.levels.WARN)
                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                  vim.notify("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
                end)
              else
                vim.notify("Failed to load `telescope-fzf-native.nvim`:\n" .. err, vim.log.levels.ERROR)
              end
            end
          end)
        end,
      },
    },
    keys = {
      {
        "<leader>,",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      {
        "<leader>/",
        telescope_builtins_wrapper({ root = true, cmd = "live_grep" }),
        desc = "Grep (Root Dir)",
      },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      {
        "<leader><space>",
        telescope_builtins_wrapper({ root = true, cwd = Path.get_root_directory() }),
        desc = "Find Files (Root Dir)",
      },
      -- find
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      {
        "<leader>fc",
        telescope_builtins_wrapper({ cwd = vim.fn.expand("$DOTFILES_DIR/.config/nvim2_jelly_lzmigrate") }),
        desc = "Find Config File",
      },
      { "<leader>ff", telescope_builtins_wrapper({ root = true }), desc = "Find Files (Root Dir)" },
      {
        "<leader>fF",
        telescope_builtins_wrapper({ git = true }),
        desc = "Find Files (git-files)",
      },
      {
        "<leader>fg",
        "<cmd>Telescope git_files<cr>",
        desc = "Find Files (git-files)",
      },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", telescope_builtins_wrapper({ cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
      { "<leader>sg", telescope_builtins_wrapper({ root = true, cmd = "live_grep" }), desc = "Grep (Root Dir)" },
      { "<leader>sG", telescope_builtins_wrapper({ pwd = true, cmd = "live_grep" }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
      {
        "<leader>sw",
        telescope_builtins_wrapper({ cmd = "grep_string", pwd = true, opts = { word_match = "-w" } }),
        desc = "Word (Root Dir)",
      },
      {
        "<leader>sW",
        telescope_builtins_wrapper({ cmd = "grep_string", filed = true, word_match = "-w" }),
        desc = "Word (cwd)",
      },
      {
        "<leader>sw",
        telescope_builtins_wrapper({ cmd = "grep_string", pwd = true }),
        mode = "v",
        desc = "Selection (Root Dir)",
      },
      {
        "<leader>sW",
        telescope_builtins_wrapper({ cmd = "grep_string", filed = true }),
        mode = "v",
        desc = "Selection (cwd)",
      },
      {
        "<leader>uC",
        telescope_builtins_wrapper({ cmd = "colorscheme", opts = { enable_preview = true } }),
        desc = "Colorscheme with Preview",
      },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = LazyVim.config.get_kind_filter(),
          })
        end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            symbols = LazyVim.config.get_kind_filter(),
          })
        end,
        desc = "Goto Symbol (Workspace)",
      },
    },
    opts = function()
      local actions = require("telescope.actions")

      local open_with_trouble = function(...)
        return require("trouble.sources.telescope").open(...)
      end
      local find_files_no_ignore = function()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        LazyVim.pick("find_files", { no_ignore = true, default_text = line })()
      end
      local find_files_with_hidden = function()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        LazyVim.pick("find_files", { hidden = true, default_text = line })()
      end

      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_with_trouble,
              ["<a-i>"] = find_files_no_ignore,
              ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["q"] = actions.close,
            },
          },
        },
      }
    end,
  },
}
