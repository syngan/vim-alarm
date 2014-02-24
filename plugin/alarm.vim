scriptencoding utf-8
" 日本語ファイル

let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_vimalarm')
  finish
endif

if exists('g:alarm_enable_at_startup') && g:alarm_enable_at_startup
  call alarm#enable()
endif

let g:loaded_vimalarm = 1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
