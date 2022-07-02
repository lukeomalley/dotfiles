" Neoformat

" Enable alignment
let g:neoformat_basic_format_align = 1

" Enable tab to spaces conversion
let g:neoformat_basic_format_retab = 1

" Enable trimmming of trailing whitespace
let g:neoformat_basic_format_trim = 1

" Have Neoformat only msg when there is an error
let g:neoformat_only_msg_on_error = 1

" Attempt to find exe in a node_modules/.bin directory in the current working directory or one of its parents (requires setting g:neoformat_try_node_exe)
let g:neoformat_try_node_exe = 1

" custom setting for clangformat
let g:neoformat_cpp_clangformat = {
    \ 'exe': 'clang-format',
    \ 'args': ['--style="LLVM"']
    \}

let g:neoformat_enabled_cpp = ['clangformat']

let g:neoformat_enabled_c = ['clangformat']

autocmd BufWritePre *.js,*.ts,*.css,*.scss,*.graphql,*.html,*.tsx,*.cpp,*.c,*.h Neoformat
