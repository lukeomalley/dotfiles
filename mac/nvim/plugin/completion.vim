" Use completion-nvim in every buffer
autocmd BufEnter * lua require'completion'.on_attach()

imap <silent> <c-space> <Plug>(completion_trigger)

