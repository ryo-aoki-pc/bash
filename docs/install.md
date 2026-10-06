# bash の共通の設定の導入手順（AlmaLinux 10 / Windows 11 の Git Bash）

## 実施手順

- 通常は [簡単な導入](quick-start.md)で、clone と `install.sh` の実行だけを行う。以下は移行内容を手で確認しながら進める手順。両方を通す必要はない
- `install.sh` による新規導入・再実行は AlmaLinux 10.2 の x86_64 VM でも確認した（[2026-10-06 の記録](quick-start.md#新規-almalinux-vm-での再検証2026-10-06)）。同じ VM の専用ユーザーでは、既知の旧設定を用意して手動移行も確認した（末尾の再検証記録）。任意の編集操作をすべて試した記録ではない

> [!IMPORTANT]
> - **自分のユーザーのシェルで貼る**。root のシェルにも入れるなら、この手順の後で [root のシェルでも読む（任意）](#root-のシェルでも読む任意)を通す（一般ユーザーを信用できるホストだけ）
> - **Windows 11 では、Git for Windows の Git Bash に同じブロックを貼る**。WSL は Linux のホストとして、WSL のシェルで別に通す（`/mnt/c` の clone は使わない）
> - **前提**: git が入っていること（公開のリポジトリを HTTPS で clone する。GitHub の鍵や認証は要らない）
>   - git: AlmaLinux 10 は setup-notes の [git.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/git.md)、Windows 11 は [Git for Windows](https://gitforwindows.org/)
>   - **インターネットに出られないホストは、setup-notes の [ssh-socks-tunnel.md 手順 1〜3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/ssh-socks-tunnel.md#実施手順) でトンネルを張ったシェルで貼る**（HTTPS の git は `ALL_PROXY` を読む）
> - **手順 6 はエディタで直す操作、手順 9 は端末を開き直す操作**。手順 10 は、開き直した端末で貼る

- 上から順にコードブロックを貼る
- 各手順の末尾の「補足」（折り畳み）と後半の[補足](#補足)は、実行するだけなら読まなくてよい。折り畳みの中のブロックも貼らなくてよい
- この設定が何をどの条件で読むかは [README](../README.md) にある
- 手順の後: root のシェル（`sudo -i`・`su -`）でも読むなら [root のシェルでも読む（任意）](#root-のシェルでも読む任意)。以後は[更新](#更新)・[ロールバック](#ロールバック)。ツールを入れたときに `~/.bashrc` へ書く手順（setup-notes の各手順書）は、このホストでは貼らない（各手順書の箇条書きにある）

> [!WARNING]
> **AlmaLinux 10 は、x86_64 のコンテナ・新規 VM と、aarch64 の実機（Raspberry Pi 5）で検証した**（実機は、その本物の `~/.bashrc` に導入した。どちらも、画面の代わりに擬似端末や tmux のペインで対話のシェルを動かした）。**Windows 11 は、実機の Git Bash で `HOME` を使い捨てのディレクトリにして流し、その後、その PC の本物の `~/.bashrc` に導入した**。**2026-10-06 に Windows ホストで設定本体と移行 awk を再検証した**（履歴・`shopt`・fzf・fd を含む。bat のプレビュー、Homebrew の補完、fzf の実際のキー操作は未確認）。**WezTerm の GUI の画面とキー操作は、どの OS でもまだ試していない**。**x86_64 の AlmaLinux 10 の実機では試していない**（WSL では、SSH で clone していたときの手順 2 と[更新](#更新)だけを流した）。**HTTPS の clone と既知の旧設定の手動移行は、2026-10-06 に x86_64 の新規 VM の専用ユーザーでも確認した**。**インターネットに出られないホストの、トンネル越しの HTTPS の clone と更新も試していない**。**root 自身の新規導入・再実行は x86_64 の新規 VM でも `install.sh` で確認した**。詳しくは[対象と検証環境](#対象と検証環境)。

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
   - インターネットに出られないホストでは、setup-notes の [ssh-socks-tunnel.md 手順 1〜3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/ssh-socks-tunnel.md#実施手順) でトンネルを張ったシェルで貼る（トンネル越しには試していない。この手順の補足）
   - 止まったときは `~/.config/bash` は残らないので、そのまま貼り直せる

   <details>
   <summary>補足: <code>~/.config/bash</code> に置く理由と、HTTPS の clone</summary>

   - ほかの自分用の設定（`~/.config/wezterm`・`~/.config/yazi`・`~/.config/lazygit`・`~/.config/nvim`）と同じく、ツールの名前の付いたディレクトリにまとめる
   - `~/.bashrc` の 1 行（手順 5）と、手順 3 の `awk` は、この置き場所を決め打ちにしている。別の場所に置くなら、両方を書き換える
   - Git Bash のホームは `/c/Users/<WIN_USER>`（setup-notes の [windows-openssh-server.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-openssh-server.md) の実測）なので、Windows では `C:\Users\<WIN_USER>\.config\bash` に置かれる。git は `Cloning into 'C:/…/.config/bash'...` と Windows の形のパスで出す（検証は使い捨ての `HOME` で行った）
   - `.gitattributes` で改行を LF に固定してある。`core.autocrlf=true` の git（scoop の git の既定）で clone しても、CRLF にならない（検証コンテナと、Windows 11 の Git for Windows 2.55.0 で `git -c core.autocrlf=true clone` して確かめた）
   - 2026-10-03 にこのリポジトリを公開し、clone を HTTPS に変えた（利用者の選択）
     - 認証は要らない。SSH の鍵・Git Credential Manager・gh の資格情報は使わない
     - x86_64 の AlmaLinux 10 のコンテナで、git の認証の設定の無いユーザーが、問いを出させない `GIT_TERMINAL_PROMPT=0` を付けて clone できた（`~/.ssh` も作られなかった）
     - 非公開だった間は、2026-10-01 までは HTTPS（gh の資格情報）、その後は SSH（GitHub に登録した鍵）で clone していた（記録は付録）
   - インターネットに出られないホストも、同じ URL で clone する。HTTPS の git は `ALL_PROXY` を読み、SSH の git は読まない
     - Windows 11 の PC で、待ち受けの無いプロキシ（`socks5h://127.0.0.1:9`）を `ALL_PROXY` に入れると、SSH の git はプロキシを使わずに通り、HTTPS の git は `Failed to connect to github.com:443 over proxy 127.0.0.1` で失敗した
     - HTTPS の git がトンネルを通ることは、setup-notes の ssh-socks-tunnel.md 手順 3 の補足が、公開のリポジトリで確かめている。このリポジトリをトンネル越しに clone・pull するところは試していない
   - 止まったときに `~/.config/bash` が残らないことは、非公開だったときに、HTTPS で認証を聞かれたところを `Ctrl+C` で止めて確かめた（AlmaLinux 10.2 の git 2.52.0）

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
   - yazi の `y()` は、`migrate/old-y.txt` の形のどれかと、続く行がすべて同じときだけ消す。形は、setup-notes の yazi.md の 7 行（今の形と、2026-10-01 に比べ方を直す前の形）と、それぞれを LazyVim で保存した 8 行（保存のときに shfmt が整形した形）の 4 つ。`sed '/^function y() {$/,/^}$/d'` のような範囲の消し方は、閉じ括弧が見つからないと最後の行まで消すので使わない
   - 控えの `~/.bashrc.before-bash` から読み、`~/.bashrc` に書く。`~/.bashrc` のファイル自体（パーミッション）はそのまま
   - `touch` は、Git Bash で `~/.bashrc` がまだ無いときに空のファイルを作るため
   - 検証コンテナで、実機と同じ並び（Homebrew・`y()`・zoxide・`if … fi` の 3 行の WezTerm）の `~/.bashrc` に流した出力は、[付録](#付録-コンテナでの検証記録2026-09-30)にある

   </details>

1. 手順 3 で消した行と、残った関係の行を見る。

   ```bash
   git --no-pager diff --no-index ~/.bashrc.before-bash ~/.bashrc
   grep -n -i -E 'brew|zoxide|starship|yazi|eza|gdu-go|MANPAGER|nvim|DOCKER_HOST|wezterm|HIST|shopt|bash_completion|fzf|FZF_' ~/.bashrc
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
   - Git for Windows が作った `~/.bash_profile` のある Git Bash では、`/c/Users/<WIN_USER>/.bash_profile:3:test -f ~/.bashrc && . ~/.bashrc` の 1 行が出る（何も作らない）
   - ログインシェルの設定ファイルが 1 つも無いホスト（新しい Git Bash）では、作った 2 行が出る
   - 既にあるファイルが何も出さなければ、そのファイルは `~/.bashrc` を読んでいない。エディタで `if [ -f ~/.bashrc ]; then . ~/.bashrc; fi` を足す

   <details>
   <summary>補足: Git Bash の <code>~/.bash_profile</code></summary>

   - WezTerm や Git Bash のショートカットは、bash をログインシェル（`-l`）で起動する。ログインシェルは `~/.bash_profile`・`~/.bash_login`・`~/.profile` の最初に見つかった 1 つだけを読み、`~/.bashrc` は読まない
   - Git for Windows は、`~/.bashrc` があって 3 つとも無いと、`~/.bashrc` を読む `~/.bash_profile` を作り、`WARNING: Found ~/.bashrc but no ~/.bash_profile, ~/.bash_login or ~/.profile.` と赤く表示する（`/etc/profile.d/bash_profile.sh`）。この手順は、それを先に作っておくもの
     - 検証した PC（Git for Windows 2.55.0）で、`~/.bashrc` だけがあるホームのログインシェルを開くと、この表示が出て、`# generated by Git for Windows` で始まる 3 行の `~/.bash_profile` ができた。この手順で作った後は出なかった
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
   echo "HISTSIZE=${HISTSIZE} $(shopt -p autocd globstar | tr '\n' ' ')"
   bind -X
   complete -p brew bat 2>/dev/null
   bash -c '. ~/.bashrc' 2>&1 | wc -c
   ```

   - 1 行目が `1` なら、対話のシェルでこの設定が最後まで読まれている
   - `HISTSIZE=100000 shopt -s autocd shopt -s globstar` は、どのホストでも出る（履歴と `shopt`）
   - `bind -X` は、fzf があれば Ctrl+R の `__fzf_history__` と Ctrl+T の `fzf-file-widget` を出す。Git Bash 5.3 では `"\C-r" "__fzf_history__"` のようにコロンが無く、WezTerm の統合を読むとマウス報告よけの行も出る。`complete -p` は、Homebrew の bat があれば `complete -F _fzf_path_completion bat`（fzf が無ければ `_bat`）と `brew` の行
   - 2〜4 行目は、このホストに入っているツールの分だけ出る（README の[読むもの](../README.md#読むもの)）。eza があれば `ll`・`la`・`lt`、yazi があれば `function`（`y`）、zoxide があれば `function`（`z`）
   - Git Bash では、eza が無くても `alias ll='ls -l'` が出る（Git for Windows の `/etc/profile.d/aliases.sh` のもので、この設定のものではない）。`alias gdu` は出ない（scoop の gdu は `gdu` の名前で入る）
   - AlmaLinux 10 でも、eza が無いと `alias ll='ls -l --color=auto'` が出る（coreutils-common の `/etc/profile.d/colorls.sh` のもので、この設定のものではない）
   - 最後が `0` なら、非対話のシェル（`ssh <HOST> <コマンド>`・scp・rsync）で何も出力しない
   - 1 行目が `読まれていない` なら、手順 5・8 を見直す

   <details>
   <summary>補足: 検証での出力</summary>

   検証コンテナで、Homebrew で zoxide・yazi・eza・bat・neovim・gdu・starship を入れたユーザーの、開き直した対話のシェル（`script` の擬似端末）での出力（プロンプトは省いた）:

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
   - 上の 3 つの出力は、2026-10-02 に足した `HISTSIZE` / `bind -X` / `complete -p` の 3 行より前のもの。追加分は、[x86_64 のコンテナの付録](#付録-履歴shopthomebrew-の補完fzf-を足したときの検証記録2026-10-02)と、[Windows ホストでの再検証の付録](#付録-windows-ホストでの設定の再検証2026-10-06)を参照

   AlmaLinux 10 の実機（Raspberry Pi 5。Homebrew で zoxide・yazi・neovim を入れたホスト）で、開き直したログインシェル（tmux のペイン）での出力:

   ```
   1
   alias ll='ls -l --color=auto'
   alias vi='nvim'
   function
   function
   EDITOR=nvim DOCKER_HOST=
   0
   ```

   - `alias ll` は `/etc/profile.d/colorls.sh` のもの（eza が無いので、この設定の `ll` は無い）
   - podman の API ソケットを一時的に起動して（`systemctl --user start podman.socket`）開き直すと、`EDITOR=nvim DOCKER_HOST=unix:///run/user/<UID>/podman/podman.sock` になった

   Windows 11 の PC の Git Bash（scoop で neovim・yazi・zoxide を入れた PC）で、開き直したログインシェル（画面を出さない `wezterm-mux-server` のペイン）での出力:

   ```
   1
   alias ll='ls -l'
   alias vi='nvim'
   function
   function
   EDITOR=nvim DOCKER_HOST=
   0
   ```

   - 同じ PC で eza・bat・gdu・starship も足すと、`alias ll='ls -l'` の代わりに `la`・`ll`・`lt` の eza の 3 行が出た。`alias gdu` は出なかった
   - Git Bash には `XDG_RUNTIME_DIR` が無いので、`DOCKER_HOST` は入らない

   </details>

---

## root のシェルでも読む（任意）

- **root のシェル（`sudo -i`・`su -`）でこの設定を使わないなら、この節は不要**
- root の `~/.config/bash`（`/root/.config/bash`）に root の clone を作り、root の `~/.bashrc`（`/root/.bashrc`）の末尾に同じ 1 行を足す
- [実施手順](#実施手順)のブロックは `~` を使っているので、root のシェルでそのまま貼る
- root でも、自分のユーザーと同じものを読む（`brew shellenv` で Homebrew が PATH の先頭、starship・zoxide・fzf・Homebrew の補完も）
- `DOCKER_HOST` は、root のコンテナのソケット（`/run/podman/podman.sock`。setup-notes の [lazydocker.md の「root でも使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/lazydocker.md#root-でも使う任意)）
- [実施手順](#実施手順)の手順 3 で、setup-notes が `/root/.bashrc` に書く 2 行も消える（この設定が同じことをする）
  - [homebrew.md の「root のシェルでも使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/homebrew.md#root-のシェルでも使う任意)の PATH の行と、lazydocker.md の「root でも使う」の `DOCKER_HOST` の行
- 前提: 自分のユーザーで[実施手順](#実施手順)を通してあること
- この節の手順 1 で root のシェルに入り、手順 3 で入り直す
- `sudo -i` は `ALL_PROXY` を渡さない。インターネットに出られないホストで root の clone は試していない
- 補足: [root のシェルで読むときの違い](../README.md#root-のシェルでの違い)（README）

> [!WARNING]
> - **自分専用のマシンで、一般ユーザーを信用できるときだけ通す**。root のシェルを開くたびに、Homebrew のユーザーが書き換えられるコマンド（`brew shellenv`・starship・zoxide・fzf）とファイル（Homebrew の補完）が root で動く
> - root でも Homebrew が PATH の先頭になる。root の `git`・`curl` なども、Homebrew に入っていれば Homebrew のものが使われる（`brew install` などは root では断られる）
> - この節は **x86_64 のコンテナでのみ検証した**（[付録](#付録-root-のシェルでも読む節の検証記録2026-10-05)）

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

   <details>
   <summary>補足: root で流したときの出力</summary>

   検証コンテナで、setup-notes の root の 2 行がある `/root/.bashrc` に流したときの、手順 4 の `git diff` と手順 8 の出力（抜粋）:

   ```
   @@ -20,5 +20,3 @@ export PATH
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
   -case ":${PATH}:" in *:/home/linuxbrew/.linuxbrew/bin:*) ;; *) PATH="${PATH}:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin" ;; esac
   -export DOCKER_HOST=unix:///run/podman/podman.sock
   ...
   /root/.bash_profile:4:if [ -f ~/.bashrc ]; then
   /root/.bash_profile:5:  . ~/.bashrc
   ```

   - 手順 2 は `Cloning into '/root/.config/bash'...`。この時の root のシェルはまだこの設定を読んでいないので、git は RPM のもの
   - AlmaLinux 10 の `/root/.bashrc` は、`cp`・`rm`・`mv` を `-i` のエイリアスにしている。手順 3 の `cp -p` は控えがまだ無いので聞かれない。[ロールバック](#ロールバック)の手順 3 には `command` を付けてある（付ける前は、`cp: overwrite '/root/.bashrc'?` が次に貼った行を答えとして読み、控えに戻らなかった）

   </details>

1. root のシェルを `exit` で抜けて、`sudo -i` で入り直す。

   - 自分のユーザーのシェルに戻ってから、`sudo -i` と打つ
   - ほかに開いたままの root のシェルには効かない。開き直す
   - **次の手順は、入り直した root のシェルで貼る**

1. 入り直した root のシェルで、[実施手順](#実施手順)の手順 10 を貼る。

   - 1 行目が `1`、最後が `0` ならよい
   - `DOCKER_HOST=unix:///run/podman/podman.sock` は、システムの `podman.socket` を有効にしたホスト（setup-notes の lazydocker.md の「root でも使う」の手順 1）だけ。無ければ空
   - 確かめたら `exit` で抜ける

   <details>
   <summary>補足: root のシェルでの出力</summary>

   検証コンテナ（Homebrew で starship・zoxide・fzf・eza・lazydocker を入れ、システムの `podman.socket` を有効にしたホスト）で、入り直した root のシェルでの出力（プロンプトは省いた）:

   ```
   1
   alias la='eza -la --git --group-directories-first'
   alias ll='eza -l --git --group-directories-first'
   alias lt='eza --tree --level=2'
   function
   EDITOR= DOCKER_HOST=unix:///run/podman/podman.sock
   HISTSIZE=100000 shopt -s autocd shopt -s globstar
   "\C-r": "__fzf_history__"
   "\C-t": "fzf-file-widget"
   complete -o bashdefault -o default -F _brew brew
   complete -o bashdefault -o default -F _fzf_path_completion bat
   0
   ```

   - プロンプトは starship の `root in ~` になった
   - `printenv PATH` は `/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/root/.local/bin:…` で、Homebrew が先頭。`git`・`curl` は Homebrew に無いので `/bin` のもの
   - `brew install tree` は `Error: Running Homebrew as root is extremely dangerous and no longer supported.` で止まった
   - `function` は `z` の 1 行（yazi は入れていないので `y` は無い）

   </details>

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
   - `set-url` は、HTTPS で clone したホストでは何も変えない。SSH で clone したホスト（2026-10-01〜10-03 の版の手順）を HTTPS にそろえる
   - インターネットに出られないホストは、setup-notes の [ssh-socks-tunnel.md 手順 1〜3](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/ssh-socks-tunnel.md#実施手順) でトンネルを張ったシェルで貼る（トンネル越しには試していない。[手順 2](#実施手順) の補足）
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
   - [手順 8](#実施手順) で作った `~/.bash_profile` は残す（Git Bash は、消すと次の起動で赤い `WARNING:` を出し、`~/.bashrc` を読む別の `~/.bash_profile` を作る。[手順 8](#実施手順) の補足）
   - 開いている端末には、この設定の関数やフックが残る。開き直すと消える

---

## 補足

### 対象と検証環境

- **目的**: いろいろなホストで同じ bash の設定を使う。setup-notes の手順書と wezterm の手順書がホストごとに `~/.bashrc` へ書いていた行を、このリポジトリの `bashrc` 1 つにまとめ、`~/.bashrc` からは 1 行で読む
- **進め方**: git で `~/.config/bash` に clone し、`~/.bashrc` から元の手順書の行を消して、読み込みの 1 行を足す。**読者が書き換える変数は無い**（リポジトリの URL と置き場所は固定）
- **現行版の新規 VM**: 2026-10-06 に `3d5323e` の自動導入・再実行・root の設定と、専用ユーザーの既知の旧設定の手動移行を確認した（末尾の再検証記録）。実キーの全組み合わせ、任意の手編集、物理実機は含まない
- **状態**: **AlmaLinux 10 は x86_64 のコンテナで検証済み（2026-09-30）。Windows 11 は、実機の Git Bash で `HOME` を使い捨てのディレクトリにして流し、その PC の本物の `~/.bashrc` に導入した（2026-10-01）。clone を SSH に変えた後、手順 2 と[更新](#更新)を、その PC の Git Bash と WSL の AlmaLinux 10 で流し直した（2026-10-01）。AlmaLinux 10 の aarch64 の実機（Raspberry Pi 5）の本物の `~/.bashrc` に導入した（2026-10-02）。2026-10-03 にこのリポジトリを公開して clone を HTTPS に変え、手順 2 と[更新](#更新)を x86_64 のコンテナで流し直した**
  - AlmaLinux 10: 下表の検証コンテナで、**この文書の bash のコードブロックを抜き出したもの**を、一般ユーザーの `bash -s` に手順ごとに流した（[付録](#付録-コンテナでの検証記録2026-09-30)）
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
  - Windows 11: 下表の PC の Git Bash で、**この文書の bash のコードブロックを抜き出したもの**を、画面を出さない WezTerm の端末（`wezterm-mux-server` のペイン）のログインシェル（`bash -i -l`。WezTerm の既定の起動と同じ）に、括弧付き貼り付けで貼って流した（[付録](#付録-windows-11-の-git-bash-での検証記録2026-10-01)）
    - 手順 9 は、ペインを閉じて新しいペインを開いた
    - `HOME` は使い捨てのディレクトリにした（その PC の `~/.bashrc` と `~/.bash_profile` の写し、ドットファイルの無いホーム、空白と日本語を含むホーム）
    - 確認したこと
      - 手順 1〜5・8・10、[更新](#更新)の手順 1 の pull と log、[ロールバック](#ロールバック)の手順 1〜5（その PC の `~/.bashrc` の写しは、元と同じ中身に戻った）
      - 非公開のリポジトリの clone と pull。はじめは HTTPS（認証は gh の資格情報）で流し、clone を SSH に変えた後に、手順 2（初めてつなぐときの問いに `yes` と `no`）と更新を SSH で流し直した（[付録](#付録-ssh-の-clone-に変えたときの検証記録2026-10-01)）。`core.autocrlf=true` の clone で LF
      - Git Bash の awk・`git diff --no-index`・`sed -i`・読み取り専用のファイルを含む `rm -rf`。移行の awk が、LazyVim で整形された `y()` を消さないことを見つけて直した
      - `~/.bash_profile` の無いホームで Git for Windows が出す `WARNING:` と、それが作る `~/.bash_profile`
      - 対話のシェルの OSC 133 の `D`・zoxide の警告・読み直し（starship の有無の両方）、`--hook none` の zoxide、`y()`（本物の yazi を端末で動かした）
      - 非対話のシェル（sshd の起動のしかたを真似た `bash -c`）で何も出さないこと、`set -u`、起動の時間と `command -v` の時間
      - 開いたシェルにツールを入れて `. ~/.bashrc` で読み直したとき（eza・bat）
      - その PC の sshd に、同じ PC の WSL の AlmaLinux 10 から鍵でつないだ: `ssh <HOST> <コマンド>`・`scp -O`・scp・sftp・対話の ssh。SSH のセッションで scoop の shim が起動できない状態（本物の RedirectionGuard）も作って比べた
    - 2026-10-01 の後半に、その PC の本物の `~/.bashrc` に導入した。利用者の WezTerm の GUI に新しい窓を開いて手順 1〜5・8 を貼り、開き直した窓で手順 10 と、cwd の引き継ぎ・`z`・`y` を確かめた。clone を SSH に変えた後、その PC の `~/.config/bash` も SSH に切り替えた（[更新](#更新)の手順 1 の箇条書き）
  - WSL の AlmaLinux 10（同じ PC の WSL）: 手順 2 と[更新](#更新)の手順 1 の pull と log だけを、`HOME` を使い捨てのディレクトリにして流した（[付録](#付録-ssh-の-clone-に変えたときの検証記録2026-10-01)）
  - AlmaLinux 10 の実機（下表の Raspberry Pi 5）: 利用者の依頼で、その本物の `~/.bashrc` に導入し、導入を残した（[付録](#付録-almalinux-10-の実機aarch64への導入2026-10-02)）
    - **この文書の bash のコードブロックを抜き出したもの**を、利用者の tmux とは別のソケットの tmux のペインのログインシェルに、括弧付き貼り付けで貼って流した。手順 9 は、tmux のセッションを閉じて開き直した
    - 確認したこと
      - 手順 1〜5・8・10、[更新](#更新)の手順 1 の pull と log（元の手順書の 9 行を消す移行、SSH の clone）
      - 対話のシェルの OSC 133 の `D`・zoxide の警告・読み直し（COPR の WezTerm の公式のシェル統合がある形。WezTerm の GUI・ssh・tmux の 3 つの端末の形）と、導入の前後のシェルの状態の比較
      - `y()`（本物の yazi）と `z`
      - 非対話のシェルで何も出さないこと（`bash -c`、自分のユーザーで 127.0.0.1 に立てた sshd 越しの `ssh <HOST> <コマンド>`・scp・`scp -O`・sftp）、対話の ssh、`set -u`
      - podman のソケットがあるときの `DOCKER_HOST`（`systemctl --user start` で一時的に起動した）、起動の時間
  - HTTPS の clone（2026-10-03）: x86_64 の AlmaLinux 10 のコンテナで、手順 1・2 と[更新](#更新)の手順 1 を一般ユーザーの bash に流した（[付録](#付録-https-の-clone-に変えたときの検証記録2026-10-03)）
    - 確認したこと: 問いを出させない `GIT_TERMINAL_PROMPT=0` で clone と pull が通る、LF、SSH で clone したホストの代わり（`origin` を `git@github.com:…` にした clone）が更新で HTTPS になって pull できる
  - 2026-10-02 に `bashrc` に足した履歴と `shopt`・Homebrew の補完・fzf は、x86_64 のコンテナで確かめた（[付録](#付録-履歴shopthomebrew-の補完fzf-を足したときの検証記録2026-10-02)）。2026-10-06 に Windows ホストでも設定本体と移行 awk を再検証した（[付録](#付録-windows-ホストでの設定の再検証2026-10-06)）
    - 確認したこと: 履歴の追記と `ignoreboth`、`shopt`、scoop の fzf・fd、対話と非対話での `set -u`、ログインシェル、OSC 133 の `D;1`、読み直しでのフックの重複防止、zoxide、Windows 形式の cwd-file を使う `y()`（スタブ）、非ゼロの `EUID` と既存 `DOCKER_HOST` の保存、移行 awk の 8 ケース
    - 今回確認していないこと: Homebrew の補完、bat のプレビュー、fzf の実際のキー操作、本物の yazi TUI、実 SSH 通信、導入・更新・ロールバック手順全体
  - [root のシェルでも読む](#root-のシェルでも読む任意)の節（2026-10-05）: x86_64 のコンテナで、setup-notes の root の 2 行がある `/root/.bashrc` に、その節の手順を tmux のペインに貼って流した（ブラケットペーストの無しと有り。[付録](#付録-root-のシェルでも読む節の検証記録2026-10-05)）
    - 確認したこと: 2 行が移行で消える、`sudo -i`・`su -`・`sudo -s` の root のシェルで最後まで読まれる、Homebrew が PATH の先頭で `brew install` は断られる、root の `DOCKER_HOST`、`sudo -i lazydocker` が root のコンテナを出す、非対話で何も出さない、元に戻すと `/root/.bashrc` が元と同じ中身に戻る、自分のユーザーの `DOCKER_HOST` は変わらない
    - 見つけて直したこと: [ロールバック](#ロールバック)の手順 3 の `cp`・`rm` が、root のエイリアスで聞いた
    - 確認していないこと: Linux の実機、aarch64、インターネットに出られないホストでの root の clone。Git Bash で `EUID` が 0 にならず、既存 `DOCKER_HOST` を変えないことは 2026-10-06 に確認した
  - **確認していないこと**: WSL での手順 2・更新以外、x86_64 の AlmaLinux 10 の実機、AlmaLinux 10 の実機の、システムの sshd（PAM を通る）越しの ssh と rsync、LAN の別の PC からの ssh、HTTPS の clone と更新の、Windows 11 の Git Bash と実機での実行、インターネットに出られないホストでの導入と更新（トンネル越しの HTTPS の clone と pull）、WezTerm の GUI の画面とキー操作（プロンプトへのジャンプ・出力のコピー。Windows の画面がロックされていて試せなかった。AlmaLinux 10 の実機の画面でも試していない）

| 項目 | 検証コンテナ | Windows 11 の PC（Git Bash） | AlmaLinux 10 の実機（Raspberry Pi 5） |
|---|---|---|---|
| 実施日 | 2026-09-30 | 2026-10-01 | 2026-10-02 |
| OS | AlmaLinux 10.2 (Lavender Lion) / x86_64（`almalinux:10`、Docker 29.3.1、`--network host`） | Windows 11 Pro 26H2（ビルド 26300.9457）/ x86_64 | AlmaLinux 10.2 (Lavender Lion) / aarch64（Raspberry Pi 5 Model B Rev 1.0、カーネル `6.12.96-20260724.v8.1.el10`、SELinux は Enforcing） |
| bash / git / gawk | `bash-5.2.26-6.el10` / `git-2.52.0-1.el10` / `gawk-5.3.0-6.el10` | Git for Windows 2.55.0.windows.5 の `5.3.15(2)-release`（MINGW64）/ `2.55.0.windows.5` / GNU Awk 5.4.1 | `bash-5.2.26-6.el10` / `git-2.52.0-1.el10` / `gawk-5.3.0-6.el10_2.1` |
| ツール | Homebrew 7.0.7（zoxide 0.10.0・yazi 26.9.1・eza 0.23.5・bat 0.26.1・neovim 0.12.5_1・gdu 5.37.0・starship 1.26.0） | scoop の neovim 0.12.5・yazi 26.9.1・zoxide 0.9.9。starship 1.26.0・eza 0.23.5・bat 0.26.1・gdu 5.37.0 は、scoop の manifest の URL から一時的な場所に落とし（ハッシュも照合）、scoop と同じ shim で呼んだ | Homebrew 7.0.7（zoxide 0.10.0・yazi 26.9.1・neovim 0.12.5_1）。eza・bat・gdu・starship は無い |
| WezTerm の設定 | ryo-aoki-pc/wezterm の `main`（`826037f`）に、`PS0`・`PS1` の印を BEL で終える直し（README の[読む順番](../README.md#読む順番)）を足したもの（1 回目は `PS0` だけ） | WezTerm 20260905-153129-092dcf70。ryo-aoki-pc/wezterm の `main`（`826037f`）と、ryo-aoki-pc/wezterm#26 の `shell/wezterm.sh` | ryo-aoki-pc/wezterm の `main`（`826037f`）。COPR（`wezfurlong/wezterm-nightly`）の `wezterm-20260929_043349_cab25161` の公式のシェル統合（`/etc/profile.d/wezterm.sh`）もある |
| sshd | `openssh-server-9.9p1-27.el10_2.alma.1`（検証環境だけ 127.0.0.1 の 2222 番） | OpenSSH for Windows 9.5p2（`DefaultShell` は Git Bash、`Subsystem sftp sftp-server.exe`）。クライアントは同じ PC の WSL 2.7.13.0 の AlmaLinux 10.2（OpenSSH 9.9p1。LAN の IP あて） | `openssh-server-9.9p1-27.el10_2.alma.1`。検証は、自分のユーザーで 127.0.0.1 の 2222 番に立てた sshd（`UsePAM no`。システムの sshd とは別） |
| GitHub への ssh（手順 2・更新） | 試していない（clone は bare リポジトリで代えた） | Git for Windows の `OpenSSH_10.5p1`。同じ PC の WSL の AlmaLinux 10.2 の `openssh-clients-9.9p1-27.el10_2.alma.1` と `git-core-2.52.0-1.el10` | `openssh-clients-9.9p1-27.el10_2.alma.1`。鍵は GitHub に登録済みで、GitHub のホスト鍵は `~/.ssh/known_hosts` に前からあった |

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
- **公開のリポジトリを、HTTPS で clone する**（2026-10-03 に公開し、利用者の選択で SSH から変えた）。clone と pull に認証は要らない
  - HTTPS の git は setup-notes の ssh-socks-tunnel.md のトンネル（`ALL_PROXY`）を通るので、インターネットに出られないホストも同じ URL にした（SSH の git は通らない）
  - このリポジトリへ push するには、別に認証（gh など）が要る。この手順書では push しない
  - 非公開だった間は、HTTPS（gh の資格情報）、2026-10-01 からは SSH（GitHub に登録した鍵）で clone していた（記録は付録）
- **プロンプトの 3 つ（starship・WezTerm・zoxide）は、この順に読む**。setup-notes の starship.md と ryo-aoki-pc/wezterm の手順書も、同じ並びに直した（2026-09-30。前は starship を最後に置いていた）。理由と実測は README の[読む順番](../README.md#読む順番)
- **元の手順書の行は、行全体が同じものだけを機械的に消し、ほかはエディタで直す**（手順 3・4・6・7）

### 完了時点の状態

| 場所 | 中身 |
|---|---|
| `~/.config/bash` | このリポジトリの clone（`main`。`origin` は `https://github.com/ryo-aoki-pc/bash.git`） |
| `~/.bashrc` | 元の手順書の行が消え、末尾に `if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi` |
| `~/.bashrc.before-bash` | 手順 3 の控え |
| `~/.bash_profile` | 手順 8 で作ったときだけ（ログインシェルの設定ファイルが 1 つも無かったホスト） |
| `/root/.config/bash`・`/root/.bashrc`・`/root/.bashrc.before-bash` | [root のシェルでも読む](#root-のシェルでも読む任意)の節を通したときだけ。中身は上の 3 つと同じ形 |

- 開き直したシェルでの確かめ（手順 10）の出力は、手順 10 の補足にある

### 注意点

- **非対話のシェルでも `~/.bashrc` は読まれる**
  - `ssh <HOST> <コマンド>`・scp・rsync のとき、bash は sshd から起動されたことを見分けて `~/.bashrc` を読む（検証コンテナの AlmaLinux 10 と、setup-notes の windows-openssh-server.md の Git Bash）
    - Git Bash は、`bash -c` のときに環境変数 `SSH_CLIENT` があり、`SHLVL` が無ければ読んだ（Windows 11 の PC で、sshd の起動のしかたを真似て確かめた。`SSH_CLIENT` を外すと読まなかった）
    - Windows の sshd（`DefaultShell` が Git Bash）では、sftp と scp（SFTP の方式）の `sftp-server.exe` も、`ssh <HOST> <コマンド>` と同じく `bash.exe` の下で動いた。sftp でも `~/.bashrc` が読まれる
  - `bashrc` の前半（PATH と環境変数）はそこでも効き、後半（エイリアス・関数・プロンプト）は読まない。何も出力しない（出力すると scp・sftp・rsync が壊れる）
- **Windows の sshd（`DefaultShell` が Git Bash）でも、非対話のシェルでは外部コマンドを動かさない**
  - Windows の前半は `command -v` などの組み込みだけで済む（Homebrew が無い）。SSH のセッションで scoop の shim が起動できない状態（setup-notes の windows-openssh-server.md の「scoop のツールを SSH のセッションで使う」）でも、`ssh <HOST> <コマンド>`・scp・sftp に何も出さない
  - 検証した PC の sshd で、自分で作ったジャンクションを通る shim（SSH のセッションでは起動できない）を PATH の先頭に置いて確かめた。`~/.bashrc` に zoxide の初期化を直に書いていたときは、`Shim: Could not create process …` が毎回出た（scp・sftp の転送は通ったが、エラーが出続けた）
  - 対話の SSH のセッションでは、zoxide などの初期化が scoop の shim を通る。shim が起動できない状態では、ログインのたびに shim のエラーが出て、`z` が無くなる（ほかは使える）。その任意節を行う
- **ツールを入れた直後のシェルには効かない**
  - 開いているシェルは、開いたときにあったツールの分だけ読んでいる。そのシェルで使うなら `. ~/.bashrc` で読み直す（検証コンテナで、開いたシェルに zoxide を入れて読み直し、`z` が警告無しで動いた）
  - starship だけは、端末を開き直す。読み直すと WezTerm のシェル統合より後ろに読まれ、WezTerm のフックが 2 回ずつ動いた（`false` の後に `D;1` と `D;0` が続けて送られた。README の[読む順番](../README.md#読む順番)）
- **starship を使うホストでは、wezterm の設定も新しくする**
  - WezTerm のシェル統合の `PS0` が starship の `PS0` を壊す問題を、ryo-aoki-pc/wezterm で直した。古い `~/.config/wezterm` のままだと、コマンドの出力の前に `${STARSHIP_START_TIME:0:0}` の文字が出る（Windows の WezTerm の画面では `STARSHIP_START_TIME:0:0}` と見えた）
- **トークン・パスワード・トンネルの変数（`ALL_PROXY`・`https_proxy`）は、この設定に書かない**。ホストの `~/.bashrc` の、読み込みの 1 行より後ろに書く
- **root のシェルで読むのは、一般ユーザーを信用できるホストだけ**（[root のシェルでも読む](#root-のシェルでも読む任意)の節）
  - root のシェルを開くたびに、Homebrew のユーザーが書き換えられるコマンドとファイルが root で動く
  - 一般ユーザーを信用できないホストで、root で Homebrew のコマンドだけを使うなら、この設定は入れず、setup-notes の [homebrew.md の「root のシェルでも使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/homebrew.md#root-のシェルでも使う任意)を通す（PATH の末尾に足すだけで、起動のときには何も動かさない）
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
| m3（`/etc/skel` の 25 行、26 行目 `brew shellenv`（引数なし）、27〜33 行目 `y()`、34 行目 `zoxide init bash`、36〜38 行目 `if [ -n "$WEZTERM_SHELL_INTEGRATION" ]; then` の 3 行、39〜41 行目 `if type brew &>/dev/null; then` で `brew --prefix` を使う 3 行、42 行目 `eval "$(zoxide init bash --cmd cd)"`、43 行目ダミーの `GITLAB_TOKEN`） | 手順 1〜5・6（awk）・7・8・10、[更新](#更新)の手順 1 の pull と log、[ロールバック](#ロールバック)の手順 1〜5 | 手順 3 は `bash -n: OK`。手順 4 の `git diff` は 26〜34 行目の 9 行を `-` で出し、`grep` は WezTerm の 2 行（`fi` は出ない）・Homebrew を使う 2 行・zoxide の行を出した。手順 4・5 を流したログインシェルは `zoxide: command not found` を出した（手順 4 の補足）。手順 7 は `bash -n: OK` と、読み込みの行（28 行目）の後ろに移した 29・30・32 行目。手順 10 は手順 10 の補足のとおり。更新は `Fast-forward` と `検証用のコミット` の 1 行。ロールバックの手順 1 は `0`、手順 2 は消した行と移した行を出し、手順 3 で実施前と同じ 43 行に戻った。手順 4 は `## …` の 1 行だけ、手順 5 は `No such file or directory` |
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

---

### 付録: Windows 11 の Git Bash での検証記録（2026-10-01）

前の付録の未確認事項のうち、Windows 11 の Git Bash での実行を、この設定を常用する Windows 11 の PC で確かめた。その PC の `~/.bashrc`・`~/.bash_profile`・zoxide のデータベースには書いていない。

**環境**:

- Windows 11 Pro 26H2（ビルド 26300.9457）/ x86_64。setup-notes の windows-openssh-server.md を通した PC（sshd が動いていて、`DefaultShell` は Git Bash）
- Git for Windows 2.55.0.windows.5（`C:\Program Files\Git`、bash 5.3.15、`MSYSTEM=MINGW64`、`core.autocrlf=false`）
- WezTerm 20260905-153129-092dcf70。シェル統合は、WezTerm の GUI と同じく `WEZTERM_SHELL_INTEGRATION`（`C:\Users\<WIN_USER>\.config\wezterm/shell/wezterm.sh`。ryo-aoki-pc/wezterm の `main` の `826037f`）で渡した
- ツールは[対象と検証環境](#対象と検証環境)の表
- その PC の `~/.bashrc` は、LazyVim で整形された `y()` の 8 行・`[ -n "$WEZTERM_SHELL_INTEGRATION" ] && . "$WEZTERM_SHELL_INTEGRATION"`・`eval "$(zoxide init bash)"` の 10 行。`~/.bash_profile` は Git for Windows が作った 3 行

**流し方**:

- 利用者の WezTerm の GUI とは別のソケットで `wezterm-mux-server` を動かし、`wezterm cli spawn` で開いたペイン（ConPTY。画面は出さない）に、`HOME` を使い捨てのディレクトリにしたログインシェル（`bash -i -l`）を開いた
- この文書の bash のコードブロックを機械的に抜き出し（折り畳みの中は除き、リストの字下げを外す）、`wezterm cli send-text` で括弧付き貼り付けとして貼ってから Enter を送り、`wezterm cli get-text` で画面を読んだ
- 手順 9 は、ペインを閉じて、同じ `HOME` で新しいペインを開いた
- 手順 2 の後に、手順書の外で `git -C ~/.config/bash checkout -q <検証のブランチ>` を打った（`main` にはまだこの設定が無い）。更新の前には `git -C ~/.config/bash reset -q --hard HEAD~1` で 1 つ古いコミットに戻した
- 当時の手順 2 は HTTPS の clone だった。認証は、gh の資格情報を環境変数（`GIT_CONFIG_COUNT` など）でそのペインにだけ渡した（`gh auth setup-git` が書くのと同じく、`credential.helper` を空にして、`https://github.com` だけ `!gh auth git-credential`）
- zoxide のデータベースは `_ZO_DATA_DIR` で一時的な場所にした（Windows の zoxide は `HOME` ではなく `%LOCALAPPDATA%\zoxide` に書く）
- Git の `/etc/profile` は、環境変数 `ORIGINAL_PATH` があるとそれで `PATH` を組み立て直すので、ペインでは外した（WezTerm から起動した bash には無い。検証の bash には親の Git Bash から入っていた）

| ホーム（実施前） | 流した手順 | 結果 |
|---|---|---|
| w1（その PC の `~/.bashrc` と `~/.bash_profile` の写し） | 手順 1〜5・8・10、[更新](#更新)の手順 1 の pull と log、[ロールバック](#ロールバック)の手順 1〜5 | 手順 1 は `ls` の `No such file or directory` だけ。手順 2 は `Cloning into 'C:/…/.config/bash'...` から `Resolving deltas: 100% (17/17), done.` まで。手順 3 は `bash -n: OK`、手順 4 の `git diff` は 10 行すべてを `-` で出し、`grep` は何も出さなかった（手順 6・7 は飛ばした）。手順 5 は読み込みの 1 行と `bash -n: OK`。手順 8 は `/c/…/.bash_profile:3:test -f ~/.bashrc && . ~/.bashrc`。手順 10 は手順 10 の補足の 7 行。更新は `Updating e44c6e6..3870660`・`Fast-forward` と、新しいコミットの 1 行。ロールバックの手順 1 は `0`、手順 2 は 10 行を `+` で出し、手順 3 は `bash -n: OK` で、`~/.bashrc` はその PC の `~/.bashrc` と同じ中身に戻った（`cmp` で一致）。手順 4 は `## <ブランチ>...origin/<ブランチ>` の 1 行だけ、手順 5 は `No such file or directory`（`.git` の読み取り専用のファイルも消えた） |
| g1（ドットファイルが 1 つも無い。新しい Git Bash のホームの代わり） | 手順 1〜5・8・10 | 手順 1 は `ls` と `grep` の 2 つの `No such file or directory`。手順 3 で空の `~/.bashrc` ができ、手順 4 は何も出さなかった。手順 8 は作った 2 行を出した。開き直したログインシェルに `WARNING:` は出ず、手順 10 は w1 と同じ |
| s1（g1 と同じで、パスに空白と日本語を含む `…/新しい ホーム`） | 手順 1〜5・8・10 | g1 と同じ |
| a1（`~/.bashrc` は読み込みの 1 行、`~/.bash_profile` は手順 8 の 2 行。starship・eza・bat・gdu も PATH に置いた） | 手順 10 | ryo-aoki-pc/wezterm#26 の `shell/wezterm.sh` では、手順 10 の補足のとおり eza の 3 行を含む出力。`main` の `shell/wezterm.sh` では、出力の前ごとに `STARSHIP_START_TIME:0:0}` が出た |

**手順書の外で確かめたこと**:

| 確かめたこと | 結果 |
|---|---|
| 直す前の版（`e44c6e6`）の手順 3・4（その PC の `~/.bashrc` の写し） | 手順 3 は WezTerm と zoxide の 2 行だけを消し、`y()` の 8 行は残った。手順 4 の `grep` は `y()` の中の 2 行（`tmp="$(mktemp …`・`command yazi …`）だけを出した。この `y()` は、setup-notes の yazi.md の 7 行を `shfmt -i 2 -ln bash`（shfmt 3.14.1）に通したものと 1 バイトも違わなかった（LazyVim は `~/.bashrc` を保存するときに shfmt で整形する） |
| 直した `remove-old-lines.awk` を直接（12 通りの入力。`old-y.txt` が 4 つの形になった後） | 4 つの形の `y()` はどれも消え（ファイルの末尾で改行が無くても。その PC の `~/.bashrc` の写しは 10 行すべてが消えた）、1 行を手で直したもの・閉じ括弧の無いもの・余分な `}`・空行は残った。前の付録の入力では、直す前の awk と同じ出力。`gawk --posix` でも同じ |
| 対話のシェル（`bash -i` にコマンドを 1 行ずつ流し込み、生の出力を読んだ） | `false` の後は `D;1`、`cd d1/share; cd ~` の後の `z share` は警告無しで移り、`. ~/.bashrc` の前後で `PROMPT_COMMAND`（`__wezterm_prompt_command;__wz_mouse_off;__zoxide_hook`）と `PS0` は同じ。starship もあると `PROMPT_COMMAND` は `__wezterm_prompt_command;__wz_mouse_off;starship_precmd;__zoxide_hook` で、同じく `D;1`・警告無し・読み直しても変わらない。`main` の `shell/wezterm.sh` では `${STARSHIP_START_TIME:0:0}` がコマンドごとに出て、#26 の版では出なかった |
| `--hook none` の zoxide（`eval "$(zoxide init bash --cmd cd --hook none)"` を読み込みの 1 行の後ろに） | `type -t cd z zi cdi` はすべて `function`、`PROMPT_COMMAND` の `__zoxide_hook` は読み直しても 1 つ、`cd a/share` → `cd ~/b` → `cd share` で `a/share` に移り、警告は出なかった。`--hook none` を付けなくても、Git Bash（文字列の `PROMPT_COMMAND`）ではフックは 1 つのままだった |
| `y()`（本物の yazi 26.9.1 を端末で動かした。比べ方を直す前の `!=` の形） | `y d1` → `share` に入って `q` で、シェルが `d1/share` へ移った。空白と日本語を含むディレクトリも同じ。yazi は cwd-file に `C:\Users\…\d1\share` の形で書いた。動かずに `q` で閉じると `OLDPWD` が今の場所に変わり、`Q` では変わらなかった |
| `y()`（比べ方を `-ef` に直した形。setup-notes の yazi.md と合わせて直した） | `Documents` → `Desktop` と移ってから `y` → 動かずに `q` で、`PWD` は `Desktop`、`OLDPWD` は `Documents` のまま（`cd -` で `Documents` へ戻れる）。中へ入って `q`・`Q`・空白と日本語を含むディレクトリは、直す前と同じだった。`/tmp/yazi-cwd.*` は残らなかった。Git Bash の `test` の `-ef` は、`C:\Users\<WIN_USER>\Desktop` と `/c/Users/<WIN_USER>/Desktop` を同じ、別のディレクトリを違うと判定した |
| sshd の起動のしかたを真似た `bash -c`（`C:\Program Files\Git\bin\bash.exe -c <コマンド>` を、`SSH_CLIENT` を付け、`SHLVL` を外して起動） | `~/.bashrc` を読んだ（`SSH_CLIENT` を外すと読まなかった）。この設定は `true` で 0 バイト。`EDITOR=nvim`・`VISUAL=nvim` が入り、`y`・`z`・`alias vi`・`__bash_config_loaded` は無かった。全部のツールがあると `MANPAGER` も入った |
| 起動できない scoop の shim（向き先の無い shim を `zoxide`・`nvim`・`yazi` の名前で PATH の先頭に置いた。SSH のセッションで起きる状態の代わり） | sshd を真似た `bash -c true` で、その PC の `~/.bashrc` の写しは `Shim: Could not create process with command '"…"  init bash'.` など 181 バイトを出し、この設定は 0 バイトだった |
| `set -u` | `bash -u -c '. ~/.config/bash/bashrc; echo ok'` は `ok`、`bash --norc -u -i -c '. ~/.config/bash/bashrc; echo "ok-$__bash_config_loaded"'` は `ok-1` |
| `command -v` の 1 回の時間（200 回の平均。PATH は 37 要素、ログインシェルでは 44 要素） | 見つからないとき 1.95〜2.28 ms、scoop の shim で見つかるとき 1.65〜1.88 ms、`/mingw64/bin` で見つかるとき 0.2 ms。組み込みの `declare -F` は 0.01 ms |
| 開いたシェルの PATH に、後から eza と bat の shim を置いて `. ~/.bashrc` | `alias ll la lt` が eza の 3 つになり、`MANPAGER` が入り、`ll` が eza で動いた |
| `git -c core.autocrlf=true clone`（HTTPS。gh の資格情報） | `git ls-files --eol` は 8 つとも `i/lf    w/lf`、`bashrc` などの CR は 0 個、`git status --short` は空 |
| Git Credential Manager | GitHub の資格情報が無かった（`GCM_TRACE` で `Found 0 accounts`）。`GCM_INTERACTIVE=never` にすると、git は代わりに `git-askpass.exe`（ユーザー名を聞く窓）を起動した（`GIT_TRACE` で確かめ、打ち切った。プロセスは残らなかった） |
| shellcheck 0.11.0（Mason の Windows 版。`-s bash bashrc`） | 0 件 |

起動の時間（ms。平均 / 中央値。30 周。場合を 1 回ずつ順に回し、1 周目は捨てた）:

| `~/.bashrc` | ツール | ログインシェル（`bash -i -l -c exit`） | 対話（`bash -i -c exit`） | sshd を真似た非対話（`bash -c true`） |
|---|---|---|---|---|
| 空 | その PC のもの | 226.8 / 224.7 | 130.0 / 129.2 | 50.0 / 49.2 |
| その PC の `~/.bashrc`（`y()`・WezTerm・zoxide） | その PC のもの | 326.9 / 330.4 | 229.9 / 226.2 | 157.1 / 159.1 |
| この設定 | その PC のもの | 364.7 / 360.9 | 240.2 / 237.7 | 54.7 / 54.8 |
| 空 | 全部 | 222.5 / 222.3 | 127.7 / 127.5 | 49.4 / 49.5 |
| 元の手順書の行をすべて（Homebrew を除く。starship が最後） | 全部 | 544.9 / 542.8 | 450.3 / 443.0 | 400.9 / 403.1 |
| この設定 | 全部 | 583.9 / 579.8 | 468.8 / 464.4 | 55.9 / 55.1 |

- 「その PC のもの」は neovim・yazi・zoxide、「全部」はそれに starship・eza・bat・gdu を足したもの
- 別の時間に、ログインシェルと対話の 4 行だけを 40 周測り直すと、この設定は直に書いた `~/.bashrc` より 11〜15 ms 長かった（全体は 100 ms ほど遅く出た）。差は測るたびに揺れた
- `PS4` に時刻を出した `set -x` で行ごとに見ると、増えた分は `command -v` の 8 回（1 回 2〜3 ms）だった。starship の初期化（約 250 ms）と zoxide の初期化（約 90 ms。`cygpath` を含む）は、直に書いたときと同じ

**実際の sshd での確かめ**（利用者の許可を得て、同じ PC の WSL の AlmaLinux 10.2 の鍵（その PC の sshd に登録済み）で、LAN の IP あてにつないだ）:

- 本物の `~/.bashrc` は変えず、sshd が起動した Git Bash の中で、使い捨ての `HOME` の bash をもう一段起動した（`env -u SHLVL HOME=<使い捨て> bash -c <コマンド>`。`SSH_CLIENT` は受け継がれ、`SHLVL` を外すので、sshd が起動したときと同じく `~/.bashrc` を読む）
  - `scp -O` と scp（SFTP の方式）は、`-S` に、遠くのコマンドをこの形で包む ssh のラッパーを渡した（SFTP の方式では、`sftp-server.exe` を同じ形で起動した）。sftp は、`-s` に同じ形のコマンドを渡した
  - 対話の ssh は、`ssh <HOST>` でコマンドなしに入り（本物の `~/.bashrc`）、`exec env HOME=<使い捨て> … bash -i` で入れ替えた。確かめた値は端末の出力からは拾わず（ConPTY が画面を描き直す）、遠くのシェルから Windows 側のファイルに書いた。zoxide のデータベースも一時的な場所にした
- SSH のセッションで shim が起動できない状態は、自分のユーザーで作ったジャンクション（`New-Item -ItemType Junction`。所有者は `<WIN_USER>`）を通る scoop の shim で作った。SSH でなければ動き、SSH のセッションでは `Shim: Could not create process …` で失敗した（scoop の zoxide は、管理者が作り直したジャンクションを通るので、SSH でも動いた）

| 確かめたこと | 結果 |
|---|---|
| `ssh <HOST> true`（本物の `~/.bashrc`） | 0 バイト。bash は `5.3.15(2)-release`・`MINGW64`・`SHLVL=1` で、`SSH_CLIENT` があった |
| 使い捨ての HOME の `bash -c true`（この設定） | 0 バイト。`EDITOR=nvim`、`__bash_config_loaded`・`y`・`z` は無く、`PROMPT_COMMAND` は空 |
| 起動できない shim を PATH の先頭に置き、zoxide の初期化を直に書いた `~/.bashrc` | `Shim: Could not create process … init bash'.` など 336 バイト |
| 同じ shim で、この設定 | 0 バイト |
| `scp -O`（200 KB を送って、受け取る） | この設定は、shim の有無にかかわらず中身が一致し、エラーの出力も無かった。zoxide の初期化を直に書いた形は、中身は一致したが、shim のエラーが毎回出た |
| scp（SFTP の方式） | `scp -O` と同じ |
| sftp の put と get | この設定（`-s` で `sftp-server.exe` を使い捨ての HOME の bash から起動）も、本物の `~/.bashrc` も、中身が一致した。Windows の sftp-server の絶対パスは `/C:/…` の形（`C:/…` は今のディレクトリからの相対になった） |
| sftp と `ssh <HOST> sleep 20` の間の Windows のプロセス | `sftp-server.exe` も `sleep.exe` も、`bash.exe ← bash.exe ← sshd.exe ← sshd.exe` の下で動いた |
| 対話の ssh（この設定） | 起動の出力は無かった。`__bash_config_loaded` は `1`、`y`・`z` は `function`、`alias vi='nvim'`、`PROMPT_COMMAND` は `__wz_mouse_off;__zoxide_hook`（SSH では `TERM_PROGRAM` が届かないので、WezTerm の統合は迷子のマウス報告よけだけ）。`cd Documents` → `cd Desktop` の後の `z Docu` で `Documents` へ移り、`false` の後は `rc=1`。`y` → 動かずに `q` で、`OLDPWD` は `Desktop` のまま |
| 対話の ssh（この設定。起動できない zoxide の shim） | 起動時に shim のエラーが 2 行出た。`__bash_config_loaded` は `1`、`y` は `function`、`z` は無く（`bash: z: command not found`）、`PROMPT_COMMAND` は `__wz_mouse_off`。`y` は使えた |

- 検証の方法に関わった、Windows の sshd の振る舞い:
  - 擬似端末を頼んで（`ssh -tt <HOST> <コマンド>`）コマンドを渡すと、`echo "B: …"` は何も出さず、`env -u SHLVL FOO=bar bash -c '…'` は引数の無い `env` のように環境変数の一覧を出した（最初の語だけが動いたように見えた）。コマンドなしの `ssh -tt <HOST>` は普通に入れた
  - 対話のセッションに 585 文字の 1 行を一度に打つと、次の入力が届くまで遠くの bash に渡らなかった（約 370 文字の行はすぐに渡った）
- 検証の後に、取り残された SSH のセッションの bash を止め、sshd のセッションが残っていないことを確かめた

**その PC の本物の `~/.bashrc` への導入**（利用者の依頼で。2026-10-01）:

- 利用者の WezTerm の GUI に、`wezterm cli spawn --new-window` で新しい窓を開いた（既定のシェルの Git Bash のログインシェル。その時点の本物の `~/.bashrc` で起動した）。手順 1〜5・8 のブロックを括弧付き貼り付けで貼った
  - 手順 2 の前に、gh の資格情報をそのシェルにだけ渡す 1 行（上の流し方と同じ指定。当時の手順 2 は HTTPS の clone）を打ち、手順 2 の後に `git -C ~/.config/bash checkout -q <検証のブランチ>` を打った（`main` にまだこの設定が無いため。マージした後は `main` に切り替える）
  - 書き換える前の `~/.bashrc` と `~/.bash_profile` は、手順 3 の控えとは別にも控えた
- 手順 9 は、導入の窓を閉じて新しい窓を開いた（前から開いていた窓は、開き直していない）
- `wezterm cli` でペインに打つときは、必ず `--pane-id` で新しく開いたペインを指した（付けないと、GUI で選ばれているペインに送られる）

| 手順 | 結果 |
|---|---|
| 1 | `ls` の `No such file or directory` だけ |
| 2 | `Cloning into 'C:/Users/<WIN_USER>/.config/bash'...` から `Resolving deltas: 100% (29/29), done.` まで |
| 3 | `bash -n: OK`。控えの `~/.bashrc.before-bash` は、書き換える前の `~/.bashrc` と同じ中身（sha256 が一致） |
| 4 | `git diff` は 10 行すべて（LazyVim で整形された `y()`・古い形の WezTerm の行・zoxide の行）を `-` で出し、`grep` は何も出さなかった（手順 6・7 は飛ばした） |
| 5 | 読み込みの 1 行と `bash -n: OK`。`~/.bashrc` はこの 1 行だけになった |
| 8 | `/c/Users/<WIN_USER>/.bash_profile:3:test -f ~/.bashrc && . ~/.bashrc`（何も作らない） |
| 10（開き直した窓） | 手順 10 の補足の、Windows の 7 行と同じ。`PROMPT_COMMAND` は `__wezterm_prompt_command;__wz_mouse_off;__zoxide_hook`。WezTerm の統合は、GUI が渡す `WEZTERM_SHELL_INTEGRATION` から読まれた |

開き直した窓で確かめたこと（`wezterm cli` で打ち、GUI の WezTerm の状態を読んだ）:

| 確かめたこと | 結果 |
|---|---|
| `cd ~/Documents` の後の、GUI のペインのディレクトリ | `wezterm cli list` で `file:///C:/Users/<WIN_USER>/Documents`、タイトルは `MINGW64:/c/Users/<WIN_USER>/Documents` |
| そのペインからの分割（`wezterm cli split-pane`。Ctrl+Shift+D と同じく、今のペインのディレクトリで開く経路） | 新しいペインは `Documents` で開いた。`wezterm cli spawn` で開いたタブはホームで開いた（キー操作の新しいタブとは別の経路） |
| `z wez` | 本物の zoxide のデータベースで、`~/.config/wezterm` へ移った |
| `y`（scoop の yazi 26.9.1。利用者の yazi の設定のまま） | `Desktop` → `Documents` と移ってから `y` → 動かずに `q` で、`OLDPWD` は `Desktop` のまま。`y ~/.config` → `q` で `~/.config` へ移った。`/tmp/yazi-cwd.*` は残らなかった |

- 画面の撮影と、キー操作（Ctrl+Shift+Alt+↑/↓ のプロンプトへのジャンプ・Ctrl+Shift+Alt+C の出力のコピー）は、Windows の画面がロックされていて試せなかった（前面の窓が無く、ロック画面が動いていた）。ロック中に `PrintWindow` で撮ると、WezTerm の中身は灰色だった

#### 未確認事項（Windows 11）

- LAN の別の PC からの ssh（同じ PC の WSL から、LAN の IP あてにつないだ）
- Git Credential Manager でのサインイン（ブラウザ）と、`gh auth setup-git` を実際に書いたとき（同じ指定を環境変数で渡した）
- WezTerm の GUI の画面とキー操作（プロンプトへのジャンプ・出力のコピー。OSC 133 は生の出力で見た。Windows の画面がロックされていて試せなかった）
- scoop の git（PortableGit）、mintty・Windows Terminal で開いた Git Bash

---

### 付録: SSH の clone に変えたときの検証記録（2026-10-01）

手順 2 の clone を HTTPS から SSH に変えた後に、手順 2 と[更新](#更新)を流し直した。インターネットに出られないホストだけは HTTPS のままにした（SSH の git がトンネルを通らないため）が、トンネル越しの clone と pull は試していない。どの検証も、本物の `~/.ssh/known_hosts` には書いていない。

**Windows 11 の PC の Git Bash**: 前の付録と同じ PC で、同じ流し方（`wezterm-mux-server` のペインのログインシェルに、この文書から抜き出したブロックを括弧付き貼り付けで貼る）。

- ssh は Git for Windows 2.55.0 の `OpenSSH_10.5p1`。鍵は、その PC の `~/.ssh/id_ed25519`（GitHub に登録済み。パスフレーズ無し）
- Git Bash の ssh は `HOME` の `.ssh` を見る。使い捨ての `HOME` の `.ssh` は空のディレクトリにし、鍵は `GIT_SSH_COMMAND='ssh -i <その PC の鍵> -o IdentitiesOnly=yes'` でそのペインにだけ渡した（ssh のエージェントの `SSH_AUTH_SOCK` は外した）。`known_hosts` は使い捨ての `HOME` の `.ssh` のままなので、初めてつなぐホストと同じく聞かれる

| ホーム（実施前） | 流した手順 | 結果 |
|---|---|---|
| sw1（その PC の導入前の `~/.bashrc` と `~/.bash_profile` の写し。前の付録の w1 と同じ） | 手順 1〜5・8・10、[更新](#更新)の手順 1 の pull と log | 手順 2 は、`Cloning into 'C:/…/.config/bash'...` の後に `The authenticity of host 'github.com (20.27.177.113)' can't be established.`・`ED25519 key fingerprint is: SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`・`This key is not known by any other names.`・`Are you sure you want to continue connecting (yes/no/[fingerprint])?` と出た。`yes` と打つと `Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.` と出て、`Resolving deltas: 100% (32/32), done.` まで進んだ。`known_hosts` には、GitHub の ED25519・RSA・ECDSA の 3 行が入った（つないだ後に、ssh が残りの 2 つも足した）。`remote -v` は `git@github.com:ryo-aoki-pc/bash.git`。手順 3〜5・8・10 は、前の付録の w1 と同じ。更新は、1 つ古いコミットに戻してから流し、問い無しで `Fast-forward` と新しいコミットの 1 行 |
| sw2（sw1 と同じ） | 手順 2（問いに `no`） | `Host key verification failed.` と `fatal: Could not read from remote repository.` で止まった。`known_hosts` は作られず、`~/.config/bash` も残らなかった |

手順書の外で確かめたこと:

| 確かめたこと | 結果 |
|---|---|
| GitHub に登録していない鍵（検証のために作った鍵）で、手順 2 の clone（`known_hosts` には GitHub の鍵を入れた） | `git@github.com: Permission denied (publickey).` と `fatal: Could not read from remote repository.`、終了コード 128。clone 先のディレクトリは残らなかった |
| 何も待ち受けていないプロキシ（`ALL_PROXY=socks5h://127.0.0.1:9`）を付けた `git ls-remote` | SSH（`git@github.com:…`）は、プロキシを使わずに `HEAD` を返した。HTTPS（`https://github.com/…`）は `Failed to connect to github.com:443 over proxy 127.0.0.1 after 2064 ms` で失敗した |
| 同じプロキシで `gh api user`（gh 2.102.0） | `ALL_PROXY` だけでは、プロキシを使わずに `ryo-aoki-pc` を返した。`https_proxy` と `HTTPS_PROXY` では、どちらも `proxyconnect tcp: dial tcp 127.0.0.1:9` で失敗した |
| GitHub が公開する指紋 | `gh api meta` の `ssh_key_fingerprints` の `SHA256_ED25519` と、GitHub の説明のページの Ed25519 の指紋は、どちらも手順 2 で出た指紋と同じ |
| その PC の本物の `~/.config/bash`（前の版の手順で、HTTPS で clone してあった） | `git -C ~/.config/bash remote set-url origin git@github.com:ryo-aoki-pc/bash.git` の後、更新の手順 1 の pull は `Already up to date.`、log は `646dc60 …` の 1 行（その PC の `known_hosts` には、GitHub の鍵が前からあった） |

**WSL の AlmaLinux 10.2**（同じ PC の WSL）:

- ssh は `OpenSSH_9.9p1`、git は 2.52.0、暗号ポリシーは `DEFAULT`。鍵は、WSL のユーザーの `~/.ssh/id_ed25519`（GitHub に登録済みだった。パスフレーズ無し）
- `HOME` を使い捨てのディレクトリにして、手順 2 と更新の手順 1 の pull と log のブロックを `bash` に流した。手順 2 は擬似端末（Python の `pty`）で動かし、問いに `yes` と打った
- AlmaLinux の ssh は、`HOME` ではなく passwd のホームの `~/.ssh` を見る。本物の `known_hosts` に書かないよう、`GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=<一時ファイル> -o GlobalKnownHostsFile=/dev/null'` を渡した（本物の `known_hosts` は、前後で同じ中身だった）

| 確かめたこと | 結果 |
|---|---|
| 手順 2 | `Cloning into '/tmp/…/home/.config/bash'...` の後に、Windows と同じ問いが出た。指紋の行だけ形が違い、`ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.` だった。`yes` の後は Windows と同じ。`git ls-files --eol` は 8 つとも `i/lf w/lf` |
| 更新の手順 1 の pull と log（1 つ古いコミットに戻してから） | `Updating da89849..646dc60`・`Fast-forward` と、`646dc60 …` の 1 行 |
| 空の `known_hosts` で `ssh -v -T git@github.com`（`BatchMode=yes` なので聞かずに止まる。鍵は使わない） | `kex: host key algorithm: ssh-ed25519`、`Host key verification failed.` |
| `ssh -T git@github.com`（GitHub の鍵だけを入れた `known_hosts` で） | `Hi ryo-aoki-pc! You've successfully authenticated, but GitHub does not provide shell access.`、終了コード 1 |
| HTTPS の clone（インターネットに出られないホストの形。git の認証の設定が無い使い捨ての `HOME`。擬似端末で問いに `Ctrl+C`。トンネルは使っていない） | `Cloning into '/tmp/…/home/.config/bash'...` の後に `Username for 'https://github.com':` と聞かれた。`Ctrl+C` で止まり、`~/.config/bash` は残らなかった（`~/.config` だけ残った） |

#### 未確認事項（SSH の clone）

- 鍵を作って GitHub に登録するところ、パスフレーズのある鍵（検証した 2 つの鍵には無かった）
- AlmaLinux 10 の実機（WSL では手順 2 と更新だけ）
- インターネットに出られないホストでの、トンネル越しの HTTPS の clone と pull、そのホストでの gh のログイン（`https_proxy` を入れた `gh auth login`）

---

### 付録: AlmaLinux 10 の実機（aarch64）への導入（2026-10-02）

前の付録の未確認事項のうち、AlmaLinux 10 の実機と aarch64 を、利用者の依頼で、Raspberry Pi 5 の本物の `~/.bashrc` に導入して確かめた。導入は残した（[完了時点の状態](#完了時点の状態)のとおり）。

**環境**:

- Raspberry Pi 5 Model B Rev 1.0（4 コア・8 GB）、AlmaLinux 10.2 / aarch64。版は[対象と検証環境](#対象と検証環境)の表
- 利用者は、別の PC から ssh で入り、tmux の中で使っている（GNOME の画面もあるが、検証では使っていない）
- COPR の WezTerm の公式のシェル統合（`/etc/profile.d/wezterm.sh`。bash-preexec を含む）は、`TERM_PROGRAM` を見ずに、どの対話のシェルでも読まれる。ryo-aoki-pc/wezterm の `shell/wezterm.sh` は、公式の統合が先に読まれていると、迷子のマウス報告よけ（`__wz_mouse_off`）だけを足して抜ける
- 導入前の `~/.bashrc` は、`/etc/skel` の 25 行の後ろに、`eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"`・`eval "$(zoxide init bash --cmd z)"`・比べ方を直す前（`!=`）の 7 行の `y()` の 9 行。`~/.bash_profile` は `/etc/skel` のもの
- `~/.ssh/id_ed25519`（パスフレーズ無し）は GitHub に登録してあり、`~/.ssh/known_hosts` には GitHub の 3 つの鍵が前からあった

**流し方**:

- 書き換える前の `~/.bashrc` と `~/.bash_profile` は、手順 3 の控えとは別にも控え、`~/.ssh/known_hosts` と zoxide のデータベースの sha256 を控えた
- この文書の bash のコードブロックを機械的に抜き出し（折り畳みの中は除き、リストの字下げを外す）、利用者の tmux とは別のソケット（`tmux -L`）の tmux のペインのログインシェルに、`load-buffer` と `paste-buffer -p`（括弧付き貼り付け）で貼ってから Enter を送った。ペインの環境変数は、`env -i` で ssh で入ったときの形（`HOME`・`PATH`・`LANG`・`XDG_RUNTIME_DIR` など）にした
- 出力は `pipe-pane` で生のまま受けて読んだ。このホストの tmux（`tmux-3.3a-13.20230918gitb202a2f.el10`）は、`capture-pane` でサーバーが SIGABRT で落ちた（この設定を読まない `bash --norc` のペインでも同じだった）ので、画面は読んでいない
- 手順 9 は、tmux のセッションを閉じて、新しく開いた
- 対話のシェルの生の出力は、導入の前と後に、`script -q -E never -O <ログ> -c 'bash -il'` の擬似端末へ同じコマンドを間を空けて流し込んで比べた（WezTerm の GUI の形 `TERM=xterm-256color TERM_PROGRAM=WezTerm` と、ssh の形 `TERM_PROGRAM` 無し）
- zoxide のデータベースは `_ZO_DATA_DIR` で一時的な場所にした
- ssh は、システムの sshd を使わなかった（`~/.ssh/authorized_keys` にこのホスト自身の鍵が無く、足さなかった）。自分のユーザーで `/usr/sbin/sshd` を 127.0.0.1 の 2222 番に立て（使い捨てのホスト鍵とクライアントの鍵、`UsePAM no`・`StrictModes no`・`Subsystem sftp /usr/libexec/openssh/sftp-server`）、ssh には `-F /dev/null` と使い捨ての `known_hosts` を渡した。PAM を通らないので、そのセッションには `XDG_RUNTIME_DIR` が無い

| 手順 | 結果 |
|---|---|
| 1 | `ls` の `No such file or directory` だけ |
| 2 | `Cloning into '/home/<USER>/.config/bash'...` から `Resolving deltas: 100% (35/35), done.` まで。ホスト鍵の問いは出ず、`known_hosts` は前後で同じ中身だった。`git ls-files --eol` は 8 つとも `i/lf w/lf` |
| 3 | `bash -n: OK`。控えの `~/.bashrc.before-bash` は、書き換える前の `~/.bashrc` と同じ中身（`cmp` で一致） |
| 4 | `git diff` は 26〜34 行目の 9 行（Homebrew・zoxide・`y()`）を `-` で出し、`grep` は何も出さなかった（手順 6・7 は飛ばした） |
| 5 | 読み込みの 1 行と `bash -n: OK` |
| 8 | `/home/<USER>/.bash_profile:4:if [ -f ~/.bashrc ]; then` と `/home/<USER>/.bash_profile:5:    . ~/.bashrc`（何も作らない）。終了コードは 2 だった（無い `~/.bash_login`・`~/.profile` を `grep` が開けないため） |
| 10（開き直したペイン） | 手順 10 の補足の、AlmaLinux 10 の実機の 7 行 |
| [更新](#更新)の手順 1 の pull と log | `Already up to date.` と、`a69a10e (HEAD -> main, origin/main, origin/HEAD) 導入の clone を SSH にする (#3)` の 1 行 |

手順書の外で確かめたこと:

| 確かめたこと | 結果 |
|---|---|
| 非対話（CLAUDE.md の「よく使うコマンド」） | `bash -c '. ~/.config/bash/bashrc'`・`bash -c '. ~/.bashrc'`・sshd の起動のしかたを真似た `bash -c true`（`SSH_CLIENT` を付け、`SHLVL` 無し）は 0 バイト。`bash -u -c '. ~/.config/bash/bashrc; echo ok'` は `ok`、`bash --norc -u -i -c '. ~/.config/bash/bashrc; echo "ok-$__bash_config_loaded"'` は `ok-1` |
| 対話のシェルの生の出力（`script` の擬似端末。WezTerm の GUI の形と ssh の形） | 導入の前も後も、`false` の後は `D;1`（COPR の統合が送る。`D` は重ならない）。`cd /usr/share` → `cd` → `z share` は警告無しで `/usr/share` へ移った。`. ~/.bashrc` の前後で `PROMPT_COMMAND` は同じ（導入の後は `([0]=$'__bp_precmd_invoke_cmd\n__wz_mouse_off;:;__zoxide_hook' [1]="__bp_interactive_mode")`）で、`PS0` は無い。制御文字を印に置き換えて比べると、導入の前と後のログは同じで、違いはプロンプトごとのマウス報告の解除（`__wz_mouse_off`）だけだった（起動して最初のコマンドに `C` が無いのも、導入の前と同じ） |
| 導入の前後のシェルの状態（`alias`・`declare -F`・`PATH`・`EDITOR`・`VISUAL`・`MANPAGER`・`DOCKER_HOST`・`y` の中身） | 違いは、`alias vi='nvim'`、`EDITOR`・`VISUAL` が `nvim`、`__wz_mouse_off`・`__wz_eat_mouse_report`、`__bash_config_loaded=1`、`y` の比べ方（`!=` から `-ef`）だけ。`PATH` は同じ |
| tmux のペイン（`TERM=tmux-256color`・`TERM_PROGRAM=tmux`） | `false` の後は `D;1`、読み直しても `PROMPT_COMMAND` は同じ、`z Docu` で `~/Documents` へ移り、警告は出なかった |
| `y`（Homebrew の yazi 26.9.1。利用者の yazi の設定のまま、tmux のペインで動かした） | `Documents` → `Desktop` と移ってから `y` → 動かずに `q` で、`PWD` は `Desktop`、`OLDPWD` は `Documents` のまま。`y ~/.config` → `q` で `~/.config` へ移った。`/tmp/yazi-cwd.*` は残らなかった |
| 立てた sshd 越しの `ssh <HOST> true` | 出力は 0 バイト |
| 立てた sshd 越しの `ssh <HOST> <コマンド>` | `SHLVL=1`・`SSH_CLIENT` のある bash が `~/.bashrc` を読み、Homebrew の PATH（`brew`・`nvim`・`zoxide`）と `EDITOR=nvim` が入り、`y`・`z`・`alias vi`・`__bash_config_loaded` は無く、`PROMPT_COMMAND` は空 |
| scp（SFTP の方式）・`scp -O`・sftp（`-b` で put と get） | 200 KB の乱数のファイルを往復し、中身（sha256）が一致し、エラーの出力は無かった。sshd のログでは、scp（SFTP の方式）の 2 回と sftp は `subsystem 'sftp'` のセッション（`sftp-server` も bash から起動され、`~/.bashrc` を読む）、`scp -O` はコマンドのセッションだった |
| 対話の ssh（tmux のペインから。ログインシェル） | 起動の出力は無かった。手順 10 のブロックは、開き直したペインと同じ 7 行。`false` の後は `D;1`、読み直しても `PROMPT_COMMAND` は同じ、`z share` は警告無しで移った |
| podman のソケット（`systemctl --user start podman.socket` で一時的に起動した） | `bash -c '. ~/.bashrc'`・sshd を真似た `bash -c`・開き直したペインで、`DOCKER_HOST=unix:///run/user/<UID>/podman/podman.sock`。先に `DOCKER_HOST` を入れると変えず、`XDG_RUNTIME_DIR` が無いと入らなかった。出力は 0 バイトのまま。podman.service は起動されなかった |
| podman のソケットを止めた後（`systemctl --user stop podman.socket`） | ソケットのファイルは `/run/user/<UID>/podman/` に残り（unit に `RemoveOnStop` が無い）、その後に開いたシェルにも `DOCKER_HOST` が入った（つなぐと `Connection refused`）。検証の後に、そのファイルとディレクトリを消して、起動する前の状態に戻した |

起動の時間（ms。平均 / 中央値。20 回。場合を 1 回ずつ順に回し、1 周目は捨てた。端末を付けず、`env -i` の環境で起動した）:

| `~/.bashrc` | ログインシェル（`bash -i -l -c exit`） | 対話（`bash -i -c exit`） | sshd を真似た非対話（`bash -c true`） |
|---|---|---|---|
| `/etc/skel` のまま（使い捨ての `HOME`） | 87.7 / 87.6 | 77.5 / 77.0 | 52.5 / 52.1 |
| 導入前の `~/.bashrc`（1 回目） | 100.4 / 100.8 | 90.8 / 91.2 | 66.6 / 66.5 |
| 導入前の `~/.bashrc`（2 回目。使い捨ての `HOME` に写した） | 105.2 / 105.0 | 93.6 / 94.1 | 68.5 / 68.1 |
| この設定（1 回目） | 106.8 / 107.3 | 96.2 / 95.7 | 63.3 / 63.5 |
| この設定（2 回目） | 106.2 / 106.6 | 96.2 / 96.3 | 63.4 / 62.9 |

- ログインシェルと対話は、導入前より 1〜6 ms 長く（測るたびに揺れた）、非対話は 3〜5 ms 短かった（非対話では zoxide を初期化しないため）
- 検証の後に、tmux のサーバー・立てた sshd・podman.socket を止め、取り残されたプロセスと tmux のソケットが無いことを確かめた。`~/.ssh/known_hosts`・`~/.bash_profile`・zoxide のデータベースは、前後で同じ中身だった
- 利用者がその前から開いていた tmux のセッションのシェルは、開き直していない（古い `y`・`z` のまま）

#### 未確認事項（AlmaLinux 10 の実機）

- WezTerm の GUI の画面とキー操作（このホストの GNOME の画面では試していない。OSC 133 は生の出力で見た）
- システムの sshd（PAM を通る）越しの ssh・scp・sftp、LAN の別の PC からの ssh、rsync（このホストに無い）
- 初めて github.com につなぐホストでの手順 2 の問い（このホストの `known_hosts` には前からあった。WSL では確かめた）
- 手順 6・7（エディタで直す行が無かった）、[ロールバック](#ロールバック)（導入を残した）
- starship・eza・bat・gdu があるとき（このホストに無い）

---

### 付録: 履歴・shopt・Homebrew の補完・fzf を足したときの検証記録（2026-10-02）

setup-notes の [bash-settings.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/bash-settings.md) と [fzf.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/fzf.md) を足したときに、`bashrc` に履歴と `shopt`・Homebrew の補完・fzf（`FZF_*` を含む）を足した。**x86_64 のコンテナだけで確かめた**（Git Bash と実機は未確認）。

**環境**: AlmaLinux 10.2 の `quay.io/almalinuxorg/10-init`（Docker 29.6.2、`--privileged`・`--network host`。systemd と sshd）。Homebrew 7.0.7 に fzf 0.74.4・fd 10.5.0・bat 0.26.1・eza 0.23.5・zoxide 0.10.0・starship 1.26.0・shellcheck 0.11.0。bash-completion 2.11（BaseOS）。`~/.config/wezterm` は無し。

**確かめたこと**:

- `bash -n bashrc` と `shellcheck -s bash bashrc` が通る
- 移行の awk: `/etc/skel` の `~/.bashrc` に、setup-notes の `brew shellenv`・bash-settings.md の 5 行・fzf.md の 5 行を足したもの（36 行）から、その 11 行だけが消えて `/etc/skel` と同じ 25 行になった
- 非対話: `bash -c '. ~/.bashrc' 2>&1 | wc -c` が `0`、`ssh <HOST> true` の出力が 0 バイト。`bash -u -c` は `ok`、`bash --norc -u -i -c` は `ok-1`
- 対話（SSH でログインした bash を tmux のペインで）: 手順 10 の出力は `1`、eza の 3 つのエイリアス、`function`（`z`）、`HISTSIZE=100000 shopt -s autocd shopt -s globstar`、`bind -X` の 2 行、`complete -o bashdefault -o default -F _brew brew` と `complete -F _fzf_path_completion bat`、最後に `0`
- fzf は `PROMPT_COMMAND` に触らない: `declare -p PROMPT_COMMAND` は、`. ~/.bashrc` を 2 回読み直す前後とも `([0]="starship_precmd" [1]="__zoxide_hook")`。`bind -X | sort | uniq -d` は空のまま 2 行
- Homebrew の補完を fzf より前に読む形で、`bat --the<Tab>` は `--theme --theme-dark --theme-light` の一覧、`bat **<Tab>` は fzf の画面、`git checko<Tab>` は `checkout`、`eza --gi<Tab>` は `--git` の 4 候補の一覧
- 対話のシェルの起動（`bash -ic true`）は 81 ミリ秒（starship と zoxide の初期化を含む。足す前は測っていない）

#### 未確認事項（2026-10-02 に足した行）

- Windows 11 の Git Bash（scoop の fzf・fd・bat。`fzf --bash` が Git Bash で動くか）
- AlmaLinux 10 の実機（Raspberry Pi 5 を含む）と、Homebrew の補完を全部読むことによる起動の時間の増え方
- `~/.inputrc` は setup-notes の bash-settings.md 手順 5 のまま（この設定の対象外）

---

### 付録: HTTPS の clone に変えたときの検証記録（2026-10-03）

このリポジトリを公開した後に、手順 2 の clone を HTTPS に戻し、[更新](#更新)を 1 つの手順（`origin` を HTTPS にそろえる `set-url`・pull・log）にまとめた。そのブロックを、x86_64 のコンテナで流した。

**環境**: `docker.io/library/almalinux:10`（AlmaLinux 10.2、x86_64。クラウドのホストの Docker 29.6.2、`--network host`）に `git-core-2.52.0-1.el10` を入れ、一般ユーザー（git の設定も `~/.ssh` も無い）の `bash` に、この文書のブロックを抜き出したものを流した。

- 検証環境だけの変更: ホストの外向きの通信がプロキシ経由なので、そのユーザーに `https_proxy` を渡し、プロキシの CA を取り込んだ。dnf にもプロキシを入れ、AlmaLinux の repo ファイルは `mirrorlist=` を止めて `baseurl=` を使った
- git に問いを出させないため、`GIT_TERMINAL_PROMPT=0` を付けた（認証を聞かれると、問わずに失敗する）
- 同じ日に、認証無しの `curl` で `https://github.com/ryo-aoki-pc/bash.git/info/refs?service=git-upload-pack` が `200` を返すことも見た

| 流したもの | 結果 |
|---|---|
| 手順 1 | `No such file or directory` と、`grep` の終了コード 1 |
| 手順 2 | `Cloning into '/home/<USER>/.config/bash'...`、終了コード 0。`origin` は `https://github.com/ryo-aoki-pc/bash.git`。`git ls-files --eol` は 8 つとも `i/lf w/lf` |
| [更新](#更新)の手順 1（1 つ古いコミットに戻してから） | `Updating d33bbca..926c3d7`・`Fast-forward` と、`926c3d7 …` の 1 行。`origin` は変わらない |
| 更新の手順 1 をもう一度 | `Already up to date.` と、同じ 1 行 |
| SSH で clone したホストの代わり（同じ clone の `origin` を `git@github.com:ryo-aoki-pc/bash.git` にし、1 つ古いコミットに戻した）に更新の手順 1 | `Updating d33bbca..926c3d7`・`Fast-forward` と、`926c3d7 …` の 1 行。`origin` は `https://github.com/ryo-aoki-pc/bash.git` になり、`status` は `## main...origin/main` だけ。`~/.ssh` は作られなかった |

#### 未確認事項（HTTPS の clone）

- Windows 11 の Git Bash（Git Credential Manager が問いを出さないこと）と、AlmaLinux 10 の実機・WSL での手順 2 と更新
- SSH で clone してある実機の `~/.config/bash`（Raspberry Pi 5・Windows 11 の PC・WSL）で、更新の手順 1 が `origin` を HTTPS にすること
- インターネットに出られないホストでの、トンネル越しの clone と pull

### 付録: root のシェルでも読む節の検証記録（2026-10-05）

[root のシェルでも読む（任意）](#root-のシェルでも読む任意)と、`bashrc` の root の `DOCKER_HOST` を足したときの記録。x86_64 のクラウドホスト（Ubuntu 24.04、cgroup v1）上の Docker 29.6.2 で、使い捨てのコンテナを立てて行った。実機には何も加えていない。

**環境**:

- `quay.io/almalinuxorg/10-init:10.2`（`sha256:c8a5eee8…28e1`。中のパッケージは `x86_64_v2` のもの）を `--privileged --cgroupns=private` で、Docker の bridge のネットワークに立て、systemd・sshd・logind を動かした
- 版: `bash-5.2.26-6.el10`、`sudo-1.9.17-10.p2.el10_2.6`、`git-2.52.0-1.el10`、`rootfiles-8.1-54.el10`、`podman-5.8.2-9.el10_2.alma.1`。Homebrew 7.0.8（starship 1.26.0・zoxide 0.10.0・fzf 0.74.4・eza 0.23.5・lazydocker 0.25.2・shellcheck 0.11.0）
- 一般ユーザー `<USER>`（wheel、NOPASSWD の sudo）。自分の `podman.socket`（`systemctl --user`）と、システムの `podman.socket` を有効にした

**手順書の外で行った準備**:

- プロキシの CA・dnf・systemd とログインシェルのプロキシの環境変数を入れ、ホストの側の中継でプロキシに届かせた（root の podman のネットワークがホストに及ばないよう、`--network host` にしなかった）
- Homebrew の root の断りが効くように `/.dockerenv` を消した（あると Homebrew は root を断らない。setup-notes の homebrew.md の付録）
- 手順 2・更新の clone の URL を、このリポジトリの作業中のコミットの bare リポジトリ（`/srv/bash.git`、root の持ち物。`git config --system --add safe.directory`）に置き換えた
- `<USER>` で[実施手順](#実施手順)の手順 1〜5・8・10 を通した（手順 9 は ssh を入り直した）
- `/root/.bashrc` には、setup-notes の homebrew.md「root のシェルでも使う」の手順 1 と lazydocker.md「root でも使う」の手順 1〜3 を、`<USER>` の端末に貼って書かせた（root のコンテナ `lazydocker-root-web` も動かした）

**流し方**: ホストの tmux 3.4 のペイン（160x50）から `docker exec -it … ssh -t <USER>@127.0.0.1` でログインし、この文書から抜き出したブロック（折り畳みの外のもの）を `tmux paste-buffer` で貼った。画面は `capture-pane` で読んだ。

| 手順・確認 | 結果 |
|---|---|
| 節の前 | `/root/.bashrc` は rootfiles の既定の中身の後ろに setup-notes の 2 行。`/root/.config` は無い |
| 1 回目（ブラケットペースト無し）: 節の手順 1・2（実施手順 1〜5・8） | 実施手順 1 は `ls: cannot access '/root/.config/bash'`、2 は `Cloning into '/root/.config/bash'...`、3 は `bash -n: OK`、4 は setup-notes の 2 行が `-` で出て `grep` は何も出さない、5 は読み込みの 1 行、8 は `/root/.bash_profile:4:if [ -f ~/.bashrc ]; then` と `/root/.bash_profile:5:  . ~/.bashrc` |
| 節の手順 3・4（実施手順 10） | 手順 4 の補足の出力のとおり。プロンプトは starship の `root in ~` |
| root のシェルの中 | `printenv PATH` は Homebrew が先頭、`command -v git curl` は `/bin/git`・`/bin/curl`、`brew install tree` は `Error: Running Homebrew as root is extremely dangerous and no longer supported.`。`cd /usr/share` の後の `zoxide query --list` は `/usr/share`（データベースは `/root/.local/share/zoxide`）。`/home/linuxbrew` と `<USER>` のホームに、root の持ち物のファイルはできなかった |
| root の起動で動くもの | root の `bash -i -c exit` に `strace -f -e trace=execve` を当てた: Homebrew の `brew`（1 回）・`fzf`（1 回）・`starship`（4 回）・`zoxide`（1 回）と、`/usr/bin` の `grep`・`sed` など |
| ほかの入口 | `sudo -s`・`su -`（検証のためだけに root にパスワードを付け、後で `/etc/shadow` を戻した）は `__bash_config_loaded=1` と `DOCKER_HOST=unix:///run/podman/podman.sock`。`su`（`-` 無し）は `__bash_config_loaded=1` だが、`DOCKER_HOST` は引き継いだ `unix:///run/user/<UID>/podman/podman.sock` のまま |
| 非対話 | `sudo -i true` も、root への鍵の `ssh root@127.0.0.1 true` も 0 バイト。`ssh root@127.0.0.1 'printenv DOCKER_HOST; command -v brew'` は `unix:///run/podman/podman.sock` と Homebrew の `brew` |
| setup-notes の代わりのコマンド | `sudo -i bash -c 'printenv DOCKER_HOST; command -v lazydocker'` は `unix:///run/podman/podman.sock` と Homebrew の `lazydocker`。`sudo -i bash -c 'printenv PATH; command -v brew'` は Homebrew が先頭の PATH と `brew`。`sudo -i lazydocker` は `running  lazydocker-root-web` だけを出した |
| setup-notes の lazydocker.md の元に戻す手順 6〜8 | 手順 6 の `grep -c` は `0`。手順 8 でソケットを止めた後も `/run/podman/podman.sock` のファイルは残り、`sudo -i bash -c 'printenv DOCKER_HOST'` は `unix:///run/podman/podman.sock` を返した |
| 節の手順 5（[ロールバック](#ロールバック)の手順 1〜5）、直す前 | 手順 3 の `cp -p` が `cp: overwrite '/root/.bashrc'?` を出し、次に貼った手順 4 の行を答えとして読んだ。控えには戻らず、`/root/.bashrc.before-bash` が残った（root の `alias cp='cp -i'`）。手順 3 に `command` を付けて直した |
| 2 回目（ブラケットペースト有り）、直した後 | 節の手順 1〜5 が 1 回目と同じ結果。元に戻した後の `/root/.bashrc` の SHA-256 は、節の前と同じ。`/root/.bashrc.before-bash` と `/root/.config/bash` は無い |
| 3 回目（ブラケットペースト無し）、直した後 | 2 回目と同じ |
| `<USER>` | 実施手順 10 の `DOCKER_HOST` は `unix:///run/user/<UID>/podman/podman.sock` のまま。[更新](#更新)の手順 1 と、直した[ロールバック](#ロールバック)の手順 1〜5（`~/.bashrc` は控えと同じ SHA-256 に戻った） |
| 静的検査 | `bash -n`・`shellcheck -s bash`（0.11.0）は何も出さない。`bash -c` は 0 バイト、`bash -u -c` と `bash --norc -u -i -c` は、`<USER>` と root のどちらでも `ok` と `ok-1` |

#### 未確認事項（root の節）

- 実機（x86_64・aarch64）での実行
- Windows 11 の Git Bash（`EUID` は 0 にならないので、変わらないはず）
- インターネットに出られないホストでの root の clone（`sudo -i` は `ALL_PROXY` を渡さない）
- コンソールでの root のログイン、root への ssh の対話のログイン
- root の starship の設定（`/root/.config/starship.toml`）と、root の WezTerm のシェル統合

---

### 付録: Windows ホストでの設定の再検証（2026-10-06）

2026-10-02 と 2026-10-05 の追加分を含む、`b14a9bc` の `bashrc` と移行 awk を Windows ホストで確かめた。**設定の試験 12 ケース、移行 awk の試験 8 ケースがすべて成功し、ShellCheck の指摘は 0 件だった**。`bashrc` の変更は必要なかった。`install.sh` と導入・更新・ロールバック手順全体は今回の検証対象に含めていない。

**環境**: Windows のビルド 26300.9457 / 26H2、Git for Windows 2.55.0.windows.5、Bash `5.3.15(2)-release`（`OSTYPE=cygwin`）。fzf 0.74.4、fd 10.5.0、starship 1.26.0、zoxide 0.9.9、yazi 26.9.1、ShellCheck 0.11.0。neovim は PATH 上にあり、bat・eza・gdu-go は無かった。`/etc/bash_completion.d` も無かった。

**試験方法**:

- PowerShell から Git for Windows の `bin/bash.exe` を起動した。`--noprofile --norc` で起動するときは、Git の `usr/bin` と `mingw64/bin` を PATH に足した
- `HOME`・履歴・starship の設定とキャッシュ・`_ZO_DATA_DIR`・一時ファイルは、作業ツリー内の試験専用ディレクトリにした。本物の `~/.bashrc` と `~/.bash_profile` は変更していない
- 対話の設定の判定には `bash --noprofile --norc -u -i -c` を使った。プロンプトは `bash --noprofile -i` の標準入力にコマンドを流し、生の stdout と stderr を合わせて保存した（端末は割り当てていないため、起動時のジョブ制御の警告 2 行は試験環境によるもの）
- WezTerm は、このホストの `~/.config/wezterm/shell/wezterm.sh` を試験用にコピーし、`TERM_PROGRAM=WezTerm` と Windows 形式の `WEZTERM_SHELL_INTEGRATION` を渡した
- 移行 awk は試験用の入力ファイルに当てた。本物の `~/.bashrc` の移行は行っていない

**確かめたこと**:

| 試験 | 結果 |
|---|---|
| 構文・静的検査 | `bash -n bashrc` と `shellcheck -s bash bashrc` は終了コード 0、出力なし |
| 非対話・`set -u` | 設定の読み込みは終了コード 0、stdout / stderr とも 0 バイト。対話専用の印・`y`・starship・zoxide の関数は無い。対話の後半も `set -u` で読める |
| ツール無し | Git の標準コマンドだけの PATH でも終了コード 0、履歴と `shopt` は入る。任意のツールの関数は無い |
| 履歴 | `HISTSIZE=100000`、`HISTFILESIZE=100000`、`HISTCONTROL=ignoreboth`。同時に起動した 2 シェルが終了すると、既存の履歴と両方の追加分が残る。連続重複は 1 件、空白始まりのコマンドは保存されない |
| `shopt` | `histappend`・`autocd`・`cdspell`・`dirspell`・`globstar` がすべて on |
| fzf | `fzf --bash` が Ctrl+R・Ctrl+T の `bind -X` と Alt+C のマクロ、補完を登録。設定を 2 回読み直しても `bind -X` の内容は同じ |
| fd と `FZF_*` | ファイルとディレクトリの候補に隠し項目が入り、`.git` は除外される。実際の fd の結果から `fzf --filter=visible` で `visible.txt` を選べた。bat が無いので `FZF_CTRL_T_OPTS` と `MANPAGER` は入らない |
| プロンプト・読み直し | `false` の直後は OSC 133 の `D;1`。`PROMPT_COMMAND` は `__wezterm_prompt_command;__wz_mouse_off;starship_precmd;__zoxide_hook`。2 回読み直す前後の `PROMPT_COMMAND` と `PS0` は一致し、starship の展開式が画面に文字として漏れない |
| zoxide | 試験用データベースで別のディレクトリから `z share-target` によって移動。設定の警告なし |
| `y()`（cwd-file スタブ） | `C:\…` と `/c/…` が同じディレクトリなら `OLDPWD` は変わらない。日本語と空白を含む Windows 形式のパスへ移動。空・存在しない移動先では動かず、一時ファイルも残らない |
| Windows の `EUID`・`DOCKER_HOST` | `EUID` は 0 でなく、ソケット無しでは `DOCKER_HOST` が入らない。既存の `tcp://existing.example:2375` は変わらない |
| sshd を真似た起動 | 試験用 HOME で `SSH_CLIENT` を付け、`SHLVL` を外した `bash -c` は stdout / stderr とも 0 バイト。`EDITOR` / `VISUAL` は入り、対話専用の設定は入らない |
| ログインシェル | 試験用 `~/.bash_profile` から `~/.bashrc` を読み、設定の印・履歴・`shopt`・fzf とプロンプトの関数を確認。eza が無いので `ll` は Git の `alias ll='ls -l'` |
| 移行 awk（8 ケース） | `old-lines.txt` の全 31 行と `old-y.txt` の全 4 形が消える。編集済みの行・閉じ括弧欠落や本体編集済みの `y()` は残る。末尾改行無しでも処理でき、保存する行には LF が補われる。すべて 2 度通して同じ結果 |

#### 今回の未確認事項

- fzf の Ctrl+R・Ctrl+T・Alt+C と `**` の補完を実際の端末で操作すること、bat のプレビュー、Homebrew の補完
- 本物の yazi TUI と Windows への引数変換（今回の `y()` は cwd-file を書くスタブで試験）
- eza・bat・gdu-go の実行、ホストで常用している starship の設定、WezTerm の GUI とキー操作
- 実際の SSH・scp・sftp・rsync、HTTPS の clone と更新、導入・ロールバック手順全体

### 付録: 新規 AlmaLinux VM での手動移行の再検証（2026-10-06）

- `3d5323e` を、新規導入した AlmaLinux 10.2 Workstation の x86_64 VM の専用ユーザーで公開 URL から clone した。OS 既定の `~/.bashrc` に、`migrate/old-lines.txt` の全行と `old-y.txt` の 4 形、残すホスト設定 `VM_BASH_MANUAL_KEEP=1` を試験用に加えた
- 本文の手順 1〜5・8・10 を SSH 対話 PTY で実行した。既知の行・4 形の関数は取り除かれ、ホスト設定は残った。手順 4 の `grep` は残る対象行を出さなかったため、本文の条件どおり手順 6・7 は飛ばした
- 読み込み口は 1 行で、`bash -n` が通った。既存の `~/.bash_profile` の SHA256 は変わらず、SSH を張り直しても印は `1`、ホスト設定は `1`、履歴と 5 つの `shopt` は共通設定どおりだった。非対話シェルは出力 0 byte だった
- 手動の `cp -p` は元の 0644 を保持した。自動導入スクリプトの控えが 0600 になる結果とは区別する。今回は Windows / WSL、任意の手編集、更新・削除を再実行していない

### 付録: man ページャの修正と再検証（2026-10-06）

- 同じ新規 VM の実 SSH 対話 PTY で、`3d5323e` の `MANPAGER="sh -c 'col -bx | bat -l man -p'"` は `man bash` の SGR の ESC を落とし、`1mNAME0m`・`4mBASH24m` などを文字として表示した
- [bat の公式 README](https://github.com/sharkdp/bat#man) と同じ `MANPAGER="bat -plman"` へ変更した。旧パイプに `MANROFFOPT=-c` を付ける形でも正常に表示したが、共通設定には追加の環境変数が要らない直接 bat の形を採用した。新しい値も `migrate/old-lines.txt` に加え、旧設定の移行対象を保った
- 共通設定の読み直し後に `man bash` の見出し・本文と `q` での終了を確認した。この表示は AlmaLinux 10.2 / bat 0.26.1 / man-db 2.12.0 の結果。Windows Git Bash には `man` が無く、WSL・aarch64 の man 表示は今回は再検証していない
- 初回の補助 fixture は Windows の改行変換で CRLF になり、構文検査と行照合が失敗した。専用ユーザーの試験用設定を OS 既定に戻し、LF の fixture で頭から移行をやり直して上の結果を得た。本文のブロックの不具合ではなかった

- 修正後の `bash -n`・`shellcheck -s bash`・導入と移行の 8 回帰テストも成功した。共通設定本体は非対話・対話の `set -u` で読めた。OS の `/etc/bashrc` は起動時の `set -u` に対応していないため、その試験は共通設定本体を直接読む形で行った
