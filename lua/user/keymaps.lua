vim.keymap.set({ "n", "v", "x", "o" }, "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

local keymap = vim.keymap.set
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
keymap("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Find Files" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit terminal mode" })
keymap("n", "gl", vim.diagnostic.open_float, { noremap = true, silent = true })
keymap("n", ".", ".", { noremap = true })
keymap({ "n", "v", "o", "i" }, "<F1>", "<Nop>", { noremap = true, silent = true, desc = "Unbind F1" })
keymap("n", "U", "<C-r>", { noremap = true, silent = true, desc = "Redo" })
keymap({ "n", "v", "o" }, "<Up>",  'k', { noremap = true, silent = true, desc = 'Up' })
keymap({ "n", "v", "o" }, "<Down>", 'j', { noremap = true, silent = true, desc = 'Down' })
keymap({ "n", "v", "o" }, "<Left>",  'h', { noremap = true, silent = true, desc = 'Left' })
keymap({ "n", "v", "o" }, "<Right>", 'l', { noremap = true, silent = true, desc = 'Right' })
keymap({ "n", "v", "o" }, "<C-j>", "5j", { noremap = true, silent = true, desc = "Move 5 lines down" })
keymap({ "n", "v", "o" }, "<C-k>", "5k", { noremap = true, silent = true, desc = "Move 5 lines up" })
keymap({ "n", "v", "o" }, "<C-h>", "^",  { noremap = true, silent = true, desc = "Jump to first non-blank" })
keymap({ "n", "v", "o" }, "<C-l>", "$",  { noremap = true, silent = true, desc = "Jump to end of line" })
keymap({ "n", "v", "o" }, "§", "^", { noremap = true, silent  = true, desc    = "Jump to first non-blank (alias for ^)"})
keymap({ "n" }, "<leader>w", ":w<CR>", { noremap = true })
keymap({ "n" }, "<leader>q", ":qa!<CR>", { noremap = true })

keymap("n", "<leader><F5>", function()
	vim.cmd("update")
	local term_chan
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
			term_chan = vim.api.nvim_buf_get_var(buf, "terminal_job_id")
			break
		end
	end
	if not term_chan then
		vim.notify("No terminal window found!", vim.log.levels.WARN)
		return
	end
	local fname = vim.fn.expand("%:p")
	vim.api.nvim_chan_send(term_chan, "python " .. fname .. "\r\n")
end, {
	desc = "Run current Python file in persistent terminal (clearing any existing input)",
	silent = true,
})



keymap("n", "<F5>", function()
  vim.cmd("update")

  local term_chan, term_win
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
      term_chan = vim.api.nvim_buf_get_var(buf, "terminal_job_id")
      term_win  = win
      break
    end
  end

  if not term_chan then
    return vim.notify("No terminal window found!", vim.log.levels.WARN)
  end

  local fname = vim.fn.expand("%:p")
  vim.api.nvim_chan_send(term_chan, "python " .. fname .. "\r\n")

  vim.api.nvim_set_current_win(term_win)
  vim.cmd("startinsert")
end, {
  desc   = "Run current Python file in persistent term and enter insert mode",
  silent = true,
})



local function ToggleSplit()
  local tree_was_open = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf  = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_option(buf, "filetype") == "NvimTree" then
      tree_was_open = true
      vim.cmd("NvimTreeClose")
      break
    end
  end                                                                                                                                              

  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local cfg = vim.api.nvim_win_get_config(w)
    if cfg.relative == "" then
      local buf  = vim.api.nvim_win_get_buf(w)
      local bt   = vim.api.nvim_buf_get_option(buf, "buftype")
      if bt == "" or bt == "terminal" then
        table.insert(wins, w)
      end
    end
  end
  if #wins ~= 2 then
    vim.notify("Need exactly two edit/terminal windows to toggle",
               vim.log.levels.WARN)
    if tree_was_open then vim.cmd("NvimTreeOpen") end
    return
  end

  local row1, col1 = unpack(vim.api.nvim_win_get_position(wins[1]))
  local row2, col2 = unpack(vim.api.nvim_win_get_position(wins[2]))
  local side_by_side = (row1 == row2)

  vim.api.nvim_set_current_win(wins[2])
  if side_by_side then
    vim.cmd("wincmd J")
  else
    vim.cmd("wincmd L")
  end

  if tree_was_open then vim.cmd("NvimTreeOpen") end
end

vim.keymap.set("n", "<leader>s", function()
  ToggleSplit()
  vim.cmd("wincmd =")
end, {
  silent = true,
  desc = "Toggle split orientation and equalize window sizes",
})

vim.keymap.set("n", "m", "<C-w>", { noremap = true, silent = true, desc = "Override 'm' to act like Ctrl-w" })


local function toggle_source_header()
  if vim.lsp.buf and vim.lsp.buf.switch_source_header then
    local ok, switched = pcall(vim.lsp.buf.switch_source_header, 0)
    if ok and switched then return end
  end

  local cur   = vim.api.nvim_buf_get_name(0)
  if cur == "" then return end

  cur        = cur:gsub("\\", "/")
  local cwd  = vim.fn.getcwd():gsub("\\", "/")

  local stem = vim.fn.fnamemodify(cur, ":t:r")
  local ext  = vim.fn.fnamemodify(cur, ":e"):lower()

  local src_exts = { c=true, cc=true, cpp=true, cxx=true }
  local hdr_exts = { h=true, hh=true, hpp=true, hxx=true }

  local targets = {}
  if src_exts[ext] then
    targets = { "h", "hh", "hpp", "hxx" }
  elseif hdr_exts[ext] then
    targets = { "c", "cc", "cpp", "cxx" }
  else
    return
  end

  local matches = {}
  for _, e in ipairs(targets) do
    local pat = cwd .. "/**/" .. stem .. "." .. e
    for _, f in ipairs(vim.fn.glob(pat, true, true)) do
      f = f:gsub("\\", "/")
      if f ~= cur then table.insert(matches, f) end
    end
  end
  if #matches == 0 then
    vim.notify("No matching source/header for “" .. stem .. "”",
               vim.log.levels.INFO)
    return
  end

  local function split(path)
    local t = {}
    for seg in path:gsub("^" .. cwd .. "/", ""):gmatch("[^/]+") do
      table.insert(t, seg)
    end
    return t
  end

  local cur_segs = split(cur)

  local function score(path)
    local segs = split(path)
    local common = 0
    for i = 1, math.min(#segs, #cur_segs) do
      if segs[i] == cur_segs[i] then
        common = common + 1
      else
        break
      end
    end
    return common * 1000 - #segs
  end

  table.sort(matches, function(a, b) return score(a) > score(b) end)

  if #matches == 1 or score(matches[1]) > score(matches[2] or "") then
    vim.cmd("edit " .. vim.fn.fnameescape(matches[1]))
  else
    require("telescope.builtin").find_files({
      prompt_title = "Select source/header for “" .. stem .. "”",
      default_text = stem,
      cwd          = cwd,
      search_dirs  = { cwd },
    })
  end
end

keymap("n", "<leader>h", toggle_source_header,{ desc = "Toggle between C/C++ source and header" })




-- unbind the default 's' in normal mode
vim.keymap.set("n", "s", "<Nop>", { silent = true, desc = "Unbind default 's'" })

-- helper: focus the tree, move N nodes, open via API
local function tree_move_and_open(direction)
  -- only require the API when you actually invoke the mapping
  local api = require("nvim-tree.api")

  -- get the count (default to 1)
  local cnt = vim.v.count
  if cnt == 0 then cnt = 1 end

  -- open & focus the tree window
  api.tree.open()
  vim.cmd("NvimTreeFocus")

  -- move the cursor N lines up/down
  local move_cmd = tostring(cnt) .. (direction == "up" and "k" or "j")
  vim.cmd("silent! normal! " .. move_cmd)

  -- grab the node under the cursor, then open it
  local node = api.tree.get_node_under_cursor()
  api.node.open.edit(node)
end

-- map s<Up> and s<Down> in normal mode
vim.keymap.set("n", "s<Up>", function() tree_move_and_open("up") end,
  { silent = true, desc = "NvimTree: move up N entries and open" })
vim.keymap.set("n", "s<Down>", function() tree_move_and_open("down") end,
  { silent = true, desc = "NvimTree: move down N entries and open" })

