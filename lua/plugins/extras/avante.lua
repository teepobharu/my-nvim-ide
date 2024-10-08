return {
  -- NOTE: This is early/alpha plugin so it's not powerful/stable as CopilotChat.nvim but it's still useful with nice UI
  {
    "jellydn/avante-copilot.nvim",
    event = "VeryLazy",
    build = "make",
    opts = {
      provider = "copilot", -- You can then change this provider here
      -- provider = "claude",
      mappings = {
        ask = "<leader>ra",
        edit = "<leader>re",
        refresh = "<leader>rr",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function(_, options)
      require("avante").setup(options)

      local wk = require("which-key")
      wk.add({
        { "<leader>ra", desc = "Ask AI" },
        { "<leader>re", desc = "Edit selected" },
        { "<leader>rr", desc = "Refresh AI" },
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      file_types = { "markdown", "Avante" },
    },
    ft = { "markdown", "Avante" },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>r", group = "Refactor/AI" },
      },
    },
  },
}
