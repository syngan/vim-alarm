scriptencoding utf-8
" 日本語ファイル

let s:save_cpo = &cpo
set cpo&vim

function! alarm#action#echo(dic) " {{{
  echohl ErrorMsg
  echo "alarm: " . a:dic.message
  echohl NoNe
endfunction " }}}

if has("lua")
" @vimlint(EVL103, 1, a:dic)
function! alarm#action#beep(dic) " {{{
  :lua vim.beep()
endfunction " }}}
" @vimlint(EVL103, 0, a:dic)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
