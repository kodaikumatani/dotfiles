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

-- ペインの現在ディレクトリ（絶対パス）を取得する
local function pane_cwd(pane)
  local uri = pane:get_current_working_dir()
  if uri == nil then
    return nil
  end
  if type(uri) == "userdata" then
    return uri.file_path
  end
  -- 文字列形式 file://host/path のフォールバック
  return (uri:gsub("^file://[^/]*", ""))
end

-- 与えられたパスが PROJECTS_ROOT 配下なら、プロジェクトルート
-- （host/owner/repo = 深さ3）を返す。そうでなければ nil。
local function project_root(cwd)
  local prefix = PROJECTS_ROOT .. "/"
  if cwd:sub(1, #prefix) ~= prefix then
    return nil
  end
  local parts = {}
  for p in cwd:sub(#prefix + 1):gmatch("[^/]+") do
    parts[#parts + 1] = p
    if #parts == 3 then
      break
    end
  end
  if #parts < 3 then
    return nil
  end
  return prefix .. table.concat(parts, "/")
end

-- 新規タブを開く。現在ペインが ghq プロジェクト配下なら
-- そのプロジェクトルートで、そうでなければ現在ディレクトリで開く。
function M.spawn_tab(win, pane)
  local cwd = pane_cwd(pane)
  local root = cwd and project_root(cwd)
  if root then
    win:perform_action(act.SpawnCommandInNewTab({ cwd = root }), pane)
  else
    win:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
  end
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

return M
