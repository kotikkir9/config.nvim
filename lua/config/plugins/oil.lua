return {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = {
        { "nvim-mini/mini.icons", opts = {} }
    },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    config = function()
        local oil = require("oil")
        oil.setup({
            keymaps = {
                ["q"] = { "actions.close", mode = "n" },
                ["<C-h>"] = { "actions.parent", mode = "n" },
                ["<C-l>"] = { "actions.select", mode = "n" },
            },
            view_options = {
                sort = {
                    { "type", "asc" },
                    { "name", "asc" },
                }
            },
            keymaps_help = {
                border = "rounded"
            }
        })

        vim.keymap.set("n", "=", oil.open, { desc = "Open parent directory" })
        -- vim.keymap.set("n", "=", function() oil.open(nil, { preview = {} }) end, { desc = "Open parent directory" })
    end
}
