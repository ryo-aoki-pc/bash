# install.sh の導入を戻す

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
