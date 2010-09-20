" Vim indent file
" Language: Jade
" Maintainer: Joshua Borton
" Credits: Tim Pope (vim-jade)
" Last Change: 2010 Aug 06

if exists("b:did_indent")
  finish
endif

unlet! b:did_indent
let b:did_indent = 1

setlocal autoindent sw=2 et
setlocal indentexpr=GetJadeIndent()
setlocal indentkeys=o,O,*<Return>,},],0),!^F

" Only define the function once.
if exists("*GetJadeIndent")
  finish
endif

let s:attributes = '\%((.\{-\})\)'
let s:tag = '\([%.#][[:alnum:]_-]\+\|'.s:attributes.'\)*[<>]*'

if !exists('g:jade_self_closing_tags')
  let g:jade_self_closing_tags = 'meta|link|img|hr|br'
endif

if maparg("<Plug>FilterBlock") == ""
  inoremap <silent> <SID>FilterBlock <C-R>=<SID>fblock()<CR>
  imap <script> <Plug>FilterBlock <SID>FilterBlock
endif

if maparg('<CR>', 'i') =~# '<C-R>=.*fblock()<CR>\\\\|<\\\\%(Plug\\\\|SID\\\\)>FilterBlock'
" already mapped
elseif maparg('<CR>','i') =~ '<CR>'
    exe "imap <script> <CR>      ".maparg('<CR>','i')."<SID>FilterBlock"
else
  imap <CR> <CR><Plug>FilterBlock
endif

setlocal formatoptions+=r
setlocal comments+=n:\|

function! s:fblock()
  let lnum = line('.') - 1
  let line = getline(lnum)
  let group = synIDattr(synID(lnum,1,1),'name')
  if group == 'jadeFilter'
    return "\|"
  else
    return ""
  endif
endfunction

function! GetJadeIndent()
  let lnum = prevnonblank(v:lnum-1)
  if lnum == 0
    return 0
  endif
  let line = substitute(getline(lnum),'\s\+$','','')
  let cline = substitute(substitute(getline(v:lnum),'\s\+$','',''),'^\s\+','','')
  let lastcol = strlen(line)
  let line = substitute(line,'^\s\+','','')
  let indent = indent(lnum)
  let cindent = indent(v:lnum)
  let increase = indent + &sw
  if indent == indent(lnum)
    let indent = cindent <= indent ? -1 : increase
  endif

  let group = synIDattr(synID(lnum,lastcol,1),'name')

  if line =~ '^!!!'
    return indent
  elseif line =~ '^/\%(\[[^]]*\]\)\=$'
    return increase
  elseif group == 'jadeFilter'
    return increase
  elseif line =~ '^'.s:tag.'[&!]\=[=~-].*,\s*$'
    return increase
  elseif line == '-#'
    return increase
  elseif line =~? '^\v%('.g:jade_self_closing_tags.')>'
    return indent
  elseif group =~? '\v^%(jadeTag|jadeAttributesDelimiter|jadeClass|jadeId|htmlTagName|htmlSpecialTagName)$'
    return increase
  else
    return indent
  endif
endfunction

" vim:set sw=2:
