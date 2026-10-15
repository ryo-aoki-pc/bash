# bash 設定の補足資料

導入は [README](../../README.md) の「導入」の表、ロールバックは [extra/quick-start.md](../extra/quick-start.md)、注意点は [extra/install.md](../extra/install.md)、実測は[検証記録](../verification/readme.md)。

## 読むもの

`bashrc` は前半と後半に分かれている。前半は `ssh <ホスト> <コマンド>`・scp・rsync のような非対話のシェルでも読み、後半は対話のシェルだけで読む。

| 読むもの | 条件 | 前半 / 後半 | 手順書 |
|---|---|---|---|
| Homebrew の PATH（`brew shellenv`） | `/home/linuxbrew/.linuxbrew/bin/brew` がある | 前半 | setup-notes の [almalinux-setup.md の「Homebrew」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#homebrew)の手順 3 |
| `EDITOR` / `VISUAL` を `nvim` に | `nvim` がある | 前半 | [neovim.md の「Neovim」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md#neovim)の手順 4 |
| `MANPAGER=bat -plman` | `bat` がある | 前半 | [シェルと端末のセットアップの「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#シェルのツール)の手順 7 |
| `DOCKER_HOST` を podman のソケットに | `DOCKER_HOST` が空で、`$XDG_RUNTIME_DIR/podman/podman.sock` がある（root は `/run/podman/podman.sock` がある） | 前半 | [Podman の「Docker 向けのツールから使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#podman-docker-向けのツールから使う)（root は [lazydocker の「root でも使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#lazydocker-root-でも使う)） |
| 履歴と `shopt`（`HISTSIZE` / `HISTFILESIZE` を 100000、`HISTCONTROL=ignoreboth`、`histappend`、`autocd` `cdspell` `dirspell` `globstar`） | 条件なし | 後半 | [シェルと端末のセットアップの「共通の bash 設定」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定)の手順 2 と[「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#シェルのツール)の手順 3（`histappend` は共通設定でも有効にする。Git Bash の既定は off） |
| `alias vi=nvim` | `nvim` がある | 後半 | [neovim.md の「Neovim」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md#neovim)の手順 4 |
| `ll` / `la` / `lt`（eza） | `eza` がある | 後半 | [シェルと端末のセットアップの「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#シェルのツール)の手順 6（共通のオプション） |
| `alias gdu=gdu-go` | `gdu-go` がある | 後半 | [gdu の「gdu の名前で呼ぶ」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#gdu-gdu-の名前で呼ぶ) |
| `y`（yazi を閉じたディレクトリへ移る） | `yazi` がある | 後半 | [almalinux-setup.md の「yazi」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#yazi)の手順 4 |
| Homebrew で入れたコマンドの補完（`etc/bash_completion.d/*` を全部読む） | `$HOMEBREW_PREFIX/etc/bash_completion.d` がある | 後半（fzf より前） | [シェルと端末のセットアップの「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#シェルのツール)の手順 3 |
| fzf のキー操作（Ctrl+R・Ctrl+T・Alt+C）と `**` の補完 | `fzf` がある | 後半 | [シェルと端末のセットアップの「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#シェルのツール)の手順 5 |
| `FZF_DEFAULT_COMMAND` / `FZF_CTRL_T_COMMAND` / `FZF_ALT_C_COMMAND`（fd）、`FZF_CTRL_T_OPTS`（bat のプレビュー） | `fzf` があり、`fd` / `bat` がある | 後半 | [シェルと端末のセットアップの「fzf で fd と bat を候補とプレビューに使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#fzf-で-fd-と-bat-を候補とプレビューに使う) |
| starship | `starship` があり、まだ初期化していない | 後半 | [シェルと端末のセットアップの「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#シェルのツール)の手順 4 |
| WezTerm のシェル統合 | `$WEZTERM_SHELL_INTEGRATION`（無ければ `~/.config/wezterm/shell/wezterm.sh`）がある | 後半 | [共通 bash 設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定)が読む |
| zoxide（`z`） | `zoxide` があり、まだ初期化していない | 後半 | [シェルと端末のセットアップの「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#シェルのツール)の手順 9（`--cmd z`） |

- ツールの本体・設定のリポジトリ・ソケットの有効化は、表の「手順書」の項で別に入れる。この設定は、入っていれば読むだけ（root は、root 自身にも共通設定を入れる）
- `ls` や `cat` は置き換えない（手順書と同じ）
- eza が無いと、`ll` は AlmaLinux 10 の `alias ll='ls -l --color=auto'`（coreutils-common の `/etc/profile.d/colorls.sh`）のまま（この設定のものではない。Git Bash は[下](#windows-11-の-git-bash-での違い)）
- 対話のシェルで最後まで読むと、`__bash_config_loaded=1` が入る（確かめる用）
- [シェルと端末のセットアップの「共通の bash 設定」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定)の手順 4 の `~/.inputrc`（補完の大文字小文字、↑/↓ の履歴の検索）は、bash ではなく readline のファイルなので、この設定には含めない。各ホストで同書の手順を通す

### Windows 11 の Git Bash での違い

- Homebrew の行は何もしない（`/home/linuxbrew` が無い）
- `MANPAGER` は bat があれば入るが、Git Bash には `man` が無いので使われない
- `DOCKER_HOST` は入らない（Git Bash に `XDG_RUNTIME_DIR` が無い）。Windows の podman はこの設定の対象外
- `alias gdu=gdu-go` は入らない（scoop の gdu は `gdu` の名前で入る）
- `ll` は、eza が無いと Git for Windows の `alias ll='ls -l'`（`/etc/profile.d/aliases.sh`。ログインシェルだけ）のまま。eza があれば、この設定の `ll` が上書きする
- `y` は、yazi が書く Windows の形のパス（`C:\Users\…`）へ `cd` する（空白や日本語を含むパスにも移れた）
- WezTerm は `WEZTERM_SHELL_INTEGRATION` を Windows の形のパス（`C:\Users\<WIN_USER>\.config\wezterm/shell/wezterm.sh`）で渡す。Git Bash はそのまま読める
- zoxide の Windows 版は、プロンプトのたびに `cygpath -w` を外部コマンドで動かす（zoxide の作り）
- 非対話のシェル（`ssh <ホスト> <コマンド>`・scp・sftp）では外部コマンドを 1 つも動かさない
  - Windows の sshd（`DefaultShell` が Git Bash）は、sftp と scp（SFTP の方式）の `sftp-server.exe` も bash から起動するので、sftp でも `~/.bashrc` が読まれる
  - SSH のセッションで scoop の shim が起動できない状態（setup-notes の[scoop のツールを SSH のセッションで使う](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md#scoop-のツールを-ssh-のセッションで使う)を行っていない PC）でも、何も出さない
  - 対話の SSH のセッションでは、その状態だと zoxide の初期化が shim のエラーを出し、`z` が無くなる（ほかは使える）。上の項を行う

### root のシェルでの違い

- root は、自分の clone（`/root/.config/bash`）を、`/root/.bashrc` の同じ 1 行で読む。更新は root のシェルでも pull する
- 読むものは自分のユーザーと同じ。root のシェルを開くたびに、Homebrew の `brew`（`shellenv`）・`fzf`・starship・zoxide が root で動く
  - 自分専用のマシンで、一般ユーザーを信用できるときだけ入れる（Homebrew のファイルは一般ユーザーが書き換えられる）
- PATH の先頭が Homebrew。RPM と同じ名前のコマンドは、Homebrew 版が使われる
  - `brew shellenv` は root でも動くが、`brew install` などは `Running Homebrew as root is extremely dangerous …` で断られる
- `DOCKER_HOST` は `/run/podman/podman.sock`（システムの `podman.socket` のソケットがあるとき）
  - `su -`・`sudo -i`・`sudo -s` は root のソケットになる。`su`（`-` 無し）は自分のユーザーの `DOCKER_HOST` を引き継ぎ、そのままになる（空のときだけ入れるため）
  - `podman.socket` を止めても、ソケットのファイルは再起動まで残り、その間は入る
- zoxide のデータベースは root のもの（`/root/.local/share/zoxide`）
- AlmaLinux 10 の `/root/.bashrc` の `cp`・`rm`・`mv` の `-i` のエイリアスは残る（この設定は変えない）
- 非対話（`sudo -i <コマンド>`・`ssh root@<HOST> <コマンド>`）で何も出さない

## 読む順番

プロンプトに関わる 3 つは、**starship → WezTerm のシェル統合 → zoxide** の順に読む。3 つとも `PROMPT_COMMAND` や `PS0` に自分の処理を足すので、順番で結果が変わる。

- starship は、既にある `PROMPT_COMMAND` を自分の中に移し、`PS1` を毎回作り直す
- WezTerm のシェル統合は、終了コードを保つフックを `PROMPT_COMMAND` の先頭に足し、`PS0` の先頭に OSC 133 の `C` を足す
- zoxide は、`PROMPT_COMMAND` の末尾にフックを足し、`z` を使うたびに `PROMPT_COMMAND` にフックがあるかを確かめる（無いと `zoxide: detected a possible configuration issue.` と出す）
- fzf（`fzf --bash`）は `bind` と `complete` と関数だけで、`PROMPT_COMMAND`・`PS0`・`PS1` に触らない。この 3 つの前に読む
- 開いているシェルに後から starship を入れて `. ~/.bashrc` で読み直すと、そのシェルだけは WezTerm → starship の並びになる。starship を入れたら端末を開き直す
- 読む順番の実測は[検証記録](../verification/readme.md#読む順番の検証記録)
