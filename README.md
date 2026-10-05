# bash

いろいろなホストで共有する bash の設定。AlmaLinux 10（x86_64 / aarch64、WSL を含む）と、Windows 11 の Git Bash で同じものを使う。

- 各ホストの `~/.config/bash` に HTTPS で clone し、初回だけ `install.sh` を実行する（公開のリポジトリなので認証は要らない）。既知の旧設定の移行、控えの作成、`~/.bashrc` の読み込み行の追加をまとめて行う
- ホストによって入っているツールが違うので、どの設定も、そのコマンドがあるかをシェルを開くたびに確かめ、無ければ何もしない。ツールを後から入れても、次に開いた端末から効く
- `~/.bashrc` はホストのものとして残す（OS の既定の中身と、トークンなどホストだけの行）
- root のシェル（`sudo -i`・`su -`）でも読める。root は `/root/.config/bash` に自分の clone を作り、`/root/.bashrc` の同じ 1 行で読む（自分専用のマシンで、一般ユーザーを信用できるときだけ。[root のシェルでの違い](#root-のシェルでの違い)）

```bash
git clone https://github.com/ryo-aoki-pc/bash.git ~/.config/bash &&
  bash ~/.config/bash/install.sh
```

端末を開き直すと、入っているツールの設定が効く。以後は `git -C ~/.config/bash pull --ff-only` で更新する。既に clone 済みなら `install.sh` だけ実行する。

git の clone 自体はホームの設定を書き換えないので、初回の実行だけは必要。スクリプトが追加する読み込み口は次の 1 行。

```bash
if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi
```

通常の導入と、setup-notes で省略できる追記の一覧は [docs/quick-start.md](docs/quick-start.md)。手動で導入する場合（既にある `~/.bashrc` の行の片付けを含む）は [docs/install.md](docs/install.md) にある（root のシェルは、その任意節「root のシェルでも読む」）。

## 読むもの

`bashrc` は前半と後半に分かれている。前半は `ssh <ホスト> <コマンド>`・scp・rsync のような非対話のシェルでも読み、後半は対話のシェルだけで読む。

| 読むもの | 条件 | 前半 / 後半 | 元の手順書 |
|---|---|---|---|
| Homebrew の PATH（`brew shellenv`） | `/home/linuxbrew/.linuxbrew/bin/brew` がある | 前半 | setup-notes の [homebrew.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/homebrew.md) 手順 3 |
| `EDITOR` / `VISUAL` を `nvim` に | `nvim` がある | 前半 | [neovim.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md)「既定のエディタにする」 |
| `MANPAGER` を bat に | `bat` がある | 前半 | [bat.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/bat.md)「ページャに使う」 |
| `DOCKER_HOST` を podman のソケットに | `DOCKER_HOST` が空で、`$XDG_RUNTIME_DIR/podman/podman.sock` がある（root は `/run/podman/podman.sock` がある） | 前半 | [podman.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/podman.md)「Docker 向けのツールから使う」（root は [lazydocker.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/lazydocker.md)「root でも使う」） |
| 履歴と `shopt`（`HISTSIZE` / `HISTFILESIZE` を 100000、`HISTCONTROL=ignoreboth`、`histappend`、`autocd` `cdspell` `dirspell` `globstar`） | 条件なし | 後半 | [bash-settings.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/bash-settings.md) 手順 3（`histappend` は共通設定でも有効にする。Git Bash の既定は off） |
| `alias vi=nvim` | `nvim` がある | 後半 | neovim.md「既定のエディタにする」 |
| `ll` / `la` / `lt`（eza） | `eza` がある | 後半 | [eza.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/eza.md)「エイリアスを足す」（共通のオプション） |
| `alias gdu=gdu-go` | `gdu-go` がある | 後半 | [gdu.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/gdu.md)「gdu の名前で呼ぶ」 |
| `y`（yazi を閉じたディレクトリへ移る） | `yazi` がある | 後半 | [yazi.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/yazi.md) 手順 3 |
| Homebrew で入れたコマンドの補完（`etc/bash_completion.d/*` を全部読む） | `$HOMEBREW_PREFIX/etc/bash_completion.d` がある | 後半（fzf より前） | bash-settings.md 手順 4 |
| fzf のキー操作（Ctrl+R・Ctrl+T・Alt+C）と `**` の補完 | `fzf` がある | 後半 | [fzf.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/fzf.md) 手順 3 |
| `FZF_DEFAULT_COMMAND` / `FZF_CTRL_T_COMMAND` / `FZF_ALT_C_COMMAND`（fd）、`FZF_CTRL_T_OPTS`（bat のプレビュー） | `fzf` があり、`fd` / `bat` がある | 後半 | fzf.md「fd と bat を候補とプレビューに使う」 |
| starship | `starship` があり、まだ初期化していない | 後半 | [starship.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/starship.md) 手順 3〜5 |
| WezTerm のシェル統合 | `$WEZTERM_SHELL_INTEGRATION`（無ければ `~/.config/wezterm/shell/wezterm.sh`）がある | 後半 | ryo-aoki-pc/wezterm の [docs/install.md](https://github.com/ryo-aoki-pc/wezterm/blob/main/docs/install.md) 手順 6 |
| zoxide（`z`） | `zoxide` があり、まだ初期化していない | 後半 | [zoxide.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/zoxide.md) 手順 3（`--cmd z`） |

- `ls` や `cat` は置き換えない（元の手順書と同じ）
- eza が無いと、`ll` は AlmaLinux 10 の `alias ll='ls -l --color=auto'`（coreutils-common の `/etc/profile.d/colorls.sh`）のまま（この設定のものではない。Git Bash は[下](#windows-11-の-git-bash-での違い)）
- 対話のシェルで最後まで読むと、`__bash_config_loaded=1` が入る（確かめる用）
- bash-settings.md 手順 5 の `~/.inputrc`（補完の大文字小文字、↑/↓ の履歴の検索）は、bash ではなく readline のファイルなので、この設定には含めない。各ホストで同書の手順を通す
- 履歴と `shopt`・Homebrew の補完・fzf の 4 つは、2026-10-02 に x86_64 のコンテナで確かめた。2026-10-06 に Windows の Git Bash でも履歴・`shopt`・fzf と fd を確かめた（Homebrew の補完と bat のプレビュー、fzf の実際のキー操作は未確認。[docs/install.md の付録](docs/install.md#付録-windows-ホストでの設定の再検証2026-10-06)）

### Windows 11 の Git Bash での違い

Windows 11 の PC の Git Bash（ツールは scoop で入れたもの）で確かめた、AlmaLinux 10 との違い（2026-10-01。[docs/install.md の付録](docs/install.md#付録-windows-11-の-git-bash-での検証記録2026-10-01)）:

- Homebrew の行は何もしない（`/home/linuxbrew` が無い）
- `MANPAGER` は bat があれば入るが、Git Bash には `man` が無いので使われない
- `DOCKER_HOST` は入らない（Git Bash に `XDG_RUNTIME_DIR` が無い）。Windows の podman はこの設定の対象外
- `alias gdu=gdu-go` は入らない（scoop の gdu は `gdu` の名前で入る）
- `ll` は、eza が無いと Git for Windows の `alias ll='ls -l'`（`/etc/profile.d/aliases.sh`。ログインシェルだけ）のまま。eza があれば、この設定の `ll` が上書きする
- `y` は、yazi が書く Windows の形のパス（`C:\Users\…`）へ `cd` する（空白や日本語を含むパスにも移れた）
  - 移ったかは、`$PWD`（`/c/Users/…`）と文字列で比べず、同じディレクトリか（`-ef`）で比べる。公式の文字列の比べ方では、動かずに `q` で閉じても同じ場所へ `cd` し直し、`cd -` の戻り先が今の場所になっていた（2026-10-01 に setup-notes の yazi.md と合わせて直した）
- WezTerm は `WEZTERM_SHELL_INTEGRATION` を Windows の形のパス（`C:\Users\<WIN_USER>\.config\wezterm/shell/wezterm.sh`）で渡す。Git Bash はそのまま読める
- zoxide の Windows 版は、プロンプトのたびに `cygpath -w` を外部コマンドで動かす（zoxide の作り。`~/.bashrc` に初期化を直に書いていたときと同じ）
- 2026-10-02 に足した履歴と `shopt`・fzf・fd の `FZF_*` は、2026-10-06 に Git Bash で確かめた。`fzf --bash` がキーと補完を登録し、読み直しても `bind -X`・`PROMPT_COMMAND`・`PS0` は変わらなかった。Homebrew の補完と bat のプレビュー、キーを実際に押す動作は未確認（[付録](docs/install.md#付録-windows-ホストでの設定の再検証2026-10-06)）
- ツールの有無を確かめる `command -v` は、PATH を順に探すので 1 回に約 2ms かかる（検証した PC の 37 要素の PATH。2026-10-01 のこの設定は 8 回）。対話のシェルの起動は、`~/.bashrc` に直に書いていたときより 10〜40ms 長い（測るたびに揺れた）
- 非対話のシェル（`ssh <ホスト> <コマンド>`・scp・sftp）では外部コマンドを 1 つも動かさないので、`~/.bashrc` に zoxide の初期化を直に書いていたときより約 100ms 短い
  - Windows の sshd（`DefaultShell` が Git Bash）は、sftp と scp（SFTP の方式）の `sftp-server.exe` も bash から起動するので、sftp でも `~/.bashrc` が読まれる
  - SSH のセッションで scoop の shim が起動できない状態（setup-notes の [windows-openssh-server.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-openssh-server.md) の「scoop のツールを SSH のセッションで使う」）でも、何も出さない（その PC の sshd に WSL からつないで確かめた）
  - 対話の SSH のセッションでは、その状態だと zoxide の初期化が shim のエラーを出し、`z` が無くなる（ほかは使える）。その任意節を行う

### root のシェルでの違い

root のシェル（docs/install.md の[root のシェルでも読む](docs/install.md#root-のシェルでも読む任意)）で確かめたこと（2026-10-05、x86_64 のコンテナだけ。[docs/install.md の付録](docs/install.md#付録-root-のシェルでも読む節の検証記録2026-10-05)）:

- root は、自分の clone（`/root/.config/bash`）を、`/root/.bashrc` の同じ 1 行で読む。更新は root のシェルでも pull する
- 読むものは自分のユーザーと同じ。root のシェルを開くたびに、Homebrew の `brew`（`shellenv`）・`fzf`・starship・zoxide が root で動く
  - 自分専用のマシンで、一般ユーザーを信用できるときだけ入れる（Homebrew のファイルは一般ユーザーが書き換えられる）
- PATH の先頭が Homebrew。RPM と同じ名前のコマンドは、Homebrew 版が使われる（検証では `git`・`curl` は Homebrew に無く、`/bin` のもの）
  - `brew shellenv` は root でも動くが、`brew install` などは `Running Homebrew as root is extremely dangerous …` で断られる
- `DOCKER_HOST` は `/run/podman/podman.sock`（システムの `podman.socket` のソケットがあるとき）
  - `su -`・`sudo -i`・`sudo -s` は root のソケットになる。`su`（`-` 無し）は自分のユーザーの `DOCKER_HOST` を引き継ぎ、そのままになる（空のときだけ入れるため）
  - `podman.socket` を止めても、ソケットのファイルは再起動まで残り、その間は入る
- zoxide のデータベースは root のもの（`/root/.local/share/zoxide`）
- AlmaLinux 10 の `/root/.bashrc` の `cp`・`rm`・`mv` の `-i` のエイリアスは残る（この設定は変えない）
- 非対話（`sudo -i <コマンド>`・`ssh root@<HOST> <コマンド>`）で何も出さない
- setup-notes が以前 `/root/.bashrc` に書いていた 2 行（homebrew.md・lazydocker.md の root の節）は、導入の手順 3 で消える（この設定が同じことをする。homebrew.md の行は PATH の末尾に足すが、この設定は先頭に足す）
- Windows 11 の Git Bash では、2026-10-06 に `EUID` が 0 でなく、ソケットが無いと `DOCKER_HOST` が入らず、既存の値も変わらないことを確かめた（[付録](docs/install.md#付録-windows-ホストでの設定の再検証2026-10-06)）

## 読む順番

プロンプトに関わる 3 つは、**starship → WezTerm のシェル統合 → zoxide** の順に読む。3 つとも `PROMPT_COMMAND` や `PS0` に自分の処理を足すので、順番で結果が変わる。

- starship は、既にある `PROMPT_COMMAND` を自分の中に移し、`PS1` を毎回作り直す
- WezTerm のシェル統合は、終了コードを保つフックを `PROMPT_COMMAND` の先頭に足し、`PS0` の先頭に OSC 133 の `C` を足す
- zoxide は、`PROMPT_COMMAND` の末尾にフックを足し、`z` を使うたびに `PROMPT_COMMAND` にフックがあるかを確かめる（無いと `zoxide: detected a possible configuration issue.` と出す）
- fzf（`fzf --bash`）は `bind` と `complete` と関数だけで、`PROMPT_COMMAND`・`PS0`・`PS1` に触らない（2026-10-02 に 0.74.4 の出力を `grep` で確かめた）。この 3 つの前に読む

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
  - AlmaLinux 10 の aarch64 の実機（COPR の WezTerm 20260929。starship は無く、WezTerm → zoxide の並び）でも、`D;1`・警告無し・読み直しても変わらなかった（2026-10-02。[docs/install.md の付録](docs/install.md#付録-almalinux-10-の実機aarch64への導入2026-10-02)）。ryo-aoki-pc/wezterm の `shell/wezterm.sh` は、公式の統合が先に読まれていると、迷子のマウス報告よけだけを足して抜ける
- Windows 11 の Git Bash（bash 5.3。`PROMPT_COMMAND` は何も無いところから始まる）でも、この並びで `D;1`・警告無し・読み直しても変わらないことを確かめた（2026-10-01。starship 1.26.0・zoxide 0.9.9。starship 無しでも同じ）
  - WezTerm の `PS0` を直す前の `shell/wezterm.sh`（ryo-aoki-pc/wezterm の main）では、表の 4 行目と同じく出力の前に余計な文字が出た。生の出力は `${STARSHIP_START_TIME:0:0}` で、WezTerm の画面では先頭の `${` がエスケープの続きとして読まれ、`STARSHIP_START_TIME:0:0}` と見えた
- 開いているシェルに後から starship を入れて `. ~/.bashrc` で読み直すと、そのシェルだけは WezTerm → starship の並びになる。starship を入れたら端末を開き直す

## ホストだけの設定

- `~/.bashrc` の、読み込みの 1 行より後ろに書く（この設定の後に読まれ、上書きできる）
- 例: `GITLAB_TOKEN`（LazyVimStarter の docs/setup.md）、WSL で Windows 側の WezTerm のシェル統合を読む行（ryo-aoki-pc/wezterm の docs/install.md の WSL の節）
- Homebrew のコマンドを使う行も後ろに書く。Homebrew の PATH は、読み込みの 1 行で足される（Homebrew の補完は、2026-10-02 からこの設定が読む）
- zoxide を別の形（`--cmd cd` など）でも使うなら、`--hook none` を付けて後ろに書く（例: `eval "$(zoxide init bash --cmd cd --hook none)"`）。付けないと、AlmaLinux 10（配列の `PROMPT_COMMAND`）ではフックが 2 つになる（Git Bash の文字列の `PROMPT_COMMAND` では 1 つのままだった）。`z` はこの設定が定義する
- トークン・パスワード・トンネルの変数（`ALL_PROXY`・`https_proxy`）は、このリポジトリに書かない

## 移行で消す行

[docs/install.md の手順 3](docs/install.md#実施手順) は、元の手順書が `~/.bashrc` に書いた行のうち、次のものと行全体が同じ行を消す。少しでも違う行は残し、手順 4・6・7 で見る。

- `migrate/old-lines.txt`: 1 行ずつ
  - Homebrew（`brew shellenv bash` と、引数の無い古い形）、`EDITOR` / `VISUAL` / `alias vi=nvim`、`MANPAGER`、`DOCKER_HOST`、eza の 3 つ（既定の `EZA_OPTS`）、`alias gdu=gdu-go`、starship、WezTerm のシェル統合（今の形と `[ -n "$WEZTERM_SHELL_INTEGRATION" ]` の古い形）、zoxide（`--cmd z` と、引数の無い形）
  - bash-settings.md の `HISTSIZE` / `HISTFILESIZE` / `HISTCONTROL` / `shopt -s autocd …` の 4 行と Homebrew の補完の 1 行、fzf.md の `eval "$(fzf --bash)"` と `export FZF_…` の 4 行（2026-10-02）
  - setup-notes が以前 `/root/.bashrc` に書いていた 2 行（2026-10-05）: homebrew.md「root のシェルでも使う」の PATH の `case` の行と、lazydocker.md「root でも使う」の `export DOCKER_HOST=unix:///run/podman/podman.sock`（末尾に `# setup-notes: lazydocker root` の目印が付いた形も含む）
  - neovim.md が直接追記に付ける `# setup-notes: neovim editor begin` / `end` の目印も外す（2026-10-05）。元値の控え `~/.local/state/neovim-editor-before.bash` は消さない。この設定へ移行した後は、neovim.md の印付き部分のロールバックを使わず、この設定の `EDITOR`・`VISUAL`・`vi` を変更する
- `migrate/old-y.txt`: yazi の `y()`（並びがすべて同じときだけ消す）。空行で区切った 4 つの形がある
  - setup-notes の yazi.md 手順 3 の 7 行（移ったかを `-ef` で比べる今の形と、2026-10-01 に直す前の `!=` の形）
  - それぞれを LazyVim で開いて保存した 8 行。保存のときに shfmt が `-i 2` で整形し、字下げが空白 2 つになり、`local` の行が 2 行に分かれる（Windows 11 の PC の `~/.bashrc` は、直す前の形のこれだった）
- `migrate/remove-old-lines.awk`: 上の 2 つを使って消す awk

## 設定を足すとき

- `bashrc` に、ツールがあるときだけ動く `if … fi` を足す
  - PATH と環境変数は前半、エイリアス・関数・プロンプトは後半
  - `PROMPT_COMMAND`・`PS0`・`PS1` を触るものは、[読む順番](#読む順番)を検証コンテナで確かめてから位置を決める
- 元の手順書が `~/.bashrc` に書く行を、`migrate/old-lines.txt` にも足す
- 元の手順書（setup-notes など）は共通設定を前提にし、`~/.bashrc` への追記・削除のブロックを置かず、読み込みと確認のコマンドだけを書く
- 書き方の決まり（何も出力しない・`if` で判定する・`set -u` で読める など）は [CLAUDE.md](CLAUDE.md) の「コードの注意」

## 対象外

- macOS と zsh（Homebrew の場所も `/home/linuxbrew/.linuxbrew` 決め打ち）
- MSYS2・QMK MSYS のホーム（Git Bash とホームが別）

## ファイル構成

```
.
├── bashrc                        # ~/.bashrc から読む本体
├── install.sh                    # 初回の読み込み設定と既知の旧設定の移行
├── tests/test_install.py         # 一時ホームでの導入・移行の回帰テスト
├── migrate/
│   ├── old-lines.txt             # 移行で消す行（1 行ずつ）
│   ├── old-y.txt                 # 移行で消す y()（空行で区切った 4 つの形）
│   └── remove-old-lines.awk      # 上の 2 つで ~/.bashrc の控えから消す
├── docs/quick-start.md           # 通常の導入と setup-notes の追記との対応
├── docs/install.md               # 手動での導入・更新・ロールバックの手順書
├── .gitattributes                # 改行を LF に固定（core.autocrlf=true の git でも CRLF にしない）
├── CLAUDE.md
└── README.md
```
