# bash の共通の設定の導入手順（AlmaLinux 10 / Windows 11 の Git Bash）

## 実施手順

- [検証記録](verification/install.md)・[背景説明](reference/install.md)は別ファイルに記載する

- 通常は [簡単な導入](quick-start.md)で、clone と `install.sh` の実行だけを行う。以下は移行内容を手で確認しながら進める手順。両方を通す必要はない

> [!IMPORTANT]
> - **自分のユーザーのシェルで貼る**。root のシェルにも入れるなら、この手順の後で [root のシェルでも読む（任意）](#root-のシェルでも読む任意)を通す（一般ユーザーを信用できるホストだけ）
> - **Windows 11 では、Git for Windows の Git Bash に同じブロックを貼る**。WSL は Linux のホストとして、WSL のシェルで別に通す（`/mnt/c` の clone は使わない）
> - **前提**: git が入っていること（公開のリポジトリを HTTPS で clone する。GitHub の鍵や認証は要らない）
>   - git: AlmaLinux 10 は setup-notes の [git.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/git.md)、Windows 11 は [Git for Windows](https://gitforwindows.org/)
>   - **インターネットに出られないホストは、setup-notes の [ssh-socks-tunnel.md 手順 1〜3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/ssh-socks-tunnel.md#実施手順) でトンネルを張ったシェルで貼る**（HTTPS の git は `ALL_PROXY` を読む）
> - **手順 6 はエディタで直す操作、手順 9 は端末を開き直す操作**。手順 10 は、開き直した端末で貼る

- 上から順にコードブロックを貼る
- この設定が何をどの条件で読むかは [README](../README.md) にある
- 手順の後: root のシェル（`sudo -i`・`su -`）でも読むなら [root のシェルでも読む（任意）](#root-のシェルでも読む任意)。以後は[更新](#更新)・[ロールバック](#ロールバック)。ツールを入れたときに `~/.bashrc` へ書く手順（setup-notes の各手順書）は、このホストでは貼らない（各手順書の箇条書きにある）


1. この設定が既に入っているか確かめる。

   ```bash
   ls -ld ~/.config/bash
   grep -n 'config/bash/bashrc' ~/.bashrc
   ```

   - `ls` が `No such file or directory` で、`grep` が何も出さなければ、まだ入っていない。手順 2 へ進む
   - `ls` がディレクトリを出し、`grep` が `if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi` の行を出したら、入っている。手順 2〜10 は飛ばして、[更新](#更新)を行う
   - Git Bash で `~/.bashrc` がまだ無ければ、`grep` は `No such file or directory` と出す（手順 3 で作られる）

1. この設定を `~/.config/bash` に clone する。

   ```bash
   git clone https://github.com/ryo-aoki-pc/bash.git ~/.config/bash
   ```

   - `Cloning into '/home/<USER>/.config/bash'...` と出る（Git Bash では `Cloning into 'C:/Users/<WIN_USER>/.config/bash'...`）
   - 問いは出ない（公開のリポジトリなので、認証は要らない）
   - インターネットに出られないホストでは、setup-notes の [ssh-socks-tunnel.md 手順 1〜3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/ssh-socks-tunnel.md#実施手順) でトンネルを張ったシェルで貼る
   - 止まったときは `~/.config/bash` は残らないので、そのまま貼り直せる


1. `~/.bashrc` を控えてから、元の手順書が書いた行を消す。

   ```bash
   if [ ! -r ~/.config/bash/migrate/remove-old-lines.awk ]; then echo '中断: 手順 2 の clone ができていない' >&2
   elif [ -e ~/.bashrc.before-bash ]; then echo '中断: ~/.bashrc.before-bash が既にある' >&2
   else
     touch ~/.bashrc &&
       cp -p ~/.bashrc ~/.bashrc.before-bash &&
       awk -f ~/.config/bash/migrate/remove-old-lines.awk ~/.config/bash/migrate/old-lines.txt ~/.config/bash/migrate/old-y.txt ~/.bashrc.before-bash > ~/.bashrc &&
       bash -n ~/.bashrc && echo 'bash -n: OK'
   fi
   ```

   - `bash -n: OK` と出ればよい
   - `中断:` と出たら、何も書き換えていない。`~/.bashrc.before-bash` が前の実行の控えなら、手順 4 から続ける
   - `bash -n` が `syntax error` を出したら、`cp -p ~/.bashrc.before-bash ~/.bashrc` で戻し、手順 4 の `grep` の行をエディタで消す形に切り替える
   - 消すのは、setup-notes の手順書と wezterm の手順書が書く行と、行全体が同じ行だけ（一覧は README の[移行で消す行](reference/readme.md#移行で消す行)）


1. 手順 3 で消した行と、残った関係の行を見る。

   ```bash
   git --no-pager diff --no-index ~/.bashrc.before-bash ~/.bashrc
   grep -n -i -E 'brew|zoxide|starship|yazi|eza|gdu-go|MANPAGER|nvim|DOCKER_HOST|wezterm|HIST|shopt|bash_completion|fzf|FZF_' ~/.bashrc
   ```

   - `git diff` の `-` で始まる行が、手順 3 で消した行
   - `grep` が何も出さなければ、手順 6・7 は飛ばす
   - `grep` が行を出したら、手順 6 でエディタで見る（行の番号が左に出る）


1. `~/.bashrc` の末尾に、この設定を読む 1 行を足す。

   ```bash
   if ! grep -qxF 'if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi' ~/.bashrc; then
     [ -z "$(tail -c 1 ~/.bashrc)" ] || echo >> ~/.bashrc
     echo 'if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi' >> ~/.bashrc
   fi
   tail -n 1 ~/.bashrc
   bash -n ~/.bashrc && echo 'bash -n: OK'
   ```

   - `if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi` と `bash -n: OK` が出ればよい
   - 既にその 1 行があれば、足さない（2 度貼っても 1 行のまま）
   - このホストだけの設定を足すときは、この 1 行より後ろに書く


1. 手順 4 で行が出たときだけ、`~/.bashrc` をエディタで開き、この設定と重なる行を消して、残す行を末尾の 1 行より後ろへ移す。

   - この設定が同じことをする行（README の[読むもの](reference/readme.md#読むもの)の表）は消す。`if … fi` で囲んだ行は `fi` まで、`y()` は `function y() {` から `}` まで消す
   - この設定と違う形で使いたい行（`--cmd cd` の zoxide、手で直した `alias ll` など）は、消さずに、手順 5 で足した末尾の 1 行より後ろへ移す
   - zoxide の行を残すときは、`--hook none` を足す（例: `eval "$(zoxide init bash --cmd cd --hook none)"`）
   - Homebrew のコマンドを使う行も、手順 5 の 1 行より後ろへ移す（Homebrew の PATH は、その 1 行で足される）
   - WSL の WezTerm の行は残す。starship を使うなら、手順 5 の 1 行より後ろへ移す（前にあると、starship が WezTerm に送る終了コードを 0 にする。README の[読む順番](reference/readme.md#読む順番)）
   - トークンなど、ホストだけの行は残す（前でも後ろでもよい）
   - **次の手順は、エディタを閉じてから貼る**


1. 手順 6 でエディタで直したときだけ、構文と並びを確かめる。

   ```bash
   bash -n ~/.bashrc && echo 'bash -n: OK'
   grep -n -i -E 'config/bash/bashrc|brew|zoxide|starship|yazi|eza|gdu-go|MANPAGER|nvim|DOCKER_HOST|wezterm' ~/.bashrc
   ```

   - `bash -n: OK` と出ればよい。`syntax error` と出たら、手順 6 に戻って直す
   - 手順 6 で残した行の番号が、`config/bash/bashrc` の行（手順 5 の 1 行）の番号より大きければよい

1. ログインシェルの設定ファイルが無いときだけ（新しい Git Bash など）、`~/.bashrc` を読む `~/.bash_profile` を作る。

   ```bash
   if [ -e ~/.bash_profile ] || [ -e ~/.bash_login ] || [ -e ~/.profile ]; then
     grep -n 'bashrc' ~/.bash_profile ~/.bash_login ~/.profile 2>/dev/null
   else
     printf '%s\n' '# ログインシェルでも ~/.bashrc を読む' 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' > ~/.bash_profile
     cat ~/.bash_profile
   fi
   ```

   - AlmaLinux 10 では、既にある `~/.bash_profile` の `/home/<USER>/.bash_profile:4:if [ -f ~/.bashrc ]; then` と `/home/<USER>/.bash_profile:5:    . ~/.bashrc` の 2 行が出る（何も作らない）
   - Git for Windows が作った `~/.bash_profile` のある Git Bash では、`/c/Users/<WIN_USER>/.bash_profile:3:test -f ~/.bashrc && . ~/.bashrc` の 1 行が出る（何も作らない）
   - ログインシェルの設定ファイルが 1 つも無いホスト（新しい Git Bash）では、作った 2 行が出る
   - 既にあるファイルが何も出さなければ、そのファイルは `~/.bashrc` を読んでいない。エディタで `if [ -f ~/.bashrc ]; then . ~/.bashrc; fi` を足す


1. 開いている端末をすべて閉じて、開き直す。

   - WezTerm などの端末アプリは、ウィンドウをすべて閉じて起動し直す。ssh で入っているなら、ログアウトして入り直す
   - 開いたままのシェルには効かない（手順 3 で消した行の関数やフックも、そのシェルには残っている）
   - **次の手順は、開き直した端末で貼る**

1. 開き直した端末で、この設定が読まれたか確かめる。

   ```bash
   echo "${__bash_config_loaded-読まれていない}"
   alias | grep -E "^alias (ll|la|lt|vi|gdu)="
   type -t y z
   echo "EDITOR=${EDITOR-} DOCKER_HOST=${DOCKER_HOST-}"
   echo "HISTSIZE=${HISTSIZE} $(shopt -p autocd globstar | tr '\n' ' ')"
   bind -X
   complete -p brew bat 2>/dev/null
   bash -c '. ~/.bashrc' 2>&1 | wc -c
   ```

   - 1 行目が `1` なら、対話のシェルでこの設定が最後まで読まれている
   - `HISTSIZE=100000 shopt -s autocd shopt -s globstar` は、どのホストでも出る（履歴と `shopt`）
   - `bind -X` は、fzf があれば Ctrl+R の `__fzf_history__` と Ctrl+T の `fzf-file-widget` を出す。Git Bash 5.3 では `"\C-r" "__fzf_history__"` のようにコロンが無く、WezTerm の統合を読むとマウス報告よけの行も出る。`complete -p` は、Homebrew の bat があれば `complete -F _fzf_path_completion bat`（fzf が無ければ `_bat`）と `brew` の行
   - 2〜4 行目は、このホストに入っているツールの分だけ出る（README の[読むもの](reference/readme.md#読むもの)）。eza があれば `ll`・`la`・`lt`、yazi があれば `function`（`y`）、zoxide があれば `function`（`z`）
   - Git Bash では、eza が無くても `alias ll='ls -l'` が出る（Git for Windows の `/etc/profile.d/aliases.sh` のもので、この設定のものではない）。`alias gdu` は出ない（scoop の gdu は `gdu` の名前で入る）
   - AlmaLinux 10 でも、eza が無いと `alias ll='ls -l --color=auto'` が出る（coreutils-common の `/etc/profile.d/colorls.sh` のもので、この設定のものではない）
   - 最後が `0` なら、非対話のシェル（`ssh <HOST> <コマンド>`・scp・rsync）で何も出力しない
   - 1 行目が `読まれていない` なら、手順 5・8 を見直す


---

## root のシェルでも読む（任意）

- **root のシェル（`sudo -i`・`su -`）でこの設定を使わないなら、この節は不要**
- root の `~/.config/bash`（`/root/.config/bash`）に root の clone を作り、root の `~/.bashrc`（`/root/.bashrc`）の末尾に同じ 1 行を足す
- [実施手順](#実施手順)のブロックは `~` を使っているので、root のシェルでそのまま貼る
- root でも、自分のユーザーと同じものを読む（`brew shellenv` で Homebrew が PATH の先頭、starship・zoxide・fzf・Homebrew の補完も）
- `DOCKER_HOST` は、root のコンテナのソケット（`/run/podman/podman.sock`。setup-notes の [lazydocker.md の「root でも使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/lazydocker.md#root-でも使う任意)）
- [実施手順](#実施手順)の手順 3 で、setup-notes が `/root/.bashrc` に書く 2 行も消える（この設定が同じことをする）
  - [almalinux-setup.md の「Homebrew を root のシェルでも使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#homebrew-を-root-のシェルでも使う任意)（もとは homebrew.md）の PATH の行と、lazydocker.md の「root でも使う」の `DOCKER_HOST` の行
- 前提: 自分のユーザーで[実施手順](#実施手順)を通してあること
- この節の手順 1 で root のシェルに入り、手順 3 で入り直す
- `sudo -i` は `ALL_PROXY` を渡さない
- 補足: [root のシェルで読むときの違い](reference/readme.md#root-のシェルでの違い)（README）

> [!WARNING]
> - **自分専用のマシンで、一般ユーザーを信用できるときだけ通す**。root のシェルを開くたびに、Homebrew のユーザーが書き換えられるコマンド（`brew shellenv`・starship・zoxide・fzf）とファイル（Homebrew の補完）が root で動く
> - root でも Homebrew が PATH の先頭になる。root の `git`・`curl` なども、Homebrew に入っていれば Homebrew のものが使われる（`brew install` などは root では断られる）


1. 自分のユーザーのシェルで、root のシェルに入る。

   ```bash
   sudo -i
   ```

   - プロンプトが `[root@<HOST> ~]#` になる
   - **次の手順は、root のシェルで貼る**

1. root のシェルで、[実施手順](#実施手順)の手順 1〜8 を順に貼る。

   - `~` は `/root`。手順 1 は `/root/.config/bash` と `/root/.bashrc` を見る
   - setup-notes の root の 2 行を書いたホストでは、手順 4 の `git diff` に、その 2 行が `-` で出る
   - 手順 6・7 は、手順 4 の `grep` が行を出したときだけ（root のシェルのエディタで直す）
   - 手順 8 は、AlmaLinux 10 の `/root/.bash_profile` が `~/.bashrc` を読むので、2 行が出る（何も作らない）
   - 手順 9 は飛ばし、この節の手順 3 で入り直す


1. root のシェルを `exit` で抜けて、`sudo -i` で入り直す。

   - 自分のユーザーのシェルに戻ってから、`sudo -i` と打つ
   - ほかに開いたままの root のシェルには効かない。開き直す
   - **次の手順は、入り直した root のシェルで貼る**

1. 入り直した root のシェルで、[実施手順](#実施手順)の手順 10 を貼る。

   - 1 行目が `1`、最後が `0` ならよい
   - `DOCKER_HOST=unix:///run/podman/podman.sock` は、システムの `podman.socket` を有効にしたホスト（setup-notes の lazydocker.md の「root でも使う」の手順 1）だけ。無ければ空
   - 確かめたら `exit` で抜ける


1. 元に戻すときは、`sudo -i` の root のシェルで、[ロールバック](#ロールバック)の手順 1〜5 を貼る。

   - [ロールバック](#ロールバック)の手順 5 は、`/root/.config/bash` を消す（取り戻せない）
   - 控え（`/root/.bashrc.before-bash`）に戻すと、setup-notes の root の 2 行も戻る
   - 戻した後は、root のシェルを開き直す

---

## 更新

- この設定を新しくする。ツールを入れたり外したりしたときは、何もしなくてよい（開き直した端末から効く）

1. origin を HTTPS にそろえて、設定のリポジトリを pull する。

   ```bash
   git -C ~/.config/bash remote set-url origin https://github.com/ryo-aoki-pc/bash.git
   git -C ~/.config/bash pull --ff-only
   git -C ~/.config/bash log -1 --oneline
   ```

   - 新しいコミットが無ければ `Already up to date.` と出て、最後にいちばん新しいコミットが 1 行出る
   - `set-url` は、HTTPS で clone したホストでは何も変えない。SSH で clone したホストを HTTPS にそろえる
   - インターネットに出られないホストは、setup-notes の [ssh-socks-tunnel.md 手順 1〜3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/ssh-socks-tunnel.md#実施手順) でトンネルを張ったシェルで貼る
   - 手元で変えたファイルがあって pull が止まったら、`git -C ~/.config/bash status` で見る
   - 開いている端末には効かない。[手順 9](#実施手順) と同じく開き直す

1. root のシェルにも入れたときだけ、`sudo -i` の root のシェルで、この節の手順 1 を貼る。

   - `/root/.config/bash` が新しくなる。出力は、この節の手順 1 と同じ
   - 開いている root のシェルには効かない。`exit` で抜けて入り直す

---

## ロールバック

- この文書で足したものを外す。ツールと、ツールごとの設定（`~/.config/wezterm` など）は消さない
- 外した後もツールを使うなら、そのツールの手順書の `~/.bashrc` に書く手順を貼り直すか、この節の手順 3 で控えから戻す
- root のシェルにも入れたなら、root の分は [root のシェルでも読む](#root-のシェルでも読む任意)の節の手順 5 で戻す

> [!CAUTION]
> **この節の手順 5 は、`~/.config/bash` を消す**。手元で変えて commit・push していないものは取り戻せない。この節の手順 4 で確かめてから貼る。

1. `~/.bashrc` から、この設定を読む行を消す。

   ```bash
   sed -i '\#config/bash/bashrc#d' ~/.bashrc
   grep -c 'config/bash/bashrc' ~/.bashrc
   ```

   - `0` と出ればよい
   - この節の手順 3 で控えに戻すまで、新しく開いたシェルでは、[手順 6](#実施手順) で後ろへ移した行が `command not found` を出すことがある（Homebrew の PATH を足す行が無くなるため）

1. [手順 3](#実施手順) の控えと、今の `~/.bashrc` の違いを見る。

   ```bash
   git --no-pager diff --no-index ~/.bashrc ~/.bashrc.before-bash
   ```

   - `+` で始まる行が、控えから戻すと戻る行（[手順 3](#実施手順) で消した行と、[手順 6](#実施手順) でエディタで消した行）
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
   - [手順 8](#実施手順) で作った `~/.bash_profile` は残す（Git Bash は、消すと次の起動で赤い `WARNING:` を出し、`~/.bashrc` を読む別の `~/.bash_profile` を作る。[ログイン設定の説明](reference/install.md#git-bash-の-bash_profile)）
   - 開いている端末には、この設定の関数やフックが残る。開き直すと消える

---


## 前提・確認・対処

### 完了時点の状態

| 場所 | 中身 |
|---|---|
| `~/.config/bash` | このリポジトリの clone（`main`。`origin` は `https://github.com/ryo-aoki-pc/bash.git`） |
| `~/.bashrc` | 元の手順書の行が消え、末尾に `if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi` |
| `~/.bashrc.before-bash` | 手順 3 の控え |
| `~/.bash_profile` | 手順 8 で作ったときだけ（ログインシェルの設定ファイルが 1 つも無かったホスト） |
| `/root/.config/bash`・`/root/.bashrc`・`/root/.bashrc.before-bash` | [root のシェルでも読む](#root-のシェルでも読む任意)の節を通したときだけ。中身は上の 3 つと同じ形 |

- 開き直したシェルでは、実施手順の手順 10 の確認欄に従って結果を確かめる

### 注意点

- 非対話のシェルでも `~/.bashrc` が読まれる。scp・sftp・rsync を壊さないよう、ホスト固有の追記から出力しない
- Windows の対話 SSH で scoop の shim が起動できないときは、setup-notes の windows-openssh-server.md「scoop のツールを SSH のセッションで使う」を行う
- ツールを後から入れたときは `. ~/.bashrc` で読み直す。starship を入れたときは、読み込み順を保つため端末を開き直す
- starship を使うホストでは、WezTerm の設定も更新する。コマンド出力の前に `${STARSHIP_START_TIME:0:0}` が出るときは古いシェル統合を更新する
- トークン・パスワード・トンネルの変数（`ALL_PROXY`・`https_proxy`）は共通設定に書かず、ホストの読み込み行より後ろに置く
- root に導入するのは一般ユーザーを信用できるホストだけ。root は一般ユーザーが書き換えられる Homebrew のコマンドを実行する
- WSL は WSL 側で導入する。MSYS2・QMK MSYS・macOS・zsh は対象外
