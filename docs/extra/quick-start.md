# install.sh で入れた共通の bash 設定のロールバック

`install.sh` で入れたもの（setup-notes の[共通の bash 設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定)の手順 1、[Git Bash と WezTerm の設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#git-bash-と-wezterm-の設定)の手順 6）を戻す。検証は[検証記録](https://github.com/ryo-aoki-pc/setup-notes-verification/blob/main/repos/bash/docs/verification/quick-start.md)、注意点は [extra/install.md](install.md)。

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

---

## リポジトリも消す

- [ロールバック](#ロールバック)で読み込みを外してから行う。root の分は `sudo -i` で入った root のシェルで行う

> [!CAUTION]
> **この節の手順 2 は、`~/.config/bash` を消す**。手元だけの変更・コミット・stash は取り戻せない。手順 1 で確かめてから貼る。

1. 設定のリポジトリに、手元だけの変更が無いか確かめる。

   ```bash
   git -C ~/.config/bash status --short --branch
   git -C ~/.config/bash log --branches --not --remotes --oneline
   git -C ~/.config/bash stash list
   ```

   - `## main...origin/main` の 1 行だけが出て、`log` と `stash list` が何も出さなければ、手元だけの変更は無い
   - ほかの行・`[ahead 1]` など・`log` のコミット・`stash@{0}` などが出たら、要るものを別の場所へ写してから、手順 2 へ進む

1. 設定を消す（取り戻せない）。

   ```bash
   rm -rf ~/.config/bash
   ls -ld ~/.config/bash
   ```

   - `No such file or directory` と出る
   - `install.sh` で作った `~/.bash_profile` は残す（Git Bash は、消すと次の起動で赤い `WARNING:` を出し、`~/.bashrc` を読む別の `~/.bash_profile` を作る。[ログイン設定の説明](../reference/install.md#git-bash-の-bash_profile)）
   - 開いている端末には、この設定の関数やフックが残る。開き直すと消える
