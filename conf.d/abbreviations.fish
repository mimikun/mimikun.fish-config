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
if command -v chezmoi >/dev/null 2>&1
    abbr --add ccd "chezmoi cd"
    abbr --add chd "chezmoi cd"
    abbr --add chec "chezmoi cd"
    abbr --add cap "chezmoi apply"
    abbr --add chp "chezmoi apply"
    abbr --add chep "chezmoi apply"
end
 
# pueue
if command -v pueue >/dev/null 2>&1
    abbr --add pu pueue
    abbr --add puc "pueue clean -s"
    abbr --add pucf "pueue clean"
    abbr --add puf "pueue follow"
    abbr --add pul "pueue log"
    abbr --add pum "pueue | more"
    abbr --add puq "pueue enqueue"
end

# trashy
if command -v trashy >/dev/null 2>&1
    abbr --add trash "trashy"
end

# gh cli
if command -v gh >/dev/null 2>&1
    abbr --add ghview "gh repo view -w"
    abbr --add ghissue "gh issue ls"
end

# rage
if command -v rage >/dev/null 2>&1
    abbr --add ragee "rage -e -r $AGE_PUBKEY"
    abbr --add raged "rage -d -i ~/.age/key.txt"
end

 
# ls
# # TODO: config now
# ## eza
# if command -v eza >/dev/null 2>&1
#     abbr --add ls "eza --color=always --icons=always --group-directories-first"
#     abbr --add la "eza --color=always --icons=always --group-directories-first --all"
#     abbr --add l1 "eza --color=always --icons=always --group-directories-first --oneline"
# 
#     abbr --add ll "eza --color=always --icons=always --group-directories-first --long --header"
#     abbr --add lla "eza --color=always --icons=always --group-directories-first --long --header --all"
#     abbr --add ll1 "eza --color=always --icons=always --group-directories-first --long --header --oneline"
# 
#     abbr --add lt "eza --color=always --icons=always --group-directories-first --tree"
#     abbr --add lta "eza --color=always --icons=always --group-directories-first --tree --all"
#     abbr --add lt1 "eza --color=always --icons=always --group-directories-first --tree --oneline"
#     abbr --add llt "eza --color=always --icons=always --group-directories-first --tree --long --header"
# end
# 
# ## lla
# # TODO: config now
# #if command -v lla >/dev/null 2>&1
# #    abbr --add ls "lla --icons --sort-dirs-first --grid --no-dotfiles"
# #    abbr --add la "lla --icons --sort-dirs-first --grid"
# #    abbr --add l1 "lla --icons --sort-dirs-first --no-dotfiles"
# #
# #    abbr --add ll "lla --icons --sort-dirs-first --grid --no-dotfiles --long"
# #    abbr --add lla "lla --icons --sort-dirs-first --grid --long"
# #    abbr --add ll1 "lla --icons --sort-dirs-first --long"
# #
# #    abbr --add lt "lla --icons --sort-dirs-first --no-dotfiles --tree"
# #    abbr --add lta "lla --icons --sort-dirs-first --tree"
# #    abbr --add lt1 "lla --icons --sort-dirs-first --no-dotfiles --tree"
# #    abbr --add llt "lla --icons --sort-dirs-first --no-dotfiles --long --tree"
# #
# #    #Use table listing format
# #    #--table
# #    #Organized grid layout you can use `-g --grid-ignore` to ignore terminal width (Warning: may extend beyond screen)
# #    #--grid
# #    #Visual representation of file sizes
# #    #--sizemap
# #    #Group files by time periods
# #    #--timeline
# #    #Show git status and information
# #    #--git
# #    #Interactive fuzzy finder (Experimental)
# #    #--fuzzy
# #end
# 
# ## lsd
# # TODO: config now
# #if command -v lsd >/dev/null 2>&1
# #    abbr --add ls "lsd --color=always --icons=always --group-dirs=first"
# #    abbr --add la "lsd --color=always --icons=always --group-dirs=first --all"
# #    abbr --add l1 "lsd --color=always --icons=always --group-dirs=first --oneline"
# #
# #    abbr --add ls "lsd --color=always --icons=always --group-dirs=first --long --header"
# #    abbr --add lla "lsd --color=always --icons=always --group-dirs=first --long --header --all"
# #    abbr --add ll1 "lsd --color=always --icons=always --group-dirs=first --long --header --oneline"
# #
# #    abbr --add lt "lsd --color=always --icons=always --group-dirs=first --tree"
# #    abbr --add lta "lsd --color=always --icons=always --group-dirs=first --tree --all"
# #    abbr --add lt1 "lsd --color=always --icons=always --group-dirs=first --tree --oneline"
# #    abbr --add llt "lsd --color=always --icons=always --group-dirs=first --tree --long --header"
# #end
 
# # WSL only abbrs
# {{ if (ne .chezmoi.hostname "azusa") -}}
# abbr --add open wsl-open
# {{ end -}}
