# Mimic Tim Pope’s Vim surround plugin
# When in normal mode, use:
# - cs (change surrounding)
# - ds (delete surrounding)
# - ys (add surrounding)

autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround

# Text objects for brackets and quotes
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $km -- $c select-bracketed
    done
    for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
        bindkey -M $km -- $c select-quoted
    done
done