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
-- fuzzy=false（デフォルトモード）なので j/k で移動、/ でファジー検索、Enter で決定
function M.switch_workspace(win, pane)
  local choices = {}
  for _, name in ipairs(wezterm.mux.get_workspace_names()) do
    choices[#choices + 1] = { id = name, label = name }
  end
  win:perform_action(
    act.InputSelector({
      title = "Switch workspace (j/k, / to filter)",
      choices = choices,
      fuzzy = false,
      action = wezterm.action_callback(function(inner_win, inner_pane, id)
        if id then
          inner_win:perform_action(act.SwitchToWorkspace({ name = id }), inner_pane)
        end
      end),
    }),
    pane
  )
end

-- workspace を選んで kill する（その workspace の全ペインを閉じる）
-- 現在いる workspace は安全のため候補から除外
function M.kill_workspace(win, pane)
  local current = win:active_workspace()
  local choices = {}
  for _, name in ipairs(wezterm.mux.get_workspace_names()) do
    if name ~= current then
      choices[#choices + 1] = { id = name, label = name }
    end
  end
  if #choices == 0 then
    win:toast_notification("wezterm", "kill できる workspace がありません（現在の workspace は対象外）", nil, 4000)
    return
  end
  win:perform_action(
    act.InputSelector({
      title = "Kill workspace (j/k, / to filter)",
      choices = choices,
      fuzzy = false,
      action = wezterm.action_callback(function(_, _, id)
        if not id then
          return
        end
        -- 対象 workspace の全ペインを CLI で kill
        local shell = os.getenv("SHELL") or "/bin/zsh"
        local ok, stdout = wezterm.run_child_process({ shell, "-lc", "wezterm cli list --format json" })
        if not ok then
          return
        end
        for _, p in ipairs(wezterm.json_parse(stdout)) do
          if p.workspace == id then
            wezterm.run_child_process({ shell, "-lc", "wezterm cli kill-pane --pane-id " .. p.pane_id })
          end
        end
      end),
    }),
    pane
  )
end

return M
