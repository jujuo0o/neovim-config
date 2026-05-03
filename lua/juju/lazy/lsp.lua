return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Mason: installs LSP servers, formatters, linters, DAP adapters
            { "mason-org/mason.nvim", config = true },
            "mason-org/mason-lspconfig.nvim",

            -- Autocompletion (modern, fast)
            {
                "saghen/blink.cmp",
                version = "*", -- use latest release; required for prebuilt binaries
                opts = {
                    keymap = { preset = "super-tab" },
                    appearance = { nerd_font_variant = "mono" },
                    completion = {
                        list = { selection = { preselect=true, autoselect=false }},
                        documentation = { auto_show = true, auto_show_delay_ms = 200 },
                    },
                    sources = {
                        default = { "lsp", "path", "snippets", "buffer" },
                    },
                },
            },

            -- Useful status updates for LSP
            { "j-hui/fidget.nvim", opts = {} },
        },
        config = function()
            -- Configure mason-lspconfig: which servers to auto-install
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",       -- Lua
                    "ts_ls",        -- TypeScript / JavaScript
                    "rust_analyzer",-- Rust
                    "gopls",        -- Go
                    "pyright",      -- Python
                    "bashls",       -- Bash
                    "clangd",       -- C / C++


                    "powershell_es",   -- PowerShell
                    "roslyn_ls",       -- C# / .NET (or "omnisharp" if roslyn gives trouble)
                    "volar",           -- Vue 3 SFCs
                    "vtsls",           -- TypeScript (Vue-aware when paired with volar)
                    "jdtls",           -- Java

                },
                automatic_installation = true,
            })

            -- Tell each server about blink.cmp's capabilities
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- On Nvim 0.11+, vim.lsp.config and vim.lsp.enable handle setup.
            -- mason-lspconfig v2 hooks into this automatically; we just add capabilities.
            vim.lsp.config("*", { capabilities = capabilities })

            -- Per-server overrides (optional)
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } }, -- stop "undefined global 'vim'" warnings
                    },
                },
            })

            -- Keymaps that fire when an LSP attaches to a buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local opts = { buffer = event.buf, silent = true }
                    local map = function(keys, fn, desc)
                        vim.keymap.set("n", keys, fn, vim.tbl_extend("force", opts, { desc = desc }))
                    end

                    map("gd", vim.lsp.buf.definition,      "Go to definition")
                    map("gD", vim.lsp.buf.declaration,     "Go to declaration")
                    map("gr", vim.lsp.buf.references,      "Find references")
                    map("gi", vim.lsp.buf.implementation,  "Go to implementation")
                    map("K",  vim.lsp.buf.hover,           "Hover docs")
                    map("<leader>rn", vim.lsp.buf.rename,  "Rename symbol")
                    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
                    map("[d", vim.diagnostic.goto_prev,    "Prev diagnostic")
                    map("]d", vim.diagnostic.goto_next,    "Next diagnostic")
                    map("<leader>e", vim.diagnostic.open_float, "Show diagnostic")
                end,
            })

            -- Diagnostic display tweaks
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })
        end,
    },
}
