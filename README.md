# bash

導入・利用・更新は [AlmaLinux 10 の手順](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md) / [Windows 11 の手順](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md) に集約している。設定仕様・開発者向け操作・過去の検証・ロールバックはこのリポジトリで管理する。


いろいろなホストで共有する bash の設定。AlmaLinux 10（x86_64 / aarch64、WSL を含む）と、Windows 11 の Git Bash で同じものを使う。

- 各ホストの `~/.config/bash` に HTTPS で clone し、初回だけ `install.sh` を実行する（公開のリポジトリなので認証は要らない）。既知の旧設定の移行、控えの作成、`~/.bashrc` の読み込み行の追加をまとめて行う
- ホストによって入っているツールが違うので、どの設定も、そのコマンドがあるかをシェルを開くたびに確かめ、無ければ何もしない。ツールを後から入れても、次に開いた端末から効く
- `~/.bashrc` はホストのものとして残す（OS の既定の中身と、トークンなどホストだけの行）
- root のシェル（`sudo -i`・`su -`）でも読める。root は `/root/.config/bash` に自分の clone を作り、`/root/.bashrc` の同じ 1 行で読む（自分専用のマシンで、一般ユーザーを信用できるときだけ。[root のシェルでの違い](docs/reference/readme.md#root-のシェルでの違い)）

通常は [AlmaLinux 10](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#共通の-bash-設定) / [Windows 11](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md#git-bash-と-wezterm-の設定) の `install.sh` で導入する。手で確認しながら移行する場合だけ、[手動移行](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#共通の-bash-設定を手動で移行する任意)の全節を自分のユーザーの bash で行う。Windows 11 は Git Bash、WSL は WSL 側で別に行う。

[root への導入](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#共通の-bash-設定を-root-に入れる任意)と更新（[AlmaLinux 10](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#共通の-bash-設定を更新する) / [Windows 11](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md#共通の-bash-設定を更新する)）も正本で行う。戻すときは [install.sh の復元](docs/extra/quick-start.md#ロールバック) / [手動移行の復元](docs/extra/install.md#ロールバック)を使う。

[開発者検査](docs/quick-start.md#検証)・[設定一覧](docs/reference/readme.md)・[運用上の注意](docs/extra/install.md#注意点)・[検証記録](docs/verification/readme.md)・[集約対応表](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/dev/consolidation-map.md)。

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
