return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		sections = {
			lualine_x = {
				{
					function()
						return vim.g.autoformat and "[Autofmt]" or "[Autofmt: off]"
					end,
				},
				"encoding",
				"fileformat",
				"filetype",
			},
		},
	},
}
