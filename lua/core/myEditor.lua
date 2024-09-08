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
    -- print("other " .. mode)
    require("toggleterm").send_lines_to_terminal("visual_lines", true, { args = vim.v.count })
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

return {
  -- folke/edgy.nvim:  https://github.com/LazyVim/LazyVim/blob/1f8469a53c9c878d52932818533ce51c27ded5b6/lua/lazyvim/plugins/extras/ui/edgy.lua#L97
  -- { "ibhagwan/fzf-lua", enabled = false },
  {
    "stevearc/oil.nvim",
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
    "akinsho/toggleterm.nvim",
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
    "CopilotC-Nvim/CopilotChat.nvim",
    keys = {
      {
        "<leader>aE",
        "<cmd>CopilotChatBuffEdit<cr>",
        desc = "~ Copilot Chat Buf Edit ",
      },
    },
    opts = {
      debug = true, -- add to debug message by calling l-a-d and  see in file using <gf> or check :messages in the logfile name else see only error (not prompt and embedding used)
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
          "pipenv run python -u", -- Have some lag
          -- "python3 -u", -- Original
        },
      },
    },
  },
  -- { import = "plugins.extras.copilot-chat-v2" },
  -- { import = "plugins.extras.telescope-lazy" },
  { import = "plugins.extras.telescope" },
  -- { import = "plugins.extras.telescope-map-essntials" },
  { import = "plugins.extras.myNoice" },
  { import = "plugins.extras.neotree" },
  { import = "plugins.extras.fzf" },
}
