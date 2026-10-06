# bash 導入の補足資料

操作は [install.md](../install.md)、実施結果は [検証記録](../verification/install.md) を参照する。

## 補足

### <code>~/.config/bash</code> に置く理由と、HTTPS の clone

元の説明は [実施手順](../install.md#実施手順)の手順 2 に対応する。

- ほかの自分用の設定（`~/.config/wezterm`・`~/.config/yazi`・`~/.config/lazygit`・`~/.config/nvim`）と同じく、ツールの名前の付いたディレクトリにまとめる
- `~/.bashrc` の 1 行（手順 5）と、手順 3 の `awk` は、この置き場所を決め打ちにしている。別の場所に置くなら、両方を書き換える

### 消し方

元の説明は [実施手順](../install.md#実施手順)の手順 3 に対応する。

- `migrate/old-lines.txt` の行と、行全体が同じ行を消す。手で直した行や、`--cmd cd` の zoxide・別の `EZA_OPTS` の eza のように少しでも違う行は残る（手順 4 で見る）
- 控えの `~/.bashrc.before-bash` から読み、`~/.bashrc` に書く。`~/.bashrc` のファイル自体（パーミッション）はそのまま
- `touch` は、Git Bash で `~/.bashrc` がまだ無いときに空のファイルを作るため

### 残る行の例

元の説明は [実施手順](../install.md#実施手順)の手順 4 に対応する。

- 古い形の WezTerm の行（`if [ -n "$WEZTERM_SHELL_INTEGRATION" ]; then` から `fi` までの 3 行など）。`grep` は `fi` の行を出さないので、手順 6 で `fi` まで消す
- 手で直した行（`alias ll="eza -l --icons"`、`eval "$(zoxide init bash --cmd cd)"` など）
- 手で直した `y()`。`grep` は関数の中の `yazi` を含む 2 行だけを出し、`function y() {` と `}` の行は出さないので、手順 6 で `}` まで消す
- Homebrew のコマンドを使う行（`brew --prefix` で補完を読む行など）。手順 3 で消した `brew shellenv` の行の代わりに、手順 5 の 1 行が Homebrew の PATH を足すので、その 1 行より前では動かなくなる
- WSL で、Windows 側のシェル統合を読む行（wezterm の docs/install.md の「WSL でもシェル統合を使う」）。WSL の `~/.config/wezterm` は無いので、この行は残す
- `diff` は AlmaLinux 10 の最小のコンテナに無かったので、git の `diff --no-index` を使っている

### 1 行の形

元の説明は [実施手順](../install.md#実施手順)の手順 5 に対応する。

- `[ -r … ] && . …` と書かずに `if` にしてあるのは、ファイルが無いときに `$?` を 1 のまま残さないため。`~/.bashrc` の最後の `$?` は、最初のプロンプトの前のコマンドの終了コードとして扱われ、WezTerm のシェル統合が送る OSC 133 の `D;1`（失敗）になる
- `tail -c 1` は、`~/.bashrc` の最後の行に改行が無いときに、1 行を前の行につなげて書かないため
- `~/.config/bash` が無いホスト（まだ clone していない・消した）では、何もしない

### 残す行を後ろへ移す理由

元の説明は [実施手順](../install.md#実施手順)の手順 6 に対応する。

- 前に残した行は、この設定より先に読まれる。Homebrew の PATH はまだ無く（`command not found`）、エイリアスはこの設定に上書きされる。zoxide の行が前にあると、この設定は zoxide を初期化し直さないので、`z` ができない

### Git Bash の <code>~/.bash_profile</code>

元の説明は [実施手順](../install.md#実施手順)の手順 8 に対応する。

- WezTerm や Git Bash のショートカットは、bash をログインシェル（`-l`）で起動する。ログインシェルは `~/.bash_profile`・`~/.bash_login`・`~/.profile` の最初に見つかった 1 つだけを読み、`~/.bashrc` は読まない
- AlmaLinux 10 の `~/.bash_profile`（`/etc/skel` から）は、`~/.bashrc` を読む

### 選択した方針

- **自分のリポジトリにまとめ、ツールの有無はシェルを開くたびに見る**
  - どのホストにも同じ `bashrc` を置き、`command -v` でツールがあるときだけ読む。ホストごとの差（入っているツール）を、ファイルの中身ではなく起動時の判定で吸収する
  - ツールを後から入れても、何もせずに次の端末から効く
  - 採らなかった形:
    - chezmoi のテンプレート: ツールの有無を見るのは `chezmoi apply` のときなので、ツールを入れるたびに適用し直す。Windows やインターネットに出られないホストにも chezmoi が要る
    - GNU Stow・yadm などで `~/.bashrc` 自体を同期: `~/.bashrc` は OS ごとに既定の中身（AlmaLinux の `/etc/skel`、Git Bash は無し）が違い、ホストだけの行（トークンなど）も入る
    - Syncthing などでの同期: 変更の履歴が残らず、Windows とインターネットに出られないホストで使いにくい
    - AlmaLinux の `~/.bashrc.d/`: `/etc/skel/.bashrc` が読むが、Git Bash には無い
- **`~/.bashrc` はホストのものとして残し、1 行だけ足す**
  - OS の既定の中身と、ホストだけの行（`GITLAB_TOKEN` など）は `~/.bashrc` に残す。ホストだけの行は、読み込みの 1 行より後ろに書く
- **`bashrc` は 1 つのファイルにした**（`conf.d/` に分けない）
  - 項目が約 10 個で、読む順番を 1 か所で見られる。ファイルの並びの順（ロケール）や、NTFS でファイルを開く回数を気にしなくてよい
- **元の手順書の行は、行全体が同じものだけを機械的に消し、ほかはエディタで直す**（手順 3・4・6・7）

### 参照

- setup-notes の手順書（`~/.bashrc` に書く手順のあるもの）: [homebrew.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/homebrew.md)・[zoxide.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/zoxide.md)・[starship.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/starship.md)・[yazi.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/yazi.md)・[eza.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/eza.md)・[gdu.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/gdu.md)・[bat.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/bat.md)・[neovim.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md)・[podman.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/podman.md)
- ryo-aoki-pc/wezterm の [docs/install.md](https://github.com/ryo-aoki-pc/wezterm/blob/main/docs/install.md) — シェル統合
- `man bash`（INVOCATION: ログインシェル・対話のシェル・sshd から起動されたときに読むファイル）

---
