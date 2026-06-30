-- 外観: フォント・配色・タブバー（tokyonight）
local wezterm = require("wezterm")

local M = {}

function M.apply(config)
  config.color_scheme = "Tokyo Night"
  config.font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font",
    "Noto Sans JP",
  })
  config.font_size = 14
end

return M
