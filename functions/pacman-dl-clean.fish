function pacman-dl-clean --description 'Remove stale interrupted-download temp files from the pacman cache'
    # Interrupted/parallel downloads leave orphaned `download-XXXXXX` temp files
    # in the pacman cache. `paru -Sc` can't parse them and spews
    # "could not open file .../download-XXXXXX: Error reading fd 7".
    # -mmin +5 skips any download still in progress, so this is safe to run anytime.
    sudo find /var/cache/pacman/pkg -maxdepth 1 -name 'download-*' -mmin +5 -delete
end
