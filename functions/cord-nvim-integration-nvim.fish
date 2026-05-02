function cord-nvim-integration-nvim
  if not pidof socat > /dev/null 2>&1
    if test -e /tmp/discord-ipc-0
      rm -f /tmp/discord-ipc-0
    end
    socat UNIX-LISTEN:/tmp/discord-ipc-0,fork \
      EXEC:"/mnt/c/Users/mimikun/npiperelay.exe //./pipe/discord-ipc-0" 2>/dev/null &
  end

  command nvim $argv
end
