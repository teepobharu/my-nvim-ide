-- editor.lua in Lazy override
-- setup examples
-- https://github.com/LazyVim/LazyVim/blob/0e2eaa3fbad1519e9f4fb29235e13374f297ff00/lua/lazyvim/plugins/editor.lua#L43
-- open spectre search and live grep telescope : https://www.reddit.com/r/neovim/comments/17o6g2n/comment/k7wf2wp/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
local Util = require("lazy.core.util")
local Path = require("utils.path")

-- LazyVim : original neotree https://github.com/LazyVim/LazyVim/blob/1f8469a53c9c878d52932818533ce51c27ded5b6/lua/lazyvim/plugins/editor.lua#L23
return {
  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    -- https://github.com/LazyVim/LazyVim/blob/b601ade71c7f8feacf62a762d4e81cf99c055ea7/lua/lazyvim/plugins/editor.lua
    -- original config: https://github.com/nvim-neo-tree/neo-tree.nvim?tab=readme-ov-file#quickstart
    cmd = "Neotree",
    init = function()
      -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
      -- because `cwd` is not set up properly.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        desc = "Start Neo-tree with directory",
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == "directory" then
              require("neo-tree")
            end
          end
        end,
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    keys = {
      -- {
      --   "<leader>e",
      --   function()
      --     require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
      --   end,
      --   desc = "Explorer NeoTree (Root Dir)",
      -- },
      -- {
      --   "<leader>E",
      --   function()
      --     require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      --   end,
      -- desc = "Explorer NeoTree (cwd)",
      -- },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git Explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer Explorer",
      },
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = Path.get_root_directory() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    -- { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
    -- { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    opts = function(_, opts)
      -- lazyvim.nvim
      opts.open_files_do_not_replace_types = opts.open_files_do_not_replace_types
        or { "terminal", "Trouble", "qf", "Outline", "trouble" }
      table.insert(opts.open_files_do_not_replace_types, "edgy")
      -- use function to merge config (behiovr = force/override  )
      Util.merge(
        opts,
        -- lazy
        {
          sources = { "filesystem", "buffers", "git_status" },
          open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
          filesystem = {
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
          },
          window = {
            mappings = {
              ["l"] = "open",
              ["h"] = "close_node",
              ["<space>"] = "none",
              ["Y"] = {
                function(state)
                  local node = state.tree:get_node()
                  local path = node:get_id()
                  vim.fn.setreg("+", path, "c")
                end,
                desc = "Copy Path to Clipboard",
              },
              ["O"] = {
                function(state)
                  require("lazy.util").open(state.tree:get_node().path, { system = true })
                end,
                desc = "Open with System Application",
              },
              ["P"] = { "toggle_preview", config = { use_float = false } },
            },
          },
          default_component_configs = {
            indent = {
              with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
              expander_collapsed = "",
              expander_expanded = "",
              expander_highlight = "NeoTreeExpander",
            },
            git_status = {
              symbols = {
                unstaged = "󰄱",
                staged = "󰱒",
              },
            },
          },
        },
        ---- my part
        {
          commands = {
            copy_selector = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local filename = node.name
              local modify = vim.fn.fnamemodify

              local results = {
                filepath,
                modify(filepath, ":."),
                modify(filepath, ":~"),
                filename,
                modify(filename, ":r"),
                modify(filename, ":e"),
              }

              vim.ui.select({
                "1. Absolute path: " .. results[1],
                "2. Path relative to CWD: " .. results[2],
                "3. Path relative to HOME: " .. results[3],
                "4. Filename: " .. results[4],
                "5. Filename without extension: " .. results[5],
                "6. Extension of the filename: " .. results[6],
              }, { prompt = "Choose to copy to clipboard:" }, function(choice)
                if choice then
                  local i = tonumber(choice:sub(1, 1))
                  if i then
                    local result = results[i]
                    vim.fn.setreg('"', result)
                    vim.notify("Copied: " .. result .. " to vim clipboard")
                  else
                    vim.notify("Invalid selection")
                  end
                else
                  vim.fn.setreg('"', results[4])
                  vim.notify("Copied: " .. results[4] .. " to vim clipbard by default")
                end
              end)
            end,
            copy_file_name_current = function(state)
              local node = state.tree:get_node()
              local filename = node.name
              vim.fn.setreg('"', filename)
              vim.notify("Copied: " .. filename)
            end,
            copy_abs_file = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              vim.fn.setreg('"', filepath)
              vim.notify("Copied: " .. filepath)
            end,
            telescope_livegrep_cwd = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local is_dir = node.type == "directory"
              local cwdPath = is_dir and filepath or vim.fn.fnamemodify(filepath, ":h")
              local extra_opts = node.type == "file" and { "-d=1" } or {}
              require("telescope.builtin").live_grep({ cwd = cwdPath, additional_args = extra_opts })
            end,
            telescope_find_files = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local is_dir = node.type == "directory"
              local cwdPath = is_dir and filepath or vim.fn.fnamemodify(filepath, ":h")
              local extra_opts = node.type == "file" and { "-d=1" } or {}
              require("telescope.builtin").find_files({ cwd = cwdPath, opts = extra_opts })
            end,
            telescope_cd = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local cwdPath = vim.fn.fnamemodify(filepath, ":h")
              vim.notify("Changing directory to: " .. cwdPath)
              vim.cmd("cd " .. cwdPath)
            end,
          },
          -- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/370
          filesystem = {
            window = {
              width = 30,
              mappings = {
                ["l"] = "open",
                ["h"] = "close_node",
                ["<space>"] = "none",
                ["<Esc>"] = "clear_filter",
                ["/"] = "none",
                ["f"] = "fuzzy_finder",
                ["F"] = "filter_on_submit",
                ["<tab>"] = "toggle_node",

                ["Y"] = {
                  function(state)
                    local node = state.tree:get_node()
                    local path = node:get_id()
                    vim.fn.setreg("+", path, "c")
                  end,
                  desc = "Copy Path to Clipboard",
                },

                ["O"] = {
                  function(state)
                    require("lazy.util").open(state.tree:get_node().path, { system = true })
                  end,
                  desc = "Open with System Application",
                },
                ["P"] = { "toggle_preview", config = { use_float = false } },
                -- custom binding
                ["YY"] = "copy_selector",
                ["Yp"] = "copy_file_name_current",
                ["YP"] = "copy_abs_file",
                ["Tg"] = "telescope_livegrep_cwd",
                ["Tf"] = "telescope_find_files",
                -- git copied from git mapping
                -- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/README.md#L302
                ["gu"] = "git_unstage_file",
                ["ga"] = "git_add_file",
                ["gr"] = "git_revert_file",
                ["gc"] = "git_commit",
                ["Tc"] = "telescope_cd",
              },
            },
          },
          buffers = {
            window = {
              mappings = {
                ["X"] = "buffer_delete",
              },
            },
          },
        }
      )
      return opts
    end,
    config = function(_, opts)
      -- local function on_move(data)
      --   LazyVim.lsp.on_rename(data.source, data.destination)
      -- end

      -- local events = require("neo-tree.events")
      -- opts.event_handlers = opts.event_handlers or {}
      -- vim.list_extend(opts.event_handlers, {
      --   { event = events.FILE_MOVED, handler = on_move },
      --   { event = events.FILE_RENAMED, handler = on_move },
      -- })
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },
}
