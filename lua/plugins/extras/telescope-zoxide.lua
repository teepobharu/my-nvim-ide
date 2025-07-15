return {
  "jvgrootveld/telescope-zoxide",
  cmd = "Telescope zoxide list", -- Lazy load when this command is called
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local tele_status_ok, telescope = pcall(require, "telescope")
    -- local t = require("telescope")
    -- local z_utils = require("telescope._extensions.zoxide.utils")
    -- Configure telescope-zoxide
    if not tele_status_ok then
      return
    end

    telescope.setup({
      extensions = {
        zoxide = {
          prompt_title = "Zoxide ~ CD",
          mappings = {
            default = {
              after_action = function(selection)
                print("Update to (" .. selection.z_score .. ") " .. selection.path)
              end,
            },
            ["<C-s>"] = {
              before_action = function(selection)
                -- print("before C-s")
              end,
              action = function(selection)
                vim.cmd.edit(selection.path)
              end,
            },
            -- ["<C-q>"] = {
            --   action = z_utils.create_basic_command("split"),
            -- },
          },
        },
      },
      -- https://github.com/jvgrootveld/telescope-zoxide?tab=readme-ov-file
    })

    -- Define a custom command to open aerial with telescope
    vim.keymap.set("n", "<leader>c.", "<cmd>Telescope zoxide list<CR>", {
      desc = "Telescope Zoxide",
    })

    telescope.load_extension("zoxide")
    -- keymap("n", "<leader>c.", t.extensions.zoxide.list, { desc = "Telescope Zoxide" })
  end,
}
