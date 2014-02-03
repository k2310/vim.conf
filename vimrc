" ======================================================================
"
"                       VIM CONF のための設定
"
" ======================================================================

" ---------------------------------------------------------------------- 
"   基本的な変数群   
"
"     環境変数 $VIM_CONF_ROOT をこのファイル(conf/vimrc)のディレクトリに
let $VIM_CONF_ROOT=expand('<sfile>:p:h')
"     環境変数 $VIM_CONF_VIMFILES ... プラグインなどを保存
let $VIM_CONF_VIMFILES=$VIM_CONF_ROOT . '/vimfiles'
"     環境変数 $VIM_CONF_SETTINGS ... 設定ファイルなどを保存
let $VIM_CONF_SETTINGS=$VIM_CONF_ROOT . '/settings'
"     環境変数 $VIM_CONF_MISCS ... その他雑多なものを保存
let $VIM_CONF_MISCS=$VIM_CONF_ROOT . '/miscs'
" ---------------------------------------------------------------------- 
"   runtimepathに $VIM_CONF_VIMFILES を追加
"
let &runtimepath=$VIM_CONF_VIMFILES . ','. &runtimepath
" ---------------------------------------------------------------------- 
"   設定情報を読み込むための関数(このスクリプトでのみ使用)
"
function! s:load_settings (name)
  " 設定情報は $VIM_CONF_SETTINGS 以下に
  "   <a:name>/config.vim
  " として保存されていることを想定している。
  "
  " この関数は name が実在するかどうかチェックしない。
  " 
  let config_file = $VIM_CONF_SETTINGS . "/" . a:name . "/config.vim"
  exec "source " . config_file
endfunction
" ---------------------------------------------------------------------- 
"   設定情報の一覧を取得するための関数(このスクリプトでのみ使用)
"
function! s:list_settings ()
  " $VIM_CONF_SETTINGS ディレクトリ内にあるディレクリのうち、
  " 直下に 設定ファイル(config.vim) があるものを列挙する
  " 戻り値は次の形式のハッシュ
  "   nameX    ... 設定情報名
  "   dirnameX ... ディレクトリ名(<数値>_<設定情報名>)
  "   { 'name1' : 'dirname1', 'name2' : 'dirname2', 'name3' : 'dirname3' ... }
  set verbose=2
  let config_files = filter(split(globpath($VIM_CONF_SETTINGS,  '*/config.vim'), '\n'), '!isdirectory(v:val)')
  let settings = {}
  for config_file in config_files
    let dirname = fnamemodify(config_file, ":p:h:t")
    let name    = matchlist(dirname, '\v^\d{2}_(.+)$')[1]
    let settings[name] = dirname
  endfor
  set verbose=0
  return settings
endfunction
" ---------------------------------------------------------------------- 
"   $VIM_CONF_SETTINGS以下の設定情報をインデックスする
"
let s:settings_list = s:list_settings()
" ---------------------------------------------------------------------- 
"   settings_to_use_list
"
if !exists("settings_to_use_list")
  echo "Warning : user variable 'settings_to_use_list' is not defined"
  let settings_to_use_list = []
endif
" ---------------------------------------------------------------------- 
"   settings_to_use_list の要素が存在するかチェックする
"    → 存在しない場合は警告を出す
"
function s:check_settings_to_use_list(user_list, settings_list)
  for item in a:user_list 
    if !has_key(a:settings_list, item)
      echo "[" . item . "]の設定情報 -  " . $VIM_CONF_SETTINGS . "/" . item . "/config.vim - が見つかりません。"
    endif
  endfor
endfunction
call s:check_settings_to_use_list(settings_to_use_list, s:settings_list)
" ---------------------------------------------------------------------- 
"  設定を読み込む 
"
function s:load_settings_to_use_list(user_list, settings_list)
  let dirs = [] 
  " ユーザの設定したリストから読み込むディレクトリの候補リストを作成
  for item in a:user_list 
    if has_key(a:settings_list, item)
       call add(dirs, a:settings_list[item])
    endif
  endfor
  " 候補リストを並び替える
  call sort(dirs)
  " 順に読み込む
  for dir in dirs
     call s:load_settings(dir)
  endfor
endfunction
call s:load_settings_to_use_list(settings_to_use_list, s:settings_list)








let &termencoding=&encoding
set encoding=utf-8

" 日本語の自動判別(iconv.dllを使用)
" http://www.kawaz.jp/pukiwiki/?vim#cb691f26
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " check iconv can use eucJP-ms
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " check iconv can use JISX0213
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodings
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  unlet s:enc_euc
  unlet s:enc_jis
endif
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      " let &fileencoding=&encoding
      set fileencoding=utf-8
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
set fileformats=unix,dos,mac
if exists('&ambiwidth')
  set ambiwidth=double
endif

" モードラインに文字コードや改行タイプを表示する
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P

" タブ幅の設定
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" インデント設定
set cindent
set autoindent
"
" vcall pathogen#infect()
" vcall pathogen#helptags()
" vsyntax on
" vfiletype plugin indent on



" ----------------------------------------------------------------------

" "unite prefix key.
" nnoremap [unite] <Nop>
" nmap <Space>f [unite]
" 
" "unite general settings
" "インサートモードで開始
" let g:unite_enable_start_insert = 1
" "最近開いたファイル履歴の保存数
" let g:unite_source_file_mru_limit = 50
" 
" "file_mruの表示フォーマットを指定。空にすると表示スピードが高速化される
" let g:unite_source_file_mru_filename_format = ''
" 
" "現在開いているファイルのディレクトリ下のファイル一覧。
" "開いていない場合はカレントディレクトリ
" nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" "バッファ一覧
" nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
" "レジスタ一覧
" nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>
" "最近使用したファイル一覧
" nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
" "ブックマーク一覧
" nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>
" "ブックマークに追加
" nnoremap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>
" "uniteを開いている間のキーマッピング
" autocmd FileType unite call s:unite_my_settings()
" function! s:unite_my_settings()"{{{
" 	"ESCでuniteを終了
" 	nmap <buffer> <ESC> <Plug>(unite_exit)
" 	"入力モードのときjjでノーマルモードに移動
" 	imap <buffer> jj <Plug>(unite_insert_leave)
" 	"入力モードのときctrl+wでバックスラッシュも削除
" 	imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
" 	"ctrl+jで縦に分割して開く
" 	nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
" 	inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
" 	"ctrl+jで横に分割して開く
" 	nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
" 	inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
" 	"ctrl+oでその場所に開く
" 	nnoremap <silent> <buffer> <expr> <C-o> unite#do_action('open')
" 	inoremap <silent> <buffer> <expr> <C-o> unite#do_action('open')
" endfunction"}}}
" 
" " howm ------------------------------------
" " qfixappにruntimepathを通す(パスは環境に合わせてください)
" "set runtimepath+=c:/temp/qfixapp
" 
" " キーマップリーダー
" "let QFixHowm_Key = 'g'
" 
" " howm_dirはファイルを保存したいディレクトリを設定
" let howm_dir             = '$HOME/howm'
" let howm_filename        = '%Y/%m/%Y-%m-%d-%H%M%S.txt'
" let howm_fileencoding    = 'cp932'
" let howm_fileformat      = 'dos'


" 改行したらコメント文字が引き続き挿入されるのを阻止する
" http://d.hatena.ne.jp/hyuki/20140122/vim
"   https://gist.github.com/rbtnn/8540338 （一部修正）
augroup auto_comment_off
	autocmd!
	autocmd BufEnter * setlocal formatoptions-=r
	autocmd BufEnter * setlocal formatoptions-=o
augroup END




" 勝手な改行をなくす
"   http://kaworu.jpn.org/kaworu/2007-07-29-1.php
set textwidth=0
" Kaoriya版Vimでtxtファイルの自動改行を無くす
"   http://chroju89.hatenablog.jp/entry/2013/07/23/220013
autocmd FileType text setlocal textwidth=0



" ---------------------------------------------------------------------- 
"   Pthogen
" ---------------------------------------------------------------------- 
"call pathogen#runtime_append_all_bundles()


" http://vim.wikia.com/wiki/List_loaded_scripts
" Execute 'cmd' while redirecting output.
" Delete all lines that do not match regex 'filter' (if not empty).
" Delete any blank lines.
" Delete '<whitespace><number>:<whitespace>' from start of each line.
" Display result in a scratch buffer.
function! s:Filter_lines(cmd, filter)
  let save_more = &more
  set nomore
  redir => lines
  silent execute a:cmd
  redir END
  let &more = save_more
  new
  setlocal buftype=nofile bufhidden=hide noswapfile
  put =lines
  g/^\s*$/d
  %s/^\s*\d\+:\s*//e
  if !empty(a:filter)
    execute 'v/' . a:filter . '/d'
  endif
  0
endfunction
command! -nargs=? Scriptnames call s:Filter_lines('scriptnames', <q-args>)


"The following is a more generic function allowing you to view any ex command in a scratch buffer:
" http://vim.wikia.com/wiki/List_loaded_scripts

function! s:Scratch (command, ...)
   redir => lines
   let saveMore = &more
   set nomore
   execute a:command
   redir END
   let &more = saveMore
   call feedkeys("\<cr>")
   new | setlocal buftype=nofile bufhidden=hide noswapfile
   put=lines
   if a:0 > 0
      execute 'vglobal/'.a:1.'/delete'
   endif
   if a:command == 'scriptnames'
      %substitute#^[[:space:]]*[[:digit:]]\+:[[:space:]]*##e
   endif
   silent %substitute/\%^\_s*\n\|\_s*\%$
   let height = line('$') + 3
   execute 'normal! z'.height."\<cr>"
   0
endfunction
 
command! -nargs=? Scriptnames call <sid>Scratch('scriptnames', <f-args>)
command! -nargs=+ Scratch call <sid>Scratch(<f-args>)

