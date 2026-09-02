vim.g.mapleader = " "

-- Go to directory
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Split screen
vim.keymap.set("n", "<leader>s", vim.cmd.vsp)

-- Move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Yank to clipboard
vim.keymap.set("v", "<leader>y", '"+y')

-- Open undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Open fugitive (Git wrapper)
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- Tabs at 4 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Show special characters (tabs, newlines etc)
vim.opt.list = true

-- Line and absolute line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Give undo tree long access logs
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Only show search on single line
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

-- Keeps top/bottom of term 8 characters away
vim.opt.scrolloff = 8

-- Faster updates (aka error messages etc..)
vim.opt.updatetime = 50

-- Opens messages (error/info/warn) in scrollable copyable buffer
vim.keymap.set("n", "<leader>m", function()
	local messages = vim.fn.execute("messages")
	local lines = vim.split(messages, "\n")
	-- take last 40
	local start = math.max(1, #lines - 39)
	lines = vim.list_slice(lines, start, #lines)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = math.floor(vim.o.columns * 0.8)
	local height = 40
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	})

	vim.keymap.set("n", "q", "<cmd>bd!<cr>", { buffer = buf, silent = true })
end, { desc = "Open last 40 messages in floating window" })

local function retab()
	local view = vim.fn.winsaveview()
	vim.cmd("retab! 4")
	vim.fn.winrestview(view)
end

vim.keymap.set("n", "<leader>rt", retab, { desc = "Retab: convert tabs to spaces" })

vim.keymap.set("n", "<leader>pwd", function()
	local cwd = vim.fn.getcwd()
	vim.fn.setreg("+", cwd)
	vim.notify("Copied: " .. cwd)
end, { desc = "Copy cwd to clipboard" })
