
local map = function(mode,sequence,action)
    vim.keymap.set(mode, sequence, action, {noremap = true, silent =true})
end

--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- stay in indent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- keep default register intact for pasting stuff
map("v", "p", '"_dP')

-- No highlight 
map("n", ";", ":noh<CR>")


-- move text
map("n", "<A-S-j>", ":m .+1<CR>==") -- move line up(n)
map("n", "<A-S-k>", ":m .-2<CR>==") -- move line down(n)
map("v", "<A-S-j>", ":m '>+1<CR>gv=gv") -- move line up(v)
map("v", "<A-S-k>", ":m '<-2<CR>gv=gv") -- move line down(v)
map("i", "<A-S-j>", "<ESC>:m .+1<CR>==gi")
map("i", "<A-S-k>", "<ESC>:m .-2<CR>==gi")

-- split window
map("n", "<leader>wv", ":vsplit<CR>")
map("n", "<leader>wh", ":split<CR>")

-- commenting (replaces mini.comment)
vim.keymap.set({"n", "v"}, "<C-_>", "gcc", { remap = true })

-- toggles
map("n", "<leader>tw", function() vim.opt.wrap = not vim.opt.wrap:get() end)
map("n", "<leader>tr", function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end)
map("n", "<leader>ts", function() vim.opt.spell = not vim.opt.spell:get() end)
map("n", "<leader>tc", function() vim.opt.conceallevel = vim.o.conceallevel == 0 and 2 or 0 end)

-- terminal toggle
map("n", "<leader>tt", function()
    local term_buf = vim.g._toggle_term_buf
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        local wins = vim.fn.win_findbuf(term_buf)
        if #wins > 0 then
            vim.api.nvim_win_close(wins[1], true)
            return
        end
    end
    vim.cmd("botright 15split")
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        vim.api.nvim_win_set_buf(0, term_buf)
    else
        vim.cmd("terminal")
        vim.g._toggle_term_buf = vim.api.nvim_get_current_buf()
    end
end)
vim.keymap.set("t", "<leader>tt", [[<C-\><C-n><leader>tt]], { remap = true })

-- terminal mode: window navigation and resize (passthrough to tmux.nvim)
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-h>]], { noremap = true, silent = true })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-j>]], { noremap = true, silent = true })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-k>]], { noremap = true, silent = true })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-l>]], { noremap = true, silent = true })
vim.keymap.set("t", "<A-h>", [[<C-\><C-n><A-h>]], { noremap = true, silent = true })
vim.keymap.set("t", "<A-j>", [[<C-\><C-n><A-j>]], { noremap = true, silent = true })
vim.keymap.set("t", "<A-k>", [[<C-\><C-n><A-k>]], { noremap = true, silent = true })
vim.keymap.set("t", "<A-l>", [[<C-\><C-n><A-l>]], { noremap = true, silent = true })
