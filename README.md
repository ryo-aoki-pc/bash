# bash

いろいろなホストで共有する bash の設定。AlmaLinux 10（x86_64 / aarch64、WSL を含む）と、Windows 11 の Git Bash で同じものを使う。

- 各ホストの `~/.config/bash` に HTTPS で clone し、初回だけ `install.sh` を実行する（公開のリポジトリなので認証は要らない）。既知の旧設定の移行、控えの作成、`~/.bashrc` の読み込み行の追加をまとめて行う
- ホストによって入っているツールが違うので、どの設定も、そのコマンドがあるかをシェルを開くたびに確かめ、無ければ何もしない。ツールを後から入れても、次に開いた端末から効く
- `~/.bashrc` はホストのものとして残す（OS の既定の中身と、トークンなどホストだけの行）
- root のシェル（`sudo -i`・`su -`）でも読める。root は `/root/.config/bash` に自分の clone を作り、`/root/.bashrc` の同じ 1 行で読む（自分専用のマシンで、一般ユーザーを信用できるときだけ。[root のシェルでの違い](docs/reference/readme.md#root-のシェルでの違い)）

```bash
git clone https://github.com/ryo-aoki-pc/bash.git ~/.config/bash &&
  bash ~/.config/bash/install.sh
```

端末を開き直すと、入っているツールの設定が効く。以後は `git -C ~/.config/bash pull --ff-only` で更新する。既に clone 済みなら `install.sh` だけ実行する。


git の clone 自体はホームの設定を書き換えないので、初回の実行だけは必要。スクリプトが追加する読み込み口は次の 1 行。

```bash
if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi
```

通常の導入は [docs/quick-start.md](docs/quick-start.md)。setup-notes の追記との対応は [補足資料](docs/reference/quick-start.md)。手動で導入する場合（既にある `~/.bashrc` の行の片付けを含む）は [docs/install.md](docs/install.md) にある（root のシェルは、その任意節「root のシェルでも読む」）。

背景と設定一覧は [補足資料](docs/reference/readme.md)、実測と実施結果は [検証記録](docs/verification/readme.md) にある。

## ホストだけの設定

- `~/.bashrc` の、読み込みの 1 行より後ろに書く（この設定の後に読まれ、上書きできる）
- 例: `GITLAB_TOKEN`（LazyVimStarter の docs/setup.md）、WSL で Windows 側の WezTerm のシェル統合を読む行（ryo-aoki-pc/wezterm の docs/install.md の WSL の節）
- Homebrew のコマンドを使う行も後ろに書く。Homebrew の PATH は、読み込みの 1 行で足される（Homebrew の補完は共通設定が読む）
- zoxide を別の形（`--cmd cd` など）でも使うなら、`--hook none` を付けて後ろに書く（例: `eval "$(zoxide init bash --cmd cd --hook none)"`）。付けないと、AlmaLinux 10（配列の `PROMPT_COMMAND`）ではフックが 2 つになる。`z` はこの設定が定義する
- トークン・パスワード・トンネルの変数（`ALL_PROXY`・`https_proxy`）は、このリポジトリに書かない

## 設定を足すとき

- `bashrc` に、ツールがあるときだけ動く `if … fi` を足す
  - PATH と環境変数は前半、エイリアス・関数・プロンプトは後半
  - `PROMPT_COMMAND`・`PS0`・`PS1` を触るものは、[読む順番](docs/reference/readme.md#読む順番)を検証コンテナで確かめてから位置を決める
- 元の手順書が `~/.bashrc` に書く行を、`migrate/old-lines.txt` にも足す
- 元の手順書（setup-notes など）は共通設定を前提にし、`~/.bashrc` への追記・削除のブロックを置かず、読み込みと確認のコマンドだけを書く
- 書き方の決まり（何も出力しない・`if` で判定する・`set -u` で読める など）は [AGENTS.md](AGENTS.md) の「コードの注意」

## 対象外

- macOS と zsh（Homebrew の場所も `/home/linuxbrew/.linuxbrew` 決め打ち）
- MSYS2・QMK MSYS のホーム（Git Bash とホームが別）
