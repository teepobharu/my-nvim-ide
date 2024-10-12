local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set
local pathUtils = require("utils.path")
local test = require("gitsigns.test")

local function stringTest()
  local somebuffername = "term://lazygit/1"
  print(somebuffername)
  local ismatchlzg1 = string.match(somebuffername, ".*(lazygit)/1$")
  print([==[stringTest ismatchlzg1:]==], vim.inspect(ismatchlzg1)) -- __AUTO_GENERATED_PRINT_VAR_END__
  print([==[str find]==], string.find(somebuffername, "lazygit"))
  print([==[str findnone]==], string.find(somebuffername, "zxc"))
  is_lazygit = string.match(somebuffername, "lazygit")
  print([==[stringTest is_lazygit:]==], vim.inspect(is_lazygit)) -- __AUTO_GENERATED_PRINT_VAR_END__
end

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
local function testGit()
  local gitOriginSSH = "git@github.com:teepobharu/my-nvim-ide.git"
  local gitOriginHTTPS = "https://github.com/teepobharu/my-nvim-ide.git"

  local function extractNavigablePart(gitUrl)
    local sshPattern = "git@(.+):(.+).git"
    local httpsPattern = "https://(.+)/(.+).git"

    local domain, repo = gitUrl:match(sshPattern)
    if not domain then
      domain, repo = gitUrl:match(httpsPattern)
    end

    if domain and repo then
      return domain .. "/" .. repo
    else
      return nil, "Invalid Git URL"
    end
  end

  local navigablePartSSH = extractNavigablePart(gitOriginSSH)
  local navigablePartHTTPS = extractNavigablePart(gitOriginHTTPS)
  local git_current_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD")

  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[testGit git_mainbranch:]==], vim.inspect(git_mainbranch)) -- __AUTO_GENERATED_PRINT_VAR_END__
  print([==[testGit git_current_branch:]==], vim.inspect(git_current_branch)) -- __AUTO_GENERATED_PRINT_VAR_END__

  local function get_remote_path(remote_url)
    -- Remove the protocol part (git@ or https://) and remove the first : after the protocol
    local path = remote_url:gsub("^git@", ""):gsub("^https?://", "")
    -- remove the first colon only
    path = path:gsub(":", "/", 1)
    -- Remove the .git suffix
    path = path:gsub("%.git$", "")
    return path
  end
  print("using gsub function")
  print(get_remote_path(gitOriginSSH))
  print("using gsub 2 function")
  print(get_remote_path(gitOriginHTTPS) or "NONE")
  print("using extract function")
  print(navigablePartSSH) -- Output: github.com/teepobharu/my-nvim-ide
  print(navigablePartHTTPS) -- Output: github.com/teepobharu/my-nvim-ide
end
function testGit2()
  local current_file = path or vim.fn.expand("%:p")

  local urlPath = require("utils.git").get_remote_path()
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[testGit2 urlPath:]==], vim.inspect(urlPath)) -- __AUTO_GENERATED_PRINT_VAR_END__
  local mainBranch = require("utils.git").git_main_branch()
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[testGit2 mainBranch:]==], vim.inspect(mainBranch)) -- __AUTO_GENERATED_PRINT_VAR_END__
  local gitroot = require("utils.path").get_root_directory()
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[testGit2 gitroot:]==], vim.inspect(gitroot)) -- __AUTO_GENERATED_PRINT_VAR_END__
  local currentBranch = require("lazy.util").git_info(gitroot)
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[testGit2 currentBranch:]==], vim.inspect(currentBranch)) -- __AUTO_GENERATED_PRINT_VAR_END__

  -- gitlab vs gfithuib cases
  -- folder
  -- https://github.com/teepobharu/lazy-nvim-ide/tree/main/spell
  -- file
  -- -- https://gitlab.agodadev.io/full-stack/fe-data/messaging-client-js-core/-/blob/beta/.husky/commit-msg?ref_type=heads

  local branch = ""
  vim.ui.select({
    "1. Main Branch",
    "2. Current Branch",
  }, { prompt = "Choose to open in browser:" }, function(choice)
    if choice then
      local i = tonumber(choice:sub(1, 1))
      if i == 1 then
        branch = mainBranch
      else
        branch = currentBranch
      end
    else
    end
  end)
  local fullUrl = "https://" .. urlPath .. "/" .. current_file .. "/blob/" .. branch
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[testGit2 fullUrl:]==], vim.inspect(fullUrl)) -- __AUTO_GENERATED_PRINT_VAR_END__
  vim.fn.system("open " .. fullUrl)
  require("lazy.util").open(fullUrl)
end

function getGitList()
  local results = {}
  local remote_branches = vim.fn.system("git branch -r")
  for branch in remote_branches:gmatch("[^\r\n]+") do
    table.insert(results, { value = branch })
  end
end
function checkPyVenv()
  local pathVenv = vim.fn.getcwd() .. "/.venv"
  local isdir = vim.fn.isdirectory(pathVenv)
  if isdir == 1 then
    print(pathVenv .. " exists")
  else
    print(pathVenv .. " not exists")
  end
end

function getArrListConfig()
  local arrConfig = {
    { ssl = true, proxy = "" },
    { ssl = false, proxy = "http://localhost:11435" },
  }
  print(arrConfig[2].ssl)
  print(arrConfig[2].proxy)

  -- vim.g.copilot_proxy = "http://localhost:11435"
  -- vim.g.copilot_proxy_strict_ssl = false
end

function filesys()
  local f = vim.fn.tempname()
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[ f:]==], vim.inspect(f)) -- __AUTO_GENERATED_PRINT_VAR_END__
end

function executables()
  local ppath = vim.fn.exepath("python3")
  local ppath = vim.fn.exepath("python")
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[main ppath:]==], vim.inspect(ppath)) -- __AUTO_GENERATED_PRINT_VAR_END__
  get_pythonpath()
end

function get_pythonpath()
  -- check if pyrightconfig.json exists if yes proceed to get path from there else use pipenv --py to get other path else use default
  --
  -- find upward but do not exceed root project dir
  -- check if pyrightconfig.json exists
  -- if yes read venvPath and venv from there
  local root_dir = pathUtils.get_root_directory()
  local pyrightconfig = root_dir .. "/pyrightconfig.json"
  print([==[M.get_pythonpath pyrightconfig:]==], vim.inspect(pyrightconfig))
  if vim.fn.filereadable(pyrightconfig) == 1 then
    local config_content = vim.fn.readfile(pyrightconfig)
    local config = vim.fn.json_decode(table.concat(config_content, "\n"))

    if config == nil then
      print("config is nil")
    else
      local venvPath = config.venvPath
      local venv = config.venv
      local test = config.asda
      print([==[get_pythonpath#if config.venvPath:]==], vim.inspect(config)) -- __AUTO_GENERATED_PRINT_VAR_END__
      -- error if path not found
      if venvPath == nil or vim.fn.empty(venvPath) == 1 then
        vim.notify("pyrightconfig exist but venvPath not found", vim.log.levels.ERROR)
      else
        local venvPath = string.gsub(venvPath, root_dir, "")
        -- Remove front / back slash if it exists
        if string.sub(venvPath, 1, 1) == "/" then
          venvPath = string.sub(venvPath, 2)
        end
        if string.sub(venvPath, -1) == "/" then
          venvPath = string.sub(venvPath, 1, -2)
        end
        -- print("using from config: " .. root_dir .. "/" .. venvPath .. "/" .. "/bin/python")
        local pythonPath = root_dir .. "/" .. venvPath .. "/" .. "/bin/python"
        if vim.fn.filereadable(pythonPath) == 1 then
          -- print("pythonPath exists")
          return root_dir .. "/" .. venvPath .. "/" .. "/bin/python"
          -- print("pythonPath not exists")
        end
      end
    end
  end

  local python_path = vim.fn.systemlist("pipenv --py")[1]
  if vim.v.shell_error == 0 then
    print([==[get_pythonpath python_path (pipenv --py):]==], vim.inspect(python_path)) -- __AUTO_GENERATED_PRINT_VAR_END__
    return python_path
  else
    local python = vim.fn.exepath("python")
    print("==get_pythonpath using default python exe == :", python)
    return python
  end
end

function errorHandling()
  local ok, result = pcall(function()
    -- read non existing json decode
    local config = vim.fn.readfile("nonexisting.json")
    local decoded = vim.fn.json_decode(table.concat(config, "\n"))
    -- error("error")
  end)
  if not ok then
    print("error ==")
    vim.notify(result, vim.log.levels.ERROR)
  end
end
local function buffers()
  local prev_buf = vim.fn.bufnr("#") or 0
  local line_no = vim.api.nvim_buf_get_mark(prev_buf, ".")
  -- __AUTO_GENERATED_PRINT_VAR_START__
  print([==[ line_no:]==], prev_buf, "line:", vim.inspect(line_no))
  print([==[ line_no][1]==], line_no[1])
end
local function main()
  buffers()
  -- get_pythonpath()
  -- errorHandling()
  -- executables()
  -- filesys()
  -- getArrListConfig()
  if false then
    stringTest()
    printVariables()
    checkPyVenv()
    getGitList()
    testGit2()
    testGit()
    print(table.concat({ 1, 2, 3 }, ","))
    vim.opt_local.timeoutlen = 1000 -- setlocal can used (still not found any differences when set)
    print([==[main   vim.timeoutlen:]==], vim.inspect(vim.opt.timeoutlen._value)) -- __AUTO_GENERATED_PRINT_VAR_END__
    print([==[main   vim.timeoutlenlocal:]==], vim.inspect(vim.opt_local.timeoutlen._value)) -- __AUTO_GENERATED_PRINT_VAR_END__
    -- __AUTO_GENERATED_PRINT_VAR_START__
    toggleTermCheck()
    testKeyMap()
    -- require("toggleterm").setup({ size = 20, open_mapping = [[<C-\>]] }) -- open terminal with <C-\>
    print("not run functions")
    checkLspClients()
  end
end

main()
