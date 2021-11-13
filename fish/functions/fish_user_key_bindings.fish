function fish_user_key_bindings
  # peco
  bind \cr peco_select_history # Bind for peco select history to Ctrl+R
  bind \cl peco_change_directory # Bind for peco change directory to Ctrl+F

  # prevent iterm2 from closing when typing Ctrl-D (EOF)
  bind \cd delete-char

  # vim-like
  # bind \cf forward-char
  for mode in insert default visual
    bind -M $mode \cf forward-char
    bind -M $mode \cr peco_select_history # Bind for peco select history to Ctrl+R
    bind -M $mode \cl peco_change_directory # Bind for peco change directory to Ctrl+F
  end
end
