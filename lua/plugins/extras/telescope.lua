local LazyUtil = require("utils.lazyutils")
local Path = require("utils.path")
local have_make = vim.fn.executable("make") == 1
local have_cmake = vim.fn.executable("cmake") == 1
local telescopePickers = require("config.telescope_pickers")
--- Open selected file in vertical split
local function open_selected_file_in_vertical()
  local entry = require("telescope.actions.state").get_selected_entry()
  require("telescope.actions").close(entry)
  vim.cmd("vsplit " .. entry.path)
end

local function find_files_from_project_git_root()
  local opts = {}
  if Path.is_git_repo() then
    opts = {
      cwd = Path.get_git_root(),
    }
  end
  require("telescope.builtin").find_files(opts)
end

local function live_grep_from_project_git_root()
  local opts = {}
  local is_in_dotfiles_dir = Path.get_git_root() == vim.env.DOTFILES_DIR
  local additional_args = is_in_dotfiles_dir and { "--hidden" } or {}
  if Path.is_git_repo() then
    opts = {
      cwd = Path.get_git_root(),
      additional_args = additional_args,
    }
  end

  require("telescope.builtin").live_grep(opts)
end
-- Custom function to run fd command and get results
local function run_fd_command(cmd)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  return vim.split(result, "\n")
end

local context_options =
  { "~ and DOTFILES tracked", "~ and DOTFILES with ignore", "DOTFILES/.config deep", ".config -d2" }
local commands_option = {
  "fd --type f --hidden --max-depth 1 . $HOME $DOTFILES_DIR",
  "fd --type f --hidden -I --max-depth 1 . $HOME $DOTFILES_DIR",
  "fd --type f --max-depth 14 . $DOTFILES_DIR/.config -E '*.xml' -E 'coc/*' -E 'raycast' -E 'neovim' -E 'nvim' -E 'alfred' -E 'karabiner/automatic_backups'",
  "fd --type f --hidden --max-depth 2 . $HOME/.config",
}
local current_index = 1

local function toggle_context(prompt_bufnr)
  local actions = require("telescope.actions")

  -- cycle between options
  current_index = current_index % #context_options + 1
  current_context = context_options[current_index]

  local current_text = require("telescope.actions.state").get_current_line()
  actions.close(prompt_bufnr)

  -- re-run the picker with the new context
  find_files_in_home_and_config(current_text)
end

-- custom picker function
function find_files_in_home_and_config(initialText)
  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")
  local previewers = require("telescope.previewers")
  local conf = require("telescope.config").values
  local all_files = {}

  all_files = run_fd_command(commands_option[current_index])
  -- all_files = run_fd_command("fd --type f --max-depth 2 . ~/.config")
  -- all_files = run_fd_command("fd --type f --max-depth 14 . ~/.config -E '*.xml' -E 'coc/*' -E 'raycast' -E 'neovim' -E 'nvim' -E 'alfred' -E 'karabiner/automatic_backups'")
  -- end

  -- Sort the combined list of files alphabetically
  table.sort(all_files)

  pickers
    .new({}, {
      default_text = initialText or "",
      prompt_title = "["
        .. current_index
        .. "/"
        .. #context_options
        .. "]"
        .. " Find config in . . . "
        .. context_options[current_index],
      finder = finders.new_table({
        results = all_files,
      }),
      previewer = previewers.cat.new({}),

      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        -- Bind Ctrl-Space to toggle the search context
        map({ "i", "n" }, "<C-Space>", function()
          toggle_context(prompt_bufnr)
        end)
        return true
      end,
    })
    :find()
end

function find_dot_config_files()
  -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#having-a-factory-like-function-based-on-a-dict - configure factory like dict differenet find cmds
  -- if current path is ~ only limit to depth = 1  with prompt = find HOME files include hidden files and folders
  -- if vim.fn.getcwd() == vim.fn.expand("~") then
  -- check if path is not inside ~/.config
  -- if not then find files in ~ and .config
  if vim.fn.getcwd() ~= vim.fn.expand("~/.config") then
    require("telescope.builtin").find_files({
      prompt_title = "Find $HOME and .config files",
      cwd = "~",
      find_command = { "fd", "--type", "f", "--hidden", "--max-depth", "1" },
      -- fd -H -d 1 -t d . ~ ~/.config
      search_dirs = { "~", ".config" },

      -- find_command = { "fd", "--type", "f", "--hidden", "--max-depth", "1", ".", "~", ".config" },
      -- # generate fd command to find in both dir ~ and ~/.config with max depth 1
    })
    return
  end
  require("telescope.builtin").find_files({ prompt_title = "Find .Config files", cwd = "~/.config" })
end
vim.api.nvim_create_user_command("FindConfig", find_dot_config_files, {})

local function session_pickers()
  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local opts = {}
  local get_session_list = function()
    local session_dir = vim.g.startify_session_dir or "~/.config/session"
    -- Logic to handle session previews using the session directory
    -- You can customize this to display session information or previews
    -- Example: Display session files in the specified directory
    local results = {}
    for file in
      io.popen(
        "find " .. session_dir .. ' -maxdepth 1 -type f -name "[[:alpha:][:digit:]][[:alnum:]_]*" -exec basename {} +'
      )
        :lines()
    do
      table.insert(results, { value = file })
    end
    return results
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

          if current_line ~= "" then
            vim.cmd("SSave! " .. session_name)

            if firstMultiSelection then
              vim.notify(
                "Save session from first multi selected " .. firstMultiSelection.value,
                vim.log.levels.INFO,
                { title = "Telescope session" }
              )
            else
              vim.notify(
                "Save session from input prompt" .. current_line,
                vim.log.levels.INFO,
                { title = "Telescope session" }
              )
            end
          end
        end

        function reloadResults()
          local state = require("telescope.actions.state")
          local current_picker = state.get_current_picker(prompt_bufnr)
          local new_finder = require("telescope.finders").new_table({
            results = get_session_list(),
            -- require below else not working
            entry_maker = function(entry)
              return {
                display = entry.value,
                value = entry.value,
                ordinal = entry.value,
              }
            end,
          })
          current_picker:refresh(new_finder)
          -- reopen_session_pickers(prompt_bufnr)

          -- close the current picker
        end
        map("i", "<C-s>", function()
          saveSession(prompt_bufnr)
          require("telescope.actions").close(prompt_bufnr)
        end)
        map("n", "<C-s>", function()
          saveSession(prompt_bufnr)
          reloadResults()
        end)
        map("n", "X", function()
          local entry = action_state.get_selected_entry()
          -- confirming
          local user_input = vim.fn.confirm("Confirm Delete Session: " .. entry.value, "&Yes\n&No", 2)
          if user_input == 1 then
            vim.cmd("SDelete! " .. entry.value)
            reloadResults()
          end
        end)

        --- end ---
        return true
      end,
      finder = finders.new_table({
        results = get_session_list(),
        entry_maker = function(entry)
          return {
            display = entry.value,
            value = entry.value,
            ordinal = entry.value,
          }
        end,
      }),
      sorter = require("telescope.config").values.generic_sorter(opts),
      -- })
    })
    :find()
  -- return require("telescope").register_extension{
  --   exports = { startify = session_picker }
  -- }
end

return {
  { import = "plugins.extras.telescope-zoxide" },
  {
    "nvim-telescope/telescope.nvim",
    -- duplicate of the ./telescope-lazy.lua file config
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = have_make and "make"
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = have_make or have_cmake,
        config = function(plugin)
          LazyUtil.on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf." .. (LazyUtil.is_win() and "dll" or "so")
              if not vim.uv.fs_stat(lib) then
                vim.notify("`telescope-fzf-native.nvim` not built. Rebuilding...", vim.log.levels.WARN)
                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                  vim.notify("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
                end)
              else
                vim.notify("Failed to load `telescope-fzf-native.nvim`:\n" .. err, vim.log.levels.ERROR)
              end
            end
          end)
        end,
      },
    },
    opts = function()
      return {
        defaults = {
          prompt_prefix = "   ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
              ["X"] = require("telescope.actions").delete_buffer,
              ["<C-u>"] = false, -- disable scroll preview - to use clear prompt
            },
            n = {
              ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
            },
          },
        },
      }
    end,
    keys = {
      -- add <leader>fa to find all, including hidden files
      -- {
      --   "<leader>sc",
      --   "<cmd> Telescope command_history <CR>",
      --   mode = "v",
      --   desc = "Command History",
      -- },
      {
        "<leader>fa",
        "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
        desc = "Find All Files (including hidden)",
      },
      -- add <leader>fl to live grep from git root
      -- {
      --   "<leader>fl",
      --   function()
      --     live_grep_from_project_git_root()
      --   end,
      --   desc = "Live Grep From Project Git Root",
      -- },
      -- -- add <leader>fg to find files from project git root
      -- {
      --   "<leader>fg",
      --   function()
      --     find_files_from_project_git_root()
      --   end,
      --   desc = "Find Files From Project Git Root",
      -- },
      {
        "<leader>fz",
        find_files_in_home_and_config,
        desc = "Find my dotconfig files in home and config",
      },
      {
        "<localleader>go",
        telescopePickers.telescope.getPickers({}).git_branch_remote_n_diff_picker,
        desc = "Open Git Pickers",
      },
      {
        "<leader>fs",
        session_pickers,
        desc = "Find Sesssions",
      },
    },
  },
}
