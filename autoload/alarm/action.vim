scriptencoding utf-8
" アクション定義

let s:save_cpo = &cpo
set cpo&vim

function! alarm#action#echo(dic) " {{{
  echohl ErrorMsg
  echo "alarm: " . a:dic.message
  echohl NoNe
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
