return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local api = require("nvim-tree.api")

        local function on_attach(bufnr)
            api.config.mappings.default_on_attach(bufnr)

            vim.api.nvim_win_set_option(0, "number", true)
            vim.api.nvim_win_set_option(0, "relativenumber", true)
            vim.api.nvim_win_set_option(0, "numberwidth", 1)

            local function change_root_and_cd()
                local node = api.tree.get_node_under_cursor()
                if not node or not node.absolute_path then return end
                local path = node.absolute_path

                api.tree.change_root_to_node()
                vim.cmd("cd " .. path)

                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
                        local job_id = vim.b[buf].terminal_job_id
                        if job_id then
                            vim.api.nvim_chan_send(job_id, 'cd "' .. path .. '"\r\n')
                        end
                    end
                end
            end

            vim.keymap.set("n", "<leader>r", change_root_and_cd, {
                desc = "NvimTree: Change root and cd in terminal",
                buffer = bufnr,
                noremap = true,
                silent = true,
                nowait = true,
            })
        end
        local api = require("nvim-tree.api")
        vim.keymap.set("n", "ü", function()
            local win = vim.api.nvim_get_current_win()
            api.tree.toggle()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_current_win(win)
            end
        end, { desc = "Toggle NvimTree without focusing it", noremap = true, silent = true })

        require("nvim-tree").setup({
            on_attach = on_attach,
            hijack_netrw = true,
            sync_root_with_cwd = true,
            respect_buf_cwd = true,
            view = {
                width = 30,
                side = "left",
                number = false,
                relativenumber = true,
                preserve_window_proportions = true,
            },
            update_focused_file = {
                enable = true,
                update_root = false,
            },
        })
    end,
}
