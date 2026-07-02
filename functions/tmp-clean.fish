function tmp-clean --description 'Remove stale cargo-install temp dirs from /tmp'
    # Show usage before cleanup (percentage + used size)
    set -l before (df -h /tmp | tail -1 | awk '{print $5" ("$3")"}')

    # Target only cargo-install* leftovers that have been untouched for 30+ min.
    # The -mmin guard skips any build currently in progress, so this is safe to
    # run anytime without sudo and never touches your own work dirs in /tmp.
    find /tmp -maxdepth 1 -name 'cargo-install*' -type d -mmin +30 \
        -exec rm -rf {} + 2>/dev/null

    set -l after (df -h /tmp | tail -1 | awk '{print $5" ("$3")"}')
    echo "tmp: $before -> $after"
end
