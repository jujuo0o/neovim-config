return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers",
                numbers = "ordinal",
                diagnostics = "nvim_lsp",
                separator_style = "slant",
                show_buffer_close_icons = true,
                show_close_icon = false,
                always_show_bufferline = true,
                offsets = {
                    {
                        filetype = "nerdtree",
                        text = "Explorer",
                        text_align = "center",
                        separator = true,
                    },
                },
                close_command = function(bufnr)
                    smart_close(bufnr)
                end,
            },
        })

        -- Close a buffer without losing the editor window.
        -- Falls back to the most recently used other buffer, or a fresh empty one.
        function _G.smart_close(bufnr)
            bufnr = bufnr or vim.api.nvim_get_current_buf()

            -- Don't operate from inside NERDTree
            if vim.bo[bufnr].filetype == "nerdtree" then
                return
            end

            -- Find the editor window (the one currently showing this buffer)
            local target_win
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == bufnr then
                    target_win = win
                    break
                end
            end
            if not target_win then return end

            -- Find other listed, non-tree buffers, sorted by most recently used
            local others = vim.tbl_filter(function(b)
                return b ~= bufnr
                    and vim.api.nvim_buf_is_loaded(b)
                    and vim.bo[b].buflisted
                    and vim.bo[b].filetype ~= "nerdtree"
            end, vim.api.nvim_list_bufs())

            table.sort(others, function(a, b)
                return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
            end)

            if #others > 0 then
                vim.api.nvim_win_set_buf(target_win, others[1])
            else
                -- No other files — put a fresh empty buffer in the editor window
                local empty = vim.api.nvim_create_buf(true, false)  -- listed, not scratch
                vim.api.nvim_win_set_buf(target_win, empty)
            end

            -- Now safe to delete the original buffer
            pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
        end

        -- Buffer navigation that always operates in the editor window
        local function in_editor(action)
            return function()
                if vim.bo.filetype == "nerdtree" then
                    vim.cmd("wincmd p")
                end
                action()
            end
        end

        vim.keymap.set("n", "<M-h>", in_editor(function() vim.cmd("BufferLineCyclePrev") end),
            { desc = "Previous buffer" })
        vim.keymap.set("n", "<M-l>", in_editor(function() vim.cmd("BufferLineCycleNext") end),
            { desc = "Next buffer" })
        vim.keymap.set("n", "<M-w>", function() _G.smart_close() end,
            { desc = "Close buffer (keep layout)" })

        for i = 1, 9 do
            vim.keymap.set("n", "<M-" .. i .. ">", in_editor(function()
                require("bufferline").go_to(i, true)
            end), { desc = "Go to buffer " .. i })
        end
    end,
}
