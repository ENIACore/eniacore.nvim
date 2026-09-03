--[[
-- Automatically ensures formatters are installed and enabled
--]]
local registry = require("utils.registry")
local formatters = {
	"prettierd", -- ts, js, html, css, scss, json, jsonc, markdown, yaml, graphql
	"ruff", -- python (linter and formatter, contains both ruff_format and ruff_organize_imports)
	"goimports", -- golang
	"gofumpt", -- golang
	"stylua", -- lua
	"shfmt", -- sh, bash
	"google-java-format",
	"clang-format", -- c, cpp
	"sql-formatter", -- sql
	"xmlformatter", -- xml
}
registry:install_pkg_list(formatters)

local conform = require("conform")

conform.setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		python = { "ruff_format", "ruff_organize_imports" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		vue = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		lua = { "stylua" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		markdown = { "prettier" },
		yaml = { "prettier" },
		graphql = { "prettier" },
		java = {},
		c = { "clang-format" },
		cpp = { "clang-format" },
		xml = { "xmlformatter" },
	},
})

vim.g.autoformat = true

vim.api.nvim_create_user_command("ToggleAutoformat", function()
	vim.g.autoformat = not vim.g.autoformat
	require("conform").setup({
		format_on_save = vim.g.autoformat and { timeout_ms = 500, lsp_fallback = true } or nil,
	})
	vim.notify("Autoformat " .. (vim.g.autoformat and "enabled" or "disabled"))
end, {})
