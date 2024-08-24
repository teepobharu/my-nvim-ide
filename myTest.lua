local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

local test = require("gitsigns.test")
local function printVariables()
  local n = { 1, 2 }
  print([==[ n:]==], vim.inspect(n))
  print(123123)
  print(n[2])

  local current_file_path = vim.fn.expand("%:p")
  print([==[ current_file_path:]==], vim.inspect(current_file_path))
  local current_dir = vim.fn.expand("%:p:h")
  print([==[ current_dir:]==], vim.inspect(current_dir))
  local vim_getcwd = vim.fn.getcwd()
  -- get current lcd dir
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[printVariables vim_getcwd:]==], vim.inspect(vim_getcwd)) -- __AUTO_GENERATED_PRINT_VAR_END__
  local dir = vim.fn.expand("$DOTFILES_DIR/.config/nvim2_jelly_lzmigrate")
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[main dir:]==], vim.inspect(dir)) -- __AUTO_GENERATED_PRINT_VAR_END__

  fname = vim.fn.expand("%:p")
  print("dir from filename: " .. fname .. "  dir=" .. vim.fn.fnamemodify(fname, ":h"))
end

-- local keymap = vim.api.nvim_set_keymap
local function handleMode(mode)
  return function()
    if vim.fn.mode() == mode then
      vim.cmd("normal! y")
    else
      vim.cmd("normal! gv")
    end
  end
end

local function testKeyMap()
  opts.desc = "check if in V mode or v line mode"
  keymap("v", "<leader>z", checkIfInVmodeOrVLinemode, opts)
  keymap("v", "<leader>z", sentSelectedToTerminal, opts)

  -- opts.desc = "yank in visual mode"
  -- keymap("v", "v", handleMode("v"), opts)
  -- keymap("v", "V", handleMode("V"), opts)

  opts.desc = "Duplicate line and preserve yank register"
  keymap("n", "<A-d>", duplicateselected, opts)
  keymap("v", "<A-d>", duplicateselected, opts)
end

function sentSelectedToTerminal()
  -- -- !!! this will not work in visual mode
  -- vim.api.nvim_put("yyp") -- async cause the work is done in the background
  local mode = vim.fn.mode()
  if mode == "V" then
    print("in V mode")
    require("toggleterm").send_lines_to_terminal("visual_lines", true, { args = vim.v.count })
  elseif mode == "\22" then -- "\22" is the ASCII representation for CTRL-V
    print("in ^V mode")
    require("toggleterm").send_lines_to_terminal("visual_selection", true, { args = vim.v.count })
  elseif mode == "v" then
    print("in v mode")
    require("toggleterm").send_lines_to_terminal("visual_selection", true, { args = vim.v.count })
  else
    print("other " .. mode)
  end
end

local function checkLspClients()
  local lspconfig = require("lspconfig")
  local lspclient_f = lspconfig.util.get_lsp_clients({ name = "typescript-tools" })
  local lspclient_f2 = lspconfig.util.get_lsp_clients({ name = "denols" })
  local lspclient_ft = lspconfig.util.get_active_clients_list_by_ft("typescript")
  print([==[ lspclient_ft:]==], vim.inspect(lspclient_ft))
  print([==[ lspclient:]==], vim.inspect(lspclient_f))
  print([==[ lspclient:]==], vim.inspect(lspclient_f2))
end

function checkIfInVmodeOrVLinemode()
  local mode = vim.fn.mode()
  -- echo 1
  -- echo 2
  if mode == "V" then
    print("in V mode")
  elseif mode == "\22" then -- "\22" is the ASCII representation for CTRL-V
    print("in ^V mode")
  elseif mode == "v" then
    print("in v mode")
  else
    print("other " .. mode)
  end
end

function duplicateselected()
  local saved_unnamed = vim.fn.getreg('"')

  local current_selected_line = ""
  local current_mode = vim.fn.mode()
  if current_mode == "v" or current_mode == "V" then
    -- Get the selected lines
    current_selected_line = vim.fn.getline("`<", "`>")
  else
    current_selected_line = vim.fn.getline(".")
  end

  print("current_selected_line")
  print(current_selected_line)

  -- Duplicate the current line or selected lines
  if current_mode == "v" or current_mode == "V" then
    -- In visual mode, use normal command to duplicate lines
    vim.api.nvim_command("normal! y`>p`>")
    -- vim.api.nvim_command("normal! y`>$p`>") -- new line (will not work with v mode not new line)
  else
    -- In normal mode, duplicate the current line
    vim.cmd("normal! yyp")
  end

  -- Restore previous yank registers
  vim.fn.setreg('"', saved_unnamed)
end

local function toggleTermCheck()
  -- already avail in keymap function
  --   local set_opfunc = vim.fn[vim.api.nvim_exec(
  --     [[
  --   func s:set_opfunc(val)
  --     let &opfunc = a:val
  --   endfunc
  --   echon get(function('s:set_opfunc'), 'name')
  -- ]],
  --     true
  --   )]
  -- print(vim.fn.expand("%:p:h"))
  -- local Terminal = require("toggleterm.terminal").Terminal
  -- Terminal:new({ dir = vim.fn.expand("%:p:h") })
  local function CreateNewTerm()
    local Terminal = require("toggleterm.terminal").Terminal
    -- why normal command without stop command not show here
    -- Terminal:new({ dir = "git_dir", direction = "horizontal" })
    -- Terminal:toggle()
    local t1 = Terminal:new({ cmd = "sh pwd", close_on_exit = false })
    -- local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
    -- lazygit:toggle()
    t1:toggle()
  end
  -- CreateNewTerm()

  opts.desc = "Send whole file to terminal"
  vim.keymap.set("n", [[<localleader>ta]], function()
    set_opfunc(function(motion_type)
      require("toggleterm").send_lines_to_terminal(motion_type, false, { args = vim.v.count })
    end)
    vim.api.nvim_feedkeys("ggg@G''", "n", false)
  end, opts)
  opts.desc = ""
end

local function main()
  print(table.concat({ 1, 2, 3 }, ","))
  vim.opt_local.timeoutlen = 1000 -- setlocal can used (still not found any differences when set)
  print([==[main   vim.timeoutlen:]==], vim.inspect(vim.opt.timeoutlen._value)) -- __AUTO_GENERATED_PRINT_VAR_END__
  print([==[main   vim.timeoutlenlocal:]==], vim.inspect(vim.opt_local.timeoutlen._value)) -- __AUTO_GENERATED_PRINT_VAR_END__
  -- __AUTO_GENERATED_PRINT_VAR_START__
  if false then
    printVariables()
    toggleTermCheck()
    testKeyMap()
    -- require("toggleterm").setup({ size = 20, open_mapping = [[<C-\>]] }) -- open terminal with <C-\>
    print("not run functions")
    checkLspClients()
  end
end

main()
