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
if command -v mise >/dev/null 2>&1
    alias paleovim "$HOME/.local/share/mise/installs/vim/ref-master/bin/vim"
end

