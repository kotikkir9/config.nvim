return {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        if vim.fn.has("win32") == 1 then
            local powershell_options = {
                shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
                shellcmdflag =
                    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
                shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
                shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
                shellquote = "",
                shellxquote = "",
            }

            for option, value in pairs(powershell_options) do
                vim.opt[option] = value
            end
        end

        require("toggleterm").setup()

        vim.keymap.set("n", "<leader>ts", "<cmd>:TermSelect<CR>")
        vim.keymap.set("n", "<leader>tt", "<cmd>:ToggleTerm<CR>")
        vim.keymap.set("n", "<leader>ta", "<cmd>:ToggleTermToggleAll<CR>")
        vim.keymap.set("n", "<leader>th", "<cmd>:ToggleTerm direction=horizontal<CR>")
        vim.keymap.set("n", "<leader>tv", "<cmd>:ToggleTerm direction=vertical size=100<CR>")
        vim.keymap.set("n", "<leader>tf", "<cmd>:ToggleTerm direction=float<CR>")
        vim.keymap.set("t", "<M-q>", "<cmd>:ToggleTerm<CR>")
    end
}
