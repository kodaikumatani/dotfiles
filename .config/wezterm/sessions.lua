-- 現在のペインの作業ディレクトリを workspace にして切り替える（無ければ作成）
local wezterm = require("wezterm")

local M = {}

function M.create_or_switch(win, pane)
  local cwd = pane:get_current_working_dir()
  if not cwd then
    return
  end
  local path = cwd.file_path

  win:perform_action(
    wezterm.action.SwitchToWorkspace({
      name = path,
      spawn = { cwd = path },
    }),
    pane
  )
end

return M
