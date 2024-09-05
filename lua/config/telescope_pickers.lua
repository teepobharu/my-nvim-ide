local M = {}
local gitUtil = require("utils.git")
M.telescope = {}

M.telescope.getPickers = function(opts)
  local conf = require("telescope.config").values
  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local action_utils = require("telescope.actions.utils")

  local session_pickers = function()
    local session_dir = vim.g.startify_session_dir or "~/.config/session"
    -- Logic to handle session previews using the session directory
    -- You can customize this to display session information or previews
    -- Example: Display session files in the specified directory
    local results = {}
    --
    -- for file in io.popen('ls ' .. session_dir):lines() do
    -- find to format output as filename only not the full path
    --p[[:alnum:]_].*find $(pwd) -name '
    --for more format see man re_format
    for file in
      io.popen(
        "find " .. session_dir .. ' -maxdepth 1 -type f -name "[[:alpha:][:digit:]][[:alnum:]_]*" -exec basename {} +'
      )
        :lines()
    do
      -- file that starts with alpahnumerical
      table.insert(results, { value = file })
    end

    -- add key map for loadding with SLoad when press C-enter
    -- actions.select_default:replace(function(prompt_bufnr)
    --  local entry = actions.get_selected_entry(prompt_bufnr)
    --  if entry this_offset_encoding
    --

    -- Return the results for display in Telescope
    return pickers
      .new(opts, {
        prompt_title = "Startify Sessions",
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()

            if selection then
              vim.cmd("SLoad " .. selection.value)
            end
          end)
          map("i", "<C-CR>", function(_prompt_bufnr)
            local entry = action_state.get_selected_entry()
            if entry then
              vim.cmd("SLoad " .. entry.value)
            end
          end)

          local saveSession = function(_prompt_bufnr)
            local picker = action_state.get_current_picker(_prompt_bufnr)
            local firstMultiSelection = picker:get_multi_selection()[1]

            local current_line = action_state.get_current_line()
            -- trim right the current_line
            current_line = current_line:gsub("%s+$", "")

            local session_name = firstMultiselection or current_line

            if firstMultiSelection then
              print("Save session from first multi selected " .. firstMultiSelection.value)
            else
              print("Save session from input prompt .. " .. current_line)
            end

            if current_line ~= "" then
              vim.cmd("SSave! " .. session_name)
            end
          end

          map("i", "<C-s>", function()
            saveSession(prompt_bufnr)
          end)
          map("n", "<C-s>", function()
            saveSession(prompt_bufnr)
          end)
          map("n", "X", function()
            local entry = action_state.get_selected_entry()
            -- confirming

            local user_input = vim.fn.confirm("Confirm Delete Session" .. entry.value, "yesno", 2)
            if user_input == 1 then
              vim.cmd("SDelete! " .. entry.value)
              -- local picker = action_state.get_current_picker(_prompt_bufnr)
              -- picker.refresh()
            end
          end)

          --- end ---
          return true
        end,
        finder = finders.new_table({
          results = results,
          entry_maker = function(entry)
            return {
              display = entry.value,
              value = entry.value,
              ordinal = entry.value,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        -- })
      })
      :find()
    -- return require("telescope").register_extension{
    --   exports = { startify = session_picker }
    -- }
  end

  local open_git_pickers = function()
    local file_path = vim.fn.expand("%:p")

    local function get_git_root()
      local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
      return git_root
    end

    local function get_branch_url(branch)
      -- local sanitized_branch = branch:gsub("^%s*(.-)%s*$", "")
      local function remove_remote_prefix(ref)
        local sanitized_ref = ref:gsub("^%s*(.-)%s*$", "%1")
        -- # HEAD -> origin/HEAD
        -- # remotes/origin/branch

        -- Remove the first asterisk or + (if present)
        -- trim space
        sanitized_ref = sanitized_ref:gsub(" ", "")
        santized_ref = sanitized_ref:gsub("^[*|+]", "")
        sanitized_ref = sanitized_ref:gsub("^remotes/[%w%p]+/", "")
        -- Remove leading/trailing whitespace
        -- remote_path needs to remove prefix remotes/<any remote name>/
        return sanitized_ref
      end

      local sanitized_branch = remove_remote_prefix(branch)
      -- __AUTO_GENERATED_PRINT_VAR_START__
      print([==[function#function#get_branch_url sanitized_branch:]==], vim.inspect(sanitized_branch)) -- __AUTO_GENERATED_PRINT_VAR_END__
      -- local ssh="git@github.com:teepobharu/mynotes.git"
      -- local http="https://github.com/teepobharu/mynotes.git"
      -- result should not contain ssh part and .git suffix and colon for ssh and http case
      local remote_path = gitUtil.get_remote_path()
      -- __AUTO_GENERATED_PRINT_VAR_START__
      print([==[function#function#get_branch_url remote_path:]==], vim.inspect(remote_path)) -- __AUTO_GENERATED_PRINT_VAR_END__
      -- remote_path needs to remove prefix remotes/<any remote name>/
      local line_number = vim.fn.line(".")
      local git_file_path = file_path:gsub(get_git_root() .. "/", "")
      local url_pattern = "https://%s/blob/%s/%s#L%d"
      -- if findpath empty
      if git_file_path == "" or git_file_path:gsub(" ", "") == "" then
        -- return just the repo
        return remote_path
      end
      return string.format(url_pattern, remote_path, sanitized_branch, git_file_path, line_number)
    end

    -- print(get_branch_url("master"))

    local function open_branch_url(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      local branch = selection.value
      local url = get_branch_url(branch)

      vim.fn.setreg("+", url)

      local open_command = "open"

      -- vim.fn.jobstart({ "tmux", "run-shell", "-b", "-c", "open " .. url }, { detach = true })
      -- not work in tmux not sure why
      vim.fn.jobstart({ open_command, url }, { detach = true }) -- not work in tmux

      require("lazy.util").open(url)
      -- vim.cmd("silent !open " .. url)
    end

    local default_branch = gitUtil.git_main_branch()
    print(default_branch)

    vim.fn.setreg("+", get_branch_url(default_branch))

    -- TODO: only get remote branches, trim * and whitespace, remove remotes/origin/ prefix
    -- use this in neotree and normal shortcut in current buffer as well

    local function get_remote_branches_name()
      local results = {}
      local remote_branches = vim.fn.system("git branch --remote | sed -E 's|.* ||; s|^[^/]+/||' | uniq")
      for branch in remote_branches:gmatch("[^\r\n]+") do
        table.insert(results, { value = branch })
      end
      return results
    end

    return pickers
      .new({
        prompt_title = "Open Branch URL",
        finder = finders.new_table({
          results = get_remote_branches_name(),
          entry_maker = function(entry)
            return {
              display = entry.value,
              value = entry.value,
              ordinal = entry.value,
            }
          end,
        }),
        -- finder = finders.new_oneshot_job(preview_commands, conf.vimgrep_arguments),

        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            open_branch_url(prompt_bufnr)
          end)
          map("i", "<CR>", function()
            open_branch_url(prompt_bufnr)
          end)
          map("i", "<C-c>", function()
            vim.fn.setreg("+", get_branch_url(action_state.get_selected_entry().value))
          end)
          return true
        end,
      })
      :find()
  end

  local test_pickers = function()
    local results = {
      { value = "test1" },
      { value = "test2" },
      { value = "test3" },
      { value = "start1" },
    }

    return pickers
      .new(opts, {
        prompt_title = "Test Picker",
        finder = finders.new_table({
          results = results,
          entry_maker = function(entry)
            return {
              display = entry.value,
              value = entry.value,
              ordinal = entry.value,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()

            if selection then
              print("Entered on : " .. selection.value)
            end
          end)
          map("i", "<C-s>", function(_prompt_bufnr)
            print("Saving")
            local entry = action_state.get_selected_entry()
            print("cursor entry = " .. entry.value)
            local picker = action_state.get_current_picker(_prompt_bufnr)
            print("===========DEBUG ===========")
            print("Get multi selection")
            local selections_multi = picker:get_multi_selection()
            local num_selections = table.getn(selections_multi)
            print(num_selections)
            print(vim.inspect(picker:get_multi_selection()))
            local firstMultiSelection = picker:get_multi_selection()[1]
            print(vim.inspect(firstMultiSelection))

            print("current line: " .. action_state.get_current_line())

            local prompt_bufnr2 = vim.api.nvim_get_current_buf()
            print(prompt_bufnr .. " _pbn: " .. _prompt_bufnr .. " pbuf2: " .. prompt_bufnr2)

            local current_line = action_state.get_current_line()
            -- trim right the current_line
            current_line = current_line:gsub("%s+$", "")

            print(" MAP SELECTION ")
            action_utils.map_selections(_prompt_bufnr, function(entry)
              print(entry.value)
            end)

            print(" MAP ENTRIES")
            action_utils.map_entries(prompt_bufnr2, function(entry, index, row)
              print(entry.value .. " idx:" .. index .. " row:" .. row)
            end)
          end)
          return true
        end,
      })
      :find()
  end

  return {
    session_pickers = session_pickers,
    test_pickers = test_pickers,
    open_git_pickers = open_git_pickers,
  }
end

return M
