local prompts = {
  -- Code related prompts
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please explain how the selected code works, then generate unit tests for it.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
  SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
  -- Text related prompts
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",
}

function setupPrompts(initialPrompts)
  -- local sysp = require("CopilotChat.prompts") -- see default prompts here
  ---@class CopilotChat.config.prompt
  return vim.tbl_extend("force", initialPrompts, {
    DocAlgo = "Please provide brief documentation for the following algorithm, if code does not summarize pitfalls briefly and add simple breaking case sample finally analyze the time and space complexity.",
    ReactTestingLibraryConvert = {
      prompt = [[
      Please convert the React component testing code to not use enzyme related library,
      and use React Testing Library instead.
    ]],
      description = "Convert React component testing code to use React Testing Library",
      selection = function(source)
        return require("CopilotChat.select").visual(source) or require("CopilotChat.select").buffer(source)
      end,
    },
    ReactBestPractices = {
      prompt = [[
      Please refactor the following React code to follow best practices and performance measures : rerender, readability, etc.
    ]],
      selection = function(source)
        return require("CopilotChat.select").visual(source) or require("CopilotChat.select").buffer(source)
      end,
      show_system_prompt = true,
      -- seems not to working
      system_prompt = [[
      First greet the user with a random jokes message.
      Then ask the user to provide the code.
      Finally, thank the user for using the service.
    ]],
    },
  })
end

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai", mode = { "n", "v" } },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "diff", "markdown" } },
  },
  {
    -- [NOTE]: brew install lynx if you want browser terminal
    dir = IS_DEV and "~/research/CopilotChat.nvim" or nil,
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    -- version = "v3.7.0",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      prompts = prompts,
      model = "claude-3.7-sonnet",
      mappings = {
        -- Use tab for completion
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        -- Close the chat
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        -- Reset the chat buffer
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
        -- Submit the prompt to Copilot
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        -- Accept the diff
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        -- Show help
        show_help = {
          normal = "g?",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      local hostname = io.popen("hostname"):read("*a"):gsub("%s+", "")
      local user = hostname or vim.env.USER or "User"
      opts.question_header = "  " .. user .. " "
      opts.answer_header = "  Copilot "
      -- Override the git prompts message
      opts.prompts.Commit = {
        prompt = '> #git:staged\n\nWrite commit message with commitizen convention. Write clear, informative commit messages that explain the "what" and "why" behind changes, not just the "how".',
      }

      opts.prompts = setupPrompts(opts.prompts)
      chat.setup(opts)

      local select = require("CopilotChat.select")
      vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
        chat.ask(args.args, { selection = select.visual })
      end, { nargs = "*", range = true })

      -- Inline chat with Copilot
      vim.api.nvim_create_user_command("CopilotChatInline", function(args)
        chat.ask(args.args, {
          selection = select.visual,
          window = {
            layout = "float",
            relative = "cursor",
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = "*", range = true })

      -- Visual chat that get current buffer and the system clipboard combined as a selection
      -- This is useful for chat that require both the current buffer and the system clipboard
      -- For example, when you want to ask Copilot to refactor the code and provide a better Naming
      vim.api.nvim_create_user_command("CopilotChatBuffEdit", function(args)
        --- @param source CopilotChat.config.source
        --- @return CopilotChat.config.selection|nil
        ---
        local curr_bufnr = vim.api.nvim_get_current_buf()
        local curr_filepath = vim.fn.expand("%:p")
        local curr_filetype = vim.bo[curr_bufnr].filetype
        -- __AUTO_GENERATED_PRINT_VAR_START__
        print([==[function#function curr_filetype:]==], vim.inspect(curr_filetype)) -- __AUTO_GENERATED_PRINT_VAR_END__

        local buffer = {
          -- __AUTO_GENERATED_PRINT_VAR_START__
          --f ile name of current active buffer
          filename = curr_filepath,
          lines = vim.api.nvim_buf_get_lines(curr_bufnr, 0, -1, false),
          filetype = vim.api.nvim_buf_get_option(curr_bufnr, "filetype"),
          sname = vim.fn.fnamemodify(curr_filepath, ":."),
          uptoTwoParentPath = vim.fn.fnamemodify(curr_filepath, ":~:~:t"),
          rfname = vim.fn.fnamemodify(curr_filepath, ":."),
        }
        print([==[function#function buffer:]==], vim.inspect(buffer)) -- __AUTO_GENERATED_PRINT_VAR_END__
        local clipboard = select.clipboard() or select.unnamed() or ""
        local clipboard_lines = clipboard.lines
            and vim.tbl_flatten({
              { "```" .. curr_filetype },
              vim.split(clipboard.lines, "\n"),
              { "```" },
            })
          or {}

        local lines = {
          "`file: " .. buffer.uptoTwoParentPath .. "`",
          "```" .. buffer.filetype,
        }

        -- Ensure lines is an array by appending each element of buffer.lines
        for _, line in ipairs(buffer.lines) do
          table.insert(lines, line)
        end
        -- vim.list_extend(lines, buffer.lines)
        lines = vim.tbl_flatten({
          lines,
          "```",
          clipboard_lines,
        })

        print([==[function#function lines:]==], vim.inspect(lines)) -- __AUTO_GENERATED_PRINT_VAR_END__
        -- display the whle prompt in float temp buffer to see the aggregate content once saved to buffer proceed to run the editted content and pass to the chat
        local bufnr = vim.api.nvim_create_buf(true, true)
        -- __AUTO_GENERATED_PRINT_VAR_START__
        print([==[function#function bufnr:]==], vim.inspect(bufnr)) -- __AUTO_GENERATED_PRINT_VAR_END__

        vim.bo[bufnr].buftype = "" -- Allow writing to the buffer
        vim.bo[bufnr].syntax = "markdown"
        vim.bo[bufnr].modifiable = true
        vim.treesitter.start(bufnr, "markdown")
        -- set buffer unique name as CopilotChatBuffer
        local bufname = "CopilotChatEdit ~" .. (buffer.uptoTwoParentPath or "")
        -- if buf name exists add index until no buffer with the same name

        local count = 0
        while vim.fn.bufexists(bufname) == 1 do
          count = count + 1
          bufname = "CopilotChatEdit ~" .. (buffer.uptoTwoParentPath or "") .. " " .. count
        end
        --
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
        vim.api.nvim_buf_set_name(bufnr, bufname)
        -- vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)

        local width = 0
        for _, line in ipairs(lines) do
          width = math.max(width, #line)
        end

        local height = math.min(vim.o.lines - 3, #lines)
        local winOpts = {
          title = bufname,
          relative = "editor",
          width = width,
          height = height,
          row = (vim.o.lines - height) / 2 - 1,
          col = (vim.o.columns - width) / 2,
          style = "minimal",
          border = "rounded",
          footer = table.concat({
            "Press <enter>/C-s to send to Copilot",
            "C-s CopilotChat - Save and send to chat",
            "C-x Close and send original content",
          }, " "),
        }

        local win = vim.api.nvim_open_win(bufnr, true, winOpts)
        local function send_content_and_close(use_original)
          print("send_content_and_close")
          local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local selection = { lines = use_original and table.concat(lines, "\n") or table.concat(content, "\n") }
          -- __AUTO_GENERATED_PRINT_VAR_START__
          print([==[function#function#send_content_and_close content:]==], vim.inspect(content)) -- __AUTO_GENERATED_PRINT_VAR_END__
          if win then
            vim.api.nvim_win_close(win, true)
            win = nil
          end
          if content then
            chat.ask(table.concat(content, "\n"), {
              selection = function(source)
                return selection
              end,
            })
          end
        end
        -- map c-s to use the edited content and send chat
        vim.keymap.set("n", "<C-s>", function()
          send_content_and_close(false)
        end, { noremap = true, silent = true, buffer = bufnr })
        vim.keymap.set("n", "<C-x>", function()
          send_content_and_close(true)
        end, { noremap = true, silent = true, buffer = bufnr })
        -- listen for save or close event (if close use original content , if save use the edited content)
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-s>", "<cmd>lua require('CopilotChat').ask(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), {selection = require('CopilotChat.select').buffer})<CR>", { noremap = true, silent = true })
      end, { nargs = "*", range = true })
      -- Restore CopilotChatBuffer
      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = "*", range = true })

      -- Custom buffer for CopilotChat
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true
        end,
      })
    end,
    keys = {
      -- Show prompts actions
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt({
            context = {
              "buffers",
            },
          })
        end,
        desc = "CopilotChat - Prompt actions",
      },
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        mode = "x",
        desc = "CopilotChat - Prompt actions",
      },
      -- Code related commands
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>at", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>ar", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>aR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
      { "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
      -- Chat with Copilot in visual mode
      {
        "<leader>av",
        ":CopilotChatVisual",
        mode = "x",
        desc = "CopilotChat - Open in vertical split",
      },
      {
        "<leader>ax",
        ":CopilotChatInline",
        mode = "x",
        desc = "CopilotChat - Inline chat",
      },
      -- Custom input for CopilotChat
      {
        "<leader>ai",
        function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "CopilotChat - Ask input",
      },
      -- Generate commit message based on the git diff
      {
        "<leader>am",
        "<cmd>CopilotChatCommit<cr>",
        desc = "CopilotChat - Generate commit message for all changes",
      },
      {
        "<leader>aq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, {
              selection = require("CopilotChat.select").buffer,
            })
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      -- Fix the issue with diagnostic
      { "<leader>af", "<cmd>CopilotChatFixError<cr>", desc = "CopilotChat - Fix Diagnostic" },
      -- Clear buffer and chat history
      { "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
      -- Toggle Copilot Chat Vsplit
      { "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
      -- Copilot Chat Models
      { "<leader>a?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
      -- Copilot Chat Agents
      { "<leader>aa", "<cmd>CopilotChatAgents<cr>", desc = "CopilotChat - Select Agents" },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>gm", group = "Copilot Chat" },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      file_types = { "markdown", "copilot-chat" },
    },
    ft = { "markdown", "copilot-chat" },
  },
}
