# bash 導入の補足資料

手順は setup-notes の[共通の bash 設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定)。ロールバックは [extra/quick-start.md](../extra/quick-start.md)、注意点は [extra/install.md](../extra/install.md)、実施結果は[検証記録](../verification/install.md)。

## 配置と読み込み

### <code>~/.config/bash</code> に置く理由

- ほかの自分用の設定（`~/.config/wezterm`・`~/.config/yazi`・`~/.config/lazygit`・`~/.config/nvim`）と同じく、ツールの名前の付いたディレクトリにまとめる
- `install.sh` と `~/.bashrc` の読み込みの 1 行は、この置き場所を使う

### 読み込みの 1 行

- `[ -r … ] && . …` と書かずに `if` にしてあるのは、ファイルが無いときに `$?` を 1 のまま残さないため。`~/.bashrc` の最後の `$?` は、最初のプロンプトの前のコマンドの終了コードとして扱われ、WezTerm のシェル統合が送る OSC 133 の `D;1`（失敗）になる
- `install.sh` は、`~/.bashrc` の最後の行に改行が無いときに `tail -c 1` で見分け、読み込みの 1 行を前の行につなげて書かない
- `~/.config/bash` が無いホスト（まだ clone していない・消した）では、何もしない

### install.sh の処理

- 既存の `~/.bashrc` を一時ファイルへ写し、読み込みの 1 行が無ければ足す。`~/.bashrc` が無ければ空の内容から作る
- 設定本体と、読み込み行を足した内容を `bash -n` で確かめる。構文が不正なら、`~/.bashrc` と控えを作成・変更しない
- 内容が同じなら `cmp` で変更なしとし、`~/.bashrc` と控えは書き直さない
- 変更するときは、元の内容を `~/.bashrc.before-bash` に控える。既存の控えは上書きせず中断する。新規導入の控えは空ファイル
- 一時ファイルと控えは、秘密を含み得るので `umask 077` で作る。既存の `~/.bashrc` のリンクとパーミッションは保つ
- 設定本体の実行・ネットワーク接続・ツールの導入は行わない

### ホストだけの設定を後ろに置く理由

- 前にある行は、この設定より先に読まれる。Homebrew の PATH はまだ無く（`command not found`）、エイリアスはこの設定に上書きされる。zoxide の行が前にあると、この設定は zoxide を初期化し直さないので、`z` ができない

### Git Bash の <code>~/.bash_profile</code>

- WezTerm や Git Bash のショートカットは、bash をログインシェル（`-l`）で起動する。ログインシェルは `~/.bash_profile`・`~/.bash_login`・`~/.profile` の最初に見つかった 1 つだけを読み、`~/.bashrc` は読まない
- `install.sh` は、3 つとも無いときだけ `~/.bashrc` を読む `~/.bash_profile` を作る。既存のログイン設定は変えない
- AlmaLinux 10 の `~/.bash_profile`（`/etc/skel` から）は、`~/.bashrc` を読む

## 選択した方針

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
- **`bashrc` は 1 つのファイルにする**（`conf.d/` に分けない）
  - 項目が約 10 個で、読む順番を 1 か所で見られる。ファイルの並びの順（ロケール）や、NTFS でファイルを開く回数を気にしなくてよい

## 参照

- 対象ツールの導入: [AlmaLinux 10 の初期設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md)（Homebrew・yazi）・[シェルと端末のセットアップ](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md)（共通の bash 設定・zoxide・starship・eza・bat・fzf）・[Neovim](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md)・[gdu の導入](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#gdu)・[Podman の導入](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/containers.md#podman)
- ryo-aoki-pc/wezterm の [README の「シェル統合」](https://github.com/ryo-aoki-pc/wezterm#シェル統合)
- `man bash`（INVOCATION: ログインシェル・対話のシェル・sshd から起動されたときに読むファイル）
