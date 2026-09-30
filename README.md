# bash

いろいろなホストで共有する bash の設定。AlmaLinux 10（x86_64 / aarch64、WSL を含む）と、Windows 11 の Git Bash で同じものを使う。

- 各ホストの `~/.config/bash` に clone し、`~/.bashrc` の末尾の 1 行で読む
- ホストによって入っているツールが違うので、どの設定も、そのコマンドがあるかをシェルを開くたびに確かめ、無ければ何もしない。ツールを後から入れても、次に開いた端末から効く
- `~/.bashrc` はホストのものとして残す（OS の既定の中身と、トークンなどホストだけの行）

```bash
if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi
```

導入（既にある `~/.bashrc` の行の片付けを含む）は [docs/install.md](docs/install.md) にある。

## 読むもの

`bashrc` は前半と後半に分かれている。前半は `ssh <ホスト> <コマンド>`・scp・rsync のような非対話のシェルでも読み、後半は対話のシェルだけで読む。

| 読むもの | 条件 | 前半 / 後半 | 元の手順書 |
|---|---|---|---|
| Homebrew の PATH（`brew shellenv`） | `/home/linuxbrew/.linuxbrew/bin/brew` がある | 前半 | setup-notes の [homebrew.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/homebrew.md) 手順 3 |
| `EDITOR` / `VISUAL` を `nvim` に | `nvim` がある | 前半 | [neovim.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md)「既定のエディタにする」 |
| `MANPAGER` を bat に | `bat` がある | 前半 | [bat.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/bat.md)「ページャに使う」 |
| `DOCKER_HOST` を podman のソケットに | `DOCKER_HOST` が空で、`$XDG_RUNTIME_DIR/podman/podman.sock` がある | 前半 | [podman.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/podman.md)「Docker 向けのツールから使う」 |
| `alias vi=nvim` | `nvim` がある | 後半 | neovim.md「既定のエディタにする」 |
| `ll` / `la` / `lt`（eza） | `eza` がある | 後半 | [eza.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/eza.md)「エイリアスを足す」（`EZA_OPTS` は既定の値） |
| `alias gdu=gdu-go` | `gdu-go` がある | 後半 | [gdu.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/gdu.md)「gdu の名前で呼ぶ」 |
| `y`（yazi を閉じたディレクトリへ移る） | `yazi` がある | 後半 | [yazi.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/yazi.md) 手順 3 |
| starship | `starship` があり、まだ初期化していない | 後半 | [starship.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/starship.md) 手順 3 |
| WezTerm のシェル統合 | `$WEZTERM_SHELL_INTEGRATION`（無ければ `~/.config/wezterm/shell/wezterm.sh`）がある | 後半 | ryo-aoki-pc/wezterm の [docs/install.md](https://github.com/ryo-aoki-pc/wezterm/blob/main/docs/install.md) 手順 6 |
| zoxide（`z`） | `zoxide` があり、まだ初期化していない | 後半 | [zoxide.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/zoxide.md) 手順 6（`--cmd z`） |

- `ls` や `cat` は置き換えない（元の手順書と同じ）
- 対話のシェルで最後まで読むと、`__bash_config_loaded=1` が入る（確かめる用）

## 読む順番

プロンプトに関わる 3 つは、**starship → WezTerm のシェル統合 → zoxide** の順に読む。3 つとも `PROMPT_COMMAND` や `PS0` に自分の処理を足すので、順番で結果が変わる。

- starship は、既にある `PROMPT_COMMAND` を自分の中に移し、`PS1` を毎回作り直す
- WezTerm のシェル統合は、終了コードを保つフックを `PROMPT_COMMAND` の先頭に足し、`PS0` の先頭に OSC 133 の `C` を足す
- zoxide は、`PROMPT_COMMAND` の末尾にフックを足し、`z` を使うたびに `PROMPT_COMMAND` にフックがあるかを確かめる（無いと `zoxide: detected a possible configuration issue.` と出す）

検証コンテナで、並びを変えて対話のシェル（`script` の擬似端末の `bash -il`）に同じコマンドを打ち、端末に出た生の出力を調べた（2026-09-30。`TERM_PROGRAM=WezTerm`。AlmaLinux 10 の `/etc/bashrc` は `PROMPT_COMMAND` を配列にするので、Git Bash と同じ文字列の `PROMPT_COMMAND` でも流した）:

| 並び | `false` の後の OSC 133 の `D` | `z` の警告 | 出力の前の余計な文字 | `. ~/.bashrc` で読み直した後 |
|---|---|---|---|---|
| **starship → WezTerm → zoxide**（この設定） | `D;1`（正しい） | 出ない | 無し | 変わらない |
| zoxide → WezTerm → starship（starship.md の並び） | いつも `D;0` | 文字列の `PROMPT_COMMAND` で出る | 無し | WezTerm のフックが 2 回ずつ動く |
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
- 開いているシェルに後から starship を入れて `. ~/.bashrc` で読み直すと、そのシェルだけは WezTerm → starship の並びになる。starship を入れたら端末を開き直す

## ホストだけの設定

- `~/.bashrc` の、読み込みの 1 行より後ろに書く（この設定の後に読まれ、上書きできる）
- 例: `GITLAB_TOKEN`（LazyVimStarter の docs/setup.md）、WSL で Windows 側の WezTerm のシェル統合を読む行（ryo-aoki-pc/wezterm の docs/install.md の WSL の節）
- トークン・パスワード・トンネルの変数（`ALL_PROXY`・`https_proxy`）は、このリポジトリに書かない

## 移行で消す行

[docs/install.md の手順 3](docs/install.md#実施手順) は、元の手順書が `~/.bashrc` に書いた行のうち、次のものと行全体が同じ行を消す。少しでも違う行は残し、手順 4・5 で見る。

- `migrate/old-lines.txt`: 1 行ずつ
  - Homebrew（`brew shellenv bash` と、引数の無い古い形）、`EDITOR` / `VISUAL` / `alias vi=nvim`、`MANPAGER`、`DOCKER_HOST`、eza の 3 つ（既定の `EZA_OPTS`）、`alias gdu=gdu-go`、starship、WezTerm のシェル統合（今の形と `[ -n "$WEZTERM_SHELL_INTEGRATION" ]` の古い形）、zoxide（`--cmd z` と、引数の無い形）
- `migrate/old-y.txt`: yazi の `y()` の 7 行（7 行の並びがすべて同じときだけ消す）
- `migrate/remove-old-lines.awk`: 上の 2 つを使って消す awk

## 設定を足すとき

- `bashrc` に、ツールがあるときだけ動く `if … fi` を足す
  - PATH と環境変数は前半、エイリアス・関数・プロンプトは後半
  - `PROMPT_COMMAND`・`PS0`・`PS1` を触るものは、[読む順番](#読む順番)を検証コンテナで確かめてから位置を決める
- 元の手順書が `~/.bashrc` に書く行を、`migrate/old-lines.txt` にも足す
- 元の手順書（setup-notes など）の `~/.bashrc` に書く手順に、「自分用の bash の設定を入れたホストでは、このブロックは貼らない」の箇条書きを足す
- 書き方の決まり（何も出力しない・`if` で判定する・`set -u` で読める など）は [CLAUDE.md](CLAUDE.md) の「コードの注意」

## 対象外

- macOS と zsh（Homebrew の場所も `/home/linuxbrew/.linuxbrew` 決め打ち）
- root のシェル（Homebrew のユーザーが持つコマンドを root で動かすことになる）
- MSYS2・QMK MSYS のホーム（Git Bash とホームが別）

## ファイル構成

```
.
├── bashrc                        # ~/.bashrc から読む本体
├── migrate/
│   ├── old-lines.txt             # 移行で消す行（1 行ずつ）
│   ├── old-y.txt                 # 移行で消す y() の 7 行
│   └── remove-old-lines.awk      # 上の 2 つで ~/.bashrc の控えから消す
├── docs/install.md               # 導入・更新・ロールバックの手順書
├── .gitattributes                # 改行を LF に固定（core.autocrlf=true の git でも CRLF にしない）
├── CLAUDE.md
└── README.md
```
