#!/usr/bin/env bun
/**
 * Generate fish completions for the `claude` CLI (Claude Code).
 *
 * The CLI ships no completion generator, so this walks `claude --help`
 * recursively and turns the Commander.js help output into `complete -c claude`
 * lines. Run it again after `claude update`:
 *
 *   ./scripts/gen-claude-completion.ts > completions/claude.fish
 */
import { $ } from "bun";

// ---------------------------------------------------------------- model

type Opt = {
  short?: string;
  longs: string[];
  arg?: string;
  desc: string;
  choices?: string[];
};

type Cmd = {
  path: string[];
  aliases: string[];
  desc: string;
  opts: Opt[];
  subs: Cmd[];
};

type ValueHint =
  | { kind: "values"; values: string[] }
  | { kind: "dirs" }
  | { kind: "files" }
  | { kind: "func"; fn: string };

// ---------------------------------------------------------------- hints

// Values that `--help` does not expose but that are cheap to complete offline.
// Keep this table small: everything here has to be maintained by hand.
const MODELS = [
  "fable",
  "opus",
  "sonnet",
  "haiku",
  "claude-fable-5",
  "claude-opus-5",
  "claude-sonnet-5",
  "claude-haiku-4-5-20251001",
];

const OPTION_HINTS: Record<string, ValueHint> = {
  model: { kind: "values", values: MODELS },
  "fallback-model": { kind: "values", values: MODELS },
  effort: { kind: "values", values: ["low", "medium", "high", "xhigh", "max"] },
  agent: { kind: "func", fn: "__fish_claude_agents" },
  "add-dir": { kind: "dirs" },
  "plugin-dir": { kind: "dirs" },
  cwd: { kind: "dirs" },
  settings: { kind: "files" },
  "mcp-config": { kind: "files" },
  "debug-file": { kind: "files" },
  config: { kind: "files" },
  file: { kind: "files" },
};

const POSITIONAL_HINTS: Record<string, ValueHint> = {
  install: { kind: "values", values: ["stable", "latest"] },
  "plugin details": { kind: "func", fn: "__fish_claude_plugins" },
  "plugin disable": { kind: "func", fn: "__fish_claude_plugins" },
  "plugin enable": { kind: "func", fn: "__fish_claude_plugins" },
  "plugin uninstall": { kind: "func", fn: "__fish_claude_plugins" },
  "plugin update": { kind: "func", fn: "__fish_claude_plugins" },
  "plugin marketplace remove": { kind: "func", fn: "__fish_claude_marketplaces" },
  "plugin marketplace update": { kind: "func", fn: "__fish_claude_marketplaces" },
};

// ---------------------------------------------------------------- parsing

/** Split a help page into its `Options:` / `Commands:` blocks. */
function sections(help: string): Map<string, string[]> {
  const out = new Map<string, string[]>();
  let cur: string | null = null;
  for (const line of help.split("\n")) {
    const m = line.match(/^([A-Z][A-Za-z ]*):$/);
    if (m) {
      cur = m[1]!;
      out.set(cur, []);
      continue;
    }
    if (cur) out.get(cur)!.push(line);
  }
  return out;
}

function parseChoices(desc: string): string[] | undefined {
  const m = desc.match(/\(choices:\s*(.+?)(?:,\s*(?:preset|default):[^)]*)?\)/);
  if (!m) return undefined;
  const vals = [...m[1]!.matchAll(/"([^"]*)"/g)].map((x) => x[1]!);
  return vals.length ? vals : undefined;
}

function parseOptions(lines: string[]): Opt[] {
  // An entry starts at exactly two spaces followed by a dash; anything more
  // indented continues the previous entry's description.
  const entries: string[][] = [];
  for (const line of lines) {
    if (!line.trim()) continue;
    if (/^ {2}-/.test(line)) entries.push([line.slice(2)]);
    else if (entries.length) entries[entries.length - 1]!.push(line.trim());
  }

  const opts: Opt[] = [];
  for (const entry of entries) {
    const head = entry[0]!;
    const sep = head.search(/ {2,}/);
    const spec = (sep === -1 ? head : head.slice(0, sep)).trim();
    const descParts = sep === -1
      ? entry.slice(1)
      : [head.slice(sep).trim(), ...entry.slice(1)];
    const desc = descParts.join(" ").replace(/\s+/g, " ").trim();

    // The argument placeholder is always attached to the last flag token.
    const am = spec.match(/\s+([<[].*)$/);
    const arg = am ? am[1]!.trim() : undefined;
    const flags = (am ? spec.slice(0, am.index) : spec).trim();

    const tokens = flags.split(",").map((t) => t.trim()).filter(Boolean);
    const longs = tokens.filter((t) => t.startsWith("--")).map((t) => t.slice(2));
    const short = tokens.find((t) => /^-[^-]$/.test(t))?.slice(1);
    if (!longs.length && !short) continue;

    opts.push({ short, longs, arg, desc, choices: parseChoices(desc) });
  }
  return opts;
}

type SubRef = { name: string; aliases: string[]; desc: string };

/**
 * Pull subcommand names out of a `Commands:` block.
 *
 * `claude mcp --help` embeds a multi-line example block inside the description
 * of `add`, so the name token is constrained and every remaining token before
 * the description must be a bracketed placeholder.
 */
function parseCommands(lines: string[]): SubRef[] {
  const re =
    /^ {2}([a-z][a-z0-9-]*(?:\|[a-z0-9-]+)*)((?:\s+(?:\[[^\]]*\]|<[^>]*>))*)(?:(\s{2,})(.*))?$/;
  const subs: SubRef[] = [];
  let descCol = -1;
  for (const line of lines) {
    const m = line.match(re);
    if (m) {
      const [name, ...aliases] = m[1]!.split("|");
      descCol = m[4] === undefined
        ? -1
        : 2 + m[1]!.length + m[2]!.length + m[3]!.length;
      if (name === "help") {
        descCol = -1;
        continue;
      }
      subs.push({ name: name!, aliases, desc: (m[4] ?? "").trim() });
      continue;
    }
    // A wrapped description sits at or past the description column; the example
    // block inside `claude mcp add`'s help is indented far to the left of it.
    const last = subs[subs.length - 1];
    if (last && descCol > 0 && line.length > descCol &&
      !line.slice(0, descCol).trim()
    ) {
      last.desc = `${last.desc} ${line.trim()}`.trim();
    }
  }
  return subs;
}

/** Guard against a mis-parsed name: the help page must be for this exact path. */
function usageMatches(help: string, path: string[]): boolean {
  const first = help.split("\n")[0] ?? "";
  const m = first.match(/^Usage:\s+claude\s*(.*)$/);
  if (!m) return false;
  const toks = m[1]!
    .split(/\s+/)
    .filter((t) => t && !t.startsWith("[") && !t.startsWith("<"));
  if (toks.length < path.length) return false;
  return path.every((seg, i) => (toks[i] ?? "").split("|").includes(seg));
}

// ---------------------------------------------------------------- walking

let inFlight = 0;
const queue: (() => void)[] = [];

/** Cap concurrent `claude` spawns; the binary is 263MB. */
async function limited<T>(fn: () => Promise<T>): Promise<T> {
  if (inFlight >= 6) await new Promise<void>((r) => queue.push(r));
  inFlight++;
  try {
    return await fn();
  } finally {
    inFlight--;
    queue.shift()?.();
  }
}

async function walk(
  path: string[],
  aliases: string[],
  desc: string,
): Promise<Cmd | null> {
  const res = await limited(() => $`claude ${path} --help`.nothrow().quiet());
  if (res.exitCode !== 0) return null;
  const text = res.stdout.toString();
  if (!usageMatches(text, path)) return null;

  const secs = sections(text);
  const opts = parseOptions(secs.get("Options") ?? []);
  const refs = parseCommands(secs.get("Commands") ?? []);
  const subs = (
    await Promise.all(
      refs.map((r) => walk([...path, r.name], r.aliases, r.desc)),
    )
  ).filter((c): c is Cmd => c !== null);

  return { path, aliases, desc, opts, subs };
}

// ---------------------------------------------------------------- emitting

/** Quote for fish single-quoted strings. */
function q(s: string): string {
  return "'" + s.replace(/\\/g, "\\\\").replace(/'/g, "\\'") + "'";
}

function shorten(d: string): string {
  const s = d.replace(/\s+/g, " ").trim();
  return s.length > 90 ? s.slice(0, 89).trimEnd() + "…" : s;
}

function valueFlags(hint: ValueHint): string[] {
  switch (hint.kind) {
    case "values":
      return ["-x", "-a", q(hint.values.join(" "))];
    case "dirs":
      return ["-x", "-a", q("(__fish_complete_directories)")];
    case "files":
      return ["-r", "-F"];
    case "func":
      return ["-x", "-a", q(`(${hint.fn})`)];
  }
}

const PREAMBLE = `# Helpers ---------------------------------------------------------------

function __fish_claude_agents -d 'Agent names from ~/.claude/agents and ./.claude/agents'
    for dir in ~/.claude/agents .claude/agents
        set -l files $dir/*.md
        test (count $files) -gt 0; or continue
        string replace -r '\\\\.md$' '' -- (path basename $files)
    end
end

function __fish_claude_plugins -d 'Installed plugins as name@marketplace'
    command -q jq; or return
    set -l f ~/.claude/plugins/installed_plugins.json
    test -f $f; or return
    jq -r '.plugins // {} | keys[]' $f 2>/dev/null
end

function __fish_claude_marketplaces -d 'Configured plugin marketplaces'
    command -q jq; or return
    set -l f ~/.claude/plugins/known_marketplaces.json
    test -f $f; or return
    jq -r 'keys[]' $f 2>/dev/null
end

# Every \`complete\` below tests the same condition, so the path is resolved once
# per command line and cached instead of once per candidate.
function __fish_claude_resolve -d 'Cache the canonical subcommand path typed so far'
    set -l tokens (commandline -opc)
    set -l key (string join \\x1f -- $tokens)
    test "$key" = "$__fish_claude_key"; and return
    set -e tokens[1]
    set -l path ''
    for t in $tokens
        string match -qr '^-' -- $t; and continue
        set -l next (__fish_claude_child "$path" "$t")
        test -n "$next"; and set path "$next"
    end
    set -g __fish_claude_key $key
    set -g __fish_claude_path $path
end

function __fish_claude_at -d 'Test the current subcommand path against the arguments'
    __fish_claude_resolve
    contains -- "$__fish_claude_path" $argv
end
`;

/** Per-level alias resolution, so `plugins`/`rm`/`i` land on the canonical path. */
function emitChildFn(root: Cmd): string {
  const out: string[] = [
    "function __fish_claude_child -d 'Resolve a token to a canonical subcommand path'",
    "    switch \"$argv[1]\"",
  ];
  const visit = (cmd: Cmd) => {
    if (cmd.subs.length) {
      const p = cmd.path.join(" ");
      out.push(`        case ${p === "" ? "''" : q(p)}`);
      out.push('            switch "$argv[2]"');
      for (const s of cmd.subs) {
        const names = [s.path[s.path.length - 1]!, ...s.aliases];
        out.push(`                case ${names.map(q).join(" ")}`);
        out.push(`                    echo ${q(s.path.join(" "))}`);
      }
      out.push("            end");
    }
    for (const s of cmd.subs) visit(s);
  };
  visit(root);
  out.push("    end", "end");
  return out.join("\n");
}

function emitNode(cmd: Cmd, out: string[]): void {
  const p = cmd.path.join(" ");
  const cond = `__fish_claude_at ${p === "" ? '""' : `"${p}"`}`;
  const label = p === "" ? "claude" : `claude ${p}`;
  out.push("", `# ${label}`);

  for (const s of cmd.subs) {
    const name = s.path[s.path.length - 1]!;
    const line = ["complete", "-c", "claude", "-n", q(cond), "-a", q(name)];
    if (s.desc) line.push("-d", q(shorten(s.desc)));
    out.push(line.join(" "));
  }

  const positional = POSITIONAL_HINTS[p];
  if (positional) {
    out.push(
      ["complete", "-c", "claude", "-n", q(cond), ...valueFlags(positional)]
        .join(" "),
    );
  }

  for (const o of cmd.opts) {
    const base = ["complete", "-c", "claude", "-n", q(cond)];
    if (o.short) base.push("-s", o.short);
    for (const l of o.longs) base.push("-l", l);

    const hint: ValueHint | undefined = o.choices
      ? { kind: "values", values: o.choices }
      : o.arg
      ? o.longs.map((l) => OPTION_HINTS[l]).find(Boolean)
      : undefined;
    const flags = hint ? valueFlags(hint) : [];
    const candidates = flags.includes("-a");

    // Candidates go on their own line: a `complete` carrying both `-a` and `-d`
    // repeats the option's description once per value in the menu.
    if (candidates) out.push([...base, ...flags].join(" "));

    const tail = candidates
      ? ["-x"]
      : flags.length
      ? flags
      // `[optional]` arguments stay unmarked so fish keeps offering subcommands.
      : o.arg?.startsWith("<")
      ? ["-r"]
      : [];
    out.push([...base, ...(o.desc ? ["-d", q(shorten(o.desc))] : []), ...tail].join(" "));
  }

  for (const s of cmd.subs) emitNode(s, out);
}

// ---------------------------------------------------------------- main

const version = (await $`claude --version`.quiet().text()).trim().split(/\s+/)[0];
const root = await walk([], [], "");
if (!root) {
  console.error("failed to parse `claude --help`");
  process.exit(1);
}

const today = new Date().toISOString().slice(0, 10);
const out: string[] = [
  `# fish completions for the claude CLI (Claude Code).`,
  `#`,
  `# Generated from claude ${version} on ${today}.`,
  `# Do not edit by hand - run \`task gen-claude-completion\` after \`claude update\`.`,
  "",
  "complete -c claude -f",
  "",
  PREAMBLE,
  emitChildFn(root),
];
emitNode(root, out);
console.log(out.join("\n"));
