----- MY OVERRIDE SETTINGS END ------
-- TO OVERRIDE USE THIS
vim.g.enable_plugins = {
  codecompanion = "yes",
  ["no-neck-pain"] = "yes",
  lspsaga = "no",
  wakatime = "no",
}

-- __AUTO_GENERATED_PRINT_VAR_START__
vim.g.enable_langs = {
  go = "no",
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
