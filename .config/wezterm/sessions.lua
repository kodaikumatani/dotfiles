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

-- プロジェクトディレクトリを一覧から選び、そのディレクトリで workspace を作成・切替する
function M.select_dir(win, pane)
  local choices = {}
  for _, path in ipairs(list_project_dirs()) do
    local name = path:match("([^/]+/[^/]+)$") or path -- owner/repo を表示・名前に
    choices[#choices + 1] = { id = path, label = name }
  end
  win:perform_action(
    act.InputSelector({
      title = "Open project",
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(inner_win, inner_pane, id, label)
        if id then
          inner_win:perform_action(
            act.SwitchToWorkspace({ name = label, spawn = { cwd = id } }),
            inner_pane
          )
        end
      end),
    }),
    pane
  )
end

-- 開いている workspace の一覧から選んで切り替える
function M.switch_workspace(win, pane)
  local choices = {}
  for i, name in ipairs(wezterm.mux.get_workspace_names()) do
    choices[#choices + 1] = { id = name, label = string.format("%d. %s", i, name) }
  end
  win:perform_action(
    act.InputSelector({
      title = "Switch workspace",
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(inner_win, inner_pane, id)
        if id then
          inner_win:perform_action(act.SwitchToWorkspace({ name = id }), inner_pane)
        end
      end),
    }),
    pane
  )
end

return M
