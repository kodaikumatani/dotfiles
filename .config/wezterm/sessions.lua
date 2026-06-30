-- ghq + workspace によるプロジェクト切り替え（tmux sessionizer 相当）
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- ghq list からプロジェクトを選び、そのプロジェクト名の workspace へ切り替える。
-- workspace が無ければ、そのリポジトリのディレクトリで新規作成する。
function M.switch_project()
  return wezterm.action_callback(function(window, pane)
    -- GUI 起動だと PATH に brew が無いことがあるのでログインシェル経由で実行
    local shell = os.getenv("SHELL") or "/bin/zsh"
    local ok, stdout, stderr = wezterm.run_child_process({ shell, "-lc", "ghq list -p" })
    if not ok then
      window:toast_notification("wezterm", "ghq list failed: " .. (stderr or ""), nil, 4000)
      return
    end

    local choices = {}
    for path in stdout:gmatch("[^\r\n]+") do
      local name = path:match("([^/]+)$") or path -- 末尾＝リポジトリ名を workspace 名に
      table.insert(choices, { id = path, label = name })
    end

    window:perform_action(
      act.InputSelector({
        title = "ghq projects",
        choices = choices,
        fuzzy = true,
        action = wezterm.action_callback(function(win, p, id, label)
          if not id then
            return -- キャンセル
          end
          win:perform_action(
            act.SwitchToWorkspace({
              name = label,
              spawn = { cwd = id },
            }),
            p
          )
        end),
      }),
      pane
    )
  end)
end

return M
