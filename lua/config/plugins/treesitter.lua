return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'main',
        build = ":TSUpdate",
        enabled = true,
        main = 'nvim-treesitter',
        init = function()
            vim.api.nvim_create_autocmd('FileType', {
                callback = function()
                    -- Enable treesitter highlighting and disable regex syntax
                    pcall(vim.treesitter.start)
                    -- Enable treesitter-based indentation
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            local ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "http" }
            local already_installed = require('nvim-treesitter.config').get_installed()
            local parsers_to_install = vim.iter(ensure_installed)
                :filter(function(parser)
                    return not vim.tbl_contains(already_installed, parser)
                end)
                :totable()
            require('nvim-treesitter').install(parsers_to_install)
        end,

        -- config = function()
        --     ---@diagnostic disable-next-line: missing-fields
        --     require('nvim-treesitter').setup {
        --         -- A list of parser names, or "all" (the listed parsers MUST always be installed)
        --         ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "http" },
        --
        --         -- Automatically install missing parsers when entering buffer
        --         -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        --         auto_install = true,
        --
        --         indent = {
        --             enabled = true
        --         },
        --
        --         highlight = {
        --             enable = true,
        --
        --             -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        --             disable = function(_, buf)
        --                 local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        --                 local max_filesize = 100 * 1024 -- 100 KB
        --                 if ok and stats and stats.size > max_filesize then
        --                     return true
        --                 end
        --             end,
        --
        --             -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        --             -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        --             -- Using this option may slow down your editor, and you may see some duplicate highlights.
        --             -- Instead of true it can also be a list of languages
        --             additional_vim_regex_highlighting = false,
        --         },
        --     }
        -- end
    }
}
