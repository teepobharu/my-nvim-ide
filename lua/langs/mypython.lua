-- https://stackoverflow.com/a/75509259
-- after doing this works in ide correctly
-- echo '{ "venvPath": ".", "venv": ".venv" }' >> pyrightconfig.json
--
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
      },
    },
  },
}
