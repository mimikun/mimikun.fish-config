# Tool init scripts below are cached with fish-evalcache (a pez plugin), since
# re-running each one costs a subprocess on every shell start. Run
# `_evalcache_clear <tool>` after upgrading a tool, or `_evalcache_clear` for all.
#
# Only cache commands whose output is static for a given tool version. Anything
# that inspects the current directory or session (e.g. `mise hook-env`) must
# keep running every time.
if not functions -q _evalcache
  # Plugin not installed yet (fresh checkout before `pez install`): run directly.
  function _evalcache
    $argv | source
  end
end

# dotnet-core completions
if status is-interactive; and command -q dotnet
  complete -f -c dotnet -a "(dotnet complete)"
end

# inshellisense
if status is-interactive; and test -f "$HOME/.inshellisense/key-bindings.fish"
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
if test "$USE_SHELL_PROMPT" = "starship"; and status is-interactive
  if command -q starship
    starship init fish --print-full-init | source
  end
end

# oh-my-posh
if test "$USE_SHELL_PROMPT" = "oh-my-posh"; and status is-interactive
  if command -q oh-my-posh
    oh-my-posh init fish --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/tokyonight_storm.omp.json' | source
  end
end

# pay-respects
if status is-interactive; and command -q pay-respects
  pay-respects fish --alias | source
end

# jujutsu
if status is-interactive; and command -q jj
  jj util completion fish | source
end

# go-task
if status is-interactive; and command -q task
  _evalcache task --completion fish
end

# jump
if status is-interactive; and command -q jump
  _evalcache jump shell fish
end

# wtp
if status is-interactive; and command -q wtp
  _evalcache wtp shell-init fish
end

# handler (a Python CLI: ~1.5s of interpreter startup for 608 bytes of output).
# Export the var rather than wrapping in `env`, so the cache key is keyed on
# "handler" instead of a shared "env" entry.
if status is-interactive; and command -q handler
  set -lx _HANDLER_COMPLETE fish_source
  _evalcache handler
end

# worktrunk
if status is-interactive; and command -q wt
  wt config shell init fish | source
end

# git-wt
if status is-interactive; and command -q git-wt
  _evalcache git wt --init fish
end

# atuin
if status is-interactive; and command -q atuin
  atuin init fish | source
end

# fnox
if command -q fnox
  fnox activate fish | source
end

# pitchfork
if command -q pitchfork
  pitchfork activate fish | source
end

# kyushu is sourced by its installer-generated conf.d/kyushu-cli.env.fish

# x-cmd
if test -f "$HOME/.x-cmd.root/local/data/fish/rc.fish"
  source "$HOME/.x-cmd.root/local/data/fish/rc.fish"
end

# envman
if test -s "$HOME/.config/envman/load.fish"
  source "$HOME/.config/envman/load.fish"
end

# TODO: WORK IN PROGRESS
# If you can enable zeno feature, run `set -Ux USE_ZENO true`
# disable zeno feature, run `set -e USE_ZENO`
if set -q USE_ZENO; and status is-interactive
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
else if test -f /nix/var/nix/profiles/default/etc/profile.d/nix.fish
  # nix activate script
  source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
  fish_add_path --global $HOME/.nix-profile/bin
end
#{{ end -}}

# zoxide
if status is-interactive; and command -q zoxide
  zoxide init fish | source
end

# vim:ft=fish

