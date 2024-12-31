source $VIMRUNTIME/defaults.vim

set cinoptions+=(0,:0 formatoptions+=ro hlsearch mouse= number

let g:rst_style = 1
let g:ollama_no_tab_map = 1
inoremap <buffer> <C-l> <Plug>(ollama-tab-completion)

autocmd DiffUpdated * if &diff | syntax off | endif

augroup lsp_install

    "let g:lsp_diagnostics_virtual_text_enabled = 0
    "let g:lsp_log_file = expand("~/vim-lsp.log")

    function! s:on_lsp_buffer_enabled() abort
        nnoremap <buffer> <C-\>C <Plug>(lsp-call-hierarchy-incoming)
        nnoremap <buffer> <C-\>G <Plug>(lsp-definition)
        nnoremap <buffer> <C-\>H <Plug>(lsp-hover)
        nnoremap <buffer> <C-\>S <Plug>(lsp-references)

        nnoremap <buffer> <expr><C-j> lsp#scroll(+4)
        nnoremap <buffer> <expr><C-k> lsp#scroll(-4)

        inoremap <buffer> <expr><C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<Plug>(ollama-tab-completion)'
    endfunction

    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()

    if executable('bash-language-server')
        autocmd User lsp_setup call lsp#register_server({
              \ 'name': 'bash-language-server',
              \ 'cmd': {server_info->[&shell, &shellcmdflag, 'bash-language-server start']},
              \ 'allowlist': ['sh'],
              \ })
    endif

    if executable('clangd')
        let g:compile_commands_dir = "--"

        if expand("%:t") == "compile_commands.json" || expand("%:t") == "cscope.files"
            " Add the database associated
            execute "cs add " expand("%:h") expand("%:h")
            " Specify a path to look for compile_commands.json
            let g:compile_commands_dir = "--compile-commands-dir=" . expand("%:h")
        endif

        autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'clangd',
            \ 'cmd': {server_info->['clangd', '--header-insertion=never', g:compile_commands_dir]},
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

    if executable('java-disabled')
        autocmd User lsp_setup call lsp#register_server({
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
            \     '-jar', expand("~/Downloads/eclipse-workspace/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar"),
            \     '-configuration', expand("~/Downloads/eclipse-workspace/jdtls/config_linux/"),
            \     '-data', getcwd(),
            \ ]},
            \ 'allowlist': ['java'],
            \ 'initialization_options': {
            \     'bundles': split(expand("~/Downloads/eclipse-workspace/jdtls.pde/extension/server/*")),
            \ },
            \ })
        autocmd FileType java inoremap PK^ System.out.println("\033[36m" + Thread.currentThread().getStackTrace()[1] + "\033[00m");<Esc>F"
        autocmd FileType java inoremap PK&                                 Thread.currentThread().dumpStack();<Esc>
    endif

    if executable('pyright-langserver')
        autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'pyright-langserver',
            \ 'cmd': {server_info->['pyright-langserver', '--stdio']},
            \ 'allowlist': ['python'],
            \ })
        autocmd FileType python inoremap PK^ import inspect; print(f"\033[36m {inspect.currentframe().f_code.co_name} {inspect.currentframe().f_lineno}\033[00m")<Esc>F"
        autocmd FileType python inoremap PK& import time; time.sleep(7)<Esc>F7
    endif

    if executable('rls')
        autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'rls',
            \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
            \ 'workspace_config': {'rust': {'clippy_preference': 'on'}},
            \ 'allowlist': ['rust'],
            \ })
    endif

    if executable('typescript-language-server')
        autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'typescript-language-server',
            \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
            \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
            \ 'allowlist': ['typescript', 'typescript.tsx', 'typescriptreact'],
            \ })
    endif

    if executable('vim-language-server')
        autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'vim-language-server',
            \ 'cmd': {server_info->['vim-language-server', '--stdio']},
            \ 'allowlist': ['vim'],
            \ 'initialization_options': {
            \   'vimruntime': $VIMRUNTIME,
            \   'runtimepath': &rtp,
            \ }})
    endif
augroup END
