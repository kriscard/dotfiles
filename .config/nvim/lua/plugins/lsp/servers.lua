-- Per-server LSP config table.
--
-- Each entry is merged on top of nvim-lspconfig's lsp/<name>.lua defaults and the
-- '*' wildcard config (capabilities). Project-scoped servers use root_markers +
-- workspace_required = true so they don't start outside their target projects:
-- attaching biome in a Next.js repo that uses ESLint is just overhead.
--
-- root_markers can be a flat list (priority by index) or nested for equal priority:
--   { { "tsconfig.json", "jsconfig.json" }, "package.json" }
-- means "either of the first pair, else package.json".

local M = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Filetype groups (pull-out for clarity)
-- ─────────────────────────────────────────────────────────────────────────────

local JS_TS = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

-- ─────────────────────────────────────────────────────────────────────────────
-- Per-server specs
-- ─────────────────────────────────────────────────────────────────────────────

M.specs = {
	-- ── Lua ────────────────────────────────────────────────────────────────────
	lua_ls = {
		settings = {
			Lua = {
				completion = { callSnippet = "Replace" },
				runtime = { version = "LuaJIT" },
				diagnostics = {
					globals = { "vim", "Snacks", "require" },
					disable = { "missing-fields" },
				},
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	},

	-- ── TypeScript / JavaScript (vtsls) ────────────────────────────────────────
	vtsls = {
		filetypes = JS_TS,
		root_markers = { { "tsconfig.json", "jsconfig.json" }, "package.json" },
		settings = {
			complete_function_calls = true,
			vtsls = {
				enableMoveToFileCodeAction = true,
				autoUseWorkspaceTsdk = true,
				experimental = {
					maxInlayHintLength = 10,
					completion = {
						enableServerSideFuzzyMatch = false,
						entriesLimit = 100,
					},
				},
			},
			typescript = {
				tsserver = { maxTsServerMemory = 4096 },
				updateImportsOnFileMove = { enabled = "always" },
				disableAutomaticTypeAcquisition = true,
				suggest = {
					completeFunctionCalls = false,
					includeCompletionsForModuleExports = true,
					includeCompletionsForImportStatements = true,
				},
				inlayHints = {
					includeInlayEnumMemberValueHints = false,
					includeInlayFunctionLikeReturnTypeHints = false,
					includeInlayFunctionParameterTypeHints = false,
					includeInlayParameterNameHints = "none",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayPropertyDeclarationTypeHints = false,
					includeInlayVariableTypeHints = false,
					includeInlayVariableTypeHintsWhenTypeMatchesName = false,
				},
				preferences = {
					-- Prefer alias paths from tsconfig.paths over relative imports.
					-- Key is `importModuleSpecifier` per vtsls schema; the `*Preference`
					-- suffix variant is silently ignored.
					importModuleSpecifier = "non-relative",
					includePackageJsonAutoImports = "off",
					organizeImportsIgnoreCase = false,
					organizeImportsCollation = "ordinal",
					organizeImportsLocale = "en",
					organizeImportsNumericCollation = false,
					organizeImportsAccentCollation = false,
					organizeImportsCaseFirst = "lower",
				},
				watchOptions = {
					excludeDirectories = {
						"**/node_modules", "**/.git", "**/dist", "**/.next",
						"**/build", "**/coverage", "**/out", "**/.turbo", "**/.cache",
					},
					excludeFiles = {
						"**/.eslintrc.js", "**/webpack.config.js",
						"**/rollup.config.js", "**/vite.config.js",
					},
				},
			},
			javascript = {
				suggest = {
					completeFunctionCalls = false,
					includeCompletionsForModuleExports = true,
					includeCompletionsForImportStatements = true,
				},
				preferences = {
					importModuleSpecifier = "non-relative",
					includePackageJsonAutoImports = "off",
				},
			},
		},
	},

	-- ── ESLint ─ only attaches when project has eslint config ──────────────────
	eslint = {
		cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=4096" },
		root_markers = {
			".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.mjs",
			".eslintrc.json", ".eslintrc.yaml", ".eslintrc.yml",
			"eslint.config.js", "eslint.config.mjs", "eslint.config.cjs",
			"eslint.config.ts", "eslint.config.mts", "eslint.config.cts",
		},
		workspace_required = true,
		settings = {
			workingDirectories = { mode = "auto" },
			format = true,
		},
	},

	-- ── Biome ─ only attaches when project has biome config ────────────────────
	biome = {
		filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact", "css" },
		root_markers = { "biome.json", "biome.jsonc" },
		workspace_required = true,
	},

	-- ── Oxlint ─ Rust-based fast linter (~50× faster than ESLint) ─────────────
	-- Attaches in ANY JS/TS project (uses its built-in default rules when no
	-- .oxlintrc.json is present). Drop a config file at the project root if you
	-- want to override the defaults. Coexists with eslint — the two emit
	-- different `source` strings, so duplicate diagnostics are visible but not
	-- silent.
	oxlint = {
		filetypes = JS_TS,
		root_markers = {
			".oxlintrc.json", ".oxlintrc.json5", ".oxlintrc.yaml", ".oxlintrc.yml",
			"package.json", ".git",
		},
	},

	-- ── CSS ────────────────────────────────────────────────────────────────────
	cssls = {
		settings = { css = { lint = { unknownAtRules = "ignore" } } },
	},

	-- ── Tailwind ─ only attaches when tailwind.config.* exists ─────────────────
	tailwindcss = {
		filetypes = { "typescriptreact", "javascriptreact", "html", "svelte", "vue" },
		root_markers = {
			"tailwind.config.js", "tailwind.config.cjs",
			"tailwind.config.mjs", "tailwind.config.ts",
		},
		workspace_required = true,
	},

	-- ── UnoCSS ─ only attaches when uno.config.* / unocss.config.* exists ──────
	unocss = {
		filetypes = {
			"html", "javascriptreact", "rescript", "typescriptreact",
			"vue", "svelte", "astro", "css", "postcss", "sass", "scss", "stylus",
		},
		root_markers = {
			"uno.config.js", "uno.config.ts", "uno.config.mjs",
			"unocss.config.js", "unocss.config.ts", "unocss.config.mjs",
		},
		workspace_required = true,
	},

	-- ── Stylelint ─ only attaches when project has stylelint config ────────────
	stylelint_lsp = {
		filetypes = { "css", "scss", "sass", "less", "postcss" },
		root_markers = {
			".stylelintrc", ".stylelintrc.js", ".stylelintrc.cjs", ".stylelintrc.mjs",
			".stylelintrc.json", ".stylelintrc.yaml", ".stylelintrc.yml",
			"stylelint.config.js", "stylelint.config.cjs", "stylelint.config.mjs",
		},
		workspace_required = true,
		settings = { stylelintplus = { autoFixOnSave = true, autoFixOnFormat = true } },
	},

	-- ── Emmet ─ html/css only (JSX uses className, not class — emmet is noisy) ─
	emmet_ls = {
		filetypes = { "html", "css", "scss", "sass", "less" },
	},

	-- ── GraphQL ────────────────────────────────────────────────────────────────
	graphql = { filetypes = { "graphql" } },

	-- ── Grammar/spell (Rust, fast — replaces Java-based ltex) ─────────────────
	-- Harper parses with tree-sitter and only checks natural-language regions:
	-- prose in markdown/text/gitcommit, plus JSDoc /** */ blocks, // comments,
	-- and JSX text content in JS/TS files. Code identifiers are never touched.
	-- Custom dictionary at ~/.config/harper-ls/dictionary.txt.
	harper_ls = {
		filetypes = {
			"markdown", "text", "gitcommit", "git",
			"javascript", "javascriptreact", "typescript", "typescriptreact",
		},
		settings = {
			["harper-ls"] = {
				userDictPath = vim.fn.expand("~/.config/harper-ls/dictionary.txt"),
				linters = {
					SpellCheck = true,
					SpelledNumbers = false,
					AnA = true,
					SentenceCapitalization = true,
					UnclosedQuotes = true,
					WrongQuotes = false,
					LongSentences = false,
					RepeatedWords = true,
					Spaces = true,
					Matcher = true,
					CorrectNumberSuffix = true,
				},
			},
		},
	},

	-- ── MDX ────────────────────────────────────────────────────────────────────
	mdx_analyzer = {
		filetypes = { "mdx" },
		init_options = { typescript = { enabled = true } },
	},

	-- ── Project-scoped servers ─ workspace_required keeps them off in scratch ──
	prismals = { workspace_required = true },
	rust_analyzer = { workspace_required = true },
	sqlls = { workspace_required = true },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Mason install list (mason-lspconfig server names — underscores not hyphens)
-- ─────────────────────────────────────────────────────────────────────────────

M.install = {
	"lua_ls",
	"vtsls", "eslint", "biome", "oxlint",
	"cssls", "tailwindcss", "unocss", "stylelint_lsp", "emmet_ls",
	"html", "jsonls", "yamlls", "graphql",
	"marksman", "harper_ls", "mdx_analyzer",
	"bashls", "prismals", "sqlls", "rust_analyzer",
	"dockerls", "docker_compose_language_service",
}

-- Mason-tool-installer list (formatters/linters that are NOT LSP servers)
M.tools = { "stylua", "prettier", "prettierd" }

return M
