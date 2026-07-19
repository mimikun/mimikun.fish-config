function __cached_init --description 'Source a tool init script, caching its output until the tool changes'
    # Usage: __cached_init <tool> [args...]
    #
    # Tools like `task --completion fish` emit the same text every time, but
    # cost a full process launch on each shell start. Cache that output and
    # source the file instead.
    #
    # Only for commands whose output is static for a given tool version.
    # Anything that inspects the cwd or session (e.g. `mise hook-env`) must
    # keep running every time.

    if test (count $argv) -eq 0
        return 1
    end

    set -l tool_path (command -v $argv[1])
    if test -z "$tool_path"
        return 1
    end

    set -l cache_dir $FISH_CACHE_DIR/init
    if test -z "$FISH_CACHE_DIR"
        set cache_dir $HOME/.cache/fish/init
    end

    # Key on the command line *and* the binary's size/mtime, so upgrading the
    # tool invalidates the cache on its own -- no manual clearing needed.
    set -l stamp (stat -c '%s-%Y' "$tool_path" 2>/dev/null; or echo nostat)
    set -l key (string join ' ' -- $argv $stamp | md5sum | string split ' ')[1]
    set -l name (basename $argv[1])
    set -l cache_file "$cache_dir/$name-$key.fish"

    if test -s "$cache_file"
        source "$cache_file"
        return
    end

    set -l output ($argv 2>/dev/null)
    set -l rc $status

    # Never cache a failed or empty run: the plugin this replaces would happily
    # store half-written output and keep sourcing it forever.
    if test $rc -ne 0; or test (count $output) -eq 0
        echo "__cached_init: '$argv' failed (status $rc); skipping this init" >&2
        return 1
    end

    mkdir -p "$cache_dir"

    # Drop entries for older versions of this tool.
    for stale in "$cache_dir/$name-"*.fish
        rm -f "$stale"
    end

    # Write via a temp file so an interrupted write can't leave a partial cache.
    set -l tmp "$cache_file.$fish_pid.tmp"
    printf '%s\n' $output >"$tmp"; and mv -f "$tmp" "$cache_file"
    or begin
        rm -f "$tmp"
        printf '%s\n' $output | source
        return
    end

    source "$cache_file"
end
