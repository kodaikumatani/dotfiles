-- エントリポイント: 機能別モジュールを読み込んで config を組み立てる
local wezterm = require("wezterm")

-- 設定ディレクトリを require のパスに追加（モジュール解決を確実にする）
package.path = wezterm.config_dir .. "/?.lua;" .. package.path

local config = wezterm.config_builder()

require("appearance").apply(config)
require("keybinds").apply(config)

return config
