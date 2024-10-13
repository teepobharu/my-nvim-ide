local M = {}

function M.git_main_branch()
  local git_dir = vim.fn.system("git rev-parse --git-dir 2> /dev/null")
  if vim.v.shell_error ~= 0 then
    return nil
  end

  local refs = {
    "refs/heads/main",
    "refs/heads/trunk",
    "refs/heads/mainline",
    "refs/heads/default",
    "refs/heads/master",
    "refs/remotes/origin/main",
    "refs/remotes/origin/trunk",
    "refs/remotes/origin/mainline",
    "refs/remotes/origin/default",
    "refs/remotes/origin/master",
    "refs/remotes/upstream/main",
    "refs/remotes/upstream/trunk",
    "refs/remotes/upstream/mainline",
    "refs/remotes/upstream/default",
    "refs/remotes/upstream/master",
  }

  for _, ref in ipairs(refs) do
    local show_ref = vim.fn.system("git show-ref -q --verify " .. ref)
    if vim.v.shell_error == 0 then
      return ref:gsub("^refs/%w+/", "")
    end
  end

  return "master"
end

function M.get_remote_path(upstream)
  if not upstream or upstream == "" then
    upstream = "origin"
  end
  local remote_url = vim.fn.system("git config --get remote." .. upstream .. ".url"):gsub("\n", "")
  if remote_url == "" then
    remote_url = vim.fn.system("git remote -v | awk '{print $2}' | head -n1"):gsub("\n", "")
  end
  -- Remove the protocol part (git@ or https://) and remove the first : after the protocol
  local path = remote_url:gsub("^git@", ""):gsub("^https?://", "")
  -- remove the first colon only
  path = path:gsub(":", "/", 1)
  -- Remove the .git suffix
  path = path:gsub("%.git$", "")
  return path
end

return M
