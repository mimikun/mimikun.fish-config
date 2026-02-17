# dotnet-core completions
if command -q dotnet
  complete -f -c dotnet -a "(dotnet complete)"
end

# inshellisense
if test -f "$HOME/.inshellisense/key-bindings.fish"
  source "$HOME/.inshellisense/key-bindings.fish"
end

# Linuxbrew
if command -q brew
  /home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source
end

# mise config
if command -q mise
  mise activate fish | source
end

# starship
if test "$USE_SHELL_PROMPT" = "starship"
  if command -q starship
    starship init fish --print-full-init | source
  end
end

# oh-my-posh
if test "$USE_SHELL_PROMPT" = "oh-my-posh"
  if command -q oh-my-posh
    oh-my-posh init fish --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/tokyonight_storm.omp.json' | source
  end
end

# pay-respects
if command -q pay-respects
  pay-respects fish --alias | source
end

# jujutsu
if command -q jj
  jj util completion fish | source
end

# go-task
if command -q task
  task --completion fish | source
end

# jump
if command -q jump
  jump shell fish | source
end

# wtp
if command -q wtp
  wtp shell-init fish | source
end

# handler
if command -q handler
  _HANDLER_COMPLETE=fish_source handler | source
end

# worktrunk
if command -q wt
  wt config shell init fish | source
end

# git-wt
if command -q git-wt
  git wt --init fish | source
end

# atuin
if command -q atuin
  atuin init fish | source
end

# x-cmd
if test -f "$HOME/.x-cmd.root/local/data/fish/rc.fish"
  source "$HOME/.x-cmd.root/local/data/fish/rc.fish"
end

# TODO: WORK IN PROGRESS
# If you can enable zeno feature, run `set -Ux USE_ZENO true`
# disable zeno feature, run `set -e USE_ZENO`
if set -q USE_ZENO
  if test "$ZENO_LOADED" = "1"
    bind space zeno-auto-snippet
    bind -M insert space zeno-auto-snippet
    bind \r zeno-auto-snippet-and-accept-line
    bind -M insert \r zeno-auto-snippet-and-accept-line
    bind \t zeno-completion
    bind -M insert \t zeno-completion
    bind \cx\x20 zeno-insert-space
    bind -M insert \cx\x20 zeno-insert-space
  end
end

# TODO: it
#{{ if (isExecutable "/usr/local/bin/this_is_work_pc") -}}
if command -q this_is_work_pc
  #cat $XDG_CONFIG_HOME/{{ (rbwFields "dotfiles-chezmoi").source_work_pc_only_tool_fish_1.value }} | source
else
  # nix activate script
  source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
  set -gx PATH $HOME/.nix-profile/bin $PATH
end
#{{ end -}}

# TODO: WORK IN PROGRESS
# NOTE: NEED end of config file!
# see: https://github.com/ajeetdsouza/zoxide#installation
zoxide init fish | source

# vim:ft=fish

