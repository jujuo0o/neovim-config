return {
    "preservim/nerdtree",
    dependencies = {
        "ryanoasis/vim-devicons",
    },
    lazy = false,
    config = function()
        vim.g.NERDTreeShowHidden = 1
        vim.g.NERDTreeMinimalUI = 1
        vim.g.NERDTreeDirArrows = 1
        vim.g.NERDTreeWinSize = 32
        vim.g.NERDTreeStatusline = ""
        vim.g.NERDTreeHijackNetrw = 0   -- let us handle directory opens ourselves

        vim.keymap.set("n", "<leader>e", "<cmd>NERDTreeToggle<cr>", { desc = "Toggle NERDTree" })
        vim.keymap.set("n", "<leader>nf", "<cmd>NERDTreeFind<cr>", { desc = "Find file in NERDTree" })

        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                pcall(vim.cmd, "autocmd! NERDTreeHijackNetrw")
                local arg = vim.fn.argv(0)
                if vim.fn.argc() == 1 and vim.fn.isdirectory(arg) == 1 then
                    vim.schedule(function()
                       -- vim.cmd("cd " .. vim.fn.fnameescape(arg))
                       -- vim.cmd("silent! bwipeout #")
                        vim.cmd("NERDTree " .. vim.fn.fnameescape(arg))
                        vim.cmd("wincmd p")
                        vim.cmd("enew")
                    end)
                end
            end,
        })
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "nerdtree",
            callback = function()
                local opts = { buffer = true, silent = true, nowait = true, remap = true }
                vim.keymap.set("n", "a", "ma", opts)
                vim.keymap.set("n", "d", "md", opts)
                vim.keymap.set("n", "r", "mm", opts)
            end,
        })
    end,
}
