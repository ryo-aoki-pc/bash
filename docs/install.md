# bash の共通の設定の導入手順（AlmaLinux 10 / Windows 11 の Git Bash）

## 実施手順

> [!IMPORTANT]
> - **自分のユーザーのシェルで貼る**。`sudo -i` した root のシェルでは貼らない（root の `~/.bashrc` は対象外。[注意点](#注意点)）
> - **Windows 11 では、Git for Windows の Git Bash に同じブロックを貼る**。WSL は Linux のホストとして、WSL のシェルで別に通す（`/mnt/c` の clone は使わない）
> - **前提**: git が入っていて、GitHub の非公開のリポジトリを clone できること
>   - AlmaLinux 10: setup-notes の [git.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/git.md) と、[gh.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/gh.md) の `gh auth login`（git の認証も gh に任せる）
>   - Windows 11: [Git for Windows](https://gitforwindows.org/)（git の認証は、同梱の Git Credential Manager がブラウザで聞く）
> - **手順 2 は、git の認証を聞かれることがある**（Windows は Git Credential Manager がブラウザで聞く）。clone が終わってから手順 3 を貼る
> - **手順 6 はエディタで直す操作、手順 9 は端末を開き直す操作**。手順 10 は、開き直した端末で貼る

- 上から順にコードブロックを貼る
- 各手順の末尾の「補足」（折り畳み）と後半の[補足](#補足)は、実行するだけなら読まなくてよい。折り畳みの中のブロックも貼らなくてよい
- この設定が何をどの条件で読むかは [README](../README.md) にある
- 手順の後: 以後は[更新](#更新)・[ロールバック](#ロールバック)。ツールを入れたときに `~/.bashrc` へ書く手順（setup-notes の各手順書）は、このホストでは貼らない（各手順書の箇条書きにある）

> [!WARNING]
> **AlmaLinux 10 は x86_64 のコンテナでのみ検証した**（画面の代わりに `script` の擬似端末で対話のシェルを動かした）。**実機・Windows 11 の Git Bash・WSL では試していない**。詳しくは[対象と検証環境](#対象と検証環境)。

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

   - `Cloning into '/home/<USER>/.config/bash'...` と出る
   - 非公開のリポジトリなので、git の認証が無いと `Username for 'https://github.com':` と聞かれる。`Ctrl+C` で止め、[前提](#実施手順)の認証を済ませてから貼り直す
   - Windows では、Git Credential Manager がブラウザで GitHub のサインインを聞くことがある（試していない）
   - **次の手順は、clone が終わってから貼る**（認証を聞かれている間に貼ると、答えとして食われる）

   <details>
   <summary>補足: <code>~/.config/bash</code> に置く理由</summary>

   - ほかの自分用の設定（`~/.config/wezterm`・`~/.config/yazi`・`~/.config/lazygit`・`~/.config/nvim`）と同じく、ツールの名前の付いたディレクトリにまとめる
   - `~/.bashrc` の 1 行（手順 5）と、手順 3 の `awk` は、この置き場所を決め打ちにしている。別の場所に置くなら、両方を書き換える
   - Git Bash のホームは `/c/Users/<WIN_USER>`（setup-notes の [windows-openssh-server.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-openssh-server.md) の実測）なので、Windows では `C:\Users\<WIN_USER>\.config\bash` に置かれるはず（試していない）
   - `.gitattributes` で改行を LF に固定してある。`core.autocrlf=true` の git（scoop の git の既定）で clone しても、CRLF にならない（検証コンテナで `git -c core.autocrlf=true clone` して確かめた）

   </details>

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
   - 消すのは、setup-notes の手順書と wezterm の手順書が書く行と、行全体が同じ行だけ（一覧は README の[移行で消す行](../README.md#移行で消す行)）

   <details>
   <summary>補足: 消し方</summary>

   - `migrate/old-lines.txt` の行と、行全体が同じ行を消す。手で直した行や、`--cmd cd` の zoxide・別の `EZA_OPTS` の eza のように少しでも違う行は残る（手順 4 で見る）
   - yazi の `y()` は、`migrate/old-y.txt` の形のどれかと、続く行がすべて同じときだけ消す。形は、setup-notes の yazi.md の 7 行と、それを LazyVim で保存した 8 行（保存のときに shfmt が整形した形）の 2 つ。`sed '/^function y() {$/,/^}$/d'` のような範囲の消し方は、閉じ括弧が見つからないと最後の行まで消すので使わない
   - 控えの `~/.bashrc.before-bash` から読み、`~/.bashrc` に書く。`~/.bashrc` のファイル自体（パーミッション）はそのまま
   - `touch` は、Git Bash で `~/.bashrc` がまだ無いときに空のファイルを作るため
   - 検証コンテナで、実機と同じ並び（Homebrew・`y()`・zoxide・`if … fi` の 3 行の WezTerm）の `~/.bashrc` に流した出力は、[付録](#付録-コンテナでの検証記録2026-09-30)にある

   </details>

1. 手順 3 で消した行と、残った関係の行を見る。

   ```bash
   git --no-pager diff --no-index ~/.bashrc.before-bash ~/.bashrc
   grep -n -i -E 'brew|zoxide|starship|yazi|eza|gdu-go|MANPAGER|nvim|DOCKER_HOST|wezterm' ~/.bashrc
   ```

   - `git diff` の `-` で始まる行が、手順 3 で消した行
   - `grep` が何も出さなければ、手順 6・7 は飛ばす
   - `grep` が行を出したら、手順 6 でエディタで見る（行の番号が左に出る）

   <details>
   <summary>補足: 残る行の例</summary>

   - 古い形の WezTerm の行（`if [ -n "$WEZTERM_SHELL_INTEGRATION" ]; then` から `fi` までの 3 行など）。`grep` は `fi` の行を出さないので、手順 6 で `fi` まで消す
   - 手で直した行（`alias ll="eza -l --icons"`、`eval "$(zoxide init bash --cmd cd)"` など）
   - 手で直した `y()`。`grep` は関数の中の `yazi` を含む 2 行だけを出し、`function y() {` と `}` の行は出さないので、手順 6 で `}` まで消す
   - Homebrew のコマンドを使う行（`brew --prefix` で補完を読む行など）。手順 3 で消した `brew shellenv` の行の代わりに、手順 5 の 1 行が Homebrew の PATH を足すので、その 1 行より前では動かなくなる
   - WSL で、Windows 側のシェル統合を読む行（wezterm の docs/install.md の「WSL でもシェル統合を使う」）。WSL の `~/.config/wezterm` は無いので、この行は残す
   - 手順 3 から手順 6 までの間に新しく開いたシェルでは、残った行が `command not found` を出すことがある（検証コンテナで、手順 6 の前に残っていた `eval "$(zoxide init bash --cmd cd)"` が `zoxide: command not found` を出した。手順 6 で後ろへ移すと出なくなった）
   - `diff` は AlmaLinux 10 の最小のコンテナに無かったので、git の `diff --no-index` を使っている

   </details>

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

   <details>
   <summary>補足: 1 行の形</summary>

   - `[ -r … ] && . …` と書かずに `if` にしてあるのは、ファイルが無いときに `$?` を 1 のまま残さないため。`~/.bashrc` の最後の `$?` は、最初のプロンプトの前のコマンドの終了コードとして扱われ、WezTerm のシェル統合が送る OSC 133 の `D;1`（失敗）になる
   - `tail -c 1` は、`~/.bashrc` の最後の行に改行が無いときに、1 行を前の行につなげて書かないため
   - `~/.config/bash` が無いホスト（まだ clone していない・消した）では、何もしない

   </details>

1. 手順 4 で行が出たときだけ、`~/.bashrc` をエディタで開き、この設定と重なる行を消して、残す行を末尾の 1 行より後ろへ移す。

   - この設定が同じことをする行（README の[読むもの](../README.md#読むもの)の表）は消す。`if … fi` で囲んだ行は `fi` まで、`y()` は `function y() {` から `}` まで消す
   - この設定と違う形で使いたい行（`--cmd cd` の zoxide、手で直した `alias ll` など）は、消さずに、手順 5 で足した末尾の 1 行より後ろへ移す
   - zoxide の行を残すときは、`--hook none` を足す（例: `eval "$(zoxide init bash --cmd cd --hook none)"`）
   - Homebrew のコマンドを使う行も、手順 5 の 1 行より後ろへ移す（Homebrew の PATH は、その 1 行で足される）
   - WSL の WezTerm の行は残す。starship を使うなら、手順 5 の 1 行より後ろへ移す（前にあると、starship が WezTerm に送る終了コードを 0 にする。README の[読む順番](../README.md#読む順番)）
   - トークンなど、ホストだけの行は残す（前でも後ろでもよい）
   - **次の手順は、エディタを閉じてから貼る**

   <details>
   <summary>補足: 残す行を後ろへ移す理由</summary>

   - 前に残した行は、この設定より先に読まれる。Homebrew の PATH はまだ無く（`command not found`）、エイリアスはこの設定に上書きされる。zoxide の行が前にあると、この設定は zoxide を初期化し直さないので、`z` ができない
   - この設定は `eval "$(zoxide init bash)"` でフックを足している。zoxide は `PROMPT_COMMAND` の先頭の要素しか見ないので、AlmaLinux 10（`/etc/bashrc` が配列にする）では、後ろに残した zoxide の行がフックをもう 1 つ足し、`. ~/.bashrc` で読み直すたびに増える（検証コンテナで `[1]="__zoxide_hook" [2]="__zoxide_hook"`）
   - `--hook none` を足すと、残した行は `cd` などの関数だけを足す。検証コンテナでは、フックは読み直しても 1 つのままで、`cd share` で `/usr/share` に移り、`zoxide: detected a possible configuration issue.` は出なかった。`z` もそのまま使える（この設定が定義する）

   </details>

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
   - ログインシェルの設定ファイルが 1 つも無いホスト（新しい Git Bash）では、作った 2 行が出る
   - 既にあるファイルが何も出さなければ、そのファイルは `~/.bashrc` を読んでいない。エディタで `if [ -f ~/.bashrc ]; then . ~/.bashrc; fi` を足す

   <details>
   <summary>補足: Git Bash の <code>~/.bash_profile</code></summary>

   - WezTerm や Git Bash のショートカットは、bash をログインシェル（`-l`）で起動する。ログインシェルは `~/.bash_profile`・`~/.bash_login`・`~/.profile` の最初に見つかった 1 つだけを読み、`~/.bashrc` は読まない
   - Git for Windows は、`~/.bashrc` があって 3 つとも無いと、`~/.bashrc` を読む `~/.bash_profile` を作り、`WARNING: Found ~/.bashrc but no ~/.bash_profile, ~/.bash_login or ~/.profile.` と赤く表示する（`/etc/profile.d/bash_profile.sh`）。この手順は、それを先に作っておくもの
   - AlmaLinux 10 の `~/.bash_profile`（`/etc/skel` から）は、`~/.bashrc` を読む

   </details>

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
   bash -c '. ~/.bashrc' 2>&1 | wc -c
   ```

   - 1 行目が `1` なら、対話のシェルでこの設定が最後まで読まれている
   - 2〜4 行目は、このホストに入っているツールの分だけ出る（README の[読むもの](../README.md#読むもの)）。eza があれば `ll`・`la`・`lt`、yazi があれば `function`（`y`）、zoxide があれば `function`（`z`）
   - 最後が `0` なら、非対話のシェル（`ssh <HOST> <コマンド>`・scp・rsync）で何も出力しない
   - 1 行目が `読まれていない` なら、手順 5・8 を見直す

   <details>
   <summary>補足: 検証コンテナでの出力</summary>

   Homebrew で zoxide・yazi・eza・bat・neovim・gdu・starship を入れたユーザーの、開き直した対話のシェル（`script` の擬似端末）での出力（プロンプトは省いた）:

   ```
   1
   alias gdu='gdu-go'
   alias la='eza -la --git --group-directories-first'
   alias ll='eza -l --git --group-directories-first'
   alias lt='eza --tree --level=2'
   alias vi='nvim'
   function
   function
   EDITOR=nvim DOCKER_HOST=
   0
   ```

   - `DOCKER_HOST` は、podman の API ソケット（setup-notes の [podman.md 手順 8](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/podman.md#実施手順)）があるときだけ入る。検証コンテナには無かった

   </details>

---

## 更新

- この設定を新しくする。ツールを入れたり外したりしたときは、何もしなくてよい（開き直した端末から効く）

1. 設定のリポジトリを pull する。

   ```bash
   git -C ~/.config/bash pull --ff-only
   ```

   - 新しいコミットが無ければ、`Already up to date.` と出る
   - `Username for 'https://github.com':` と聞かれたら、`Ctrl+C` で止め、[前提](#実施手順)の認証を済ませてから貼り直す
   - 手元で変えたファイルがあって pull が止まったら、`git -C ~/.config/bash status` で見る
   - インターネットに出られないホストは、setup-notes の [ssh-socks-tunnel.md 手順 1〜3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/ssh-socks-tunnel.md#実施手順) でトンネルを張ったシェルで貼る（git は `ALL_PROXY` を読む。試していない）
   - **次の手順は、pull が終わってから貼る**（認証を聞かれている間に貼ると、答えとして食われる）

1. 取り込んだコミットを確かめる。

   ```bash
   git -C ~/.config/bash log -1 --oneline
   ```

   - いちばん新しいコミットが 1 行出る
   - 開いている端末には効かない。[手順 9](#実施手順) と同じく開き直す

---

## ロールバック

- この文書で足したものを外す。ツールと、ツールごとの設定（`~/.config/wezterm` など）は消さない
- 外した後もツールを使うなら、そのツールの手順書の `~/.bashrc` に書く手順を貼り直すか、この節の手順 3 で控えから戻す

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
   cp -p ~/.bashrc.before-bash ~/.bashrc && rm ~/.bashrc.before-bash
   bash -n ~/.bashrc && echo 'bash -n: OK'
   ```

   - `bash -n: OK` と出ればよい

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
   - [手順 8](#実施手順) で作った `~/.bash_profile` は残す（Git Bash は、消すと次の起動で赤い `WARNING:` を出し、`~/.bashrc` を読む別の `~/.bash_profile` を作る。[手順 8](#実施手順) の補足。試していない）
   - 開いている端末には、この設定の関数やフックが残る。開き直すと消える

---

## 補足

### 対象と検証環境

- **目的**: いろいろなホストで同じ bash の設定を使う。setup-notes の手順書と wezterm の手順書がホストごとに `~/.bashrc` へ書いていた行を、このリポジトリの `bashrc` 1 つにまとめ、`~/.bashrc` からは 1 行で読む
- **進め方**: git で `~/.config/bash` に clone し、`~/.bashrc` から元の手順書の行を消して、読み込みの 1 行を足す。**読者が書き換える変数は無い**（リポジトリの URL と置き場所は固定）
- **状態**: **x86_64 のコンテナでのみ検証済み（2026-09-30）。実機・Windows 11 の Git Bash・WSL では本実行していない**
  - 下表の検証コンテナで、**この文書の bash のコードブロックを抜き出したもの**を、一般ユーザーの `bash -s` に手順ごとに流した（[付録](#付録-コンテナでの検証記録2026-09-30)）
  - 手順 9・10 は、端末の代わりに `script` の擬似端末でログインシェル（`bash -il`）を開き、手順 10 のブロックを打ち込んで出力を読んだ
  - 手順 5・6 を入れ替えた今の版（レビューの後）を、もう一度はじめから流した（付録の「2 回目」）
  - 確認したこと
    - 未導入の判定、clone（`core.autocrlf=true` でも LF）、clone に失敗したときの手順 3 の `中断:`
    - 元の手順書の行の消し方: 実機と同じ並びの `~/.bashrc`（ホストだけの行つき）、今の手順書の行をすべて持つ `~/.bashrc`、`/etc/skel` のままの `~/.bashrc`、`~/.bashrc` の無いホーム（Git Bash の代わり）
    - 手順 6 で残す行を後ろへ移す形（Homebrew のコマンドを使う行、`--hook none` を足した `--cmd cd` の zoxide）と、手順 7 の確かめ
    - 移行の前後のシェルの比較（エイリアス・関数・`PATH`・環境変数・`PROMPT_COMMAND`）
    - 読み込みの 1 行と 2 度貼ったとき、`~/.bash_profile` の有無、開き直したログインシェルでの読み込み
    - 非対話のシェルで何も出さないこと（`bash -c`・`ssh` のコマンド・scp・sftp・rsync）、`set -u`（非対話の前半と、対話の後半）
    - 更新（新しいコミットを入れた fast-forward）、ロールバック（手元だけのコミットと stash が見えることも）
    - 開いたシェルにツールを入れて `. ~/.bashrc` で読み直したとき（Homebrew・zoxide・yazi・eza・gdu・bat・Neovim・starship）
  - **確認していないこと**: Windows 11 の Git Bash（`awk`・`~/.bash_profile` の生成・起動の時間・`y()` が Windows のパスを受け取るところ）、WSL、実機（AlmaLinux 10）と aarch64、非公開のリポジトリの認証（検証コンテナは手元の bare リポジトリから clone した）、インターネットに出られないホストでの更新、端末の画面（プロンプトへのジャンプなど）、podman のソケットがあるときの `DOCKER_HOST`

| 項目 | 検証コンテナ |
|---|---|
| 実施日 | 2026-09-30 |
| OS | AlmaLinux 10.2 (Lavender Lion) / x86_64（`almalinux:10`、Docker 29.3.1、`--network host`） |
| bash / git / gawk | `bash-5.2.26-6.el10` / `git-2.52.0-1.el10` / `gawk-5.3.0-6.el10` |
| Homebrew | 7.0.7（zoxide 0.10.0・yazi 26.9.1・eza 0.23.5・bat 0.26.1・neovim 0.12.5_1・gdu 5.37.0・starship 1.26.0） |
| WezTerm の設定 | ryo-aoki-pc/wezterm の `main`（`826037f`）に、`PS0`・`PS1` の印を BEL で終える直し（README の[読む順番](../README.md#読む順番)）を足したもの（1 回目は `PS0` だけ） |
| sshd | `openssh-server-9.9p1-27.el10_2.alma.1`（検証環境だけ 127.0.0.1 の 2222 番） |

> [!NOTE]
> 出力例の値は `<USER>` / `<WIN_USER>` / `<HOST>` などのプレースホルダで書いてある。ツールの版は実行日によって変わる。

手順書全体に関わる理由・実測・落とし穴と検証記録（手順ごとのものは各手順の末尾の「補足」にある）。手順を実行するだけなら読まなくてよい。

### 実施前の状態

| 項目 | 移行するホスト（検証の m3） | 新しいホスト（検証の n2） |
|---|---|---|
| `~/.bashrc` | `/etc/skel` の 25 行の後ろに、元の手順書の行とホストだけの行（付録） | `/etc/skel` のまま |
| `~/.config/bash` | 無し | 無し |
| Homebrew とツール | あり（検証環境の表） | あり |
| `~/.config/wezterm` | あり | 無し |

### 選択した方針

- **自分のリポジトリにまとめ、ツールの有無はシェルを開くたびに見る**
  - どのホストにも同じ `bashrc` を置き、`command -v` でツールがあるときだけ読む。ホストごとの差（入っているツール）を、ファイルの中身ではなく起動時の判定で吸収する
  - ツールを後から入れても、何もせずに次の端末から効く
  - 採らなかった形:
    - chezmoi のテンプレート: ツールの有無を見るのは `chezmoi apply` のときなので、ツールを入れるたびに適用し直す。Windows やインターネットに出られないホストにも chezmoi が要る
    - GNU Stow・yadm などで `~/.bashrc` 自体を同期: `~/.bashrc` は OS ごとに既定の中身（AlmaLinux の `/etc/skel`、Git Bash は無し）が違い、ホストだけの行（トークンなど）も入る
    - Syncthing などでの同期: 変更の履歴が残らず、Windows とインターネットに出られないホストで使いにくい
    - AlmaLinux の `~/.bashrc.d/`: `/etc/skel/.bashrc` が読むが、Git Bash には無い
- **`~/.bashrc` はホストのものとして残し、1 行だけ足す**
  - OS の既定の中身と、ホストだけの行（`GITLAB_TOKEN` など）は `~/.bashrc` に残す。ホストだけの行は、読み込みの 1 行より後ろに書く
- **`bashrc` は 1 つのファイルにした**（`conf.d/` に分けない）
  - 項目が約 10 個で、読む順番を 1 か所で見られる。ファイルの並びの順（ロケール）や、NTFS でファイルを開く回数を気にしなくてよい
- **非公開のリポジトリ**（利用者の選択）。clone と pull に GitHub の認証が要る
- **プロンプトの 3 つ（starship・WezTerm・zoxide）は、この順に読む**。setup-notes の starship.md と ryo-aoki-pc/wezterm の手順書も、同じ並びに直した（2026-09-30。前は starship を最後に置いていた）。理由と実測は README の[読む順番](../README.md#読む順番)
- **元の手順書の行は、行全体が同じものだけを機械的に消し、ほかはエディタで直す**（手順 3・4・6・7）

### 完了時点の状態

| 場所 | 中身 |
|---|---|
| `~/.config/bash` | このリポジトリの clone（`main`） |
| `~/.bashrc` | 元の手順書の行が消え、末尾に `if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi` |
| `~/.bashrc.before-bash` | 手順 3 の控え |
| `~/.bash_profile` | 手順 8 で作ったときだけ（ログインシェルの設定ファイルが 1 つも無かったホスト） |

- 開き直したシェルでの確かめ（手順 10）の出力は、手順 10 の補足にある

### 注意点

- **非対話のシェルでも `~/.bashrc` は読まれる**
  - `ssh <HOST> <コマンド>`・scp・rsync のとき、bash は sshd から起動されたことを見分けて `~/.bashrc` を読む（検証コンテナの AlmaLinux 10 と、setup-notes の windows-openssh-server.md の Git Bash）
  - `bashrc` の前半（PATH と環境変数）はそこでも効き、後半（エイリアス・関数・プロンプト）は読まない。何も出力しない（出力すると scp・rsync が壊れる）
- **ツールを入れた直後のシェルには効かない**
  - 開いているシェルは、開いたときにあったツールの分だけ読んでいる。そのシェルで使うなら `. ~/.bashrc` で読み直す（検証コンテナで、開いたシェルに zoxide を入れて読み直し、`z` が警告無しで動いた）
  - starship だけは、端末を開き直す。読み直すと WezTerm のシェル統合より後ろに読まれ、WezTerm のフックが 2 回ずつ動いた（`false` の後に `D;1` と `D;0` が続けて送られた。README の[読む順番](../README.md#読む順番)）
- **starship を使うホストでは、wezterm の設定も新しくする**
  - WezTerm のシェル統合の `PS0` が starship の `PS0` を壊す問題を、ryo-aoki-pc/wezterm で直した。古い `~/.config/wezterm` のままだと、コマンドの出力の前に `${STARSHIP_START_TIME:0:0}` の文字が出る
- **トークン・パスワード・トンネルの変数（`ALL_PROXY`・`https_proxy`）は、この設定に書かない**。ホストの `~/.bashrc` の、読み込みの 1 行より後ろに書く
- **root のシェルは対象外**
  - root の `~/.bashrc` にこの 1 行を足すと、Homebrew のユーザーが持つコマンドを root で動かす。root で Homebrew のコマンドを使うなら、setup-notes の [homebrew.md の「root のシェルでも使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/homebrew.md#root-のシェルでも使う任意)
- **WSL・MSYS2・QMK MSYS は、ホームが別**
  - WSL は、WSL の中で手順 1〜10 を通す（試していない）。MSYS2・QMK MSYS のホームは対象外
- **macOS と zsh は対象外**（Homebrew の場所も `/home/linuxbrew/.linuxbrew` 決め打ち）

### 参照

- [README](../README.md) — 読むものの表、読む順番とその実測、移行で消す行
- setup-notes の手順書（`~/.bashrc` に書く手順のあるもの）: [homebrew.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/homebrew.md)・[zoxide.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/zoxide.md)・[starship.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/starship.md)・[yazi.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/yazi.md)・[eza.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/eza.md)・[gdu.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/gdu.md)・[bat.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/bat.md)・[neovim.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/neovim.md)・[podman.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/podman.md)
- ryo-aoki-pc/wezterm の [docs/install.md](https://github.com/ryo-aoki-pc/wezterm/blob/main/docs/install.md) — シェル統合
- `man bash`（INVOCATION: ログインシェル・対話のシェル・sshd から起動されたときに読むファイル）

---

### 付録: コンテナでの検証記録（2026-09-30）

x86_64 のクラウドホストで `dockerd` を動かし、`docker run -d --network host almalinux:10 sleep infinity` で使い捨てのコンテナを立てた。実機には何も加えていない。

- 検証環境だけの変更
  - dnf・Homebrew・git がホストのプロキシを通るように `https_proxy` を渡し、プロキシの CA を取り込んだ
  - root で `git openssh-server openssh-clients rsync strace procps-ng util-linux which sudo findutils tar file gcc make diffutils man-db` を入れた
  - Homebrew は、`/home/linuxbrew/.linuxbrew` を先に作って、インストーラを `NONINTERACTIVE=1` で流して入れた。その後 `brew install zoxide yazi eza bat neovim gdu starship shellcheck`（全ユーザーから見える）
  - 手順 2 の clone の URL を、このリポジトリの作業中のコミットの bare リポジトリ（`/tmp/bash.git`）に置き換えた（非公開の GitHub への認証は試していない）。root が持つ bare リポジトリなので、`git config --system --add safe.directory /tmp/bash.git` を足した
  - `~/.config/wezterm` には ryo-aoki-pc/wezterm を clone し、`shell/wezterm.sh` を直したものに差し替えた
  - sshd は、`/etc/ssh/sshd_config.d/90-test.conf`（`Port 2222`・`ListenAddress 127.0.0.1`）で立て、ユーザーごとに鍵を作った
- **この文書の bash のコードブロックを機械的に抜き出したもの**を、手順ごとにそのユーザーの `bash -s` に流した（折り畳みの中のブロックは除いた。`su -` で入るので、流すたびにそのユーザーのログインシェルが `~/.bashrc` を読む）
- 手順 6 は、エディタの代わりに awk で、手順 4 の `grep` が出した WezTerm の `if … fi` の 3 行を消し、Homebrew を使う 3 行と zoxide の行を末尾へ移して、zoxide の行に `--hook none` を足した
- 手順 9・10: そのユーザーで `script -q -E never -O <ログ> -c 'bash -il'` を `TERM=xterm-256color TERM_PROGRAM=WezTerm` で開き（手順 9 の代わり）、手順 10 のブロックを 1 行ずつ打ち込んで、ログから制御文字を除いて読んだ

**2 回目（今の版。手順 5・6 を入れ替え、手順 7 を足し、更新を 2 つに分け、ロールバックの手順 4 に `log` と `stash list` を足した後）**

| ユーザー（実施前の `~/.bashrc`） | 流した手順 | 結果 |
|---|---|---|
| m3（`/etc/skel` の 25 行、26 行目 `brew shellenv`（引数なし）、27〜33 行目 `y()`、34 行目 `zoxide init bash`、36〜38 行目 `if [ -n "$WEZTERM_SHELL_INTEGRATION" ]; then` の 3 行、39〜41 行目 `if type brew &>/dev/null; then` で `brew --prefix` を使う 3 行、42 行目 `eval "$(zoxide init bash --cmd cd)"`、43 行目ダミーの `GITLAB_TOKEN`） | 手順 1〜5・6（awk）・7・8・10、[更新](#更新)の手順 1・2、[ロールバック](#ロールバック)の手順 1〜5 | 手順 3 は `bash -n: OK`。手順 4 の `git diff` は 26〜34 行目の 9 行を `-` で出し、`grep` は WezTerm の 2 行（`fi` は出ない）・Homebrew を使う 2 行・zoxide の行を出した。手順 4・5 を流したログインシェルは `zoxide: command not found` を出した（手順 4 の補足）。手順 7 は `bash -n: OK` と、読み込みの行（28 行目）の後ろに移した 29・30・32 行目。手順 10 は手順 10 の補足のとおり。更新は `Fast-forward` と `検証用のコミット` の 1 行。ロールバックの手順 1 は `0`、手順 2 は消した行と移した行を出し、手順 3 で実施前と同じ 43 行に戻った。手順 4 は `## …` の 1 行だけ、手順 5 は `No such file or directory` |
| m4（`/etc/skel` の後ろに、手順書が書く行をすべて、並びを直す前の手順書の並びで。starship が最後） | 手順 1〜5・8・10 | 手順 3 で 20 行がすべて消え、手順 4 の `grep` は何も出さなかった（手順 6・7 は飛ばした） |
| n2（`/etc/skel` のまま） | 手順 1〜5・8・10 | 手順 4 は何も出さず、手順 10 は m4 と同じ |
| g2（ホームにドットファイルが 1 つも無い。Git Bash の新しいホームの代わり） | 手順 1〜5・8・10 | 手順 1 は `grep: /home/g2/.bashrc: No such file or directory` も出した。手順 3 で空の `~/.bashrc` ができた。手順 8 は 2 行の `~/.bash_profile` を作り、手順 10 のログインシェルはそこから `~/.bashrc` を読んだ（1 行目が `1`） |

- 最初に流した n2・g2 は、検証の手違いで `~/.config` を root で作っていたので、手順 2 が `Permission denied` になり、手順 3 は `中断: 手順 2 の clone ができていない` で何も変えなかった（直してから、はじめから流し直した）

2 回目で個別に確かめたこと:

| 確かめたこと | 結果 |
|---|---|
| m3 の、開き直した対話のシェル | `MY_BREW_PREFIX=/home/linuxbrew/.linuxbrew`（Homebrew を使う行が動いた）、`type -t cd z` は 2 つとも `function`、`PROMPT_COMMAND` の `__zoxide_hook` は `. ~/.bashrc` の前後とも 1 つ、`cd /usr/share; cd; cd share` で `/usr/share`、`zoxide: detected a possible configuration issue.` は出なかった |
| `set -u`（m3） | `bash --norc -u -i -c '. ~/.config/bash/bashrc; echo "ok-$__bash_config_loaded"'` は `ok-1`（後半まで読んだ） |
| 手元だけのコミットと stash があるときのロールバックの手順 4（n2） | `[ahead 1]`、`log` のコミット 1 行、`stash@{0}: …` が出た |

**1 回目（手順 5 と 6 が逆で、手順 7 が無かった版）**

| ユーザー（実施前の `~/.bashrc`） | 流した手順（今の番号） | 結果 |
|---|---|---|
| mig（m3 から、Homebrew を使う 3 行と `--cmd cd` の zoxide の行を除いたもの。`GITLAB_HOST` の行もあった） | 手順 1〜4、手順 6（`sed -i 27,29d`）、手順 5・8・10、更新（当時の 1 つのブロック）、ロールバックの手順 1〜5 | 最初の手順 2 は、bare リポジトリの `safe.directory` を足す前で `fatal: detected dubious ownership` になり、手順 3 は `中断: 手順 2 の clone ができていない` で何も変えなかった。そのほかは 2 回目の m3 と同じ（手順 3 で 9 行が消え、手順 3 の控えから実施前に戻った） |
| mig2（2 回目の m4 と同じ） | 手順 1〜5・8・10 | 2 回目の m4 と同じ |
| new・gb（2 回目の n2・g2 と同じ） | 手順 1〜5・8・10 | 2 回目の n2・g2 と同じ |

1 回目で個別に確かめたこと:

| 確かめたこと | 結果 |
|---|---|
| 移行の前後の、対話のシェルの状態（mig2。`alias`・`declare -F`・`PATH`・`EDITOR`・`VISUAL`・`MANPAGER`・`DOCKER_HOST`・`PROMPT_COMMAND`） | 違いは 2 つだけ。`DOCKER_HOST` が `unix:///podman/podman.sock`（ソケットが無く、`XDG_RUNTIME_DIR` も空のまま足されていた）から空になった。`PROMPT_COMMAND` は `([0]="starship_precmd" [1]="__zoxide_hook")` から `([0]="__wezterm_prompt_command;__wz_mouse_off;starship_precmd" [1]="__zoxide_hook")` になった（README の[読む順番](../README.md#読む順番)） |
| 移行の前後（mig） | `PATH` は変わらず、`GITLAB_*` の 2 行は `~/.bashrc` に残った。前の `~/.bashrc` に無かった eza・gdu・Neovim・bat・starship の設定が足された（Homebrew に入っているため）。WezTerm の関数は、古い形の行が `WEZTERM_SHELL_INTEGRATION` を要したので前には無かった |
| 2 度目の手順 3・5 | `中断: ~/.bashrc.before-bash が既にある`。読み込みの行は 1 つのまま |
| `git -c core.autocrlf=true clone` | `git ls-files --eol` はすべて `i/lf w/lf attr/text=auto eol=lf`、`bashrc` の CR は 0 個。CRLF にした `bashrc` を読むと `$'\r': command not found` と `syntax error` になった |
| `remove-old-lines.awk` を直接（すべての行の後ろに、手で直した `alias ll="eza -l --icons"`、ファイルの末尾で改行の無い `y()`、余分な `}` を置いたファイル） | 手で直した行と余分な `}` は残り、`y()` は 2 つとも消えた。余分な `}` は `bash -n` が `syntax error near unexpected token '}'` で見つけた |
| 非対話のシェル（全部のツールがあるユーザー） | `bash -c '. ~/.bashrc' 2>&1 \| wc -c` は `0`。`ssh <HOST> true` の出力は 0 バイト（初回の `known_hosts` の警告を除く）。`ssh <HOST> 'echo …'` では `EDITOR=nvim` と Homebrew の `brew` が見え、`y`・`ll`・`z` と `__bash_config_loaded` は無かった。scp・`scp -O`・sftp・rsync は通った |
| `set -u`（非対話） | `bash -u -c '. ~/.config/bash/bashrc; echo ok'` は `ok` |
| 起動の時間（`bash -i -c exit` を 20 回の平均。全部のツールがあるユーザー） | `/etc/skel` だけ 38.6 ms、今の手順書どおりの `~/.bashrc` 77.5 ms、この設定 79.1 ms |
| 非対話で `~/.bashrc` を読む時間と、起動するプロセス（`strace -f` の `clone`） | `/etc/skel` だけ 34.1 ms・22 回、今の手順書どおり 64.2 ms・54 回、この設定 46.7 ms・27 回（非対話では zoxide と starship を初期化しないため） |
| 開いたシェルに zoxide を入れて `. ~/.bashrc` | `z` が使え、警告は出ず、`false` の後は `D;1` |
| 開いたシェルに Homebrew・eza・gdu・yazi・bat・Neovim を入れて（`brew link` し直して）`. ~/.bashrc` | 開いた直後は無く、読み直した後に `brew --version`（と Homebrew の zoxide・eza）・`alias ll la lt`・`alias gdu`・`type -t y`・`MANPAGER`・`EDITOR` / `VISUAL` / `alias vi` が、元の手順書の確かめと同じ値になった |
| 開いたシェルに starship を入れて `. ~/.bashrc` | WezTerm のフックが `PROMPT_COMMAND` と starship の退避先の両方に入り、`false` の後に `D;1` と `D;0` が続けて送られた（[注意点](#注意点)） |
| shellcheck 0.11.0（`-s bash bashrc`） | 0 件（WezTerm の統合を読む行に `# shellcheck source=/dev/null` を置いた） |

#### 未確認事項

- Windows 11 の Git Bash での実行（`awk`・`git diff --no-index`・`~/.bash_profile` の生成と Git for Windows の警告・起動の時間・`command -v` が見つからないときの時間・`y()`・`--hook none` の zoxide）
- WSL、MSYS2・QMK MSYS
- 実機（AlmaLinux 10）と aarch64
- 非公開の GitHub のリポジトリの clone と pull（gh と Git Credential Manager の認証）
- インターネットに出られないホストでの更新
- podman のソケットがあるときの `DOCKER_HOST`（ソケットのある systemd のユーザーのセッションは作っていない）
- 端末の画面（プロンプトへのジャンプ・出力のコピー）
