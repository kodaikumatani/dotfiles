-- Workspace（tmux のセッション相当）管理
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- プロジェクトディレクトリの探索ルート（ghq のレイアウト <root>/<host>/<owner>/<repo>）
local PROJECTS_ROOT = (os.getenv("HOME") or "") .. "/ghq"

-- ルート配下のリポジトリ（host/owner/repo = 深さ3）を列挙する
local function list_project_dirs()
  local shell = os.getenv("SHELL") or "/bin/zsh"
  local ok, stdout = wezterm.run_child_process({
    shell,
    "-lc",
    "find " .. PROJECTS_ROOT .. " -mindepth 3 -maxdepth 3 -type d",
  })
  if not ok then
    return {}
  end
  local dirs = {}
  for path in stdout:gmatch("[^\r\n]+") do
    dirs[#dirs + 1] = path
  end
  return dirs
end

-- ディレクトリを一覧から選び、そのディレクトリで workspace を作成・切替する
function M.select_dir(win, pane)
  local choices = {}
  for _, path in ipairs(list_project_dirs()) do
    local name = path:match("([^/]+/[^/]+)$") or path -- owner/repo を表示・名前に
    choices[#choices + 1] = { id = path, label = name }
  end
  win:perform_action(
    act.InputSelector({
      title = "Select project directory",
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(_, _, id, label)
        if id then
          win:perform_action(
            act.SwitchToWorkspace({ name = label, spawn = { cwd = id } }),
            pane
          )
        end
      end),
    }),
    pane
  )
end

return M
