fun! s:on_gtags_finish()
    if exists('s:gtags_need_update') && s:gtags_need_update == 1
        call s:update_gtags()
    endif
endf

fun! s:update_gtags()
    if &diff
        return
    endif

    if exists('s:gtags_job') && job_status(s:gtags_job) ==# 'run'
        let s:gtags_need_update = 1
    else
        let s:gtags_need_update = 0

        if filereadable('GPATH') && filereadable('GRTAGS') && filereadable('GTAGS')
            if executable('global')
                let s:gtags_need_update = 0
                "let l:cmd = 'global -u --single-update="' . expand('%') . '"'
                let l:cmd = 'global -u'
                let s:gtags_job = job_start(l:cmd, {'stoponexit': '', 'in_io': 'null', 'out_io': 'null', 'err_io': 'null', 'exit_cb' : {->s:on_gtags_finish()}})
            endif
        else
            if executable('gtags')
                let s:gtags_job = job_start('gtags', {'stoponexit': '', 'in_io': 'null', 'out_io': 'null', 'err_io': 'null', 'exit_cb' : {->s:on_gtags_finish()}})
            endif
        endif
    endif
endf

call s:update_gtags()

augroup AutoGtag
    au BufWritePost,BufEnter * call s:update_gtags()
    au VimLeave * silent! call job_stop(s:gtags_job, "int")
augroup END
