# See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes

cursor_block='\e[2 q'
cursor_underline='\e[4 q'
cursor_beam='\e[6 q'

function zle-keymap-select {
    case ${KEYMAP} in
        vicmd)      echo -ne $cursor_block ;;
        visual)     echo -ne $cursor_underline ;;
        viins|main) echo -ne $cursor_beam ;;
    esac
}

function zle-line-init {
    (( ${+terminfo[smkx]} )) && echoti smkx
    echo -ne $cursor_beam
}

function zle-line-finish {
    (( ${+terminfo[rmkx]} )) && echoti rmkx
}

zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish
