local pathUtil = require("utils.path")
local gitUtil = require("utils.git")

local mapping_key_prefix = vim.g.ai_prefix_key or "<leader>A" -- orginal from codecompanion.lua
function sentSelectedToTerminal()
  local mode = vim.fn.mode()
  if mode == "V" then
    -- print("in V mode")
    require("toggleterm").send_lines_to_terminal("visual_lines", true, { args = vim.v.count })
  elseif mode == "\22" then -- "\22" is the ASCII representation for CTRL-V
    -- print("in ^V mode")
    require("toggleterm").send_lines_to_terminal("visual_selection", true, { args = vim.v.count })
  elseif mode == "v" then
    -- print("in v mode")
    require("toggleterm").send_lines_to_terminal("visual_selection", true, { args = vim.v.count })
  else
    require("toggleterm").send_lines_to_terminal("single_line", true, {})
  end
end

local lazygitTerm = {}
---@param termOpts TermCreateArgs?
---@param name string
local isToggleCurrentLazyTerm = function(name, termOpts)
  if lazygitTerm and lazygitTerm.term and name == lazygitTerm.name then
    lazygitTerm.term:toggle()
  else
    local lazygitBaseTerm = {
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })

        -- Allow to make it work for lazygit for Esc and ctrl + hjkl
        vim.keymap.set("t", "<c-h>", "<c-h>", { buffer = term.bufnr, nowait = true })
        vim.keymap.set("t", "<c-j>", "<c-j>", { buffer = term.bufnr, nowait = true })
        vim.keymap.set("t", "<c-k>", "<c-k>", { buffer = term.bufnr, nowait = true })
        vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = term.bufnr, nowait = true })
        vim.keymap.set("t", "<esc>", "<esc>", { buffer = term.bufnr, nowait = true })
      end,
      -- function to run on closing the terminal
      on_close = function(_)
        vim.cmd("startinsert!")
      end,
    }
    require("utils.lazygit").open() -- overide nvim edit set key config for lazygit
    termOpts.on_open = lazygitBaseTerm.on_open
    termOpts.on_close = lazygitBaseTerm.on_close
    local lazygit = require("toggleterm.terminal").Terminal:new(termOpts)
    lazygitTerm = {
      name = name,
      term = lazygit,
    }
    lazygitTerm.term:toggle()
  end
end

---@param ref : string
---@param mode "file" | "commit" | "branch"
local open_remote = function(ref, mode)
  -- print([==[function mode:]==], vim.inspect(mode)) -- __AUTO_GENERATED_PRINT_VAR_END__
  local file_path = vim.fn.expand("%:p")
  local line_number = vim.fn.line(".")

  local gitroot = pathUtil.get_git_root()
  local remote_name = ref:match("([^/]+)")
  -- print([==[function remote_name:]==], vim.inspect(remote_name)) -- __AUTO_GENERATED_PRINT_VAR_END__
  local remote_path = gitUtil.get_remote_path(remote_name)
  local ref_no_remote = ref:gsub("^[^/]+/", "") -- remove remote
  -- print([==[function ref_no_remote:]==], vim.inspect(ref_no_remote)) -- __AUTO_GENERATED_PRINT_VAR_END__
  local git_file_path = file_path:gsub(gitroot .. "/?", "")
  local url_pattern = "https://%s/blob/%s/%s#L%d"
  local url = ""
  local is_commit = ref_no_remote:match("[0-9a-fA-F]+$") ~= nil and (#ref_no_remote == 40 or #ref_no_remote == 7)
  -- print([==[function is_commit:]==], vim.inspect(is_commit))

  if mode == "file" then
    url = string.format(url_pattern, remote_path, ref_no_remote, git_file_path, line_number)
  else
    if mode == "commit" then
      url = string.format("https://%s/commit/%s", remote_path, ref_no_remote)
    else
      -- remove remote parts
      url = string.format("https://%s/tree/%s", remote_path, ref_no_remote)
    end
  end
  vim.fn.jobstart({ "open", url }, { detach = true })
end

return {
  -- Disabled list
  { "nvimdev/dashboard-nvim", lazy = true, enabled = false },
  { "Wansmer/treesj", enabled = false },
  -- folke/edgy.nvim:  https://github.com/LazyVim/LazyVim/blob/1f8469a53c9c878d52932818533ce51c27ded5b6/lua/lazyvim/plugins/extras/ui/edgy.lua#L97
  {
    "jellydn/hurl.nvim",
    keys = {},
  },
  {
    "stevearc/oil.nvim",
    enabled = true,
    opts = {
      -- default_file_explorer = false,
    },
    keys = {
      -- disabled <leader-e> key
      {
        "<leader>e",
        false,
      },
      {
        "<leader>fO",
        function()
          require("oil").toggle_float()
        end,
        desc = "Open OIL explorer",
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    -- tutorials : https://github.com/stevearc/overseer.nvim/blob/master/doc/tutorials.md#run-a-file-on-save
    -- support on vscode tasks ?
    opts = {
      -- default config: https://github.com/stevearc/overseer.nvim/blob/a2734d90c514eea27c4759c9f502adbcdfbce485/lua/overseer/config.lua#L4
      strategy = {
        "terminal",
        -- "toggleterm", -- https://github.com/stevearc/overseer.nvim/blob/master/doc/third_party.md#toggleterm
        use_shell = true,
      },
      task_list = {
        bindings = {
          ["<C-q>"] = ":q<CR>",
          ["<C-s>"] = ":OverseerQuickAction<CR>",
          ["S"] = ":OverseerSaveBundle<CR>",
          ["T"] = ":OverseerTaskAction<CR>",
          ["Q"] = ":OverseerDeleteBundle<CR>",
          ["C"] = ":OverseerClearCache<CR>",
          ["I"] = ":OverseerInfo<CR>",
          ["B"] = ":OverseerLoadBundle<CR>",

          ["<S-Up>"] = "ScrollOutputUp",
          ["<S-Down>"] = "ScrollOutputDown",
          ["<A-q>"] = "OpenQuickFix",
          -- ["<C-l>"] = "",
          -- ["<C-h>"] = "",
          ["<C-l>"] = false,
          ["<C-h>"] = false,
          -- c-j and c-k remove bind
          ["<C-j>"] = false,
          ["<C-k>"] = false,
          ["J"] = "DecreaseDetail",
          ["L"] = "IncreaseDetail",
          -- ["K"] = "IncreaseAllDetail",
          -- ["L"] = "",
          -- ["H"] = "",
          -- ["zk"] = "DecreaseDetail",
          -- ["zj"] = "IncreaseDetail",
          -- ["zl"] = "IncreaseAllDetail",
          -- ["zh"] = "DecreaseAllDetail",
        },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    opts = {
      persist_size = false,
      persist_mode = false,
    },
    keys = {
      {
        "<c-_>",
        desc = "Toggle term",
      },
      {
        "<leader><c-_>",
        "<cmd>:ToggleTermSendCurrentLine<cr>",
        desc = "Send current line to terminal",
      },
      {
        -- "<leader><c-_>",
        "<localleader>ta",
        function()
          set_opfunc(function(motion_type)
            require("toggleterm").send_lines_to_terminal(motion_type, false, { args = vim.v.count })
          end)
          vim.api.nvim_feedkeys("ggg@G''", "n", false)
        end,
        desc = "Send visual selection to terminal",
      },
      {
        "<localleader>t",
        sentSelectedToTerminal,
        desc = "Send visual selection to terminal",
        mode = "v",
      },
      {
        "<localleader>t",
        sentSelectedToTerminal,
        desc = "Send visual selection to terminal",
      },
      {
        "<localleader>tf",
        "<cmd>:ToggleTerm direction=float<cr>",
        desc = "Toggle term Float",
      },
      {
        "<localleader>th",
        "<cmd>:ToggleTerm direction=horizontal<cr>",
        desc = "Toggle term Horiz",
      },
      {
        "<localleader>tv",
        "<cmd>:ToggleTerm direction=vertical<cr>",
        desc = "Toggle term vertical",
      },
      {
        "<localleader>t2",
        "<cmd>:2ToggleTerm<cr>",
        desc = "Find Terminal",
      },
      {
        "<localleader>tr",
        "<cmd>:ToggleTermSetName<cr>",
        desc = "Set Terminal Name",
      },
      {
        "<localleader>ts",
        "<cmd>:TermSelect<cr>",
        desc = "Find Term",
      },
      {
        "<localleader>gl",
        function()
          require("utils.lazygit").blame_line()
        end,
        desc = "Git Blame Line",
        mode = "n",
      },

      {
        "<leader>lc",
        function()
          local dotfilescwd = vim.fn.expand("$DOTFILES_DIR")
          isToggleCurrentLazyTerm("_lc", {
            cmd = "lazygit",
            dir = dotfilescwd,
            direction = "float",
          })
        end,
        desc = "Lazygit Config Toggle",
        mode = "n",
      },
      -- see: https://github.com/LazyVim/LazyVim/blob/b8bdebe5be7eba91db23e43575fc1226075f6a56/lua/lazyvim/util/lazygit.lua#L64
      --       map("n", "<leader>gg", function() LazyVim.lazygit( { cwd = LazyVim.root.git() }) end, { desc = "Lazygit (Root Dir)" })
      -- map("n", "<leader>gG", function() LazyVim.lazygit() end, { desc = "Lazygit (cwd)" })
      -- map("n", "<leader>gb", LazyVim.lazygit.blame_line, { desc = "Git Blame Line" })
      -- map("n", "<leader>gB", LazyVim.lazygit.browse, { desc = "Git Browse" })
      {
        "<leader>gG",
        function()
          local lazycwd = require("utils.root").cwd()
          isToggleCurrentLazyTerm("_gG", {
            cmd = "lazygit",
            dir = lazycwd,
            direction = "float",
          })
        end,
        desc = "Lazygit Toggle (CWD)",
        mode = "n",
      },
      {
        "<leader>gg",
        function()
          isToggleCurrentLazyTerm("_gg", {
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
          })
        end,
        desc = "Lazygit Toggle",
        mode = "n",
      },
    },
  },
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<C-q>",
        false,
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    keys = {
      {
        mapping_key_prefix .. "A",
        "<cmd>CodeCompanionChat Add<cr>",
        desc = "Code Companion - Add selected",
        mode = "v",
      },
      {
        mapping_key_prefix .. "V",
        -- "<cmd>CodeCompanionChat Toggle<cr>",
        "<cmd>CodeCompanionChat<cr>", -- will add selected input and toggle
        desc = "Code Companion - Add and Toggle",
        mode = "v",
      },
      { mapping_key_prefix .. "v", "<cmd>CodeCompanionChat<cr>", mode = "v" }, -- not sure why not override

      {
        mapping_key_prefix .. "q",
        "<cmd>CodeCompanionChat<cr>",
        desc = "Code Companion - Chat",
        mode = "v",
      },
      {
        mapping_key_prefix .. "Q",
        function()
          vim.cmd("CodeCompanion")
        end,
        desc = "Code Companion - Quick chat",
        mode = "v",
      },
    },
    adapters = {
      llama3_2 = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama3", -- Give this adapter a different name to differentiate it from the default ollama adapter
          schema = {
            model = {
              default = "llama3.2:latest",
            },
            num_ctx = {
              default = 16384,
            },
            num_predict = {
              default = -1,
            },
          },
        })
      end,

      -- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/adapters/ollama.lua
      llama3latest = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama3latest", -- Give this adapter a different name to differentiate it from the default ollama adapter
          schema = {
            model = {
              default = "llama3:latest",
            },
            num_ctx = {
              default = 16384,
            },
            num_predict = {
              default = -1,
            },
          },
        })
      end,
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
    keys = {
      {
        "<leader>aE",
        "<cmd>CopilotChatBuffEdit<cr>",
        desc = "~ Copilot Chat Buf Edit ",
      },
    },
    opts = {
      model = "gpt-4o", -- override claude-sonnet model since not support on my copilot (get ereror)
      -- debug = true, -- add to debug message by calling l-a-d and  see in file using <gf> or check :messages in the logfile name else see only error (not prompt and embedding used)
      mappings = {
        complete = {
          detail = "Use @<C-Tab> or /<C-Tab> to complete the suggestion.",
          insert = "<C-t>",
        },
      },
    },
  },
  {
    "jellydn/quick-code-runner.nvim",
    keys = {
      {
        "<leader>cP",
        "gg0vGg$:QuickCodeRunner<CR>",
        desc = "Code Run File",
        mode = "n",
      },
    },
    opts = {
      -- debug = true, -- add to debug and see what happens when codepad is called
      file_types = {
        -- @ Troubleshoot when pip install does not work globally
        -- The code will create in ~/.cache/dir_/tofile.py
        -- Workaround create pipenv inside the ~/.cache/
        -- cd ~/.cache && pipenv --python 3
        -- pipenv install pandas
        python = {
          pathUtil.get_pythonpath(false, true) .. " -u",
          -- first check if therre is virt env in the git rroot dir or .venv or not if not python3 -u else pipenv run python -u
          -- purre cli handle not work with handling https://github.com/jellydn/quick-code-runner.nvim/blob/main/lua/quick-code-runner/utils.lua#L248
          -- "[[ -d .venv ]] && echo 'pipenv run python -u' || echo 'python3 -u'", -- not work
          -- "pipenv run python -u", -- Have some lag
          -- "python3 -u", -- Original
        },
        -- from common  -------------------
        -- https://github.com/jellydn/quick-code-runner.nvim/blob/main/lua/quick-code-runner/init.lua#L17
        -- do not know why ned to override else not work
        javascript = {
          "bun run",
        },
        go = {
          "go run",
        },
        lua = {
          "lua",
        },
        typescript = {
          "bun run",
        },
        --  end common -------------------
        sh = {
          "bash",
        },
      },
      global_files = {
        javascript = pathUtil.get_global_file_by_type("js"),
        typescript = pathUtil.get_global_file_by_type("ts"),
        python = pathUtil.get_global_file_by_type("py"),
        go = pathUtil.get_global_file_by_type("go"),
        lua = pathUtil.get_global_file_by_type("lua"),
        --  end common -------------------
        sh = pathUtil.get_global_file_by_type("sh"),
      },
    },
  },
  -- { import = "plugins.extras.copilot-chat-v2" },
  -- { import = "plugins.extras.telescope-lazy" },
  { import = "plugins.extras.neotree" },
  { import = "plugins.extras.myNoice" },
  -- { import = "plugins.extras.fzf" },
  { import = "plugins.extras.telescope" },
  -- { import = "plugins.extras.telescope-map-essntials" },
}
