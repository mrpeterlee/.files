require('hlslens').setup({
    calm_down = true,
    nearest_only = true,
})

vim.api.nvim_set_keymap(
  "n",
  "n",
  "execute('normal! ' . v:count1 . 'nzzzv')lua require('hlslens').start()",
  { noremap = true, silent = true }
)

vim.api.nvim_set_keymap(
  "n",
  "N",
  "execute('normal! ' . v:count1 . 'Nzzzv')lua require('hlslens').start()",
  { noremap = true, silent = true }
)

vim.api.nvim_set_keymap("n", "*", "<Plug>(asterisk-z*)lua require('hlslens').start()", { silent = true })
vim.api.nvim_set_keymap("n", "#", "<Plug>(asterisk-z#)lua require('hlslens').start()", { silent = true })
