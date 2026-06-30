-- 外観: フォント・配色（kanagawa で nvim と統一）
local wezterm = require("wezterm")

local M = {}

function M.apply(config)
  config.color_scheme = "Kanagawa (Gogh)"
  config.font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font",
    "Noto Sans JP",
  })
  config.font_size = 14
end

return M
