# mimikun.fish-config

## 起動速度 — 触る前に読むこと

対話シェルの起動は **3.56s → 0.50s** に落としてある（hyperfine 実測、WSL2）。
**元に戻しやすい形の変更が混ざっているので、下の理由を知らずに「整理」しないこと。**

### PATH を短くしても速くならない

**遅さの原因は PATH の *長さ* ではなく、`/mnt/c` が 9p/drvfs 越しで stat が遅いこと。**
重複除去は**一切効かなかった**。実測:

| PATH | 1 miss あたり |
|---|---|
| 172件（当時のまま） | 78.0ms |
| 115件（重複除去） | **79.1ms**（効果なし） |
| 77件（Windows は4件だけ残す） | 6.5ms |
| 73件（Windows 全除去） | 0.8ms |

→ `config/env_paths.fish` で **Windows 側を許可リスト化**した。残したのは
`system32` / `WINDOWS` / `$WIN_HOME/scoop/shims` / `$WIN_HOME/scoop/apps/gsudo/current`。

**Windows PATH を削って困るのは、fish で対話的に Windows コマンドを打つときだけ。**
心配になりやすい3つはいずれも fish の PATH に依存しない:

- `~/.wsl2-ssh-agent` は **systemd user service の Linux バイナリ**で、その PATH に `/mnt` は0件。
  `powershell.exe` はバイナリ内に絶対パス直書き（`-powershell-path` で変更可）
- cord-nvim の `npiperelay.exe` も `$WIN_HOME/` の絶対パス指定

### `functions/__cached_init.fish` が自作である理由

`kyohsuke/fish-evalcache` を最初は採用したが、**次の欠陥を実験で再現したので置き換えた。
再導入しないこと。**

- **終了ステータスを見ない。** `$argv > $cacheFile` を無条件実行するので、
  途中で失敗したツールの中途半端な出力がキャッシュされ、
  **ツールが直った後も永久に読まれ続ける**
- **キャッシュキーがコマンドラインのみ。** ツール更新で無効化されない
- `FISH_EVALCACHE_DISABLE=true` の分岐が `eval ($argv | source)` という無意味な式

自作版は **失敗・空出力ならキャッシュせず**、解決先バイナリの
**パス + サイズ + mtime をキーに含めて自動無効化**する。**手動クリアは要らない。**

対象は task / jump / wtp / git-wt の4つ（計 351ms）。キャッシュ先は `$FISH_CACHE_DIR/init`。

### キャッシュできないもの

- **`mise` は不可。** コストの実体は `hook-env` で、ディレクトリ連動なので毎回必要
- PWD イベントハンドラ（mise / jump / fnox / pitchfork / zoxide）はキャッシュ後も
  全て生存することを `functions --handlers` で確認済み

## `vim` と `vimc` は分けたまま

- `vim` → `nvim`（素の Neovim）
- `vimc` → `cord-nvim-integration-nvim`（Discord IPC 経由の cord.nvim 付き）

**cord.nvim を常に有効にしたいわけではないので、`vimc` は意図的な opt-in。**
**統合や、cord を既定にする提案をしない。**
