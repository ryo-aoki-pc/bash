# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## このリポジトリは何か

いろいろなホスト（AlmaLinux 10 の x86_64 / aarch64・WSL、Windows 11 の Git Bash）で共有する bash の設定。各ホストの `~/.config/bash` に clone し、`~/.bashrc` の末尾の 1 行（`if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi`）で読む。ホストごとに入っているツールが違うので、どの設定もツールがあるかを起動のたびに確かめる。root のシェルでも読める（2026-10-05。root は `/root/.config/bash` に自分の clone を作り、`/root/.bashrc` の同じ 1 行で読む。自分専用のマシンで一般ユーザーを信用できる前提で、root でも `brew shellenv`・starship・zoxide・fzf を同じように読む。違うのは `DOCKER_HOST` だけで、root は `/run/podman/podman.sock`）。公開のリポジトリで（2026-10-03 に公開）、どのホストも HTTPS で clone する（`https://github.com/ryo-aoki-pc/bash.git`。認証は要らない。HTTPS の git は setup-notes の ssh-socks-tunnel.md のトンネルも通る）。非公開だった間は、HTTPS（gh の資格情報）、2026-10-01 からは SSH（GitHub に登録した鍵）で clone していた。

- 読むもの・読む順番とその実測・移行で消す行の説明は `README.md`（参照用）
- 導入の手順は `docs/install.md`（手順書。[setup-notes](https://github.com/ryo-aoki-pc/setup-notes) と同じ書式。下の「docs/install.md の書き方」）

初回導入は `install.sh`（`docs/quick-start.md`）。既知の行の移行と構文検査を先に行い、控えが既にあれば上書きせず中断する。`.bashrc` のリンクとモードを保ち、既存のログイン設定は変えない。設定本体の実行・ネットワーク接続・ツールの導入はしない。

2026-10-06 に AlmaLinux 10.2 Workstation の x86_64 新規 VM で `install.sh` の初回・再実行・root 自身の導入と 8 回帰テストを確認した。別の専用ユーザーでは既知の旧設定の手動移行も通した（`docs/quick-start.md`・`docs/install.md` の再検証記録）。Windows / WSL の新スクリプトの実導入、任意の手編集、全ツールの組み合わせは含まない。

同日の実 PTY の `man bash` で、旧 `col -bx` パイプが SGR の断片を文字として残したため、bat 公式 README と同じ `MANPAGER="bat -plman"` へ変更した。移行一覧は旧値を残して新値も加えた。AlmaLinux 10.2 の表示を確認し、Windows / WSL / aarch64 の表示は再検証していない。

導入の回帰テストは `python3 -m unittest discover -s tests`（使い捨てのホームだけを変更する）。ビルド・外部のテストフレームワークは無い。ドキュメント・コードのコメント・コミットメッセージは日本語で書く。検証していないことを「動く」と書かない。

## よく使うコマンド

```bash
# 構文と静的検査（shellcheck は setup-notes の docs/shellcheck.md で入れる）
bash -n bashrc
shellcheck -s bash bashrc

# 非対話のシェルで何も出さないこと（0 が出ればよい）
bash -c '. ~/.config/bash/bashrc' 2>&1 | wc -c
bash -u -c '. ~/.config/bash/bashrc; echo ok'                                  # set -u でも読める（前半。非対話では後半の前で抜ける）
bash --norc -u -i -c '. ~/.config/bash/bashrc; echo "ok-$__bash_config_loaded"'  # 後半も（ok-1 が出ればよい）

# 移行の awk を、控えに当てて結果だけ見る（~/.bashrc は変えない）
awk -f migrate/remove-old-lines.awk migrate/old-lines.txt migrate/old-y.txt ~/.bashrc | diff ~/.bashrc -
```

- プロンプトに関わる変更（`PROMPT_COMMAND`・`PS0`・`PS1`）は、対話のシェルを擬似端末で動かして生の出力を見る。`script -q -E never -O <ログ> -c 'bash -il'` に、間を空けてコマンドを流し込み、ログの OSC 133（`\e]133;[A-D]`）の並びと `false` の後の `D;1`、`zoxide: detected a possible configuration issue.`、`. ~/.bashrc` の前後の `declare -p PROMPT_COMMAND PS0` を比べる（README の「読む順番」の表の作り方）
  - AlmaLinux 10 の `/etc/bashrc` は `PROMPT_COMMAND` を配列にする。Git Bash と同じ文字列の場合も、環境変数で `PROMPT_COMMAND=:` を渡して起動して確かめる
- AlmaLinux 10 のコンテナで試すときは、`almalinux:10` に Homebrew（setup-notes の docs/homebrew.md）でツールを入れ、`~/.config/wezterm` に ryo-aoki-pc/wezterm を置く。sshd は 127.0.0.1 の別のポートで立て、`ssh` のコマンド・scp・sftp・rsync を通す
- AlmaLinux 10 の実機で試すときは、利用者の tmux とは別のソケット（`tmux -L <名前>`）のペインに、`load-buffer`・`paste-buffer -p` で貼る。出力は `pipe-pane` で生のまま受ける（AlmaLinux 10 の `tmux-3.3a-13.20230918git…` は、`capture-pane` でサーバーが SIGABRT で落ちた）
  - zoxide の本物のデータベースに書かないよう、`_ZO_DATA_DIR` を一時的な場所にする
  - ssh・scp・sftp は、自分のユーザーで `/usr/sbin/sshd` を 127.0.0.1 の別のポートに立てて通す（使い捨てのホスト鍵とクライアントの鍵、`UsePAM no`・`StrictModes no`。`~/.ssh/authorized_keys` は変えない）。PAM を通らないので `XDG_RUNTIME_DIR` は無い。対話の ssh に `_ZO_DATA_DIR` を渡すなら、その sshd に `AcceptEnv`、ssh に `-o SetEnv=…` を足す
  - podman.socket を一時的に起動したら、止めた後に `/run/user/<UID>/podman/podman.sock` を消す（unit に `RemoveOnStop` が無く、残ったファイルで `DOCKER_HOST` が入り続ける）
- Windows 11 の Git Bash で試すときは、`HOME` を使い捨てのディレクトリにする（その PC の `~/.bashrc` には書かない。docs/install.md の Windows の付録）
  - Git Bash には `script` が無い。擬似端末の代わりに、`wezterm-mux-server` を別のソケット（`unix_domains` の `socket_path`。長いパスは `SUN_LEN` で断られる）で動かし、`wezterm cli spawn`・`send-text`・`get-text` でペインを操作する。`wezterm cli` には必ず `WEZTERM_UNIX_SOCKET` で検証のソケットを渡す（WezTerm の中では、利用者の GUI を指している）
  - `wezterm cli spawn` は、呼んだ側の環境変数をペインに引き継ぐ。`MSYS_NO_PATHCONV` などを付けて呼んだら、ペインの中で外す（付いたままだと、yazi の `--cwd-file=/tmp/…` が変換されず、`C:\tmp` に書かれる）
  - 生の出力を見るだけなら、`bash -i` にコマンドを流し込み、stdout と stderr を 1 つのファイルに受ける（プロンプトと OSC 133 がそのまま残る）
  - zoxide は `HOME` ではなく `%LOCALAPPDATA%\zoxide` にデータベースを書くので、`_ZO_DATA_DIR` を一時的な場所にする
  - Git の `/etc/profile` は、環境変数 `ORIGINAL_PATH` があるとそれで `PATH` を組み立て直す。Claude Code などの Git Bash から起動したログインシェルで PATH を足すなら、`ORIGINAL_PATH` を外す
  - sshd の非対話は、`C:\Program Files\Git\bin\bash.exe -c <コマンド>` を `SSH_CLIENT` を付け、`SHLVL` を外して起動すると真似られる（`~/.bashrc` を読む）
  - 本物の sshd で試すときは、同じ PC の WSL の AlmaLinux 10 から、LAN の IP あてに鍵でつなぐ（WSL の既定の経路の先の IP あては、ファイアウォールで捨てられる。setup-notes の windows-openssh-server.md）。本物の `~/.bashrc` は変えず、遠くで `env -u SHLVL HOME=<使い捨て> bash -c <コマンド>` を起動する
    - `scp -O`・scp は `-S` に遠くのコマンドを包むラッパーを、sftp は `-s` に同じ形のコマンド（`/` を含むとサブシステムではなくコマンドになる）を渡す。Windows の sshd は `sftp-server.exe` も bash から起動する
    - 対話は、`ssh <HOST>` でコマンドなしに入り、`exec env HOME=<使い捨て> … bash -i` に入れ替える（`ssh -tt <HOST> <コマンド>` は、最初の語しか動かなかった）。1 行が長い（585 文字）と次の入力まで渡らなかったので、パスは変数に入れて短くする。値は端末の出力からは拾わず（ConPTY が画面を描き直す）、遠くでファイルに書く
    - SSH のセッションで scoop の shim が起動できない状態は、自分のユーザーで作ったジャンクションを通る shim で作れる（SSH でなければ動く）
    - 後で、取り残された sshd のセッションの bash が無いかを見る
  - 利用者の WezTerm の GUI で試すときは、`wezterm cli spawn --new-window` で窓を足し、ペインに打つ・読む・閉じるコマンドに必ず `--pane-id` を付ける（付けないと、GUI で選ばれているペイン（この会話のペインのこともある）に送られる）
    - キー操作（プロンプトへのジャンプ・出力のコピー）と画面の撮影は、窓を前面にする必要がある。Windows の画面がロックされている間はできない（LogonUI が動き、前面の窓が無い）。ロック中に `PrintWindow` で撮ると、WezTerm の中身は灰色だった
- root のシェルを試すときは、コンテナの `/.dockerenv` を消す（あると Homebrew が root を断らず、実機と違う。setup-notes の homebrew.md の付録）。root の起動で何が動くかは、`strace -f -e trace=execve` を root の `bash -i -c exit` に当てて見る
- 手順 2・更新の git を試すときは、`GIT_TERMINAL_PROMPT=0` を付けて、認証を聞かれずに通ることを見る（docs/install.md の HTTPS の付録）
  - Windows の Git Bash では、`GIT_CONFIG_COUNT` などで `credential.helper` を空にして、Git Credential Manager を呼ばせない（非公開だったときの HTTPS の clone では、資格情報が無いとサインインの窓が開いた）
  - SSH で clone していたときの試し方（本物の `~/.ssh/known_hosts` に書かない）は、docs/install.md の SSH の付録にある

## 構成

- `bashrc` — 本体。前半（PATH と環境変数。非対話のシェルでも読む）と、`case $- in *i*)` で分けた後半（エイリアス・関数・プロンプト。対話のシェルだけ）。最後に `__bash_config_loaded=1`
- `migrate/` — 導入の手順 3 で、元の手順書が `~/.bashrc` に書いた行を消すためのもの
  - `old-lines.txt` — 行全体が同じなら消す行（1 行ずつ。空行は無視）
  - `old-y.txt` — yazi の `y()`（並びがすべて同じときだけ消す）。空行で区切って、setup-notes の今の形（7 行。移ったかを `-ef` で比べる）、それを `shfmt -i 2 -ln bash` に通した形（8 行。LazyVim で `~/.bashrc` を保存したときの整形と同じ）、2026-10-01 に直す前の形（`!=`）とその shfmt の形の 4 つ
  - `remove-old-lines.awk` — 上の 2 つを読み、控えの `~/.bashrc` から消したものを出す
- `docs/install.md` — 導入・更新・ロールバックの手順書。任意節「root のシェルでも読む」は、`sudo -i` の root のシェルで実施手順の手順 1〜8・10 をそのまま貼る形（ブロックが `~` を使うので書き分けない）
- `.gitattributes` — `* text=auto eol=lf`（scoop の git の `core.autocrlf=true` で clone しても CRLF にしない。CRLF の `bashrc` は bash が読めない）

## 変えたら合わせて直すもの

- `bashrc` に読むものを足した・変えた → README の「読むもの」の表、`docs/install.md` の手順 10 とその補足の出力
- 元の手順書（setup-notes の homebrew / zoxide / starship / yazi / eza / gdu / bat / neovim / podman / bash-settings / fzf、ryo-aoki-pc/wezterm の docs/install.md、ryo-aoki-pc/LazyVimStarter の docs/setup.md）が `~/.bashrc` に書く行が変わった → `bashrc`、`migrate/old-lines.txt`（古い形も残す）、README の「移行で消す行」
  - yazi.md の `y()` が変わった → `migrate/old-y.txt` に、新しい形と、それを `shfmt -i 2 -ln bash` に通した形を、空行で区切って足す（古い形も残す）
  - 逆に、この設定が読むものを足したら、元の手順書の直接追記・削除のブロックを外し、共通設定を前提に読み込みと確認だけを書く（setup-notes の CLAUDE.md にも同じ決まりがある）
  - setup-notes が `/root/.bashrc` に書く行（homebrew.md「root のシェルでも使う」の手順 1、lazydocker.md「root でも使う」の手順 2）も同じ扱い。変わったら `migrate/old-lines.txt` に足す。root の分岐（`EUID` が 0）を変えたら、その 2 つの手順の箇条書きも直す
- 読む順番を変えた → README の「読む順番」の表を実測で直す
- 導入のしかた（置き場所・clone の URL・読み込みの 1 行）を変えた → `docs/install.md` の手順と補足の「状態」行・注意点、README の冒頭、`bashrc` の冒頭のコメント

## コードの注意

- **何も出力しない**。`ssh <ホスト> <コマンド>`・scp・rsync のとき、bash は sshd から起動されたことを見分けて `~/.bashrc` を読む（AlmaLinux 10 と Git Bash の両方で実測）。出力すると scp・rsync が壊れる
- 前半には、非対話のシェルでも要るもの（PATH と `export` する環境変数）だけを置く。エイリアス・関数・プロンプトの初期化は後半に置く（非対話のシェルで `eval "$(zoxide init bash)"` などを動かさない）
- **判定は `if …; then …; fi` で書く**。`[ … ] && …` は、偽のときに `$?` を 1 のまま残す。ファイルの最後の `$?` は最初のプロンプトの前のコマンドの終了コードとして扱われ、WezTerm のシェル統合が OSC 133 の `D;1` を送る
- ツールの有無は `command -v <コマンド> >/dev/null 2>&1`（組み込みで fork しない）
  - ただし PATH を順に探すので、Git Bash では 1 回に約 2ms かかる（Windows 11 の PC の 37 要素の PATH。見つからないときがいちばん長い）。同じコマンドを何度も確かめる形は増やさない
- `set -u` でも読めるよう、未設定かもしれない変数は `${変数-}` で参照する
- root かどうかは bash の `${EUID-}`（組み込みの変数。外部コマンドを動かさない）で見る。Git Bash では 0 にならない
- 関数の中から読まない・読ませない（読み込むものが関数の外で `declare` を使うと、その関数のローカル変数になる。2026-09-30 の `brew shellenv`・starship 1.26.0・`shell/wezterm.sh`・zoxide 0.10.0 の初期化には無く、検証コンテナで関数の中から読んでも動いたが、上がったときに壊れないように）
- ネットワークに出ない（自動の `git pull` もしない）。秘密（`*_TOKEN`）とトンネルの変数（`ALL_PROXY`・`https_proxy`）は書かない（ホストの `~/.bashrc` の、読み込みの 1 行より後ろに書く）
- ツールの初期化の `$(…)` のほかに、`$(…)` や外部コマンドを足さない。Git Bash では `$(…)` 1 回で約 10ms、外部コマンド 1 回で 40〜55ms かかる（ryo-aoki-pc/wezterm の CLAUDE.md の実測）
- **プロンプトに関わる 3 つは starship → WezTerm → zoxide の順**。理由と実測は README の「読む順番」
  - starship と zoxide は、既に初期化してあれば初期化し直さない（`declare -F starship_precmd` / `declare -F __zoxide_hook`）。読み直すと starship は `PS0` に、zoxide は配列の `PROMPT_COMMAND` にフックを重ねる
  - ホストの `~/.bashrc` で別の形（`--cmd cd` など）の zoxide を読み込みの行より後ろに残すなら、`--hook none` を付けてもらう（付けないと、配列の `PROMPT_COMMAND` にフックが 2 つ入る。docs/install.md 手順 6）
  - WezTerm のシェル統合（`shell/wezterm.sh`）は、何度読まれてもフックを重ねない作りなので、そのまま読む
- インデントはタブ（ryo-aoki-pc/wezterm の `shell/wezterm.sh` と同じ）。`y()` の本体は setup-notes の yazi.md の手順 3 と同じ文字列にする（`migrate/old-y.txt` の 1 つ目の形とも同じ）

## docs/install.md の書き方

setup-notes の手順書と同じ骨格にする（ryo-aoki-pc/wezterm の CLAUDE.md の「docs/install.md の書き方」と同じ）。要点:

- タイトルの直後に `## 実施手順` を置き、手順は**番号付きリスト 1 つ**（マーカーはすべて `1.`、本文は 3 スペース字下げ）
  - リードの `> [!IMPORTANT]` に実行する場所・前提・対話や切り替えのある手順、続けて読み方の箇条書き、検証範囲の `> [!WARNING]`
  - 変数は置かない（URL と置き場所は固定）
- 各手順は「1 行の説明（「〜する。」）→ コマンドのブロック → 箇条書き（確認・分岐・注意）→ 折り畳み 1 つ（`<details>` / `<summary>補足: 〜</summary>`、前後に空行）」
  - 箇条書きは 1 項目 1 事実で、末尾に「。」を付けない。理由・実測・出力例は折り畳みへ
  - 条件付きの手順は 1 行の説明に条件を書き、判定する手順の箇条書きに「〜なら、手順 N は飛ばす」
  - コマンドの無い操作（エディタで直す、端末を開き直す）も独立した手順にし、次にコマンドを貼る手順の直前に「**次の手順は、〜してから貼る**」を置く
  - 対話のあるコマンド（エディタ・端末を開き直す操作のほか、問いを出すコマンド）は、その手順の最後のコマンドにする
  - `<...>` を含むコマンドはブロックに置かず、箇条書きのインラインコードにする。出力例の値は `<USER>` / `<HOST>` などのプレースホルダで書く
- 手順の後ろに `## 更新`・`## ロールバック`（リード → 番号付きリスト → `---`。節ごとに 1 から数える）、最後に `## 補足`（対象と検証環境・実施前の状態・選択した方針・完了時点の状態・注意点・参照・付録）
- 手順の参照は、`## 実施手順` の中では「手順 N」、ほかの節からは `[手順 N](#実施手順)`、その節の中は「この節の手順 N」。手順を分けたりまとめたりしたら番号を付け替える（README と、元の手順書の箇条書きの番号も）
- アラートは本文の最上位にだけ置き、1 文書に 5 つまで。取り戻せない削除のある節は `> [!CAUTION]` で手順を名指しし、その手順の説明に「（取り戻せない）」
- 閉じの `**` を約物に接して閉じない（`**…（…）**を` は太字にならない）
- 補足の「状態」行は、何を通したか・確認したこと・確認していないことの入れ子の箇条書き。**検証範囲が変わったら、状態行・リードの `> [!WARNING]`・付録を合わせて直す**。付録（検証記録）は書き直さない（手順番号の付け替えだけ）
- コマンドは実際に実行したものを載せる。手順書のブロックを変えたら、コンテナなどで抜き出して流し直してから「検証済み」と書く
- パスワード・鍵・トークンは書かない
