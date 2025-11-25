-- NOTE: https://cmp.saghen.dev/
return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "j-hui/fidget.nvim",
            {
                "saghen/blink.cmp",
                dependencies = "rafamadriz/friendly-snippets",
                version = "*",
            },
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
            {
                "seblj/roslyn.nvim",
                ft = "cs",
                -- opts = {}
            },
        },
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup('lsp-attach', {}),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    local builtin = require('telescope.builtin')

                    map('<leader>gd', builtin.lsp_definitions, '[G]oto [D]efinition')
                    map('<leader>gr', builtin.lsp_references, '[G]oto [R]eferences')
                    map('<leader>gi', builtin.lsp_implementations, '[G]oto [I]mplementation')
                    map('<leader>gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

                    -- Not sure about those:
                    -- map('<leader>D', builtin.lsp_type_definitions, 'Type [D]efinition')
                    -- map('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
                    -- map('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                    local client = vim.lsp.get_client_by_id(event.data.client_id)

                    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>ih', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, 'Toggle [I]nlay [H]ints')
                    end
                end
            })

            local blink = require("blink.cmp")
            local disable_cmp = vim.fn.has("wsl") == 1 or vim.fn.has("win32") == 1

            blink.setup({
                keymap = {
                    preset = "default",
                    ["<C-l>"] = { "select_and_accept" },
                    ["<C-h>"] = { 'show', 'show_documentation', 'hide_documentation' },
                    -- ["<C-space>"] = { "select_and_accept" },
                },
                appearance = {
                    use_nvim_cmp_as_default = true,
                    nerd_font_variant = "mono",
                },
                signature = {
                    enabled = true
                },
                cmdline = {
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    sources = function()
                        local type = vim.fn.getcmdtype()
                        local cmdline = vim.fn.getcmdline()
                        if type == '/' or type == '?' then return { 'buffer' } end
                        if type == ':' then
                            if disable_cmp and cmdline:match("^.-!") then
                                return {} -- Otherwise it will load forever (using WSL).
                            end
                            return { 'cmdline' }
                        end
                        return {}
                    end
                },
                completion = {
                    list = {
                        selection = { preselect = true, auto_insert = true } },
                    menu = {
                        max_height = 15,
                        border = 'single',
                        draw = {
                            columns = {
                                { "label",    "label_description", gap = 1 },
                                { "kind_icon" }
                            }
                        }
                    },
                },
            })

            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                blink.get_lsp_capabilities())

            require("mason").setup({
                registries = {
                    'github:mason-org/mason-registry',
                    'github:crashdummyy/mason-registry',
                },
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })

            require("mason-lspconfig").setup({
                automatic_installation = {},
                automatic_enable = true,
                ensure_installed = {
                    "lua_ls",
                    "bashls",
                    "dockerls",
                    "html",
                    "ts_ls",
                    "svelte",
                    "tailwindcss",
                    "basedpyright",
                    "ruff",
                    "clangd",
                },
                handlers = {
                    function(server_name) -- default handler (optional)
                        require("lspconfig")[server_name].setup {
                            capabilities = capabilities
                        }
                    end,
                }
            })

            -- Ensure roslyn is installed.
            local roslyn_lsp_installed = false
            for _, server in pairs(require "mason-registry".get_installed_package_names()) do
                if server == "roslyn" then
                    roslyn_lsp_installed = true
                    break
                end
            end

            if not roslyn_lsp_installed then
                vim.cmd("MasonInstall roslyn")
            end

            require("roslyn").setup({ filewatching = "roslyn" })
            require("fidget").setup({})
        end,
    }
}
