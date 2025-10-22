vim.keymap.set("n", "<leader>w", "<cmd>write<CR>")
-- vim.keymap.set("n", "<leader>wa", "<cmd>wall<CR>")
vim.keymap.set("n", "<C-S>", "<cmd>write<CR>")
vim.keymap.set("i", "<C-S>", "<cmd>write<CR>")
vim.keymap.set("n", "<M-S>", "<cmd>wall<CR>")
vim.keymap.set("i", "<M-S>", "<cmd>wall<CR>")

vim.keymap.set("n", "<leader>R", "<cmd>edit<CR>")

vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>")

vim.keymap.set("n", "<leader>F", vim.lsp.buf.format)
vim.keymap.set("n", "<M-F>", vim.lsp.buf.format)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", "\"_dP")
-- vim.keymap.set("n", "<leader>d", "\"_d")
-- vim.keymap.set("v", "<leader>d"d "\"_d")
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
vim.keymap.set("i", "jj", "<Esc>")

-- vim.keymap.set("n", "<space>tf", "<cmd>PlenaryBustedFile %<CR>")

-- <Reddit>
vim.keymap.set("n", "ycc", "yygccp", { remap = true })

vim.keymap.set("x", "/", "<Esc>/\\%V");

-- Automatically add semicolon or comma at the end of the line in INSERT and NORMAL modes
vim.keymap.set("n", ";;", "A;<ESC>")
vim.keymap.set("n", ",,", "A,<ESC>")
-- </Reddit>

local buffer_command = function(command)
    -- if vim.bo.buftype == "nofile" then
    --     return
    -- end

    if #vim.fn.getbufinfo({ buflisted = 1 }) == 0 then
        print "No buffers found."
        return
    end

    vim.cmd(command)
end

vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "[D]iagnostics" })
vim.keymap.set('n', '<leader>dl', function()
    local vl_enabled = vim.diagnostic.config().virtual_lines == true
    vim.diagnostic.config({
        virtual_lines = not vl_enabled,
        virtual_text = vl_enabled
    })
end, { desc = 'Toggle diagnostic virtual lines' })

vim.keymap.set("n", "<leader>n", function() buffer_command("bnext") end)
vim.keymap.set("n", "<leader>p", function() buffer_command("bprev") end)

vim.keymap.set("n", "<C-n>", function() buffer_command("bnext") end)
vim.keymap.set("n", "<C-p>", function() buffer_command("bprev") end)

-- vim.keymap.set("n", "<leader>bd", function()
vim.keymap.set("n", "<leader>dd", function()
    if vim.bo.buftype == "terminal" then
        vim.cmd("bd!")
    else
        -- local buffers = vim.api.nvim_list_bufs()
        -- local current = vim.api.nvim_get_current_buf()
        --
        -- for _, buf in ipairs(buffers) do
        --     if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype ~= "nofile" then
        --         vim.api.nvim_set_current_buf(buf) -- Switch to the next buffer
        --     end
        -- end
        -- vim.cmd("bd " .. current)
        vim.cmd("bd")
    end
end, { desc = "Unload buffer and delete it from the buffer list." })

-- vim.keymap.set("n", "<leader>st", function()
--     vim.cmd.vnew()
--     vim.cmd.term()
--     vim.cmd.wincmd("J")
--     vim.api.nvim_win_set_height(0, 15)
-- vim.api.nvim_command("startinsert")
-- vim.cmd("startinsert")
-- end)

-- vim.api.nvim_set_keymap('i', '"', '""<Left>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', "'", "''<Left>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '(', '()<Left>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '[', '[]<Left>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '{', '{}<Left>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '{<CR>', '{<CR>}<ESC>O', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '{;<CR>', '{<CR>};<ESC>O', { noremap = true, silent = true })
