" Find files using Telescope command-line sugar.
nnoremap <leader>f <cmd>Telescope find_files theme=dropdown<cr>
nnoremap <leader>g <cmd>Telescope live_grep theme=dropdown<cr>
nnoremap <leader>b <cmd>Telescope buffers theme=dropdown<cr>
nnoremap <silent>ca  <cmd>lua vim.lsp.buf.code_action()<cr>
" nnoremap <leader>h <cmd>Telescope help_tags<cr>
