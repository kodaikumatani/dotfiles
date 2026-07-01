-- キーバインド
-- 既定のキーバインドは全て無効化し、ここで定義したものだけを有効にする。
local wezterm = require("wezterm")
local act = wezterm.action
local sessions = require("sessions")

local M = {}

function M.apply(config)
  config.disable_default_key_bindings = true

  config.keys = {
    -- ===== 基本 =====
    { key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
    { key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackOnly") },
    { key = "x", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
    { key = "n", mods = "CMD", action = act.SpawnWindow },
    { key = "q", mods = "CMD", action = act.QuitApplication },
    -- プロジェクトディレクトリを選んで workspace 化（作成/切替）
    { key = "p", mods = "CMD", action = wezterm.action_callback(sessions.select_dir) },
    -- 開いている workspace 一覧から切替
    { key = "s", mods = "CMD", action = wezterm.action_callback(sessions.switch_workspace) },
    -- workspace を kill
    { key = "s", mods = "CMD|SHIFT", action = wezterm.action_callback(sessions.kill_workspace) },
    -- フォントサイズ
    { key = "=", mods = "CMD", action = act.IncreaseFontSize },
    { key = "-", mods = "CMD", action = act.DecreaseFontSize },
    { key = "0", mods = "CMD", action = act.ResetFontSize },

    -- ===== ペイン分割（Cmd+D 右 / Cmd+Shift+D 下） =====
    { key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "\\", mods = "CMD", action = act.TogglePaneZoomState }, -- zoom トグル
    { key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) }, -- 閉じる

    -- ===== タブ（Cmd+T 新規 / Cmd+Shift+] 次 / Cmd+Shift+[ 前） =====
    { key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "]", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },
    { key = "[", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
  }

  -- ペイン移動 Ctrl+h/j/k/l（常に WezTerm のペイン移動）
  local directions = { h = "Left", j = "Down", k = "Up", l = "Right" }
  for key, dir in pairs(directions) do
    table.insert(config.keys, {
      key = key,
      mods = "CTRL",
      action = act.ActivatePaneDirection(dir),
    })
  end
end

return M
