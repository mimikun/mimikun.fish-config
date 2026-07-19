# Tool init caching (`__cached_init`)

Many CLI tools ship a shell integration that you are meant to run at startup:

```fish
task --completion fish | source
```

Each of those is a full process launch on every shell start. They add up: on
this config they accounted for roughly 350ms combined. `__cached_init`
(`functions/__cached_init.fish`) runs such a command once, stores its output,
and sources the stored file on subsequent starts.

## Usage

```fish
# Before
if status is-interactive; and command -q task
  task --completion fish | source
end

# After
if status is-interactive; and command -q task
  __cached_init task --completion fish
end
```

Keep the surrounding `command -q` guard. `__cached_init` returns non-zero when
the tool is missing, but the guard keeps the intent obvious and avoids the call
entirely.

Current call sites are in `config/initialize.fish`: `task`, `jump`, `wtp` and
`git-wt`.

## What may be cached

**Only commands whose output is static for a given tool version.**

This is the one rule that matters, and getting it wrong breaks things silently.

| Safe | Not safe |
| --- | --- |
| `task --completion fish` | `mise hook-env -s fish` |
| `jump shell fish` | anything reading `$PWD` |
| `wtp shell-init fish` | anything reading the session, TTY or a timestamp |
| `git-wt --init fish` | anything that emits secrets or per-run tokens |

`mise` is the instructive case. `mise activate fish` looks cacheable, but the
cost it incurs is `mise hook-env`, which inspects the current directory and must
re-run on every prompt. Caching it would pin your environment to whatever
directory you happened to be in when the cache was written. It is deliberately
left uncached.

If you are unsure, run the command twice in different directories and diff the
output.

## Invalidation

The cache key is an md5 of the full command line **plus the resolved binary's
size and mtime**:

```
$FISH_CACHE_DIR/init/<tool>-<md5 of "argv size-mtime">.fish
```

Because the binary's stamp is part of the key, **upgrading a tool invalidates
its cache automatically**. There is no manual clear step in normal use. The same
mechanism covers a subtler case: if a different install of the same tool starts
winning in `PATH` (this config has both `~/go/bin/task` and
`~/.local/share/aqua/bin/task`), the resolved path changes, so the key changes.

When a new entry is written, superseded entries for the same tool are deleted,
so the directory does not grow over time.

To clear by hand — you should not normally need to:

```fish
rm -rf $FISH_CACHE_DIR/init
```

The next shell regenerates whatever it needs.

## Behaviour when things go wrong

The function is written so that a bad run cannot poison the cache.

| Situation | Behaviour |
| --- | --- |
| Tool exits non-zero | Warns on stderr, caches nothing, that one init is skipped for this shell |
| Tool produces no output | Same |
| Tool not found | Returns 1, silently |
| Cache dir not writable | Warns, sources the output directly, still works |
| Write interrupted | Output goes to a temp file and is `mv`'d into place, so a partial file is never sourced |

A skipped init means that tool's integration is absent for that session only;
the next shell retries. Nothing is written, so the failure cannot persist.

## Limitations

- **External commands only.** `command -v` returns nothing for fish functions,
  so `__cached_init myfunc` returns 1 without doing anything. This is fine for
  its purpose — functions are already in-process and cost nothing to define.
- **`stat -c` is GNU coreutils.** On a system without it the stamp falls back to
  the literal `nostat`, so caching still works but auto-invalidation does not.
  Everything here runs on Linux, so this is a graceful-degradation path rather
  than a supported configuration.
- **stdout only.** Anything a tool writes to stderr is not captured, which is
  the intent — init scripts emit shell code on stdout.

## Why not the fish-evalcache plugin

This config previously used `kyohsuke/fish-evalcache` and it was removed in
favour of the in-repo function. Two defects, both reproduced with test tools:

1. **It never checks whether the tool succeeded.** It runs
   `$argv > "$cacheFile"` unconditionally. A tool that prints a few lines and
   then fails leaves that partial output cached — and because nothing
   invalidates it, the broken cache is sourced on every subsequent start, even
   after the tool is fixed. A single transient failure is permanent.
2. **The cache key is the command line alone.** Upgrading a tool does not
   invalidate anything, which is why the plugin ships `_evalcache_clear` and
   expects you to remember to run it.

Its `FISH_EVALCACHE_DISABLE=true` escape hatch is also not usable: the branch
evaluates `eval ($argv | source)`, which is not a meaningful expression.

Keeping the function in-repo has a secondary benefit: plugin files under
`functions/` are gitignored and rewritten by `pez`, so depending on one meant
carrying a fallback shim for fresh checkouts. `__cached_init` is tracked and
always present.

## Measurements

Measured with `hyperfine --warmup 5 --runs 20 --shell=none 'fish -i -c exit'`
on Wakamo (WSL2), 2026-07-19:

| Stage | Startup |
| --- | --- |
| Before any work | 3.56s |
| After pruning the WSL interop `PATH` | 2.51s |
| After removing the unused `handler` init | ~0.85s |
| After init caching | **~0.5s** |

Indicative per-command costs, i.e. what caching avoids on each start:

| Command | Cost |
| --- | --- |
| `task --completion fish` | ~155ms |
| `wtp shell-init fish` | ~67ms |
| `git-wt --init fish` | ~66ms |
| `jump shell fish` | ~63ms |

Numbers move a little between runs depending on machine load; treat them as
orders of magnitude, not guarantees.

The largest single win was not caching at all — it was deleting the `handler`
completion init, which cost ~1.5s of Python interpreter startup to produce 608
bytes of output for a tool that was not being used. Check whether you still use
a tool before optimising its startup cost.

## Related

The other half of the startup work was pruning the WSL interop `PATH` down to an
allowlist, in `config/env_paths.fish`. WSL appends ~40 Windows directories that
live on the 9p/drvfs mount, which made every failed command lookup cost ~78ms.
See the comment there for details.
