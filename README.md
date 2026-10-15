# bash

いろいろなホストで共有する bash の設定。AlmaLinux 10（x86_64 / aarch64、WSL を含む）と、Windows 11 の Git Bash で同じものを使う。

## 導入

- 対象: AlmaLinux 10 の自分のユーザーの bash と、Windows 11 の Git Bash。WSL は WSL の中で AlmaLinux 10 と同じ手順を行う。macOS・zsh・MSYS2・QMK MSYS は対象外
- `~/.config/bash` に HTTPS で clone し（公開なので認証は要らない）、`install.sh` で `~/.bashrc` に読み込みの 1 行を足す。`install.sh` は、既知の旧設定の移行と `~/.bashrc` の控えの作成もする
- 手順は setup-notes の[シェルと端末のセットアップ](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md)にある

| | AlmaLinux 10 | Windows 11 |
| --- | --- | --- |
| 導入 | [共通の bash 設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定) | [Git Bash と WezTerm の設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#git-bash-と-wezterm-の設定)の手順 6 |
| 確かめながら手で移行する | [共通の bash 設定を手動で移行する](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を手動で移行する) | [Windows 11 で共通の bash 設定を手動で移行する](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#windows-11-で共通の-bash-設定を手動で移行する) |
| root にも入れる | [共通の bash 設定を root に入れる](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を-root-に入れる) | — |
| 更新 | [共通の bash 設定を更新する](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を更新する) | [Windows 11 で共通の bash 設定を更新する](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#windows-11-で共通の-bash-設定を更新する) |
| 戻す（`install.sh` で入れた） | [install.sh で入れた共通の bash 設定のロールバック](docs/extra/quick-start.md#ロールバック) | 同じ |
| 戻す（手で移行した） | [共通の bash 設定の手動移行のロールバック](docs/extra/install.md#ロールバック) | 同じ |

- root に入れるのは、自分専用のマシンで一般ユーザーを信用できるときだけ（[root のシェルでの違い](docs/reference/readme.md#root-のシェルでの違い)）

## しくみ

- `~/.bashrc` はホストのものとして残す（OS の既定の中身と、トークンなどホストだけの行）。この設定は、`~/.bashrc` の 1 行から読む
- ホストによって入っているツールが違うので、どの設定も、そのコマンドがあるかをシェルを開くたびに確かめ、無ければ何もしない。ツールを後から入れても、次に開いた端末から効く
- 何を読むか・読む順番・移行で消す行は、[参考資料](docs/reference/readme.md)

## ホストだけの設定

- `~/.bashrc` の、読み込みの 1 行より後ろに書く（この設定の後に読まれ、上書きできる）
- 例: `GITLAB_TOKEN`（setup-notes の[LazyVim の GitLab プレビューを設定する](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md#lazyvim-の-gitlab-プレビューを設定する)）、WSL で Windows 側の WezTerm のシェル統合を読む行（[WezTerm のシェル統合を WSL で使う](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#wezterm-のシェル統合を-wsl-で使う)）、`BAT_CONFIG_PATH` の独自の場所、eza の独自のオプション
- Homebrew のコマンドを使う行も後ろに書く。Homebrew の PATH は、読み込みの 1 行で足される（Homebrew の補完は共通設定が読む）
- zoxide を別の形（`--cmd cd` など）でも使うなら、`--hook none` を付けて後ろに書く（例: `eval "$(zoxide init bash --cmd cd --hook none)"`）。付けないと、AlmaLinux 10（配列の `PROMPT_COMMAND`）ではフックが 2 つになる。`z` はこの設定が定義する
- トークン・パスワード・トンネルの変数（`ALL_PROXY`・`https_proxy`）は、このリポジトリに書かない。トンネルの変数は、トンネルを張ったシェルの中だけで設定し、永続化しない（setup-notes の[SSH の SOCKS トンネル](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#ssh-の-socks-トンネル)）

## 設定を足すとき

- `bashrc` に、ツールがあるときだけ動く `if … fi` を足す。PATH と環境変数は前半、エイリアス・関数・プロンプトは後半に置く
- `PROMPT_COMMAND`・`PS0`・`PS1` を触るものは、[読む順番](docs/reference/readme.md#読む順番)を確かめてから位置を決める
- 元の手順書が `~/.bashrc` に書く行を、`migrate/old-lines.txt` にも足す
- 書き方の決まりと、変えたら合わせて直すものは [AGENTS.md](AGENTS.md)

## 文書

- [参考資料](docs/reference/readme.md): 読むもの・Git Bash と root での違い・読む順番・移行で消す行。手動移行の各手順の背景は [docs/reference/install.md](docs/reference/install.md)
- [注意点](docs/extra/install.md#注意点)
- 検証記録: [README の実測](docs/verification/readme.md)・[設定本体と手動移行](docs/verification/install.md)・[install.sh](docs/verification/quick-start.md)
- 変更後の確認のコマンド: [AGENTS.md の「よく使うコマンド」](AGENTS.md#よく使うコマンド)
- 旧手順書の移動先: setup-notes の[集約対応表](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/dev/consolidation-map.md)
