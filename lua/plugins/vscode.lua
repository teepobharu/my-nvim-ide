if not vim.g.vscode then
  return {}
end

local enabled = {
  "lazy.nvim",
  "nvim-treesitter",
  "ts-comments.nvim",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "nvim-ts-context-commentstring",
  "vim-repeat",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

-- Add some vscode specific keymaps
-- Refer to https://github.com/vscode-neovim/vscode-neovim#code-navigation-bindings for default keymaps
vim.api.nvim_create_autocmd("User", {
  pattern = "NvimIdeKeymaps", -- This pattern will be called when the plugin is loaded
  callback = function()
    local vscode = require("vscode")
    -- +File
    -- Find file
    vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")

    -- Find recent open files
    vim.keymap.set("n", "<leader>fr", function()
      vscode.action("workbench.action.showAllEditorsByMostRecentlyUsed")
    end)

    -- Need to install https://github.com/jellydn/vscode-fzf-picker
    vim.keymap.set("n", "<leader>ff", function()
      vscode.action("fzf-picker.findFiles")
    end)
    -- Find word
    vim.keymap.set({ "n", "v" }, "<leader>fw", function()
      vscode.action("fzf-picker.findWithinFiles")
    end)
    vim.keymap.set("n", "<leader>fw", function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
      vscode.action("fzf-picker.findWithinFiles")
    end)
    -- Find file from git status
    vim.keymap.set("n", "<leader>fg", function()
      vscode.action("fzf-picker.pickFileFromGitStatus")
    end)
    -- Resume last search
    vim.keymap.set("n", "<leader>fR", function()
      vscode.action("fzf-picker.resumeSearch")
    end)
    -- Find todo/fixme
    vim.keymap.set("n", "<leader>fx", function()
      vscode.action("fzf-picker.findTodoFixme")
    end)

    -- Open other files
    vim.keymap.set("n", "<leader>,", function()
      vscode.action("workbench.action.showAllEditors")
    end)
    -- Find in files
    vim.keymap.set("n", "<leader>/", function()
      vscode.action("workbench.action.findInFiles")
    end)
    -- Open file explorer in left sidebar
    vim.keymap.set("n", "<leader>e", function()
      vscode.action("workbench.view.explorer")
    end)

    -- +Search
    -- Open symbol
    vim.keymap.set("n", "<leader>ss", function()
      vscode.action("workbench.action.gotoSymbol")
    end)
    -- Search word under cursor
    vim.keymap.set("n", "<leader>sw", function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
      vscode.action("workbench.action.findInFiles")
      -- Or send as the param like this: code.action("workbench.action.findInFiles", { args = { query = vim.fn.expand("<cword>") } })
    end)

    -- Keep undo/redo lists in sync with VsCode
    vim.keymap.set("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>")
    vim.keymap.set("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>")
    -- Navigate VSCode tabs like lazyvim buffers
    vim.keymap.set("n", "<S-h>", "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
    vim.keymap.set("n", "<S-l>", "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")

    -- Search work in current buffer
    vim.keymap.set("n", "<leader>sb", function()
      vscode.action("actions.find")
    end)

    -- +Code
    -- Code Action
    vim.keymap.set("n", "<leader>ca", function()
      vscode.action("editor.action.codeAction")
    end)
    -- Source Action
    vim.keymap.set("n", "<leader>cA", function()
      vscode.action("editor.action.sourceAction")
    end)
    -- Code Rename
    vim.keymap.set("n", "<leader>cr", function()
      vscode.action("editor.action.rename")
    end)
    -- Quickfix shortcut
    vim.keymap.set("n", "<leader>.", function()
      vscode.action("editor.action.quickFix")
    end)
    -- Code format
    vim.keymap.set("n", "<leader>cf", function()
      vscode.action("editor.action.formatDocument")
    end)
    -- Refactor
    vim.keymap.set("n", "<leader>cR", function()
      vscode.action("editor.action.refactor")
    end)

    -- +Terminal
    -- Open terminal
    vim.keymap.set("n", "<leader>ft", function()
      vscode.action("workbench.action.terminal.focus")
    end)

    -- +LSP
    -- View problem
    vim.keymap.set("n", "<leader>xx", function()
      vscode.action("workbench.actions.view.problems")
    end)
    -- Go to next/prev error
    vim.keymap.set("n", "]e", function()
      vscode.action("editor.action.marker.next")
    end)
    vim.keymap.set("n", "[e", function()
      vscode.action("editor.action.marker.prev")
    end)

    -- Find references
    vim.keymap.set("n", "gr", function()
      vscode.action("references-view.find")
    end)

    -- +Git
    -- Git status
    vim.keymap.set("n", "<leader>gs", function()
      vscode.action("workbench.view.scm")
    end)
    -- Go to next/prev change
    vim.keymap.set("n", "]h", function()
      vscode.action("workbench.action.editor.nextChange")
    end)
    vim.keymap.set("n", "[h", function()
      vscode.action("workbench.action.editor.previousChange")
    end)

    -- Revert change
    vim.keymap.set("v", "<leader>ghr", function()
      vscode.action("git.revertSelectedRanges")
    end)

    -- +Buffer
    -- Close buffer
    vim.keymap.set("n", "<leader>bd", function()
      vscode.action("workbench.action.closeActiveEditor")
    end)
    -- Close other buffers
    vim.keymap.set("n", "<leader>bo", function()
      vscode.action("workbench.action.closeOtherEditors")
    end)

    -- +Project
    vim.keymap.set("n", "<leader>fp", function()
      vscode.action("workbench.action.openRecent")
    end)

    -- Markdown preview
    vim.keymap.set("n", "<leader>mp", function()
      vscode.action("markdown.showPreviewToSide")
    end)

    -- Hurl runner, https://github.com/jellydn/vscode-hurl-runner
    vim.keymap.set("n", "<leader>ha", function()
      vscode.action("vscode-hurl-runner.runHurl")
    end)
    vim.keymap.set("n", "<leader>hr", function()
      vscode.action("vscode-hurl-runner.rerunLastCommand")
    end)
    vim.keymap.set("n", "<leader>hA", function()
      vscode.action("vscode-hurl-runner.runHurlFile")
    end)
    vim.keymap.set("n", "<leader>he", function()
      vscode.action("vscode-hurl-runner.runHurlFromBegin")
    end)
    vim.keymap.set("n", "<leader>hE", function()
      vscode.action("vscode-hurl-runner.runHurlToEnd")
    end)
    vim.keymap.set("n", "<leader>hg", function()
      vscode.action("vscode-hurl-runner.manageInlineVariables")
    end)
    vim.keymap.set("n", "<leader>hh", function()
      vscode.action("vscode-hurl-runner.viewLastResponse")
    end)
    vim.keymap.set("v", "<leader>hh", function()
      vscode.action("vscode-hurl-runner.runHurlSelection")
    end)

    -- Run task
    vim.keymap.set("n", "<leader>rt", function()
      vscode.action("workbench.action.tasks.runTask")
    end)
    -- Re-run
    vim.keymap.set("n", "<leader>rr", function()
      vscode.action("workbench.action.tasks.reRunTask")
    end)

    -- Debug typescript type, used with https://marketplace.visualstudio.com/items?itemName=Orta.vscode-twoslash-queries
    vim.keymap.set("n", "<leader>dd", function()
      vscode.action("orta.vscode-twoslash-queries.insert-twoslash-query")
    end)

    -- Other keymaps will be used with https://github.com/VSpaceCode/vscode-which-key, so we don't need to define them here
    -- Trigger which-key by pressing <CMD+Space>, refer more default keymaps https://github.com/VSpaceCode/vscode-which-key/blob/15c5aa2da5812a21210c5599d9779c46d7bfbd3c/package.json#L265

    -- Mutiple cursors
    vim.keymap.set({ "n", "x", "i" }, "<C-m>", function()
      require("vscode-multi-cursor").addSelectionToNextFindMatch()
    end)
  end,
})

-- X : if vscode then add run time
if vim.g.vscode then
  -- vim.cmd([[set runtimepath^=$HOME/.config/nvim2_jelly_lzmigrate]])
  -- -- print runtimepathkjA
  -- print(vim.o.runtimepath)
  --   require("config.mykeymaps")
end

vim.api.nvim_create_autocmd("User", {
  pattern = "NvimIdeKeymaps", -- This pattern will be called when the plugin is loaded
  callback = function()
    -- api : https://github.com/vscode-neovim/vscode-neovim?tab=readme-ov-file#%EF%B8%8F-api
    local vscode = require("vscode")

    local QuickOnboardKeyInstructions = [[
    <l> = leader 
    -----------------------------
    \n ?+? WhichKey search 
    <l>ls Stop plugin
    <l>lr Restart neovim plugin 
    -----------------------------
    <l>to Open output tab
    <l>oo Open test results
    <l><space> Find file
    -- Git
    <l>gb Git blame
    <l>gf Git file history
    <l>gC Git compare diff
    <l>gi Toggle inline diff
    <l>g< diff with previously
    -- 
    <l>fr Find recent open files
    <l>ff Find files using fzf-picker
    <l>fw Find word within files
    <l>fg Find file from git status
    <l>fR Resume last search
    <l>fx Find todo/fixme
    <l>, Open other files
    <l>/ Find in files
    <l>e Open file explorer in left sidebar
    <l>ss Open symbol
    <l>sw Search word under cursor
    <l>sb Search word in current buffer
    <l>ca Code action
    <l>cA Source action
    <l>cr Code rename
    <l>. Quickfix shortcut
    <l>cf Code format
    <l>cR Refactor
    <l>ft Open terminal
    <l>xx View problems
]]

    vim.notify(QuickOnboardKeyInstructions)
    -- vscode.notify(QuickOnboardKeyInstructions)
    -- Helper
    vim.keymap.set("n", "?", function()
      vscode.action("whichkey.show")
    end)
    --
    -- FIX: no output or anything in vscode
    vim.keymap.set("n", "<localleader>le", function()
      local configFile = vim.fn.expand("$HOME/.config/nvim2_jelly_lzmigrate/init.lua")
      vim.notify("Open file: " .. configFile)
      -- edit file in vscode
      vim.fn.jobstart("code " .. configFile, { detach = true })

      -- local currentfiledir = vim.fn.expand("<sfile>:p:h")
      -- vscode.notify("currdir" .. currentfiledir) -- empty
      -- vim.fn.jobstart("code " .. currentfiledir, { detach = true })
    end)

    -- +Window
    -- vs / sp split
    vim.keymap.set("n", "<leader>wv", function()
      vscode.action("workbench.action.splitEditor")
    end)
    -- Ctrl Q - close window group
    vim.keymap.set("n", "<C-q>", function()
      vscode.action("workbench.action.closeEditorsAndGroup")
    end)
    vim.keymap.set("n", "<leader>wL", function()
      vscode.action("workbench.action.closeEditorsToTheRight")
    end)
    vim.keymap.set("n", "<leader>wH", function()
      vscode.action("workbench.action.closeEditorsToTheLeft")
    end)
    vim.keymap.set("n", "<leader>wh", function()
      vscode.action("workbench.action.splitEditorDown")
    end)

    vim.keymap.set("n", "Q", function()
      -- close file
      vscode.action("workbench.action.closeActiveEditor")
    end)
    -- since bd have some problem that open output file
    vim.keymap.set("n", "L", function()
      vscode.action("workbench.action.nextEditorInGroup")
    end)
    vim.keymap.set("n", "H", function()
      vscode.action("workbench.action.previousEditorInGroup")
    end)
    vim.keymap.set("n", "<leader>to", function()
      vscode.action("workbench.panel.output.focus")
    end)

    -- +Git
    vim.keymap.set("n", "<leader>gb", function()
      -- blame
      vscode.action("gitlens.toggleFileBlame")
    end)

    -- open file history
    vim.keymap.set("n", "<leader>gf", function()
      vscode.action("gitlens.views.fileHistory.focus")
    end)

    -- open compare diff
    vim.keymap.set("n", "<leader>gC", function()
      vscode.action("gitlens.compareHeadWith")
      vscode.notify("use cmd+down browse sections")
    end)
    vim.keymap.set("n", "<leader>gi", function()
      vscode.action("toggle.diff.renderSideBySide")
    end)
    vim.keymap.set("n", "<leader>g<", function()
      vscode.action("gitlens.diffWithPreviousInDiffLeft")
    end)

    -- +File

    -- LSP and code
    -- vscode-neovim.restart with <leader>ls (stop vim)
    vim.keymap.set("n", "<leader>ls", function()
      vscode.action("vscode-neovim.stop")
    end)
    -- typescript.restartTsServer with <leader>ls (stop vim)
    -- set j k and k j to enter normal mode - not work use in settings.json
    -- vim.keymap.set("i", "jk", "<esc>")
    -- vim.keymap.set("i", "kj", "<esc>")
    -- send selected text / lline to terminal in n\v mode
    -- open shortcuts key json in vscode
    vim.keymap.set({ "n", "v" }, "<localleader>t", function()
      -- vscode.notify("Before wrun WAIT")
      vscode.action("workbench.action.terminal.runSelectedText")
      -- vscode.call("_wait", { args = { 1000 }, 100 })
      -- vscode.notify("AFFTER WAIT NEVER RUN !!")
      -- vscode.call("workbench.action.terminal.focus", {}, 100)
    end)

    vim.keymap.set({ "n", "v" }, "<leader>lr", function()
      vscode.action("vscode-neovim.restart")
      -- open output tab vscode l;og
      vscode.action("workbench.panel.output.focus")
    end)
    --

    -- Tests
    vim.keymap.set("n", "<leader>oo", function()
      vscode.action("workbench.panel.testResults.view.focus")
    end)

    -- AI
    vim.keymap.set({ "n", "v" }, "<leader>aq", function()
      vscode.action("inlineChat.start")
    end)
    vim.keymap.set({ "n", "v" }, "<leader>av", function()
      vscode.action("workbench.action.chat.openInSidebar")
    end)

    vim.keymap.set("n", "<leader>at", function()
      vscode.action("github.copilot.terminal.attachTerminalSelection")
    end)

    vim.keymap.set({ "n", "v" }, "<leader>sf", function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
      vscode.action("editor.action.startFindReplaceAction")
    end)

    vim.keymap.set({ "n", "v" }, "<leader>sF", function()
      local currentDir = vim.fn.expand("%:p:h")
      -- if v mode then use the selection text
      local query = vim.fn.getreg("v") or vim.fn.expand("<cword>")
      vscode.action("workbench.action.findInFiles", {
        args = { query = query, filesToInclude = currentDir .. "/**" },
      })
    end)

    vim.keymap.set("n", "<leader>aV", function()
      vscode.action("workbench.action.chat.openEditSession")
    end)
    vim.keymap.set("v", "<leader>aV", function()
      vscode.action("github.copilot.edits.attachSelection")
      vscode.action("workbench.panel.chat.view.edits.focus")
    end)
    vim.keymap.set({ "n", "v" }, "<leader>aa", function()
      vscode.action("continue.focusContinueInputWithoutClear")
    end)
  end,
})

return {
  {
    "xiyaowong/fast-cursor-move.nvim",
    vscode = true,
    enabled = vim.g.vscode,
    init = function()
      -- Disable acceleration, use key repeat settings instead
      vim.g.fast_cursor_move_acceleration = false
    end,
  },
  -- Refer https://github.com/vscode-neovim/vscode-multi-cursor.nvim to more usages
  -- gcc: clear multi cursors
  -- gc: create multi cursors
  -- mi/mI/ma/MA: insert text at each cursor
  {
    "vscode-neovim/vscode-multi-cursor.nvim",
    event = "VeryLazy",
    cond = not not vim.g.vscode,
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
