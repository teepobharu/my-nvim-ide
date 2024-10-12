local M = {}

--- Check if current directory is a git repo
---@return boolean
function M.is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

--- Get root directory of git project
---@return string|nil
function M.get_git_root()
  return vim.fn.systemlist("git rev-parse --show-toplevel")[1]
end

function M.get_git_root_dotgit()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end

--- Get root directory of git project or fallback to current directory
---@return string|nil
function M.get_root_directory()
  if M.is_git_repo() then
    return M.get_git_root()
  end

  return vim.fn.getcwd()
end

function M.get_pythonpath()
  local root_dir = M.get_root_directory()
  local pyrightconfig = root_dir .. "/pyrightconfig.json"

  if vim.fn.filereadable(pyrightconfig) == 1 then
    local config_content = vim.fn.readfile(pyrightconfig)
    local config = vim.fn.json_decode(table.concat(config_content, "\n"))

    if config == nil then
      vim.notify("pyrightconfig exists but not able to read", vim.log.levels.WARN)
    else
      local venvPath = config.venvPath
      if venvPath == nil or vim.fn.empty(venvPath) == 1 then
        vim.notify("pyrightconfig exists but venvPath not found", vim.log.levels.ERROR)
      else
        local pythonExeDir = "/bin/python"
        local isVenvAbsPath = string.sub(venvPath, 1, 1) == "/"

        if isVenvAbsPath then
          -- print([==[M.get_pythonpath#if#if#if#if isVenvAbsPath:]==], vim.inspect(isVenvAbsPath)) -- __AUTO_GENERATED_PRINT_VAR_END__
          -- print([==[M.get_pythonpath#if#if#if#if venvPath .. pythonExeDir):]==], vim.inspect(venvPath .. pythonExeDir))
          -- print(
          --   [==[M.get_pythonpath#if#if#if#if#if vim.fn.filereadable(venvPath .. pythonExeDir):]==],
          vim.inspect(vim.fn.filereadable(venvPath .. pythonExeDir))
          if vim.fn.filereadable(venvPath .. pythonExeDir) == 1 then
            -- __AUTO_GENERATED_PRINT_VAR_START__
            vim.notify("Using absolute path from pyrightconfig.json: " .. venvPath, vim.log.levels.INFO)
            return venvPath .. pythonExeDir
          end
        else
          -- Check if venvPath is relative to root_dir
          venvPath = string.gsub(venvPath, root_dir, "")
          if string.sub(venvPath, 1, 1) == "/" then
            venvPath = string.sub(venvPath, 2)
          end
          if string.sub(venvPath, -1) == "/" then
            venvPath = string.sub(venvPath, 1, -2)
          end
          local python_path = root_dir .. "/" .. venvPath .. pythonExeDir
          vim.notify("Using pythonpath from pyright: " .. python_path, vim.log.levels.INFO)
          if vim.fn.filereadable(python_path) == 1 then
            return python_path
          end
        end
      end
    end
  end

  -- Fallback to pipenv --py
  local python_path = vim.fn.systemlist("pipenv --py")[1]
  if vim.v.shell_error == 0 then
    vim.notify("get_pythonpath python_path (pipenv --py): " .. vim.inspect(python_path), vim.log.levels.INFO)
    return python_path
  else
    -- Fallback to default python executable
    local python = vim.fn.exepath("python")
    vim.notify("get_pythonpath using default python exe: " .. python, vim.log.levels.INFO)
    return python
  end
end

--- FROM QUICK-CODE-RUNNER :  Get global file path by type : https://github.com/jellydn/quick-code-runner.nvim/blob/main/lua/quick-code-runner/init.lua#L4
--- Get global file path by type
---@param ext string
---@return string
function M.get_global_file_by_type(ext)
  local state_path = vim.fn.stdpath("state")
  local path = state_path .. "/code-runner"

  -- Create code-runner folder if it does not exist
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path)
  end

  return string.format("%s/code-pad.%s", path, ext)
end

return M
