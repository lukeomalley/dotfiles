" Map smooth scrolling
noremap <silent> <c-u> :call smooth_scroll#up(2, 5, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(2, 5, 2)<CR>

" Enable mouse scrolling
set mouse=a
map <ScrollWheelUp> <C-u>
map <ScrollWheelDown> <C-d>
