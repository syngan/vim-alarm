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

if has('python')
function! alarm#action#mail(dic) " {{{
  if !has_key(a:dic, 'email') ||
  \  !has_key(a:dic, 'smtp_host')
    throw "alarm#action#mail: invalid argument"
  endif

  let a:dic.smtp_port = get(a:dic, 'smtp_port', 25)

  python << endpython
import vim
try:
  import smtplib
  from email.mime.text import MIMEText

  d = vim.eval('a:dic')
  m = d.get('message')
  me = d.get('email')
  you = me
  msg = MIMEText(m)
  msg['Subject'] = 'alarm.vim: ' + m
  msg['From'] = me
  msg['To'] = you

  s = smtplib.SMTP(d.get('smtp_host'), d.get('smtp_port'))
  if 'smtp_debug' in d:
    s.set_debuglevel(True)
  s.ehlo('localhost')
  if 'starttls' in s.esmtp_features:
    s.starttls()
  if 'smtp_user' in d:
    s.login(d.get('smtp_user'), d.get('smtp_pass'))
  #  s.connect()
  s.sendmail(me, [you], msg.as_string())
  s.close()
except RuntimeError as exception:
  if exception.args != ("Exit from local scope",):
    raise exception

endpython
endfunction " }}}
endif

function! alarm#action#notify(dic) " {{{
  if !has_key(a:dic, 'notify')
    let a:dic.notify = 'notify-send'
  endif
  try
    call vimproc#version()
    call vimproc#system_bg(a:dic.notify .' '. a:dic.message)
  catch
    call system(a:dic.notify .' '. a:dic.message)
  endtry
endfunction " }}}

function! alarm#action#buffer(dic) " {{{
  execute 'new'
  silent 0put ='time: ' . strftime('%y/%m/%d %H:%M')
  silent $put ='name: ' . a:dic.name
  silent $put ='message: ' . a:dic.message
  setlocal nomodified nomodifiable readonly
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker cms=\ "\ %s:
