# base
alias rm "rm -i"
alias mkdir "mkdir -p"
alias untar "tar xvf"
alias patch "patch -p1 <"

# other
alias imgcat "wezterm imgcat"
alias pip "python3 -m pip"
alias pipx "python3 -m pipx"

# mise
if command -q mise
  alias paleovim "$HOME/.local/share/mise/installs/vim/ref-master/bin/vim"
end

## ls cmds
# eza
if test "$LS_CMD" = "eza"
  if command -q eza
    alias ls "eza --color=always --icons=always --group-directories-first"
  end
end

# lla
if test "$LS_CMD" = "lla"
  if command -q lla
    alias ls "lla --icons --sort-dirs-first"
  end
end

# lsd
if test "$LS_CMD" = "lsd"
  if command -q lsd
    alias ls "lsd --help"
  end
end

# vim:ft=fish

