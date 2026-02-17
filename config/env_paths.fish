# hostname
set --local HOST_NAME (cat /etc/hostname | tr [:upper:] [:lower:])

# Global
set -gx LANG "en_US.UTF-8"
set -gx LC_ALL "en_US.UTF-8"
set -gx GHQ_ROOT $HOME/ghq
set -gx GHQ_SELECTOR fzf
set -gx PIPENV_VENV_IN_PROJECT 1
set -gx TODAY (date +"%Y/%m/%d")
set -gx TZ "Asia/Tokyo"

## ls commands
# "eza", "lla", "lsd"
set -gx LS_CMD "eza"

## shell prompts
# "oh-my-posh", "starship", "tide", "hydro", pure-fish"
set -gx USE_SHELL_PROMPT "starship"

## neovim version manager
# "nvs", "bob"
set -gx USE_NVIM_VERSION_MANAGER "bob"

# XDG Base Directory
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state

# Fish paths
set -gx FISH_CONFIG_DIR $XDG_CONFIG_HOME/fish
set -gx FISH_COMPLETIONS_DIR $FISH_CONFIG_DIR/completions
set -gx FISH_FUNCTIONS_DIR $FISH_CONFIG_DIR/functions
set -gx FISH_CACHE_DIR $XDG_CACHE_HOME/fish

set -gx CONFIG_FISH $FISH_CONFIG_DIR/config.fish
set -gx CACHE_CONFIG_FISH $FISH_CACHE_DIR/config.fish

# Linux Laptop config
if test "$HOST_NAME" = "azusa"
#{{ if (eq .chezmoi.hostname "azusa") -}}
  set -gx GTK_IM_MODULE "fcitx"
  set -gx QT_IM_MODULE "fcitx"
  set -gx XMODIFIERS "@im=fcitx"
  setxkbmap -option ctrl:nocaps # CapsLock to Ctrl
  set -gx BROWSER "vivaldi"
else
#{{ else -}}
  set -gx BROWSER "wsl-open"
end
#{{ end -}}

## env-vars

# GITHUB_USERNAME
if command -q this_is_work_pc
#{{ if (isExecutable "/usr/local/bin/this_is_work_pc") }}
  #set -gx GITHUB_USERNAME "{{ (rbwFields "dotfiles-chezmoi").github_username.value }}"
else
#{{ else -}}
  set -gx GITHUB_USERNAME "mimikun"
end
#{{ end -}}

# WIN_HOME
if test "$HOST_NAME" = "wakamo"
#{{ if (eq .chezmoi.hostname "Wakamo") -}}
  set -gx WIN_HOME "/mnt/c/Users/mimikun"
else
#{{ else -}}
  #set -gx WIN_HOME "/mnt/c/Users/user_name"
  #set -gx WIN_HOME "/mnt/c/Users/{{ (rbwFields "dotfiles-chezmoi").windows_user_name.value }}"
end
#{{ end -}}

# OBSIDIAN_VAULT_ROOT
if test "$HOST_NAME" = "azusa"
#{{ if (eq .chezmoi.hostname "azusa") -}}
  set -gx OBSIDIAN_VAULT_ROOT "Obsidian/mimikun"
else if test "$HOST_NAME" = "wakamo"
  set -gx OBSIDIAN_VAULT_ROOT "Obsidian/mimikun"
#{{ else if (eq .chezmoi.hostname "Wakamo") -}}
else
#{{ else -}}
  #set -gx OBSIDIAN_VAULT_ROOT "{{ (rbwFields "dotfiles-chezmoi").obsidian_vault_root_path.value }}"
end
#{{ end -}}

# LG_CONFIG_FILE
if test "$HOST_NAME" = "azusa"
#{{ if (eq .chezmoi.hostname "azusa") -}}
  set -gx LG_CONFIG_FILE "$XDG_CONFIG_HOME/lazygit/linux_config.yml"
else
#{{ else -}}
  set -gx LG_CONFIG_FILE "$XDG_CONFIG_HOME/lazygit/wsl_config.yml"
end
#{{ end -}}

set -gx WORKSPACE "$GHQ_ROOT/github.com/$GITHUB_USERNAME"
set -gx WORKSPACE_MIMIKUN "$GHQ_ROOT/github.com/mimikun"
set -gx NVIM_DEV_PLUGINS "$WORKSPACE_MIMIKUN/dev-plugins"

if test "$HOST_NAME" = "azusa"
#{{ if (eq .chezmoi.hostname "azusa") -}}
  set -gx obsidian_vault_root_path "$HOME/Documents/$OBSIDIAN_VAULT_ROOT"
else
#{{ else -}}
  set -gx windl "$WIN_HOME/Downloads"
  set -gx WIN_DESKTOP "$WIN_HOME/Desktop"
  set -gx WIN_DOCUMENTS "$WIN_HOME/Documents"
  set -gx obsidian_vault_root_path "$WIN_DOCUMENTS/$OBSIDIAN_VAULT_ROOT"
  set -gx DISPLAY ":0"
end
#{{ end -}}

# some services PATs
if command -q this_is_work_pc
#{{ if (isExecutable "/usr/local/bin/this_is_work_pc") }}
  #set -gx GITHUB_PAT "{{ (rbwFields "dotfiles-chezmoi").github_pat.value }}"
  #set -gx CODEBERG_PAT "{{ (rbwFields "dotfiles-chezmoi").codeberg_pat.value }}"
  #set -gx GITEA_PAT "{{ (rbwFields "dotfiles-chezmoi").gitea_pat.value }}"
end
#{{ end -}}

set -gx obsidian_vault_path $obsidian_vault_root_path
set -gx obsidian_dailynote_path $obsidian_vault_path/001_DailyNotes
set -gx obsidian $obsidian_dailynote_path
set --local dailynote_slug (date +"%Y年%m月%d日")
set -gx today_dailynote "$obsidian_dailynote_path/$dailynote_slug.md"

set -gx CHEZMOI_DIR "$XDG_DATA_HOME/chezmoi"

set -gx LOCALBIN $HOME/.local/bin

set -gx PATH /usr/bin $PATH
set -gx PATH /usr/local/bin $PATH
set -gx PATH /usr/local/sbin $PATH
set -gx PATH $HOME/go/bin $PATH
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/.local/bin $PATH

set -gx DENO_INSTALL $HOME/.deno
set -gx PATH $DENO_INSTALL/bin $PATH

# starship
if test "$USE_SHELL_PROMPT" = "starship"
  set -gx STARSHIP_CONFIG_DIR $XDG_CONFIG_HOME/starship
  set -gx STARSHIP_CONFIG $STARSHIP_CONFIG_DIR/starship.toml
  set -gx STARSHIP_CACHE $XDG_CACHE_HOME/starship
end

# tide
if test "$USE_SHELL_PROMPT" = "tide"
  set -gx TIDE_STYLE 'Classic'
  set -gx TIDE_PROMPT_COLORS 'True color'
  set -gx TIDE_CLASSIC_PROMPT_COLOR 'Light'
  set -gx TIDE_SHOW_TIME '24-hour format'
  set -gx TIDE_CLASSIC_PROMPT_SEPARATORS 'Angled'
  set -gx TIDE_POWERLINE_PROMPT_HEADS 'Round'
  set -gx TIDE_POWERLINE_PROMPT_TAILS 'Round'
  set -gx TIDE_POWERLINE_PROMPT_STYLE 'Two lines, character'
  set -gx TIDE_PROMPT_CONNECTION 'Disconnected'
  set -gx TIDE_POWERLINE_RIGHT_PROMPT_FRAME 'No'
  set -gx TIDE_PROMPT_CONNECTION_ANDOR_FRAME_COLOR 'Light'
  set -gx TIDE_PROMPT_SPACING 'Sparse'
  set -gx TIDE_ICONS 'Many icons'
  set -gx TIDE_TRANSIENT 'No'
end

# bob-nvim
if test "$USE_SHELL_PROMPT" = "bob"
  set -gx PATH "$XDG_DATA_HOME/bob/nvim-bin" $PATH
  set -gx BOB_CONFIG $XDG_CONFIG_HOME/bob/config.toml
end

# nvs
if test "$USE_SHELL_PROMPT" = "nvs"
  set -gx PATH "$NVS_BIN_DIR" $PATH
  set -gx NVS_BIN_DIR $XDG_DATA_HOME/nvs/bin
end

set -gx PATH /bin $PATH
set -gx PATH /usr/games $PATH
set -gx PATH /usr/sbin $PATH
set -gx PATH /usr/local/games $PATH
set -gx PATH /sbin $PATH
set -gx PATH /snap/bin $PATH
set -gx PATH $HOME/.fzf/bin $PATH
set -gx PATH $HOME/.local/bin/ $PATH
set -gx PATH $HOME/.npm-global/bin $PATH
set -gx PATH $HOME/.dotnet/tools/ $PATH
set -gx PATH $HOME/.gem/ruby/2.7.0/bin/ $PATH
set -gx PATH $HOME/depot_tools $PATH
set -gx PATH /usr/local/go/bin/ $PATH

set -gx EDITOR nvim
set -gx LESS "-R"
set -gx LESSCHARSET "utf-8"
set -gx PAGER less
set -gx GIT_PAGER less

# Bun
set -gx BUN_INSTALL $HOME/.bun
set -gx PATH $BUN_INSTALL/bin $PATH

# fly.io
set -gx FLYCTL_INSTALL $HOME/.fly
set -gx PATH $FLYCTL_INSTALL/bin $PATH

# pnpm
set -gx PNPM_HOME $XDG_DATA_HOME/pnpm
set -gx PATH "$PNPM_HOME" $PATH

# cabal config
set -gx PATH $HOME/.cabal/bin $PATH
set -gx PATH $HOME/.ghcup/bin $PATH

# https://github.com/antfu/ni config
if command -q ni
    set -gx NI_CONFIG_FILE $XDG_CONFIG_HOME/ni/.nirc
end

# codon config
if command -q
    set -gx PATH $HOME/.codon/bin $PATH
end

# Rye
set -gx PATH $HOME/.rye/shims $PATH

# luarocks
set -gx PATH $HOME/.luarocks/bin $PATH

set -gx LUA_PATH "/usr/local/share/lua/5.3/?.lua"
set -gx LUA_PATH "/usr/local/share/lua/5.3/?/init.lua" $LUA_PATH
set -gx LUA_PATH "/usr/local/lib/lua/5.3/?.lua" $LUA_PATH
set -gx LUA_PATH "/usr/local/lib/lua/5.3/?/init.lua" $LUA_PATH
set -gx LUA_PATH "./?.lua" $LUA_PATH
set -gx LUA_PATH "./?/init.lua" $LUA_PATH
set -gx LUA_PATH "$HOME/.luarocks/share/lua/5.3/?.lua" $LUA_PATH
set -gx LUA_PATH "$HOME/.luarocks/share/lua/5.3/?/init.lua" $LUA_PATH

set -gx LUA_CPATH "/usr/local/lib/lua/5.3/?.so"
set -gx LUA_CPATH "/usr/local/lib/lua/5.3/loadall.so" $LUA_CPATH
set -gx LUA_CPATH "./?.so" $LUA_CPATH
set -gx LUA_CPATH "$HOME/.luarocks/lib/lua/5.3/?.so" $LUA_CPATH

# aqua
set -gx AQUA_ROOT_DIR "$XDG_DATA_HOME/aqua"
set -gx AQUA_CONFIG_DIR "$XDG_CONFIG_HOME/aqua"
set -gx AQUA_BIN "$AQUA_ROOT_DIR/bin"
set -gx PATH $AQUA_BIN $PATH

set -gx AQUA_CONFIG "$AQUA_CONFIG_DIR/aqua.yaml"
set -gx AQUA_GLOBAL_CONFIG $AQUA_CONFIG
set -gx AQUA_POLICY_CONFIG "$AQUA_CONFIG_DIR/policy.yaml"
set -gx AQUA_DISABLE_POLICY true
set -gx AQUA_PROGRESS_BAR true
if test "$HOST_NAME" = "wakamo"
# Ryzen 7 9800X3D(8 Core 16 Thread)
  set -gx AQUA_MAX_PARALLELISM 3
else if test "$HOST_NAME" = "izuna"
  # Ryzen 9 3900X(12 Core 24 Thread)
  set -gx AQUA_MAX_PARALLELISM 5
else
  # Other
  set -gx AQUA_MAX_PARALLELISM 1
end
#set -gx AQUA_GITHUB_TOKEN "{{ (rbwFields "dotfiles-chezmoi").aqua_github_token.value }}"

# PHP composer
set -gx COMPOSER_CONFIG_HOME $XDG_CONFIG_HOME/composer
set -gx COMPOSER_BIN_DIR $COMPOSER_CONFIG_HOME/vendor/bin

set -gx PATH $COMPOSER_BIN_DIR $PATH

# Julia
set -gx PATH "$HOME/.juliaup/bin" $PATH

# mocword dict
set -gx MOCWORD_DATA "$XDG_CACHE_HOME/mocword.sqlite"

# Neovide env-vars

# nimble
set -gx PATH $HOME/.nimble/bin $PATH

# golang
set -gx GOPATH $HOME/go
set -gx GOBIN $GOPATH/bin
set -gx PATH $GOBIN $PATH

# zettelkasten
set -gx zettelkasten_root "$GHQ_ROOT/codeberg.org/mimikun/zettelkasten"

# forgit
set -gx PATH $FISH_CONFIG_DIR/conf.d/bin $PATH
set -gx FORGIT_NO_ALIASES true

# Claude Desktop
if test "$HOST_NAME" = "wakamo"
  set -gx CLAUDE_DESKTOP_PATH $WIN_HOME/AppData/Roaming/Claude.json
  set -gx CLAUDE_DESKTOP_CONFIG $CLAUDE_DESKTOP_PATH/claude_desktop_config.json
end

# depot
set -gx DEPOT_INSTALL_DIR "$HOME/.depot/bin"
set -gx PATH "$DEPOT_INSTALL_DIR" $PATH

# rebar3
if command -q rebar3
  set -gx PATH "$XDG_CACHE_HOME/rebar3/bin" $PATH
end

# age public keys
set -gx AGE_PUBKEY_HOME "age1cktdwc8u4z76kawluyswaruyeg7eg6078rw3t0kkmx5wqkk40d2qzajn8y"
set -gx AGE_PUBKEY_WORK "age1n03v0casqk2djs2jw3xq5ldpdjtp2s6r0u3uhtmd7zv9j2xuyf6qpl9x7l"
if command -q this_is_work_pc
#{{ if (isExecutable "/usr/local/bin/this_is_work_pc") -}}
  set -gx AGE_PUBKEY "$AGE_PUBKEY_HOME"
else
#{{ else -}}
  set -gx AGE_PUBKEY "$AGE_PUBKEY_WORK"
end
#{{ end -}}

# zoxide
if command -q zoxide
  # Linux/BSD
  set -gx _ZO_DATA_DIR "$XDG_DATA_HOME"
  # macOS
  #"$HOME/Library/Application Support"
  # When set to 1, `z` will print the matched directory before navigating to it.
  #set -gx _ZO_ECHO 1
  set -gx _ZO_EXCLUDE_DIRS "$HOME:$HOME/go/*"
  # Custom options to pass to [fzf] during interactive selection. See [`man fzf`][fzf-man] for the list of options.
  #set -gx _ZO_FZF_OPTS
  # Configures the [aging algorithm][algorithm-aging], which limits the maximum number of entries in the database.
  set -gx _ZO_MAXAGE 10000
  # When set to 1, `z` will resolve symlinks before adding directories to the database.
  #set -gx _ZO_RESOLVE_SYMLINKS 1
end

# vim:ft=fish

