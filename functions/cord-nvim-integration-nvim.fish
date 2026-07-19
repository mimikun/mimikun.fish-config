function cord-nvim-integration-nvim
  # Bridge the Discord IPC socket to the Windows side via npiperelay (WSL only).
  if command -q socat; and set -q WIN_HOME; and not pidof socat >/dev/null 2>&1
    rm -f /tmp/discord-ipc-0
    socat UNIX-LISTEN:/tmp/discord-ipc-0,fork \
      EXEC:"$WIN_HOME/npiperelay.exe //./pipe/discord-ipc-0" 2>/dev/null &
  end

  command nvim $argv
end
