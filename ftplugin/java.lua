--[[
-- Defines path to debug and test jars used by nvim dap
-- @TODO@ add following command as keybinding to get detected version OR on startup :lua local c = vim.lsp.get_clients({ name = "jdtls", bufnr = 0 })[1]; print(vim.inspect(c.request_sync("workspace/executeCommand", { command = "java.project.getSettings", arguments = { vim.uri_from_bufnr(0), { "org.eclipse.jdt.ls.core.vm.location" } } }, 1000)))

--]]
vim.treesitter.start()

local mason_registry = require("mason-registry")
local bundles = {}
-- java-debug-adapter
local java_debug = mason_registry.get_package("java-debug-adapter")
local debug_path = java_debug:get_install_path()
vim.list_extend(
	bundles,
	vim.fn.glob(debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
)
-- java-test (vscode-java-test)
local java_test = mason_registry.get_package("java-test")
local test_path = java_test:get_install_path()
vim.list_extend(bundles, vim.fn.glob(test_path .. "/extension/server/*.jar", true, true))

local on_attach_remap = require("utils.lsp").on_attach_remap

-- Create cache and worskpace directory
-- Stores data (indexes etc) related to project in .../workspaces/<project base dir name>
vim.fn.mkdir(vim.fn.expand("~/.cache/nvim/jdtls/workspaces"), "p")
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.expand("~/.cache/nvim/jdtls/workspaces/") .. project_name

local config = {
	name = "jdtls",

	-- Command invoked by mason, use --jvm-arg to pass additional args to java (21) jdtls program
	cmd = {
		"jdtls",
		"-data",
		workspace_dir,
		"--jvm-arg=-Xmx8G", -- RAM allocated to jdtls
	},

	-- Markers to determine root of project
	root_dir = vim.fs.root(0, { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" }),

	-- Adds auto completion
	capabilities = require("cmp_nvim_lsp").default_capabilities(),

	on_attach = function(client, bufnr)
		on_attach_remap(client, bufnr)

		-- Register the java DAP adapter and discover main classes
		require("jdtls").setup_dap({ hotcodereplace = "auto", config_overrides = {} })
		require("jdtls.dap").setup_dap_main_class_configs()

		local opts = { buffer = true, silent = true }

		vim.keymap.set("n", "<C-o>", require("jdtls").organize_imports, opts) -- TODO add to: gopls, tsserver, pylsp
		vim.keymap.set("n", "crv", require("jdtls").extract_variable, opts) -- TODO: add to rust-analyzer, clangd, pylsp
		vim.keymap.set("v", "crv", function()
			require("jdtls").extract_variable({ visual = true })
		end, opts) -- TODO: add to rust-analyzer, clangd, pylsp
		vim.keymap.set("n", "crc", require("jdtls").extract_constant, opts) -- TODO: add to rust-analyzer, clangd
		vim.keymap.set("v", "crc", function()
			require("jdtls").extract_constant({ visual = true })
		end, opts) -- TODO: add to rust-analyzer, clangd
		vim.keymap.set("v", "crm", function()
			require("jdtls").extract_method({ visual = true })
		end, opts) -- TODO: add to rust-analyzer, clangd, pylsp

		-- nvim-dap (if using)
		vim.keymap.set("n", "<leader>dtc", require("jdtls").test_class, opts)
		vim.keymap.set("n", "<leader>dtm", require("jdtls").test_nearest_method, opts)

		-- Reload Maven/Gradle project config (e.g. after editing pom.xml dependency versions)
		vim.keymap.set("n", "<leader>ju", require("jdtls").update_project_config, opts)

		-- Print the JAR name the current buffer belongs to (or project name if a source file)
		vim.keymap.set("n", "<leader>pn", function()
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("^jdt://") then
				local decoded = bufname:gsub("%%5C", "/"):gsub("%%5c", "/")
				local jar = decoded:match("/([^/]+%.jar)")
				vim.notify(jar or "Could not parse JAR name from buffer URI", vim.log.levels.INFO)
			else
				vim.notify(vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), vim.log.levels.INFO)
			end
		end, { buffer = bufnr, silent = true, desc = "Show JAR or project name for current buffer" })
	end,

	-- Here you can configure eclipse.jdt.ls specific settings, see https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request for a list of options
	settings = {
		java = {
			format = {
				enabled = true,
				tabSize = 4,
				settings = {
					url = vim.fn.expand("~/.config/nvim/lint/java-formatter.xml"),
					profile = "WSGC Conventions",
				},
			},
			imports = { gradle = { enabled = true } },
			configuration = {
				-- Java runtime versions available - correct version used by debugger when running project and showing errors
				runtimes = {
					{
						name = "JavaSE-1.8",
						path = "/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home",
						default = true, -- Java version used by legacy projects
					},
					{
						name = "JavaSE-11",
						path = "/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home",
					},
					{
						name = "JavaSE-17",
						path = "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home",
					},
					{
						name = "JavaSE-26",
						path = "/opt/homebrew/Cellar/openjdk/26.0.1/libexec/openjdk.jdk/Contents/Home",
					},
				},
			},
		},
	},

	init_options = {
		-- Used to list jars (java-debug and vscode-java-test) that work with nvim plugins to communicate with jdtls
		bundles = bundles,
		jvm_args = {
			"-Djava.import.generatesMetadataFilesAtProjectRoot=false", -- Prevents .classpath and .project files in project root directory
		},
		codelens = {
			implementationsCodeLens = { enabled = true },
			referencesCodeLens = { enabled = true },
		},
	},
}
require("jdtls").start_or_attach(config)
