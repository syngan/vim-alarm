scriptencoding utf-8
" 日本語ファイル

let s:save_cpo = &cpo
set cpo&vim

" s:alarm_dicts is a list of dictionary which has
"   'name' 'time' 'action'
let s:alarm_dicts = []

" s:flag_enable is true if alarm#enable() is called
let s:flag_enable = 0

let g:alarm_debug = get(g:, 'alarm_debug', 0)

function! s:default_match(dic, now) " {{{
  let time = strftime("%y%m%d%H%M", a:now)
  let a:dic.check = time " for debug: unused
  return a:dic.next_time <= time
endfunction " }}}

" 次に鳴らすタイミングを計算する.
" @return 数値で YYMMDDHHMM の形式
function! s:default_next(dic, now) " {{{
  let time = strftime("%H%M", a:now)
  if time >= a:dic.time
    " 明日
    let next = strftime("%y%m%d", a:now + 24*60*60) . a:dic.time
  else
    " 今日
    let next = strftime("%y%m%d", a:now) . a:dic.time
  endif
  return next
endfunction " }}}

let s:default_alarm = {
\   'match' : function("s:default_match"),
\   'action' : function("alarm#action#echo"),
\   'next' : function("s:default_next"),
\}

function! alarm#enable() " {{{
  augroup vimalarm
    autocmd!
    autocmd CursorHold,CursorHoldI * call s:alarm()
  augroup END
  let s:flag_enable = 1
endfunction " }}}

function! alarm#disable() " {{{
  augroup vimalarm
    autocmd!
  augroup END
  let s:flag_enable = 0
endfunction " }}}

function! alarm#is_enabled() " {{{
  return s:flag_enable
endfunction " }}}

function! alarm#register(dict) " {{{
  " 入力チェック.
  if type(a:dict) != type({}) ||
  \  !has_key(a:dict, "name") ||
  \  !has_key(a:dict, "time")
    throw "alarm#register(): invalid"
  endif

  " 上書き
  call alarm#unregister(a:dict.name)

  " デフォルト値設定
  let dict = copy(a:dict)
  let dict = extend(dict, s:default_alarm, 'keep')
  if type(dict.action) != type([])
    let action = [dict.action]
  else
    let action = dict.action
  endif

  " アクションの変換.
  let dict.action = []
  for A in action
    if type(A) == type("")
      for f in ['mail', 'echo', 'beep', 'notify', 'buffer']
        if A ==# f
          unlet A
          let A = function('alarm#action#' . f)
          break
        endif
      endfor
      if type(A) == type("")
        throw "alarm#register() : unknown action type"
      endif
    elseif type(A) != type(function('tr'))
      throw "alarm#register() : invalid action: " . string(A)
    endif
    call add(dict.action, A)
    unlet A
  endfor

  for A in dict.action
    if !exists('*' . string(A))
      throw "alarm#register() : unknown action: " . string(A)
    endif

    if A == function('alarm#action#mail')
      for key in ['email', 'smtp_host']
        if !has_key(dict, key)
          throw "alarm#register() : key not present in dictionary: " . key
        endif
      endfor
    endif
  endfor

  if !has_key(dict, 'message')
    let dict.message = dict.name
  endif

  let dict.next_time = dict.next(dict, localtime())

  call add(s:alarm_dicts, dict)
  call sort(s:alarm_dicts, 's:compare')
endfunction " }}}

function! s:compare(a1, a2)
  return a:a1.next_time - a:a2.next_time
endfunction

function! alarm#unregister(name) " {{{
  call filter(s:alarm_dicts, 'v:val.name !=#' . string(a:name))
endfunction " }}}

function! s:alarm() " {{{
  " 時刻チェック
  let now = localtime()
  let flag = 0
  for s in s:alarm_dicts
    if s.match(s, now)
      call s:action(s, now)
      let flag = 1
    else
      break
    endif
  endfor
  if flag
    call sort(s:alarm_dicts, 's:compare')
  endif
endfunction " }}}

" @vimlint(EVL102, 1, l:A)
function! s:action(dic, now) " {{{
  for A in a:dic.action
    call A(a:dic)
  endfor

  let a:dic.next_time = a:dic.next(a:dic, a:now)
endfunction " }}}
" @vimlint(EVL102, 0, l:A)

function! alarm#test(name) " {{{
  for s in s:alarm_dicts
    if s.name ==# a:name
      call s:action(s, localtime())
      call sort(s:alarm_dicts, 's:compare')
      return
    endif
  endfor
endfunction " }}}

if g:alarm_debug " {{{

function! alarm#get_alarm(...)

  if a:0 == 0
    return map(copy(s:alarm_dicts), 'v:val.name')
  endif

  let name = a:1
  for s in s:alarm_dicts
    if s.name ==# name
      return s
    endif
  endfor
endfunction

endif " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 foldmethod=marker commentstring=\ "\ %s:
