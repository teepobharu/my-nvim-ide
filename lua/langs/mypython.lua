-- https://stackoverflow.com/a/75509259
-- after doing this works in ide correctly
-- echo '{ "venvPath": ".", "venv": ".venv" }' >> pyrightconfig.json
-- check the status and settings using :checkhealth lsp
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- remove if in vscode
        pyright = {
          enabled = not vim.g.vscode,
          settings = {
            python = not vim.g.vscode and {
              -- make sure to get python inside venv if available
              -- https://stackoverflow.com/a/75509259
              -- get project root and read from pyrightconfig.json else use default
              -- 1 . read from pyrightconfig.json .venvPath
              -- }pyrightconfig.json > { "venvPath": }
              -- 2. if not found use default
              -- get_python_path(),kj
              -- run pipenv --py to get python path

              -- pythonPath = require("utils.path").get_root_directory() .. "/.venv/bin/python",
              pythonPath = require("utils.path").get_pythonpath(),
            },
          },
        },
      },
      setup = {
        pyright = function(_, opts)
          -- read settings from pyrightconfig.json
          --
          --
          -- require("utils.lsp").register_keymaps("pyright", opts.keys, "Pyright")
        end,
      },
    },
  },
}
