return {
  "folke/noice.nvim",
  keys = {
    {
      "<leader>sna",
      function()
        require("noice").cmd("all")
      end,
      desc = "Noice All",
    },
    {
      "<leader>sne",
      function()
        require("noice").cmd("errors")
      end,
      desc = "Noice Erros",
    },
    {
      "<leader>snd",
      function()
        require("noice").cmd("dismiss")
      end,
      desc = "Noice Dismiss",
    },
    {
      "<leader>snE",
      function()
        require("noice").cmd("enable")
      end,
      desc = "Noice Enable",
    },
    {
      "<leader>snx",
      function()
        require("noice").cmd("disable")
      end,
      desc = "Noice Disable",
    },
  },
}
