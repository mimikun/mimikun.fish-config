# hostname
set --local HOST_NAME (cat /etc/hostname | tr [:upper:] [:lower:])

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

# vim is neovim
abbr --add vim nvim

# vim is paleovim
abbr --add pvim paleovim

# disable sudo rm
abbr --add --command sudo rm 'echo "sudo rm は使用禁止"'

# pueued.service manage shortcuts
abbr --add pueued_enable "systemctl --user enable pueue"
abbr --add pueued_start "systemctl --user start pueue"
abbr --add pueued_restart "systemctl --user restart pueue"

# emacs from CLI
abbr --add emacs "emacs --no-window-system"

# https://github.com/ryoppippi/na.fish
abbr --add n -f _na

# forgejo-cli is codeberg
abbr --add cb "fj --host codeberg.org"

# zellij
abbr --add zel zellij
 
# git subcommands
abbr --add --command git ls 'ls-files'
abbr --add --command git graph 'log-graph'
abbr --add --command git file-diff 'diff --name-only'
abbr --add --command git empty 'commit --allow-empty -nm'
abbr --add --command git commitn 'commit -nm'
abbr --add --command git commitan 'commit -anm'
abbr --add --command git amecomi 'commit --amend'
abbr --add --command git amecomin 'commit --amend --no-verify'
abbr --add --command git namecomi 'commit --amend --no-edit'
abbr --add --command git namecomin 'commit --amend --no-edit --no-verify'
abbr --add --command git cleanfetch 'fetch --all --prune --tags --prune-tags'
abbr --add --command git hash 'log --format=%H | sed -n 1p'
abbr --add --command git shallow-clone 'clone --depth 1'
abbr --add --command git staged 'diff --cached'
 
# chezmoi
if command -q chezmoi
  abbr --add ccd "chezmoi cd"
  abbr --add chd "chezmoi cd"
  abbr --add chec "chezmoi cd"
  abbr --add cap "chezmoi apply"
  abbr --add chp "chezmoi apply"
  abbr --add chep "chezmoi apply"
end
 
# pueue
if command -q pueue
  abbr --add pu pueue
  abbr --add puc "pueue clean -s"
  abbr --add pucf "pueue clean"
  abbr --add puf "pueue follow"
  abbr --add pul "pueue log"
  abbr --add pum "pueue | more"
  abbr --add puq "pueue enqueue"
end

# trashy
if command -q trashy
  abbr --add trash "trashy"
end

# gh cli
if command -q gh
  abbr --add ghview "gh repo view -w"
  abbr --add ghissue "gh issue ls"
end

# rage
if command -q rage
  abbr --add ragee "rage -e -r $AGE_PUBKEY"
  abbr --add raged "rage -d -i ~/.age/key.txt"
end

# open is wsl-open, when using WSL
if test "$HOST_NAME" != "azusa"
  abbr --add open wsl-open
end

## ls cmds
# eza
if test "$LS_CMD" = "eza"
  if command -q eza
    alias ls "eza --color=always --icons=always --group-directories-first"
    abbr --add la  "ls --all"
    abbr --add l1  "ls --oneline"

    abbr --add ll  "ls --long --header"
    abbr --add lla "ls --long --header --all"
    abbr --add ll1 "ls --long --header --oneline"

    abbr --add lt  "ls --tree"
    abbr --add lta "ls --tree --all"
    abbr --add lt1 "ls --tree --oneline"
    abbr --add llt "ls --tree --long --header"
  end
end

# lla
if test "$LS_CMD" = "lla"
  if command -q lla
    alias ls "lla --icons --sort-dirs-first"
    abbr --add ls  "ls --grid --no-dotfiles"
    abbr --add la  "ls --grid"
    abbr --add l1  "ls --no-dotfiles"
    
    abbr --add ll  "ls --grid --no-dotfiles --long"
    abbr --add lla "ls --grid --long"
    abbr --add ll1 "ls --long"
    
    abbr --add lt  "ls --no-dotfiles --tree"
    abbr --add lta "ls --tree"
    abbr --add lt1 "ls --no-dotfiles --tree"
    abbr --add llt "ls --no-dotfiles --long --tree"
    
    # TODO: mada
    #Use table listing format
    #--table
    #Organized grid layout you can use `-g --grid-ignore` to ignore terminal width (Warning: may extend beyond screen)
    #--grid
    #Visual representation of file sizes
    #--sizemap
    #Group files by time periods
    #--timeline
    #Show git status and information
    #--git
    #Interactive fuzzy finder (Experimental)
    #--fuzzy
  end
end

# lsd
if test "$LS_CMD" = "lsd"
  if command -q lsd
    alias ls "lsd --help"
    # TODO: mada
    #abbr --add ls  "ls --grid --no-dotfiles"
  end
end

# vim:ft=fish

