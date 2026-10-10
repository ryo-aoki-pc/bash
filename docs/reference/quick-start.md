# 共通 bash 設定の導入の補足資料

操作は [quick-start.md](../quick-start.md) を参照する。

## setup-notes の追記との対応

標準の設定は共通の `bashrc` にまとめる。各ツールの手順書では設定の読み込みと確認を行う。

| setup-notes の文書 | 共通設定で読むもの | 別に行うこと |
|---|---|---|
| almalinux-setup.md の「Homebrew」の手順 1〜3（もとは homebrew.md） | `brew shellenv`（root も対象） | Homebrew 本体の導入。root は root 自身にも共通設定を導入する |
| neovim.md | `EDITOR`・`VISUAL`・`alias vi` | Neovim 本体と設定リポジトリ |
| almalinux-setup.md の「シェルのツール」の手順 1・7（もとは bat.md） | `MANPAGER` | bat 本体、任意の bat 設定ファイル |
| almalinux-setup.md の「シェルのツール」の手順 1・6（もとは eza.md） | `ll`・`la`・`lt` | eza 本体。共通のオプションは README の表を参照 |
| gdu.md | `alias gdu=gdu-go` | gdu 本体 |
| yazi.md | `y()` | yazi 本体・依存ツール・設定リポジトリ |
| almalinux-setup.md の「シェルのツール」の手順 1・5（もとは fzf.md） | 初期化と `FZF_*` の 4 変数 | fzf 本体。候補とプレビューは fd・bat があるときに有効 |
| almalinux-setup.md の「シェルのツール」の手順 1・4（もとは starship.md） | starship → WezTerm → zoxide の順で初期化 | starship 本体、任意の TOML / プリセット |
| almalinux-setup.md の「シェルのツール」の手順 1・9（もとは zoxide.md） | `z` とフック | zoxide 本体 |
| almalinux-setup.md の「共通の bash 設定」の手順 3・4 と「シェルのツール」の手順 3（もとは bash-settings.md） | 履歴・`shopt`・Homebrew の補完 | bash-completion と `~/.inputrc` |
| podman.md | rootless の `DOCKER_HOST` | ソケットの有効化。既存の `DOCKER_HOST` は上書きしない |
| lazydocker.md | root の `DOCKER_HOST` | root 自身の共通設定とシステムのソケットの有効化 |
| wezterm-nightly.md の参照先 | 通常の WezTerm のシェル統合 | WezTerm の設定リポジトリ。WSL で Windows 側を読むパスはホスト固有 |

`BAT_CONFIG_PATH` の独自の場所、eza の独自のオプション、zoxide の別のコマンド名はホスト固有の変更。参照先の LazyVimStarter が扱う `GITLAB_TOKEN` / `GITLAB_HOST` も共通化しない。`ALL_PROXY` と `https_proxy` はトンネルのセッション内だけで設定し、永続化しない。
