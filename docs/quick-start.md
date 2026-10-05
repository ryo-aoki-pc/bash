# 共通の bash 設定の導入

## 実施手順

- Git が入った自分のユーザーの bash で行う。Windows 11 は Git Bash、WSL は WSL 側で別に行う
- `git clone` は `~/.bashrc` を変更しないので、初回だけ `install.sh` の実行が必要
- `install.sh` はツールをインストールせず、ネットワークにも接続しない
- 新しい導入スクリプトは Linux の一時ホームで検証。Windows 11 / WSL の実機では未検証

1. clone して、読み込み口を設定する。

   ```bash
   git clone https://github.com/ryo-aoki-pc/bash.git ~/.config/bash &&
     bash ~/.config/bash/install.sh
   ```

   - 既に clone 済みなら `git -C ~/.config/bash pull --ff-only` で更新し、`bash ~/.config/bash/install.sh` だけ実行する
   - 変更前の内容は `~/.bashrc.before-bash` に控える。既に控えがある状態で別の変更が必要なら中断し、控えを上書きしない
   - setup-notes の標準の追記と完全一致する行・`y()` だけを移行する。手で変えた行は残す
   - 既存のログイン設定は変更しない。`~/.bash_profile`・`~/.bash_login`・`~/.profile` がどれも無いときだけ、`~/.bashrc` を読む `~/.bash_profile` を作る
   - 既存のログイン設定がある場合は、最初に読まれるファイルが `~/.bashrc` を読むことを確認する（[手動手順の手順 8](install.md#実施手順)）
   - 移行後の構文が不正になる場合は書き換える前に中断する。[手動手順](install.md)で移行する

1. 独自のツール設定が残る場合は、読み込み順を確認する。

   - [手動手順の手順 6](install.md#実施手順)に従う。共通設定と同じ行は削除し、独自の設定は読み込み行より後ろに置く
   - トークンやホスト固有の値は共通リポジトリに入れない
   - **次の手順は、編集を終えてから行う**

1. 端末を閉じて開き直す。

   - SSH はログインし直す。starship を後からインストールした場合も開き直す
   - **次の手順は、開き直した端末で貼る**

1. 読み込まれたことを確認する。

   ```bash
   echo "${__bash_config_loaded-読まれていない}"
   printf '%s\n' "$HISTSIZE" "$HISTFILESIZE" "$HISTCONTROL"
   shopt histappend autocd cdspell dirspell globstar
   ```

   - `1`、`100000`、`100000`、`ignoreboth` と、5 つの `on` が出る
   - 各ツールの設定は、そのツールが入った次のシェルから効く

## setup-notes の追記との対応

2026-10-05（日本時間）に setup-notes の全 Markdown を検索し、追記手順のある 12 文書と、WezTerm の参照先を照合した。標準の `~/.bashrc` の設定はすべて `bashrc` にある。各ツールの手順書は設定の確認を行い、同じ設定を `~/.bashrc` に重ねて書かない。

| setup-notes の文書 | 共通設定で読むもの | 別に行うこと |
|---|---|---|
| homebrew.md | `brew shellenv`（root も対象） | Homebrew 本体の導入。root は root 自身にも共通設定を導入する |
| neovim.md | `EDITOR`・`VISUAL`・`alias vi` | Neovim 本体と設定リポジトリ |
| bat.md | `MANPAGER` | bat 本体、任意の bat 設定ファイル |
| eza.md | `ll`・`la`・`lt` | eza 本体。共通のオプションは README の表を参照 |
| gdu.md | `alias gdu=gdu-go` | gdu 本体 |
| yazi.md | `y()` | yazi 本体・依存ツール・設定リポジトリ |
| fzf.md | 初期化と `FZF_*` の 4 変数 | fzf 本体。候補とプレビューは fd・bat があるときに有効 |
| starship.md | starship → WezTerm → zoxide の順で初期化 | starship 本体、任意の TOML / プリセット |
| zoxide.md | `z` とフック | zoxide 本体 |
| bash-settings.md | 履歴・`shopt`・Homebrew の補完 | bash-completion と `~/.inputrc` |
| podman.md | rootless の `DOCKER_HOST` | ソケットの有効化。既存の `DOCKER_HOST` は上書きしない |
| lazydocker.md | root の `DOCKER_HOST` | root 自身の共通設定とシステムのソケットの有効化 |
| wezterm-nightly.md の参照先 | 通常の WezTerm のシェル統合 | WezTerm の設定リポジトリ。WSL で Windows 側を読むパスはホスト固有 |

`BAT_CONFIG_PATH` の独自の場所、eza の独自のオプション、zoxide の別のコマンド名はホスト固有の変更。参照先の LazyVimStarter が扱う `GITLAB_TOKEN` / `GITLAB_HOST` も共通化しない。`ALL_PROXY` と `https_proxy` はトンネルのセッション内だけで設定し、永続化しない。

## 更新

1. 共通設定を更新する。

   ```bash
   git -C ~/.config/bash pull --ff-only
   ```

   - 更新後は端末を開き直す。読み込み口はそのまま使える
   - `install.sh` の再実行も可能。同じ状態なら変更も重複も増やさない

## ロールバック

1. 変更前に戻す場合は、控えと現在の内容を比べる。

   ```bash
   git --no-pager diff --no-index ~/.bashrc ~/.bashrc.before-bash
   ```

   - インストール後に加えた行があれば先に退避する
   - 新規導入だった場合、控えは空ファイル

1. 控えの内容を戻す。

   ```bash
   cat ~/.bashrc.before-bash > ~/.bashrc
   bash -n ~/.bashrc
   ```

   - `~/.bashrc` のリンクとパーミッションを保つ。控えは残る
   - スクリプトが作った `~/.bash_profile` は空の `~/.bashrc` でも使える。そのまま残してよい
   - 端末を開き直す。共通設定を外すと履歴の上限も OS 既定に戻るので、残したい `~/.bash_history` は先に控える

## 検証

- `python3 -m unittest discover -s tests` で新規導入、既知の旧設定の移行、再実行、控えの保護、構文エラー時の無変更、リンクと既存ログイン設定の保持を検証する
- `bash -n install.sh && bash -n bashrc` と `shellcheck -s bash install.sh bashrc` で構文と静的検査を行う
- 過去の設定本体の検証は [install.md の補足](install.md#補足)。新しいスクリプトの検証と、過去の実機検証は別のもの
