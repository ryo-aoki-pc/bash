# bash README の検証記録

以下は既存文書から移した記録。本文の「本書」「この文書」と手順番号は、記録元の手順書を指す。新しく検証した記録ではない。

導入手順は [README](../../README.md) から参照する。

### 読むものの実測

- 履歴と `shopt`・Homebrew の補完・fzf の 4 つは、2026-10-02 に x86_64 のコンテナで確かめた。2026-10-06 に Windows の Git Bash でも履歴・`shopt`・fzf と fd を確かめた（Homebrew の補完と bat のプレビュー、fzf の実際のキー操作は未確認。[docs/install.md の付録](install.md#付録-windows-ホストでの設定の再検証2026-10-06)）

### 読むものの実測

Windows 11 の PC の Git Bash（ツールは scoop で入れたもの）で確かめた、AlmaLinux 10 との違い（2026-10-01。[docs/install.md の付録](install.md#付録-windows-11-の-git-bash-での検証記録2026-10-01)）:

### 読むものの実測

- 2026-10-02 に足した履歴と `shopt`・fzf・fd の `FZF_*` は、2026-10-06 に Git Bash で確かめた。`fzf --bash` がキーと補完を登録し、読み直しても `bind -X`・`PROMPT_COMMAND`・`PS0` は変わらなかった。Homebrew の補完と bat のプレビュー、キーを実際に押す動作は未確認（[付録](install.md#付録-windows-ホストでの設定の再検証2026-10-06)）

### 読むものの実測

- ツールの有無を確かめる `command -v` は、PATH を順に探すので 1 回に約 2ms かかる（検証した PC の 37 要素の PATH。2026-10-01 のこの設定は 8 回）。対話のシェルの起動は、`~/.bashrc` に直に書いていたときより 10〜40ms 長い（測るたびに揺れた）

### 読むものの実測

root のシェル（docs/install.md の[root のシェルでも読む](../install.md#root-のシェルでも読む任意)）で確かめたこと（2026-10-05、x86_64 のコンテナ。[docs/install.md の付録](install.md#付録-root-のシェルでも読む節の検証記録2026-10-05)）。2026-10-06 には新規 x86_64 VM でも root 自身の初回・再実行と実対話シェルの読み込みを確認した（[新規 VM の記録](quick-start.md#新規-almalinux-vm-での再検証2026-10-06)）。以下のソケット・各ツールの組み合わせの記録はコンテナの結果:

### 読むものの実測

- Windows 11 の Git Bash では、2026-10-06 に `EUID` が 0 でなく、ソケットが無いと `DOCKER_HOST` が入らず、既存の値も変わらないことを確かめた（[付録](install.md#付録-windows-ホストでの設定の再検証2026-10-06)）

## 読む順番の検証記録

検証コンテナで、並びを変えて対話のシェル（`script` の擬似端末の `bash -il`）に同じコマンドを打ち、端末に出た生の出力を調べた（2026-09-30。`TERM_PROGRAM=WezTerm`。COPR の WezTerm の公式のシェル統合は無く、ryo-aoki-pc/wezterm の `shell/wezterm.sh` が働く形。AlmaLinux 10 の `/etc/bashrc` は `PROMPT_COMMAND` を配列にするので、Git Bash と同じ文字列の `PROMPT_COMMAND` でも流した）:

| 並び | `false` の後の OSC 133 の `D` | `z` の警告 | 出力の前の余計な文字 | `. ~/.bashrc` で読み直した後 |
|---|---|---|---|---|
| **starship → WezTerm → zoxide**（この設定） | `D;1`（正しい） | 出ない | 無し | 変わらない |
| zoxide → WezTerm → starship（2026-09-30 に直す前の starship.md の並び） | いつも `D;0` | 文字列の `PROMPT_COMMAND` で出る | 無し | WezTerm のフックが 2 回ずつ動く |
| WezTerm → starship → zoxide | いつも `D;0` | 出ない | 無し | WezTerm のフックが 2 回ずつ動く |
| starship → WezTerm → zoxide（WezTerm の `PS0` を直す前） | `D;1` | 出ない | `${STARSHIP_START_TIME:0:0}` がコマンドごとに出る | （初期化し直さない判定を足す前は、zoxide のフックと starship の `PS0` が重なった） |
| starship 無し（WezTerm → zoxide） | `D;1` | 出ない | 無し | 変わらない |

- starship を WezTerm より後ろに読むと、WezTerm のフックは starship の中から呼ばれ、そのときの `$?` はいつも 0 になる。WezTerm には、失敗したコマンドも成功と送られる
- WezTerm の統合は `PS0` の `C` を `ESC \` で終えていた。後ろに starship の `PS0`（`${STARSHIP_START_TIME:…}`）が続くと、bash が `\\` を `\` にしてから展開するので、その `\` が `$` をエスケープし、`${…}` が文字のまま画面に出た。ryo-aoki-pc/wezterm で `C` を BEL（`\007`）で終えるように直した
- starship を使うと、`PS1` の OSC 133 の `A` / `B` はどの並びでも消える（starship が `PS1` を毎回作り直す）。ryo-aoki-pc/wezterm の docs/install.md の注意点と同じ
- 読み直したときの重なりを避けるため、starship と zoxide は、既に初期化してあれば初期化し直さない
  - starship は、初期化のたびに `PS0` に自分を足す
  - zoxide は、`PROMPT_COMMAND` が配列のとき（AlmaLinux 10）、先頭しか見ないので、初期化のたびにフックを足す
- AlmaLinux 10 の COPR の WezTerm が入れる公式のシェル統合（`/etc/profile.d/wezterm.sh`。bash-preexec を含む）があるときも、この並びで `D;1`・警告無し・読み直しても変わらないことを確かめた（上流の `wezterm.sh` を置いた模擬）
  - AlmaLinux 10 の aarch64 の実機（COPR の WezTerm 20260929。starship は無く、WezTerm → zoxide の並び）でも、`D;1`・警告無し・読み直しても変わらなかった（2026-10-02。[docs/install.md の付録](install.md#付録-almalinux-10-の実機aarch64への導入2026-10-02)）。ryo-aoki-pc/wezterm の `shell/wezterm.sh` は、公式の統合が先に読まれていると、迷子のマウス報告よけだけを足して抜ける
- Windows 11 の Git Bash（bash 5.3。`PROMPT_COMMAND` は何も無いところから始まる）でも、この並びで `D;1`・警告無し・読み直しても変わらないことを確かめた（2026-10-01。starship 1.26.0・zoxide 0.9.9。starship 無しでも同じ）
  - WezTerm の `PS0` を直す前の `shell/wezterm.sh`（ryo-aoki-pc/wezterm の main）では、表の 4 行目と同じく出力の前に余計な文字が出た。生の出力は `${STARSHIP_START_TIME:0:0}` で、WezTerm の画面では先頭の `${` がエスケープの続きとして読まれ、`STARSHIP_START_TIME:0:0}` と見えた
- 開いているシェルに後から starship を入れて `. ~/.bashrc` で読み直すと、そのシェルだけは WezTerm → starship の並びになる。starship を入れたら端末を開き直す

## 実施結果の要約

2026-10-06 に新規 AlmaLinux 10.2 の x86_64 VM で、初回・再実行・root 自身の導入と 8 回帰テストを確認した（[新規導入の記録](quick-start.md#新規-almalinux-vm-での再検証2026-10-06)）。専用ユーザーでは[既知の旧設定の手動移行](install.md#付録-新規-almalinux-vm-での手動移行の再検証2026-10-06)も通した。同じ VM で見つけた man ページャを修正し、表示と 8 テストを再確認した（[修正の記録](install.md#付録-man-ページャの修正と再検証2026-10-06)）。Windows / WSL の新スクリプト実導入は未検証。

## 補足資料に記載していた観測

### Windows 11 の Git Bash での違いの観測

  - 移ったかは、`$PWD`（`/c/Users/…`）と文字列で比べず、同じディレクトリか（`-ef`）で比べる。公式の文字列の比べ方では、動かずに `q` で閉じても同じ場所へ `cd` し直し、`cd -` の戻り先が今の場所になっていた（2026-10-01 に setup-notes の yazi.md と合わせて直した）

### Windows 11 の Git Bash での違いの観測

  - SSH のセッションで scoop の shim が起動できない状態（setup-notes の [windows-openssh-server.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-openssh-server.md) の「scoop のツールを SSH のセッションで使う」）でも、何も出さない（その PC の sshd に WSL からつないで確かめた）

### root のシェルでの違いの観測

- PATH の先頭が Homebrew。RPM と同じ名前のコマンドは、Homebrew 版が使われる（検証では `git`・`curl` は Homebrew に無く、`/bin` のもの）

### 読む順番の観測

- fzf（`fzf --bash`）は `bind` と `complete` と関数だけで、`PROMPT_COMMAND`・`PS0`・`PS1` に触らない（2026-10-02 に 0.74.4 の出力を `grep` で確かめた）。この 3 つの前に読む

### 移行で消す行の観測

  - それぞれを LazyVim で開いて保存した 8 行。保存のときに shfmt が `-i 2` で整形し、字下げが空白 2 つになり、`local` の行が 2 行に分かれる（Windows 11 の PC の `~/.bashrc` は、直す前の形のこれだった）


## ホストだけの設定に記載していた観測

- Homebrew のコマンドを使う行も後ろに書く。Homebrew の PATH は、読み込みの 1 行で足される（Homebrew の補完は、2026-10-02 からこの設定が読む）
- zoxide を別の形（`--cmd cd` など）でも使うなら、`--hook none` を付けて後ろに書く（例: `eval "$(zoxide init bash --cmd cd --hook none)"`）。付けないと、AlmaLinux 10（配列の `PROMPT_COMMAND`）ではフックが 2 つになる（Git Bash の文字列の `PROMPT_COMMAND` では 1 つのままだった）。`z` はこの設定が定義する
