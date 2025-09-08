return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "debugloop/telescope-undo.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
        }
    },
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "help",
            callback = function()
                if vim.fn.winwidth(0) > 200 then
                    vim.cmd("wincmd L")
                end
            end,
        })

        local telescope = require("telescope")
        local actions = require("telescope.actions")

        -- NOTE: Fucking windows!
        -- https://github.com/nvim-telescope/telescope.nvim/issues/2446

        -- https://github.com/MagicDuck/grug-far.nvim/pull/305
        local is_windows = vim.fn.has('win64') == 1 or vim.fn.has('win32') == 1
        local vimfnameescape = vim.fn.fnameescape
        local winfnameescape = function(path)
            local escaped_path = vimfnameescape(path)
            if is_windows then
                local need_extra_esc = path:find('[%[%]`%$~]')
                local esc = need_extra_esc and '\\\\' or '\\'
                escaped_path = escaped_path:gsub('\\[%(%)%^&;]', esc .. '%1')
                if need_extra_esc then
                    escaped_path = escaped_path:gsub("\\\\['` ]", '\\%1')
                end
            end
            return escaped_path
        end

        local select_default = function(prompt_bufnr)
            vim.fn.fnameescape = winfnameescape
            local result = actions.select_default(prompt_bufnr, "default")
            vim.fn.fnameescape = vimfnameescape
            return result
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "TelescopeResults",
            callback = function(ctx)
                vim.api.nvim_buf_call(ctx.buf, function()
                    vim.fn.matchadd("TelescopeParent", "\t\t.*$")
                    vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
                end)
            end,
        })

        local function filename_first(_, path)
            local tail = vim.fs.basename(path)
            local parent = vim.fs.dirname(path)
            if parent == "." then return tail end
            return string.format("%s\t\t%s", tail, parent)
        end

        local function set_width(percent, min)
            return function(_, max_columns)
                return math.max(math.floor(percent * max_columns), min)
            end
        end

        telescope.setup {
            defaults = {
                -- path_display = { "smart" },
                mappings = {
                    i = {
                        ['<cr>'] = select_default,
                    },
                    n = {
                        ['<cr>'] = select_default,
                        ["q"] = actions.close,
                    }
                },
            },
            pickers = {
                find_files = {
                    path_display = filename_first,
                    -- path_display = {
                    --     filename_first = {
                    --         reverse_directories = false,
                    --     },
                    -- },
                    -- find_command = {
                    --     "rg",
                    --     "--files",
                    --     "--glob",
                    --     "!{.git/*,.svelte-kit/*,target/*,node_modules/*}",
                    --     "--path-separator",
                    --     "/",
                    -- },
                },
                buffers = {
                    theme = "dropdown",
                    initial_mode = "normal",
                    show_all_buffers = true,
                    sort_lastused = true,
                    previewer = false,
                    mappings = {
                        n = {
                            ["dd"] = "delete_buffer",
                        }
                    },
                    layout_config = {
                        width = set_width(.6, 120),
                    }
                },
                quickfix = {
                    initial_mode = "normal",
                },
                oldfiles = {
                    -- path_display = filenameFirst,
                    theme = "dropdown",
                    initial_mode = "normal",
                    sort_lastused = true,
                    previewer = false,
                    layout_config = {
                        width = set_width(.6, 120)
                    }
                },
                diagnostics = {
                    theme = "ivy",
                    path_display = filename_first,
                    initial_mode = "normal",
                    previewer = false,
                },
                lsp_references = {
                    path_display = { "tail" },
                    initial_mode = "normal",
                    theme = "ivy"
                },
                lsp_definitions = {
                    theme = "ivy",
                    path_display = { "tail" },
                    initial_mode = "normal",
                },
                lsp_implementations = {
                    theme = "ivy",
                    path_display = { "tail" },
                    initial_mode = "normal",
                },
                lsp_document_symbols = {
                    theme = "ivy",
                    initial_mode = "normal",
                },
                treesitter = {
                    theme = "ivy",
                    initial_mode = "normal",
                },
            },
            extensions = {
                fzf = {},
                undo = {},
            }
        }

        telescope.load_extension("fzf")
        telescope.load_extension("undo")

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]uzzy [H]elp' })
        vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]uzzy [K]eymaps' })
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]uzzy [F]iles' })
        vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]uzzy [D]iagnostics' })
        vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]uzzy [R]esume' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]uzzy [B]uffers' })
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = '[F]uzzy [O]ld Files' })
        vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = '[F]uzzy [Q]uickfix' })
        vim.keymap.set('n', '<leader>ft', builtin.treesitter, { desc = '[F]uzzy [T]reesitter' })

        -- Document symbols
        vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = '[F]uzzy [S]ymbols All' })
        vim.keymap.set('n', '<leader>fss', builtin.lsp_document_symbols, { desc = '[F]uzzy [S]ymbols All' })

        vim.keymap.set('n', '<leader>fsf', function()
            builtin.lsp_document_symbols({ symbols = { 'function', 'method' } })
        end, { desc = '[F]uzzy [S]ymbols Functions' })

        vim.keymap.set('n', '<leader>fsc', function()
            builtin.lsp_document_symbols({ symbols = { 'constant' } })
        end, { desc = '[F]uzzy [S]ymbols Functions' })

        -- vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[F]uzzy [S]earch [S]elect Telescope' })

        vim.keymap.set('n', '<leader>f.', function()
            -- You can pass additional configuration to Telescope to change the theme, layout, etc.
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                layout_config = {
                    width = set_width(0.6, 120)
                },
                winblend = 10,
                previewer = false,
            })
        end, { desc = '[.] Fuzzily search in current buffer' })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>fn', function()
            builtin.find_files { cwd = vim.fn.stdpath("config") }
        end, { desc = '[F]uzzy [N]eovim config files' })

        vim.keymap.set("n", "<space>u", "<cmd>Telescope undo<CR>")
        vim.keymap.set("n", "<leader>fg", require("config.telescope.multigrep").live_multigrep)

        -- vim.keymap.set("n", "<space>ep", function()
        --     ---@diagnostic disable-next-line: param-type-mismatch
        --     require("telescope.builti").find_files { cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }
        -- end)
    end
}
