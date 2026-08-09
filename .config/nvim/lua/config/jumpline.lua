-- タブページは使わないので、タブラインに jumplist の足跡をパンくずで出す。
--   main.go > hello.go > [world.go] > util.go
-- <C-o> で左へ、<C-i> で右へ。移動キーは Vim ネイティブのままで、表示だけ足す。
--
-- jumplist は「離れた位置」の列。現在位置は curidx == #list のときリストに入って
-- いないため、その場合だけ末尾に足して現在地とする。

local M = {}

local SEP = " > "
local WIDTH = 6 -- 同時に見せるファイル数

-- 表示窓の左端。ウィンドウ毎に jumplist が違うので窓もウィンドウ毎に覚える
local view_first = {}

-- 実ファイルのバッファだけを足跡に載せる。neo-tree / help / quickfix /
-- 端末などは buftype が付く（neo-tree は nofile）ので、これで弾ける
local function is_file(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.bo[bufnr].buftype == ""
    and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

local function label(bufnr)
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
end

-- 最後にファイルを表示していたウィンドウ。neo-tree や help にフォーカスが
-- 移っている間は、そちらの jumplist ではなくこのウィンドウの足跡を出す
local last_file_win = nil

--- jumplist をファイル単位の足跡へ畳む
--- @return { bufnr: integer, current: boolean }[], integer 足跡と、その持ち主のウィンドウ
--- 足跡を出す対象のウィンドウ。ファイル以外にフォーカスがあるときは
--- ファイルを映しているウィンドウへ回す
local function resolve_win()
  local cur = vim.api.nvim_get_current_win()
  if is_file(vim.api.nvim_win_get_buf(cur)) then
    last_file_win = cur
    return cur
  end

  -- 覚えているウィンドウは「今もファイルを映している」ときだけ使う。
  -- :help などは分割直後に一瞬だけ元のバッファを映すので、その瞬間に
  -- 記憶してしまうことがある
  if
    last_file_win
    and vim.api.nvim_win_is_valid(last_file_win)
    and is_file(vim.api.nvim_win_get_buf(last_file_win))
  then
    return last_file_win
  end

  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_file(vim.api.nvim_win_get_buf(w)) then
      last_file_win = w
      return w
    end
  end
  return cur
end

local function trail()
  local win = resolve_win()
  local winnr = vim.fn.win_id2win(win)
  local list, curidx = unpack(vim.fn.getjumplist(winnr))

  local seq = {}
  for _, jump in ipairs(list) do
    seq[#seq + 1] = { bufnr = jump.bufnr, current = false }
  end
  if curidx >= #list then
    seq[#seq + 1] = { bufnr = vim.api.nvim_win_get_buf(win), current = true }
  elseif seq[curidx + 1] then
    seq[curidx + 1].current = true
  end

  -- 同一ファイル内のジャンプは1つにまとめる（ファイル以外と消えたバッファは捨てる）
  local out = {}
  for _, entry in ipairs(seq) do
    if is_file(entry.bufnr) then
      local last = out[#out]
      if last and last.bufnr == entry.bufnr then
        last.current = last.current or entry.current
      else
        out[#out + 1] = { bufnr = entry.bufnr, current = entry.current }
      end
    end
  end

  -- 現在地がファイル以外だと印が付かないので（:terminal など）、
  -- 戻り先になる最後の足跡に付けておく
  if #out > 0 and not vim.iter(out):any(function(e)
    return e.current
  end) then
    out[#out].current = true
  end

  return out, win
end

--- 表示窓の左端を返す。窓の内側で動いている間は動かさず、端に達したときだけずらす
local function window_start(win, cur, total)
  local first = view_first[win] or 1

  if total <= WIDTH then
    first = 1
  elseif cur < first then
    first = cur -- 左端を越えた
  elseif cur > first + WIDTH - 1 then
    first = cur - WIDTH + 1 -- 右端を越えた
  end

  -- 足跡が減った場合に窓が宙に浮かないよう詰める
  first = math.max(1, math.min(first, math.max(1, total - WIDTH + 1)))
  view_first[win] = first
  return first
end

function M.render()
  local items, win = trail()
  if #items == 0 then
    return "%#TabLineFill#"
  end

  local cur = #items
  for i, entry in ipairs(items) do
    if entry.current then
      cur = i
    end
  end

  local first = window_start(win, cur, #items)
  local last = math.min(#items, first + WIDTH - 1)

  local parts = {}
  if first > 1 then
    parts[#parts + 1] = "%#TabLine# … "
  end
  for i = first, last do
    parts[#parts + 1] = items[i].current and "%#TabLineSel#" or "%#TabLine#"
    parts[#parts + 1] = " " .. label(items[i].bufnr) .. " "
    if i < last then
      parts[#parts + 1] = "%#TabLine#" .. SEP
    end
  end
  if last < #items then
    parts[#parts + 1] = "%#TabLine# … "
  end

  return table.concat(parts) .. "%#TabLineFill#"
end

--- ファイルが変わるまで jumplist を dir 方向へ辿る。
--- <C-o>/<C-i> は足跡の中を動くだけなので、<C-^> と違って並びを組み替えない。
--- @param dir integer -1 で戻る、1 で進む
--- @return boolean 動けたか（端に着いていたら false）
local function step_file(dir)
  local key = vim.api.nvim_replace_termcodes(dir < 0 and "<C-o>" or "<C-i>", true, false, true)
  local from = vim.api.nvim_get_current_buf()
  -- 同一ファイル内の位置は畳んで見せているので、ファイルが変わるまで進める
  for _ = 1, 100 do
    local before = vim.fn.getjumplist()[2]
    -- <C-i> は実体が Tab なので :normal だと引数として受け取れない（E471）
    vim.api.nvim_feedkeys(key, "nx", false)
    if vim.fn.getjumplist()[2] == before then
      return false
    end
    if vim.api.nvim_get_current_buf() ~= from then
      return true
    end
  end
  return false
end

-- <C-^> は押すたびに向きが反転する（戻る → 進む → 戻る …）
local last_dir = 1

--- 足跡を1ファイル分だけ戻る/進む。Vim 既定の <C-^> と違い jumplist を汚さない
function M.toggle()
  last_dir = -last_dir
  if not step_file(last_dir) then
    last_dir = -last_dir -- 端に着いていたら切り返す
    step_file(last_dir)
  end
end

function M.setup()
  vim.o.showtabline = 2
  vim.o.tabline = "%!v:lua.require'config.jumpline'.render()"

  -- 既定の <C-^> は「新しいジャンプ」なので足跡の並びを組み替えてしまう。
  -- 足跡の中を1ファイル分だけ移動する動きに置き換える
  vim.keymap.set("n", "<C-^>", M.toggle, { desc = "足跡を1つ戻る/進む" })

  local group = vim.api.nvim_create_augroup("Jumpline", { clear = true })

  -- 足跡はセッション内だけのものにする。shada は ' を必ず含む必要があり
  -- （含めると jumplist と changelist が保存される）オプションでは切れないので、
  -- 復元された直後の起動時に捨てる。file mark と changelist はそのまま残る
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      vim.cmd("clearjumps")
    end,
  })

  -- jumplist の変化はタブラインの自動再描画の契機にならないので明示的に促す
  vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "WinEnter" }, {
    group = group,
    callback = function()
      vim.cmd("redrawtabline")
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      view_first[tonumber(args.match)] = nil
    end,
  })
end

return M
