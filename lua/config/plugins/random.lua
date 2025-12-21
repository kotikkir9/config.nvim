return {
    {
        "numToStr/Comment.nvim",
        opts = {}
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- signs = false
        }
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            local hooks = require "ibl.hooks"

            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                -- vim.api.nvim_set_hl(0, "IblIndent", { fg = "#E06C75" })
                vim.api.nvim_set_hl(0, "IblScope", { fg = "#e5c07b" })
            end)

            require("ibl").setup {
                debounce = 100,
                indent = {
                    char = "│"
                },
                whitespace = {
                    remove_blankline_trail = false,
                },
                scope = {
                    enabled = true,
                    show_start = false,
                    show_end = false,
                },
            }
        end
    },
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        config = function()
            vim.o.foldcolumn = '0'
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            local ufo = require("ufo")

            vim.keymap.set('n', 'zR', ufo.openAllFolds)
            vim.keymap.set('n', 'zM', ufo.closeAllFolds)
            vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
            vim.keymap.set('n', 'zm', ufo.closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
            vim.keymap.set('n', 'K', function()
                if not ufo.peekFoldedLinesUnderCursor() then
                    vim.lsp.buf.hover()
                end
            end)

            ufo.setup({
                provider_selector = function(_, _, _)
                    return { 'treesitter', 'indent' }
                end
            })
        end
    },
    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                python = { "mypy" },
            }

            vim.api.nvim_create_user_command("Lint", function()
                require("lint").try_lint()
            end, {})

            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function() require("lint").try_lint() end,
            })
        end
    },
    {
        "rmagatti/auto-session",
        lazy = false,
        keys = {
            -- Will use Telescope if installed or a vim.ui.select picker otherwise
            { "<leader>ss", "<cmd>SessionSearch<CR>",         desc = "Session search" },
            { "<leader>sw", "<cmd>SessionSave<CR>",           desc = "Save session" },
            { "<leader>sa", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle autosave" },
        },
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
            suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
            -- log_level = "debug",
        }
    },
    {
        "mistweaverco/kulala.nvim",
        lazy = false,
        opts = {
            default_view = "headers_body",
            icons = {
                inlay = {
                    loading = "󱦟",
                    done = "",
                    error = "",
                },
                lualine = "🐼",
            },
        }
    },
    {
        "stevearc/quicker.nvim",
        event = "FileType qf",
        config = function()
            local quicker = require("quicker")

            vim.keymap.set("n", "<leader>q", function() quicker.toggle() end, { desc = "Toggle quickfix", })

            quicker.setup({
                keys = {
                    {
                        ">",
                        function() quicker.expand({ before = 2, after = 2, add_to_existing = true }) end,
                        desc = "Expand quickfix context",
                    },
                    {
                        "<",
                        function() quicker.collapse() end,
                        desc = "Collapse quickfix context",
                    },
                },
            })
        end
    },
}
