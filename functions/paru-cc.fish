function paru-cc --description 'Clean pacman/AUR cache: purge stale download-* temp files first, then paru -Sc (auto-confirm)'
    # Purge orphaned download-* temp files so `paru -Sc` runs without errors,
    # then clean the cache answering every prompt with Y via --noconfirm.
    pacman-dl-clean
    paru -Sc --noconfirm $argv
end
