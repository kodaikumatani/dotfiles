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

--- 足跡を出す対象のウィンドウ。現在のウィンドウ → 最後に覚えたウィンドウ →
--- このタブページのどれか、の順にファイルを映しているものを探す。
--- 覚えているウィンドウを毎回検証し直すのは、:help などが分割直後に一瞬だけ
--- 元のバッファを映し、その瞬間を記憶してしまうことがあるため
local function resolve_win()
  local cur = vim.api.nvim_get_current_win()
  local tab = vim.api.nvim_get_current_tabpage()
  -- last_file_win が nil なら長さ1の { cur } になり、list_extend は index 2 から
  -- 詰めるので穴は開かない。よって以下で w の nil を見る必要はない
  local wins = { cur, last_file_win }
  vim.list_extend(wins, vim.api.nvim_tabpage_list_wins(tab))
  for _, w in ipairs(wins) do
    -- 別タブページの窓に対して getjumplist() は空を返すので現在のタブに限る。
    -- last_file_win はタブを跨いで生き残るため、ここで弾く必要がある
    if
      vim.api.nvim_win_is_valid(w)
      and vim.api.nvim_win_get_tabpage(w) == tab
      and is_file(vim.api.nvim_win_get_buf(w))
    then
      last_file_win = w
      return w
    end
  end
  return cur
end

--- jumplist をファイル単位の足跡へ畳む
--- @return integer[] バッファ番号の並び
--- @return integer 現在地の位置（足跡が空なら意味を持たない）
--- @return integer 足跡の持ち主のウィンドウ
local function trail()
  local win = resolve_win()
  local list, curidx = unpack(vim.fn.getjumplist(win))

  local seq = vim.tbl_map(function(jump)
    return jump.bufnr
  end, list)
  -- 現在位置は curidx == #list のときリストに入っていないので末尾に足す
  local curpos = math.min(curidx + 1, #seq + 1)
  if curpos > #seq then
    seq[curpos] = vim.api.nvim_win_get_buf(win)
  end

  -- 同一ファイル内のジャンプは1つにまとめる（ファイル以外と消えたバッファは捨てる）
  local out, cur = {}, nil
  for i, bufnr in ipairs(seq) do
    if is_file(bufnr) then
      if out[#out] ~= bufnr then
        out[#out + 1] = bufnr
      end
      if i == curpos then
        cur = #out
      end
    end
  end

  -- cur が nil なのは現在地がファイル以外のとき（:terminal など）。
  -- 戻り先になる最後の足跡を現在地とみなす
  return out, cur or #out, win
end

--- 表示窓の左端を返す。窓の内側で動いている間は動かさず、端に達したときだけずらす
local function window_start(win, cur, total)
  local first = math.min(view_first[win] or 1, cur) -- 左端を越えた
  first = math.max(first, cur - WIDTH + 1) -- 右端を越えた

  -- 足跡が減った場合に窓が宙に浮かないよう詰める
  first = math.max(1, math.min(first, math.max(1, total - WIDTH + 1)))
  view_first[win] = first
  return first
end

function M.render()
  local items, cur, win = trail()
  if #items == 0 then
    return "%#TabLineFill#"
  end

  local first = window_start(win, cur, #items)
  local last = math.min(#items, first + WIDTH - 1)

  local parts = {}
  if first > 1 then
    parts[#parts + 1] = "%#TabLine# … "
  end
  for i = first, last do
    parts[#parts + 1] = i == cur and "%#TabLineSel#" or "%#TabLine#"
    parts[#parts + 1] = " " .. label(items[i]) .. " "
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
      -- clearjumps は現在のウィンドウにしか効かないので、-O/-o/-p で
      -- 開いた残りのウィンドウにも回る
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        vim.api.nvim_win_call(w, function()
          vim.cmd("clearjumps")
        end)
      end
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
