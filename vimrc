source $VIMRUNTIME/defaults.vim

set cinoptions+=(0,:0 formatoptions+=ro hlsearch mouse= number

if &diff | syntax off | endif

let g:rst_style = 1

if executable('clangd')
    let g:compile_commands_dir = "--compile-commands-dir=."

    if expand("%:t") == "cscope.files"
        " Add the database associated
        execute "cs add " expand("%:h") expand("%:h")
        " Specify a path to look for compile_commands.json
        let g:compile_commands_dir = "--compile-commands-dir=" . expand("%:h")
    endif

    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '-background-index', '--header-insertion=never', '-j', '8', g:compile_commands_dir]},
        \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })

    autocmd FileType c inoremap PK!  pr_alert("\033[31m1: %s %d\033[00m\n", __func__, __LINE__);<Esc>F\
    autocmd FileType c inoremap PK@   pr_crit("\033[32m2: %s %d\033[00m\n", __func__, __LINE__);<Esc>F\
    autocmd FileType c inoremap PK#    pr_err("\033[33m3: %s %d\033[00m\n", __func__, __LINE__);<Esc>F\
    autocmd FileType c inoremap PK$   pr_warn("\033[34m4: %s %d\033[00m\n", __func__, __LINE__);<Esc>F\
    autocmd FileType c inoremap PK% pr_notice("\033[35m5: %s %d\033[00m\n", __func__, __LINE__);<Esc>F\
    autocmd FileType c inoremap PK^   pr_info("\033[36m6: %s %d\033[00m\n", __func__, __LINE__);<Esc>F\
    autocmd FileType c inoremap PK&   WARN(1, "\033[37m7: %s %d\033[00m\n", __func__, __LINE__);<Esc>F\
    autocmd FileType c inoremap PK* print_hex_dump(KERN_INFO, "", DUMP_PREFIX_ADDRESS, 16, 1, buf, len, true);<Esc>Fb
endif

if executable('java')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'eclipse.jdt.ls',
        \ 'cmd': {server_info->[
        \     'java',
        \     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        \     '-Dosgi.bundles.defaultStartLevel=4',
        \     '-Declipse.product=org.eclipse.jdt.ls.core.product',
        \     '-Dlog.level=ALL',
        \     '-noverify',
        \     '--add-modules=ALL-SYSTEM',
        \     '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        \     '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        \     '-jar', expand('~/Downloads/eclipse-workspace/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar'),
        \     '-configuration', expand('~/Downloads/eclipse-workspace/jdtls/config_linux/'),
        \     '-data', getcwd(),
        \ ]},
        \ 'whitelist': ['java'],
        \ 'initialization_options': {
        \     'bundles': split(system("echo -n ~/Downloads/eclipse-workspace/jdtls.pde/extension/server/*"), " "),
        \ },
        \ })
    autocmd FileType java inoremap PK! System.out.println("\033[31m" + Thread.currentThread().getStackTrace()[1] + "\033[00m");<Esc>F"
    autocmd FileType java inoremap PK@ System.out.println("\033[32m" + Thread.currentThread().getStackTrace()[1] + "\033[00m");<Esc>F"
    autocmd FileType java inoremap PK# System.out.println("\033[33m" + Thread.currentThread().getStackTrace()[1] + "\033[00m");<Esc>F"
    autocmd FileType java inoremap PK$ System.out.println("\033[34m" + Thread.currentThread().getStackTrace()[1] + "\033[00m");<Esc>F"
    autocmd FileType java inoremap PK% System.out.println("\033[35m" + Thread.currentThread().getStackTrace()[1] + "\033[00m");<Esc>F"
    autocmd FileType java inoremap PK^ System.out.println("\033[36m" + Thread.currentThread().getStackTrace()[1] + "\033[00m");<Esc>F"
    autocmd FileType java inoremap PK&                                 Thread.currentThread().dumpStack();<Esc>
endif

if executable('rls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'rls',
        \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
        \ 'workspace_config': {'rust': {'clippy_preference': 'on'}},
        \ 'whitelist': ['rust'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
    nmap <buffer> <C-\>C <plug>(lsp-call-hierarchy-incoming)
    nmap <buffer> <C-\>D <plug>(lsp-declaration)
    nmap <buffer> <C-\>G <plug>(lsp-definition)
    nmap <buffer> <C-\>H <plug>(lsp-hover)
    nmap <buffer> <C-\>I <plug>(lsp-implementation)
    nmap <buffer> <C-\>R <plug>(lsp-rename)
    nmap <buffer> <C-\>S <plug>(lsp-references)
    nmap <buffer> <expr><C-\>J  lsp#scroll(+8)
    nmap <buffer> <expr><C-\>K  lsp#scroll(-8)
endfunction

augroup lsp_install
    let g:lsp_diagnostics_signs_enabled = 0
    let g:lsp_document_code_action_signs_enabled = 0
    "let g:lsp_log_verbose = 1
    "let g:lsp_log_file = expand('~/vim-lsp.log')
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
