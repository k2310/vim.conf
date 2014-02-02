" ---------------------------------------------------------------------- 
"   SKK
" ---------------------------------------------------------------------- 
let skk_large_jisyo = $VIM_CONF_VIMFILES . '/skk/SKK-JISYO.L'
let skk_jisyo = '~/.skk-jisyo-vim'
let skk_auto_save_jisyo = 1
let skk_keep_state = 0
let skk_egg_like_newline = 1
let skk_show_annotation = 1
let skk_use_face = 1

" IMEをデフォルトでオフにする
set imdisable
" set iminsert=0
" set imsearch=-1
"IMEデフォルトOFF(挿入・検索モード)
set iminsert=0
set imsearch=0


" SKK本体を読み込む
runtime skk/skk.vim
