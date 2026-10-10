# bash 設定の補足資料

操作は [README](../../README.md)、実測は [検証記録](../verification/readme.md) を参照する。

## 読むもの

`bashrc` は前半と後半に分かれている。前半は `ssh <ホスト> <コマンド>`・scp・rsync のような非対話のシェルでも読み、後半は対話のシェルだけで読む。

| 読むもの | 条件 | 前半 / 後半 | 元の手順書 |
|---|---|---|---|
| Homebrew の PATH（`brew shellenv`） | `/home/linuxbrew/.linuxbrew/bin/brew` がある | 前半 | setup-notes の [almalinux-setup.md の「Homebrew」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#homebrew)の手順 3（もとは homebrew.md） |
| `EDITOR` / `VISUAL` を `nvim` に | `nvim` がある | 前半 | [neovim.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md)「既定のエディタにする」 |
| `MANPAGER=bat -plman` | `bat` がある | 前半 | [almalinux-setup.md の「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#シェルのツール)の手順 7（もとは bat.md「ページャに使う」） |
| `DOCKER_HOST` を podman のソケットに | `DOCKER_HOST` が空で、`$XDG_RUNTIME_DIR/podman/podman.sock` がある（root は `/run/podman/podman.sock` がある） | 前半 | [podman.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/podman.md)「Docker 向けのツールから使う」（root は [lazydocker.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/lazydocker.md)「root でも使う」） |
| 履歴と `shopt`（`HISTSIZE` / `HISTFILESIZE` を 100000、`HISTCONTROL=ignoreboth`、`histappend`、`autocd` `cdspell` `dirspell` `globstar`） | 条件なし | 後半 | [almalinux-setup.md の「共通の bash 設定」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#共通の-bash-設定)の手順 2 と[「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#シェルのツール)の手順 3（もとは bash-settings.md。`histappend` は共通設定でも有効にする。Git Bash の既定は off） |
| `alias vi=nvim` | `nvim` がある | 後半 | neovim.md「既定のエディタにする」 |
| `ll` / `la` / `lt`（eza） | `eza` がある | 後半 | [almalinux-setup.md の「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#シェルのツール)の手順 6（もとは eza.md「エイリアスを足す」。共通のオプション） |
| `alias gdu=gdu-go` | `gdu-go` がある | 後半 | [gdu.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/gdu.md)「gdu の名前で呼ぶ」 |
| `y`（yazi を閉じたディレクトリへ移る） | `yazi` がある | 後半 | [yazi.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/yazi.md) 手順 3 |
| Homebrew で入れたコマンドの補完（`etc/bash_completion.d/*` を全部読む） | `$HOMEBREW_PREFIX/etc/bash_completion.d` がある | 後半（fzf より前） | [almalinux-setup.md の「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#シェルのツール)の手順 3（もとは bash-settings.md） |
| fzf のキー操作（Ctrl+R・Ctrl+T・Alt+C）と `**` の補完 | `fzf` がある | 後半 | [almalinux-setup.md の「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#シェルのツール)の手順 5（もとは fzf.md） |
| `FZF_DEFAULT_COMMAND` / `FZF_CTRL_T_COMMAND` / `FZF_ALT_C_COMMAND`（fd）、`FZF_CTRL_T_OPTS`（bat のプレビュー） | `fzf` があり、`fd` / `bat` がある | 後半 | [almalinux-setup.md の「fzf で fd と bat を候補とプレビューに使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#fzf-で-fd-と-bat-を候補とプレビューに使う任意) |
| starship | `starship` があり、まだ初期化していない | 後半 | [almalinux-setup.md の「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#シェルのツール)の手順 4（もとは starship.md） |
| WezTerm のシェル統合 | `$WEZTERM_SHELL_INTEGRATION`（無ければ `~/.config/wezterm/shell/wezterm.sh`）がある | 後半 | ryo-aoki-pc/wezterm の [docs/install.md](https://github.com/ryo-aoki-pc/wezterm/blob/main/docs/install.md) 手順 6 |
| zoxide（`z`） | `zoxide` があり、まだ初期化していない | 後半 | [almalinux-setup.md の「シェルのツール」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#シェルのツール)の手順 9（もとは zoxide.md。`--cmd z`） |

- `ls` や `cat` は置き換えない（元の手順書と同じ）
- eza が無いと、`ll` は AlmaLinux 10 の `alias ll='ls -l --color=auto'`（coreutils-common の `/etc/profile.d/colorls.sh`）のまま（この設定のものではない。Git Bash は[下](#windows-11-の-git-bash-での違い)）
- 対話のシェルで最後まで読むと、`__bash_config_loaded=1` が入る（確かめる用）
- [almalinux-setup.md の「共通の bash 設定」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#共通の-bash-設定)の手順 4（もとは bash-settings.md 手順 5）の `~/.inputrc`（補完の大文字小文字、↑/↓ の履歴の検索）は、bash ではなく readline のファイルなので、この設定には含めない。各ホストで同書の手順を通す

### Windows 11 の Git Bash での違い


- Homebrew の行は何もしない（`/home/linuxbrew` が無い）
- `MANPAGER` は bat があれば入るが、Git Bash には `man` が無いので使われない
- `DOCKER_HOST` は入らない（Git Bash に `XDG_RUNTIME_DIR` が無い）。Windows の podman はこの設定の対象外
- `alias gdu=gdu-go` は入らない（scoop の gdu は `gdu` の名前で入る）
- `ll` は、eza が無いと Git for Windows の `alias ll='ls -l'`（`/etc/profile.d/aliases.sh`。ログインシェルだけ）のまま。eza があれば、この設定の `ll` が上書きする
- `y` は、yazi が書く Windows の形のパス（`C:\Users\…`）へ `cd` する（空白や日本語を含むパスにも移れた）
- WezTerm は `WEZTERM_SHELL_INTEGRATION` を Windows の形のパス（`C:\Users\<WIN_USER>\.config\wezterm/shell/wezterm.sh`）で渡す。Git Bash はそのまま読める
- zoxide の Windows 版は、プロンプトのたびに `cygpath -w` を外部コマンドで動かす（zoxide の作り。`~/.bashrc` に初期化を直に書いていたときと同じ）
- 非対話のシェル（`ssh <ホスト> <コマンド>`・scp・sftp）では外部コマンドを 1 つも動かさないので、`~/.bashrc` に zoxide の初期化を直に書いていたときより約 100ms 短い
  - Windows の sshd（`DefaultShell` が Git Bash）は、sftp と scp（SFTP の方式）の `sftp-server.exe` も bash から起動するので、sftp でも `~/.bashrc` が読まれる
  - SSH のセッションで scoop の shim が起動できない状態
  - 対話の SSH のセッションでは、その状態だと zoxide の初期化が shim のエラーを出し、`z` が無くなる（ほかは使える）。その任意節を行う

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
- setup-notes が以前 `/root/.bashrc` に書いていた 2 行（homebrew.md・lazydocker.md の root の節）は、導入の手順 3 で消える（この設定が同じことをする。homebrew.md の行は PATH の末尾に足すが、この設定は先頭に足す）

## 読む順番

プロンプトに関わる 3 つは、**starship → WezTerm のシェル統合 → zoxide** の順に読む。3 つとも `PROMPT_COMMAND` や `PS0` に自分の処理を足すので、順番で結果が変わる。

- starship は、既にある `PROMPT_COMMAND` を自分の中に移し、`PS1` を毎回作り直す
- WezTerm のシェル統合は、終了コードを保つフックを `PROMPT_COMMAND` の先頭に足し、`PS0` の先頭に OSC 133 の `C` を足す
- zoxide は、`PROMPT_COMMAND` の末尾にフックを足し、`z` を使うたびに `PROMPT_COMMAND` にフックがあるかを確かめる（無いと `zoxide: detected a possible configuration issue.` と出す）
- fzf。この 3 つの前に読む


- 開いているシェルに後から starship を入れて `. ~/.bashrc` で読み直すと、そのシェルだけは WezTerm → starship の並びになる。starship を入れたら端末を開き直す
## 移行で消す行

[docs/install.md の手順 3](../install.md#実施手順) は、元の手順書が `~/.bashrc` に書いた行のうち、次のものと行全体が同じ行を消す。少しでも違う行は残し、手順 4・6・7 で見る。

- `migrate/old-lines.txt`: 1 行ずつ
  - Homebrew（`brew shellenv bash` と、引数の無い古い形）、`EDITOR` / `VISUAL` / `alias vi=nvim`、`MANPAGER`、`DOCKER_HOST`、eza の 3 つ（既定の `EZA_OPTS`）、`alias gdu=gdu-go`、starship、WezTerm のシェル統合（今の形と `[ -n "$WEZTERM_SHELL_INTEGRATION" ]` の古い形）、zoxide（`--cmd z` と、引数の無い形）
  - bash-settings.md の `HISTSIZE` / `HISTFILESIZE` / `HISTCONTROL` / `shopt -s autocd …` の 4 行と Homebrew の補完の 1 行、fzf.md の `eval "$(fzf --bash)"` と `export FZF_…` の 4 行（2026-10-02）
  - setup-notes が以前 `/root/.bashrc` に書いていた 2 行（2026-10-05）: homebrew.md「root のシェルでも使う」の PATH の `case` の行と、lazydocker.md「root でも使う」の `export DOCKER_HOST=unix:///run/podman/podman.sock`（末尾に `# setup-notes: lazydocker root` の目印が付いた形も含む）
  - neovim.md が直接追記に付ける `# setup-notes: neovim editor begin` / `end` の目印も外す（2026-10-05）。元値の控え `~/.local/state/neovim-editor-before.bash` は消さない。この設定へ移行した後は、neovim.md の印付き部分のロールバックを使わず、この設定の `EDITOR`・`VISUAL`・`vi` を変更する
- `migrate/old-y.txt`: yazi の `y()`（並びがすべて同じときだけ消す）。空行で区切った 4 つの形がある
  - setup-notes の yazi.md 手順 3 の 7 行（移ったかを `-ef` で比べる今の形と、2026-10-01 に直す前の `!=` の形）
- `migrate/remove-old-lines.awk`: 上の 2 つを使って消す awk

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
├── AGENTS.md                     # コーディングエージェント（Claude Code・Codex・Grok Build）への指示
├── CLAUDE.md                     # Claude Code に AGENTS.md を読ませる 1 行（`@AGENTS.md`）
└── README.md
```
