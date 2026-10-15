# 共通の bash 設定の手動移行のロールバックと注意点

setup-notes の[共通の bash 設定を手動で移行する](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を手動で移行する)で入れたものを戻す。背景は[参考資料](../reference/install.md)、検証は[検証記録](../verification/install.md)。「この節の手順 N」はこの文書の手順、リンクの付いた「手順 N」は正本の「共通の bash 設定を手動で移行する」の手順を指す。

## ロールバック

- AlmaLinux 10 は自分のユーザーの bash、Windows 11 は自分のユーザーの Git Bash で行う。WSL の設定は WSL 側で別に戻す
- この文書で足したものを外す。ツールと、ツールごとの設定（`~/.config/wezterm` など）は消さない
- ツールの設定も戻すときは、この節の手順 2 で控えとの差を確認し、手順 3 で控えの内容を戻す
- 手動で root にも入れたなら、`sudo -i` で入り、root 自身の設定を対象にこの節の手順 1〜5 を行う。`~` は `/root`。手順 5 は `/root/.config/bash` を消し、戻した後は root のシェルを開き直す
- `install.sh` で導入した設定の復元は [install.sh のロールバック](quick-start.md#ロールバック)を使う。root の分は root のシェルで行う

> [!CAUTION]
> **この節の手順 5 は、`~/.config/bash` を消す**。手元で変えて commit・push していないものは取り戻せない。この節の手順 4 で確かめてから貼る。

1. `~/.bashrc` から、この設定を読む行を消す。

   ```bash
   sed -i '\#config/bash/bashrc#d' ~/.bashrc
   grep -c 'config/bash/bashrc' ~/.bashrc
   ```

   - `0` と出ればよい
   - この節の手順 3 で控えに戻すまで、新しく開いたシェルでは、[手順 6](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を手動で移行する) で後ろへ移した行が `command not found` を出すことがある（Homebrew の PATH を足す行が無くなるため）

1. [手順 3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を手動で移行する) の控えと、今の `~/.bashrc` の違いを見る。

   ```bash
   git --no-pager diff --no-index ~/.bashrc ~/.bashrc.before-bash
   ```

   - `+` で始まる行が、控えから戻すと戻る行（[手順 3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を手動で移行する) で消した行と、[手順 6](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を手動で移行する) でエディタで消した行）
   - `-` で始まる行が、控えから戻すと消える行（控えを取った後に足した行）
   - 控えに戻さないなら、この節の手順 3 は飛ばす（`~/.bashrc.before-bash` は、要らなければ手で消す）

1. 控えの内容に戻すときだけ、控えから戻す。

   ```bash
   command cp -p ~/.bashrc.before-bash ~/.bashrc && command rm ~/.bashrc.before-bash
   bash -n ~/.bashrc && echo 'bash -n: OK'
   ```

   - `bash -n: OK` と出ればよい
   - `command` は、root のシェル（AlmaLinux 10 の `/root/.bashrc` が `cp`・`rm` を `-i` のエイリアスにしている）でも、上書きと削除を聞かせないため

1. 設定のリポジトリに、手元だけの変更が無いか確かめる。

   ```bash
   git -C ~/.config/bash status --short --branch
   git -C ~/.config/bash log --branches --not --remotes --oneline
   git -C ~/.config/bash stash list
   ```

   - `## main...origin/main` の 1 行だけが出て、`log` と `stash list` が何も出さなければ、手元だけの変更は無い
   - ほかの行・`[ahead 1]` など・`log` のコミット・`stash@{0}` などが出たら、要るものを別の場所へ写してから、この節の手順 5 へ進む

1. 設定を消す（取り戻せない）。

   ```bash
   rm -rf ~/.config/bash
   ls -ld ~/.config/bash
   ```

   - `No such file or directory` と出る
   - [手順 8](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を手動で移行する) で作った `~/.bash_profile` は残す（Git Bash は、消すと次の起動で赤い `WARNING:` を出し、`~/.bashrc` を読む別の `~/.bash_profile` を作る。[ログイン設定の説明](../reference/install.md#git-bash-の-bash_profile)）
   - 開いている端末には、この設定の関数やフックが残る。開き直すと消える

---

## 注意点

- 非対話のシェルでも `~/.bashrc` が読まれる。scp・sftp・rsync を壊さないよう、ホスト固有の追記から出力しない
- Windows の対話 SSH で scoop の shim が起動できないときは、setup-notes の [Windows 11 の初期設定の「scoop のツールを SSH のセッションで使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md#scoop-のツールを-ssh-のセッションで使う)を行う
- ツールを後から入れたときは `. ~/.bashrc` で読み直す。starship を入れたときは、読み込み順を保つため端末を開き直す
- starship を使うホストでは、WezTerm の設定も更新する。コマンド出力の前に `${STARSHIP_START_TIME:0:0}` が出るときは古いシェル統合を更新する
- トークン・パスワード・トンネルの変数は共通設定に書かない（README の[ホストだけの設定](../../README.md#ホストだけの設定)）
- root に導入するのは一般ユーザーを信用できるホストだけ。root は一般ユーザーが書き換えられる Homebrew のコマンドを実行する
