function __mimikun_cdx -d "mimikun's cd Extended"
  set -l selector
  set -l uniq_cmd
  set -l selector_cmd

  if test -n "$GHQ_SELECTOR"
    set selector $GHQ_SELECTOR
  else
    set selector fzf
  end

  if not type -qf $selector
    printf "\nERROR: '$selector' not found.\n"
    return 1
  end

  switch "$selector"
    case fzf
      set selector_cmd fzf --layout=reverse --no-sort --height=~15 --query="$argv"
    case sk
      set selector_cmd sk --layout=reverse --no-sort --height=~15 --query="$argv"
    case peco percol
      set selector_cmd $selector --query "$argv"
    case '*'
      if test -n "$argv"
        set selector_cmd $selector --query="$argv"
      else
        set selector_cmd $selector
      end
  end

  # Select dedup command via USE_MIMIKUN_CDX_UNIQ (perl or awk, default: perl)
  if test "$USE_MIMIKUN_CDX_UNIQ" = awk
    set uniq_cmd awk '!seen[$0]++'
  else
    set uniq_cmd perl -ne 'print unless $seen{$_}++'
  end

  begin
    # 利用頻度の高い移動先一覧
    zoxide query --list

    # 使いたくなるかもしれない移動先一覧
    ghq list -p
    find "$HOME" -maxdepth 1 -type d
    find "$HOME/.config/nvim/lua" -maxdepth 1 -type d
    #find "$HOME/.local/share/nvim/lazy" -maxdepth 1 -type d
  end \
      | $uniq_cmd \
      | $selector_cmd \
      | read -l result
  and __zoxide_cd $result
  commandline -f repaint
end
