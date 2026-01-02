
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
map("n", "<A-j>", ":m .+1<CR>==") -- move line up(n)
map("n", "<A-k>", ":m .-2<CR>==") -- move line down(n)
map("v", "<A-j>", ":m '>+1<CR>gv=gv") -- move line up(v)
map("v", "<A-k>", ":m '<-2<CR>gv=gv") -- move line down(v)
map("i", "<A-S-j>", "<ESC>:m .+1<CR>==gi")
map("i", "<A-S-k>", "<ESC>:m .-2<CR>==gi")

-- split window 
map("n", "<leader>wv", ":vsplit<CR>")
map("n", "<leader>wh", ":split<CR>")
