local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set
-- ===========================
-- LAZY NVIM ====================
-- =======================

-- Setup keys
-- check using :letmapleader or :let maplocalleader
-- -> need to put inside plugins mapping also to make it work on those mapping
-- command completion in command line mode
keymap("n", "<leader>ll", "<cmd>Lazy<CR>", { desc = "Lazy" })
-- keymap("n", "<leader>lx", "<cmd>LazyExtras<CR>", { desc = "Lazy Extras" })

-- ============================
-- EDITING
-- ============================
-- Move Lines (add silence original didnot have will blip in visual mode)
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down", silent = true })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up", silent = true })
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down", silent = true })
opts.desc = "Comment Line"
keymap("i", "<A-/>", "<esc>mt<cmd>normal gcc<cr>`tji", opts)
-- keymap("v", "A-/", "gc", opts) -- v mode not work
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up", silent = true })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down", silent = true })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up", silent = true })

vim.cmd([[
  cnoremap <expr> <C-j> wildmenumode() ? "\<C-N>" : "\<C-j>"
  cnoremap <expr> <C-k> wildmenumode() ? "\<C-P>" : "\<C-k>"
]])

local function handleMode(mode)
  return function()
    if vim.fn.mode() == mode then
      vim.cmd("normal! y")
    else
      -- do as normal trigger for visual mode / visual line modejgc
      if mode == "v" then
        vim.cmd("normal! v")
      elseif mode == "V" then
        vim.cmd("normal! V")
      else
        -- Handle unexpected mode by falling back to default key bindings
        vim.notify("Unexpected mode: " .. vim.fn.mode(), vim.log.levels.WARN)
        vim.cmd("normal! gv")
      end
    end
  end
end

opts.desc = "Yank in visual"
keymap("v", "v", handleMode("v"), opts)
keymap("v", "V", handleMode("V"), opts)

local keymap = vim.keymap.set
-- Duplicate line and preserve previous yank register
--  support mode v as
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

-- above cause to move when quit with Esc
--
-- H and L to change buffer (LAZY)
keymap("n", "<A-d>", duplicateselected, { desc = "Duplicate line and preserve yank register" })
keymap("v", "<A-d>", duplicateselected, { desc = "Duplicate line and preserve yank register" })
-- " Copy to system clipboard

-- vnoremap <leader>y "+y
-- nnoremap <leader>Y "+yg_
-- nnoremap <leader>y "+y
-- nnoremap <leader>yy "+yy

-- copy to nvim only not system clipboard
vim.opt.clipboard = ""

keymap("n", "Y", '"+y', { desc = "Copy to system clipboard" })
keymap("n", "YY", '"+yy', { desc = "Copy to system clipboard" })
keymap("v", "Y", '"+y', { desc = "Copy to system clipboard" })
keymap("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })

-- ============================
--  Navigations
-- ============================
--- Easier access to beginning and end of lines
keymap("v", "<A-h>", "^", {
  desc = "Go to start of line",
  silent = true,
})

keymap("v", "<A-l>", "$", {
  desc = "Go to end of line",
  silent = true,
})

-- v mode esc to exit visual modej
keymap("v", "<C-q>", "<esc>", { desc = "exit" })
keymap("v", "<C-j>", "<C-d>", { desc = "Move page down" })
keymap("v", "<C-k>", "<C-u>", { desc = "Move page up" })

-- /Users/tharutaipree/dotfiles/README.mdTmux navigation - move to plugins config

-- ============================
--   Windows and Tabs
-- ============================
keymap("n", "<leader>wh", ":sp<CR>", { desc = "HSplit", silent = true })
keymap("n", "<leader>wv", ":vs<CR>", { desc = "VSplit", silent = true })
keymap("n", "<M-Tab>", ":tabnext<CR>", { noremap = true, silent = true })
keymap("t", "<M-Tab>", "<cmd>tabnext<CR>", { noremap = true, silent = true })
keymap("n", "<leader>wp", ":windo b#<CR>", { desc = "Previous Window", silent = true })

-- map("n", "<C-Up>", ":resize -3<CR>", opts)
-- map("n", "<C-Down>", ":resize +3<CR>", opts)
-- map("n", "<C-Left>", ":vertical resize -3<CR>", opts)
-- map("n", "<C-Right>", ":vertical resize +3<CR>", opts)

-- Resize with ESC keys - up down use for auto cmpl
keymap("n", "<Up>", ":resize -3<CR>", opts)
keymap("n", "<Down>", ":resize +3<CR>", opts)
keymap("n", "<Left>", "<cmd>vertical resize -3<CR>", opts)
keymap("n", "<Right>", "<cmd>vertical resize +3<CR>", opts)
-- map("n", "H", ":bp<CR>", { desc = "Previous Buffer", silent = true })
-- map("n", "L", ":bn<CR>", { desc = "Next Buffer", silent = true })
-- use <l>bd instead
opts.desc = "Close buffer"
keymap("n", "<leader>bd", ":b#|bd#<CR>", opts)
-- map("n", "<leader>wX", ":bd!<CR>", { desc = "Force close buffer" })

local function toggle_fold_or_clear_highlight()
  if vim.fn.foldlevel(".") > 0 then
    vim.api.nvim_input("za")
  else
    vim.cmd("nohlsearch")
  end
end
keymap("n", "<Esc>", toggle_fold_or_clear_highlight, { expr = true, silent = true, noremap = true })
-- Terminal & Commands
-- ============================
opts.desc = "Toggle Normal"
keymap("t", "<C-q>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
opts.desc = nil

function _G.set_toggleterm_keymaps()
  -- run on all terminal buffers
  -- https://github.com/akinsho/toggleterm.nvim?tab=readme-ov-file#terminal-window-mappings
  local opts = opts
  opts.buffer = 0
  local ft = vim.bo.filetype -- toggleterm
  local is_toggleterm = ft == "toggleterm"
  local buffername = vim.fn.expand("%:t")
  if string.find(buffername, "lazygit") then
    print("Lazygit buffer")
  else
    opts.desc = "Toggle Terminal (press with <n> to toggle/open other term)"
    vim.keymap.set("n", "<C-t>", [[<Cmd>exe v:count1 . "ToggleTerm"<CR>]], opts)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  end
  -- what about buffername ?
  -- if not lazygit then do mapping
  -- resize
  opts.desc = "Resize" -- not working
  -- vim.keymap.set("t", "Up", [[<C-\><C-n>:resize -3<CR>]], opts)
  -- vim.keymap.set("t", "Down", [[:resize +3<CR>]], opts)
  -- vim.keymap.set("t", "<C-Left>", [[<C-\><C-n>:vertical resize -3<CR>]], opts)
  -- vim.keymap.set("t", "<C-Right>", [[<C-\><C-n>:vertical resize +3<CR>]], opts)
  -- vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
  -- vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end
-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_toggleterm_keymaps()")
keymap("n", ";", ":", { desc = "CMD enter command mode" })
vim.api.nvim_create_user_command("OpenTerminalInSplitWithCwd", function()
  local cwd = vim.fn.expand("%:p:h")

  vim.api.nvim_command("split | lcd " .. cwd .. " | terminal")
end, {})
keymap("n", "<Leader>t.", ":OpenTerminalInSplitWithCwd<CR>", { noremap = true, silent = true })
-- ===========================================
--  Search
-- ===============================================
-- before adding to search copy to system clipboard first
keymap("v", "//", "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>", { desc = "Search selected visual" })
keymap("v", "//", "\"+y/\\V<C-R>=escape(@\",'/\\')<CR><CR>", { desc = "Search selected visual" })
--
--
-- ===========================================
-- GIT
-- ===============================================

function gitsigns_jump_next_hunk()
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    require("gitsigns").next_hunk()
  end)
  return "<Ignore>"
end
function gitsigns_jump_prev_hunk()
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    require("gitsigns").prev_hunk()
  end)
  return "<Ignore>"
end
keymap("n", "<C-S-j>", gitsigns_jump_next_hunk, { desc = "Jump to next hunk", expr = true })
keymap("n", "<C-M-j>", gitsigns_jump_next_hunk, { desc = "Jump to next hunk", expr = true })
keymap("n", "<C-S-k>", gitsigns_jump_prev_hunk, { desc = "Jump to prev hunk", expr = true })
keymap("n", "<C-M-k>", gitsigns_jump_prev_hunk, { desc = "Jump to prev hunk", expr = true })
opts.desc = "Reset hunk"
keymap("n", "<M-z>", function()
  require("gitsigns").reset_hunk()
end, opts)
keymap("v", "<M-z>", ":Gitsigns reset_hunk<cr>", opts)
opts.desc = nil
-- Reconsidered
-- keymap("n", "<leader>gbc", ":Telescope git_bcommits<cr>", { silent = true, desc = "Git BCommits" })
-- keymap("n", "<leader>gbr", ":Telescope git_branches<cr>", { silent = true, desc = "Git Branches" })
-- keymap("n", "<leader>gbl", ":Gitsigns toggle_current_line_blame<cr>", { silent = true, desc = "Blame Inline Toggle" })
-- keymap("n", "<leader>gbL", ":Git blame<cr>", { silent = true, desc = "Git Blame" })
-- keymap("n", "<leader>gbb", ":Git blame<cr>", { silent = true, desc = "Git Blame" })
-- ===============================================
-- LOCALLEADER ==========================
-- ===============================================
local function addVenvPyrightConfig()
  local pathUtil = require("utils.path")
  local git_dir = pathUtil.get_git_root() or vim.fn.getcwd()

  local venv_path = vim.fn.input("Enter venv path: ", git_dir .. "/.venv")
  local config = { venvPath = venv_path, venv = ".venv" }
  if vim.fn.isdirectory(venv_path) == 0 then
    vim.notify("Venv path not exists, please run pipenv install", vim.log.levels.WARN)
    return
  end
  -- if file exists then confirm before override
  local pyrightconfig = git_dir .. "/pyrightconfig.json"

  if vim.fn.filereadable(pyrightconfig) == 1 then
    local confirm = vim.fn.input("Override existing pyrightconfig.json? (y/n): ")
    -- confirm or empty string continue to override if not return
    if confirm ~= "y" and confirm ~= "" then
      vim.notify("Not override pyrightconfig.json")
      return
    end
  end

  configStr = vim.fn.json_encode(config)
  vim.fn.writefile({ configStr }, pyrightconfig)
end
--   # which key migrate .nvim $HOME/.config/nvim/keys/which-key.vim
keymap("n", "<c-q>", ":q<CR>", { desc = "Close", noremap = true, silent = true })
keymap("n", "<localleader>q", ":q<CR>", { desc = "Close", noremap = true, silent = true })
keymap("n", "<localleader>cd", ":lcd%:p:h <CR>", { desc = "CD to current dir" })
keymap("n", "<localleader>cn", ':let @+=expand("%:t")<CR>', { desc = "Copy basefilename into reg" })
-- copy relative filepath name
keymap("n", "<localleader>cf", ":let @+=@%<CR>", { desc = "Copy relative filepath name" })
-- copy absolute filepath - use neotree (no relative file)
keymap("n", "<localleader>cF", ':let @+=expand("%:p")<CR>', { desc = "Copy absolute filepath" })
-- lsp / files
keymap("n", "<localleader>rp", "", { desc = "Profile & Python" })
keymap("n", "<localleader>rpp", addVenvPyrightConfig, { desc = "Python Setup pyright config " })
keymap("n", "<localleader>rl", ":luafile %<CR>", { desc = "Reload Lua file" })
keymap("v", "<localleader>rl", ":luafile %<CR>", { desc = "Reload Lua file" })
keymap("n", "<localleader>rps", function()
  vim.cmd([[
		:profile start /tmp/nvim-profile.log
		:profile func *
		:profile file *
	]])
end, { desc = "Profile Start" })

keymap("n", "<localleader>rpe", function()
  vim.cmd([[
		:profile stop
		:e /tmp/nvim-profile.log
	]])
end, { desc = "Profile End" })

--profile

-- ===========================
-- Custom commands ====================
-- =======================

local function rename_buffer()
  local old_name = vim.fn.expand("%")
  local new_name = vim.fn.input("Enter new buffer name: ", old_name)

  -- If user provided a new name and it's different from the old name
  if new_name ~= "" and new_name ~= old_name then
    -- Rename the buffer
    vim.api.nvim_buf_set_name(0, new_name)
    print("Buffer renamed to " .. new_name)
  else
    print("Buffer not renamed.")
  end
end

-- map("n", "<leader>n", "", { desc = "+CustomCommands" })
-- map("n", "<leader>nn", "<cmd>so $MYVIMRC<CR>", { desc = "Source Config" })
-- map("n", "<leader>S", "<cmd>SSave<CR>", { desc = "Save Session" })
-- map('n', '<Leader>nm', ':messages <CR>', { noremap = true, silent = true, desc = 'Show messages' })
-- map to get current basefile name

-- map('n', '<Leader>nM', [[:redir @a<CR>:messages<CR>:redir END<CR>:put! a<CR>]], { noremap = true, silent = true, desc = 'Print messages' })
-- Bind a key to invoke the renaming function
keymap("n", "<leader>bR", rename_buffer, { desc = "Rename Buffer", noremap = true, silent = true })

local open_command = "xdg-open"
if vim.fn.has("mac") == 1 then
  open_command = "open"
end

local function url_repo()
  local cursorword = vim.fn.expand("<cfile>")
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[url_repo cursorword:]==], vim.inspect(cursorword)) -- __AUTO_GENERATED_PRINT_VAR_END__
  if string.find(cursorword, "^[a-zA-Z0-9-_.]*/[a-zA-Z0-9-_.]*$") then
    cursorword = "https://github.com/" .. cursorword
  end
  print(cursorword or "")
  return cursorword or ""
end

keymap({ "n", "v" }, "gx", function()
  local url_or_word = url_repo()
  -- copy to register + if not empty
  vim.fn.jobstart({ open_command, url_or_word }, { detach = true }) -- not work in tmux
  if url_or_word ~= "" then
    vim.fn.setreg("+", url_or_word)
  end
  -- fallback to send gx if not a link or files
  -- vim.cmd("normal! gx")
  -- print("!" .. open_command .. " " .. url_repo())
  -- vim.cmd("!" .. open_command .. " " .. url_repo())
end, { silent = true, desc = "Copy word / Open url" })

set_opfunc = vim.fn[vim.api.nvim_exec(
  [[
  func s:set_opfunc(val)
    let &opfunc = a:val
  endfunc
  echon get(function('s:set_opfunc'), 'name')
]],
  true
)]

-- ===============================================
-- DELETE MAP ==========================
-- ===============================================
-- disabled in keymaps.lua (original)
vim.api.nvim_del_keymap("i", "<A-j>")
vim.api.nvim_del_keymap("i", "<A-k>")
vim.api.nvim_del_keymap("n", "<C-c>")
-- OVERRIDE MAP ==========================
keymap("n", "zj", "zj")
keymap("n", "zk", "zk")
