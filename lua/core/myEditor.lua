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
        { desc = "Open OIL explorer" },
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
