# install.sh で入れた共通の bash 設定のロールバック

`install.sh` で入れたもの（setup-notes の[共通の bash 設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定)の手順 1、[Git Bash と WezTerm の設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#git-bash-と-wezterm-の設定)の手順 6）を戻す。検証は[検証記録](../verification/quick-start.md)、手で移行したときの戻し方は[手動移行のロールバック](install.md#ロールバック)。

## ロールバック

- AlmaLinux 10 は自分のユーザーの bash、Windows 11 は Git Bash で行う。root にも入れたなら、`sudo -i` で入った root のシェルでも同じことを行う

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
