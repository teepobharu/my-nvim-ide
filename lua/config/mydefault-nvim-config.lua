----- MY OVERRIDE SETTINGS END ------
-- TO OVERRIDE USE THIS
-- load order follow the order define in the key unless it was define as deps ?
vim.g.enable_plugins = {
  ["no-neck-pain"] = "no",
  -- lspsaga = "no",
  wakatime = "no",
  avante = "no",
  codecompanion = "yes",
  blink = "no",
  magazine = "no",
  lspsaga = "yes",
  fzf = "yes", -- will still import after snacks -> need overide in snacks.nvim
  snacks = "yes",
  ["fold-preview"] = "yes",
}
-- __AUTO_GENERATED_PRINT_VAR_START__
vim.g.enable_langs = {
  go = "yes",
  rust = "no",
  python = "yes",
  tailwind = "no",
  ruby = "no",
}

-------- EXAMPLE PROJECT OVERRIDE SETTINGS ------
---vim.g.enable_plugins = vim.tbl_extend("keep", vim.g.enable_plugins or {}, {
---  codecompanion = "yes",
---  ["no-neck-pain"] = "yes",
---  lspsaga = "no",
---  wakatime = "no",
---})
---
----- __AUTO_GENERATED_PRINT_VAR_START__
---vim.g.enable_langs = vim.tbl_extend("keep", vim.g.enable_langs or {}, {
---  go = "no",
---  rust = "no",
---  python = "yes",
---  tailwind = "no",
---  ruby = "no",
---})
--
-- print([==[ enable_extra_plugins:]==], vim.inspect(vim.g.enable_plugins)) -- __AUTO_GENERATED_PRINT_VAR_END__
-- print([==[ enable_extra_langs:]==], vim.inspect(vim.g.enable_extra_langs)) -- __AUTO_GENERATED_PRINT_VAR_END__
