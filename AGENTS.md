# AGENTS.md

このリポジトリで作業するコーディングエージェント（Claude Code・Codex・Grok Build・Antigravity CLI）への指示。Claude Code は CLAUDE.md の `@AGENTS.md` で、Codex・Grok Build・Antigravity CLI はこのファイルを直接読む。

利用者への回答・質問・報告は、常に日本語で書く（コードのコメントなどの言語は、このファイルのほかの決まりに従う）。

## 導入手順の正本

導入・利用・更新の手順は、setup-notes の [shell-terminal.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md) の「共通の bash 設定」とその子の項（AlmaLinux 10）、「Git Bash と WezTerm の設定」とその子の項（Windows 11）にある。このリポジトリには置かない。共通 bash 設定が読むツールの初期化を、手順書で `~/.bashrc` に直接追記させない。

## このリポジトリは何か

AlmaLinux 10・WSL・Windows 11 の Git Bash で共有する bash 設定。各ホストの `~/.config/bash` に公開 URL を HTTPS で clone し、`~/.bashrc` の 1 行で読む。root は自分の clone を使い、一般ユーザーを信用できるホストで導入する。

初回導入は正本から `install.sh` を実行する。読み込み行を足した内容の構文検査を先に行い、控えが既にあれば上書きせず中断する。`.bashrc` のリンクとモードを保ち、既存のログイン設定は変えない。設定本体の実行・ネットワーク接続・ツールの導入はしない。

ビルド・外部のテストフレームワークは無い。ドキュメント・コードのコメント・コミットメッセージは日本語で書く。検証していないことを「動く」と書かない。

## よく使うコマンド

```bash
# 導入の回帰テスト（使い捨てのホームだけを変更する。Windows では WSL の中で動かす）
python3 -m unittest discover -s tests

# 構文と静的検査（ShellCheck は setup-notes の docs/almalinux-setup.md の「ShellCheck と shfmt」で入れる）
bash -n install.sh && bash -n bashrc
shellcheck -s bash install.sh bashrc

# 非対話のシェルで何も出さないこと（0 が出ればよい）
bash -c '. ~/.config/bash/bashrc' 2>&1 | wc -c
bash -u -c '. ~/.config/bash/bashrc; echo ok'                                  # set -u でも読める（前半。非対話では後半の前で抜ける）
bash --norc -u -i -c '. ~/.config/bash/bashrc; echo "ok-$__bash_config_loaded"'  # 後半も（ok-1 が出ればよい）
```

- プロンプトに関わる変更（`PROMPT_COMMAND`・`PS0`・`PS1`）は、対話のシェルを擬似端末で動かして生の出力を見る。`script -q -E never -O <ログ> -c 'bash -il'` に、間を空けてコマンドを流し込み、ログの OSC 133（`\e]133;[A-D]`）の並びと `false` の後の `D;1`、`zoxide: detected a possible configuration issue.`、`. ~/.bashrc` の前後の `declare -p PROMPT_COMMAND PS0` を比べる（docs/verification/readme.md の「読む順番の検証記録」の表の作り方）
  - AlmaLinux 10 の `/etc/bashrc` は `PROMPT_COMMAND` を配列にする。Git Bash と同じ文字列の場合も、環境変数で `PROMPT_COMMAND=:` を渡して起動して確かめる
- AlmaLinux 10 のコンテナで試すときは、`almalinux:10` に Homebrew（setup-notes の docs/almalinux-setup.md の「Homebrew」の手順 1〜3 と、シェルと端末のセットアップの「シェルのツール」の手順 1）でツールを入れ、`~/.config/wezterm` に ryo-aoki-pc/wezterm を置く。sshd は 127.0.0.1 の別のポートで立て、`ssh` のコマンド・scp・sftp・rsync を通す
- AlmaLinux 10 の実機で試すときは、利用者の tmux とは別のソケット（`tmux -L <名前>`）のペインに、`load-buffer`・`paste-buffer -p` で貼る。出力は `pipe-pane` で生のまま受ける（AlmaLinux 10 の `tmux-3.3a-13.20230918git…` は、`capture-pane` でサーバーが SIGABRT で落ちた）
  - zoxide の本物のデータベースに書かないよう、`_ZO_DATA_DIR` を一時的な場所にする
  - ssh・scp・sftp は、自分のユーザーで `/usr/sbin/sshd` を 127.0.0.1 の別のポートに立てて通す（使い捨てのホスト鍵とクライアントの鍵、`UsePAM no`・`StrictModes no`。`~/.ssh/authorized_keys` は変えない）。PAM を通らないので `XDG_RUNTIME_DIR` は無い。対話の ssh に `_ZO_DATA_DIR` を渡すなら、その sshd に `AcceptEnv`、ssh に `-o SetEnv=…` を足す
  - podman.socket を一時的に起動したら、止めた後に `/run/user/<UID>/podman/podman.sock` を消す（unit に `RemoveOnStop` が無く、残ったファイルで `DOCKER_HOST` が入り続ける）
- Windows 11 の Git Bash で試すときは、`HOME` を使い捨てのディレクトリにする（その PC の `~/.bashrc` には書かない。docs/verification/install.md の Windows の付録）
  - Git Bash には `script` が無い。擬似端末の代わりに、`wezterm-mux-server` を別のソケット（`unix_domains` の `socket_path`。長いパスは `SUN_LEN` で断られる）で動かし、`wezterm cli spawn`・`send-text`・`get-text` でペインを操作する。`wezterm cli` には必ず `WEZTERM_UNIX_SOCKET` で検証のソケットを渡す（WezTerm の中では、利用者の GUI を指している）
  - `wezterm cli spawn` は、呼んだ側の環境変数をペインに引き継ぐ。`MSYS_NO_PATHCONV` などを付けて呼んだら、ペインの中で外す（付いたままだと、yazi の `--cwd-file=/tmp/…` が変換されず、`C:\tmp` に書かれる）
  - 生の出力を見るだけなら、`bash -i` にコマンドを流し込み、stdout と stderr を 1 つのファイルに受ける（プロンプトと OSC 133 がそのまま残る）
  - zoxide は `HOME` ではなく `%LOCALAPPDATA%\zoxide` にデータベースを書くので、`_ZO_DATA_DIR` を一時的な場所にする
  - Git の `/etc/profile` は、環境変数 `ORIGINAL_PATH` があるとそれで `PATH` を組み立て直す。Claude Code などの Git Bash から起動したログインシェルで PATH を足すなら、`ORIGINAL_PATH` を外す
  - sshd の非対話は、`C:\Program Files\Git\bin\bash.exe -c <コマンド>` を `SSH_CLIENT` を付け、`SHLVL` を外して起動すると真似られる（`~/.bashrc` を読む）
  - 本物の sshd で試すときは、同じ PC の WSL の AlmaLinux 10 から、LAN の IP あてに鍵でつなぐ（WSL の既定の経路の先の IP あては、ファイアウォールで捨てられる。setup-notes の windows-setup.md の「SSH でログインを確かめる」と、その注意点）。本物の `~/.bashrc` は変えず、遠くで `env -u SHLVL HOME=<使い捨て> bash -c <コマンド>` を起動する
    - `scp -O`・scp は `-S` に遠くのコマンドを包むラッパーを、sftp は `-s` に同じ形のコマンド（`/` を含むとサブシステムではなくコマンドになる）を渡す。Windows の sshd は `sftp-server.exe` も bash から起動する
    - 対話は、`ssh <HOST>` でコマンドなしに入り、`exec env HOME=<使い捨て> … bash -i` に入れ替える（`ssh -tt <HOST> <コマンド>` は、最初の語しか動かなかった）。1 行が長い（585 文字）と次の入力まで渡らなかったので、パスは変数に入れて短くする。値は端末の出力からは拾わず（ConPTY が画面を描き直す）、遠くでファイルに書く
    - SSH のセッションで scoop の shim が起動できない状態は、自分のユーザーで作ったジャンクションを通る shim で作れる（SSH でなければ動く）
    - 後で、取り残された sshd のセッションの bash が無いかを見る
  - 利用者の WezTerm の GUI で試すときは、`wezterm cli spawn --new-window` で窓を足し、ペインに打つ・読む・閉じるコマンドに必ず `--pane-id` を付ける（付けないと、GUI で選ばれているペイン（この会話のペインのこともある）に送られる）
    - キー操作（プロンプトへのジャンプ・出力のコピー）と画面の撮影は、窓を前面にする必要がある。Windows の画面がロックされている間はできない（LogonUI が動き、前面の窓が無い）。ロック中に `PrintWindow` で撮ると、WezTerm の中身は灰色だった
- root のシェルを試すときは、コンテナの `/.dockerenv` を消す（あると Homebrew が root を断らず、実機と違う。setup-notes の almalinux-setup.md の検証記録にある「Homebrew」の付録）。root の起動で何が動くかは、`strace -f -e trace=execve` を root の `bash -i -c exit` に当てて見る
- clone・更新の git を試すときは、`GIT_TERMINAL_PROMPT=0` を付けて、認証を聞かれずに通ることを見る（docs/verification/install.md の HTTPS の付録）
  - Windows の Git Bash では、`GIT_CONFIG_COUNT` などで `credential.helper` を空にして、Git Credential Manager を呼ばせない

## 構成

- `bashrc` — 本体。前半（PATH と環境変数。非対話のシェルでも読む）と、`case $- in *i*)` で分けた後半（エイリアス・関数・プロンプト。対話のシェルだけ）。最後に `__bash_config_loaded=1`
- `install.sh` — 初回の読み込み設定と控えの作成。`tests/test_install.py` が、一時ホームで導入・既存内容の保持・再実行を確かめる
- `docs/extra/install.md` — 注意点。`docs/extra/quick-start.md` — `install.sh` のロールバック
- `docs/reference/readme.md` — 読むもの・Git Bash と root での違い・読む順番。`docs/reference/install.md` — 導入の背景と `install.sh` の仕組み
- `docs/verification/` — 検証記録（`readme.md` は README と参考資料の実測、`install.md` は設定本体と導入、`quick-start.md` は `install.sh`、`claude.md` は開発ガイドの検証記録）
- `.gitattributes` — `* text=auto eol=lf`（scoop の git の `core.autocrlf=true` で clone しても CRLF にしない。CRLF の `bashrc` は bash が読めない）

## 変えたら合わせて直すもの

- `bashrc` に読むものを足した・変えた → `docs/reference/readme.md` の「読むもの」の表、正本の「共通の bash 設定」の確認を同期し、`docs/verification/install.md` に新しい検証結果を追記する
- この設定が読むものを足したら、正本は共通設定を前提に読み込みと確認だけを書く（setup-notes の AGENTS.md にも同じ決まりがある）
- 読む順番を変えた → `docs/verification/readme.md` の実測を記録し、`docs/reference/readme.md` の「読む順番」を直す
- 導入のしかた（置き場所・clone の URL・読み込みの 1 行）を変えた → 正本の手順・`docs/extra/install.md` の注意点・README の「導入」・`bashrc` の冒頭のコメントを同期し、`docs/verification/install.md` に新しい対象版と実施範囲を追記する

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
- ツールの初期化の `$(…)` のほかに、`$(…)` や外部コマンドを足さない。Git Bash では `$(…)` 1 回で約 10ms、外部コマンド 1 回で 40〜55ms かかる（ryo-aoki-pc/wezterm の AGENTS.md の実測）
- **プロンプトに関わる 3 つは starship → WezTerm → zoxide の順**。理由は `docs/reference/readme.md` の「読む順番」、実測は `docs/verification/readme.md`
  - starship と zoxide は、既に初期化してあれば初期化し直さない（`declare -F starship_precmd` / `declare -F __zoxide_hook`）。読み直すと starship は `PS0` に、zoxide は配列の `PROMPT_COMMAND` にフックを重ねる
  - ホストの `~/.bashrc` で別の形（`--cmd cd` など）の zoxide を読み込みの行より後ろに残すなら、`--hook none` を付けてもらう（付けないと、配列の `PROMPT_COMMAND` にフックが 2 つ入る。README の「ホストだけの設定」）
  - WezTerm のシェル統合（`shell/wezterm.sh`）は、何度読まれてもフックを重ねない作りなので、そのまま読む
- インデントはタブ（ryo-aoki-pc/wezterm の `shell/wezterm.sh` と同じ）。`y()` は、移動先と現在のディレクトリが同じかを `-ef` で比べ、空白と日本語を含むパスも引用して扱う

## 文書の置き場所

- 導入・利用・更新の手順は正本に置き、README の「導入」の表から正本の項へ直接リンクする（手順書の先頭やカテゴリの見出しへはリンクしない）。執筆規則は setup-notes の `docs/dev/writing-rules.md`
- `docs/extra/` はロールバックと注意点、`docs/reference/` は背景、`docs/verification/` は検証記録（環境・日付・対象コミット・実出力・未確認事項）。変更後の確認のコマンドは上の「よく使うコマンド」
- 文書を移す・分ける・まとめるときは、移した経緯と、旧ファイル名・旧見出しとの対応を文書に書かない（経緯は git の履歴と Pull Request の本文に残す）。リンクを今の場所へ直す。中身が新しい場所への案内だけになったファイルは消す
- 残す検証記録の実施日・対象版・環境・出力・成功と失敗・未実施の範囲・記録したときの手順番号は書き換えない。再検証せずに検証範囲を広げない。記録の手順番号が今の手順と違い、本文を読むのに要るときだけ「記録の手順 | 今の手順」の表で結ぶ
- 操作を変えたら、正本・README の表・参考資料を合わせて直す

## 共同作業の規則

このリポジトリでは、Claude Code・Codex・Grok Build・Antigravity CLI が同じ規則で作業する。分担は人が決める。

- 起動された worktree（作業ディレクトリ）の中だけでファイルを変える。ほかの worktree のファイルは変えない
- 今のブランチにだけコミットする。`main` にはコミットも push もしない
- 頼まれた範囲のファイルだけを変える。範囲の外を変えるときは、変える前に理由を書いて確かめる
- 終わったら、テストとリンターを通してから、目的ごとにコミットする。通らなければコミットせずに、結果を報告する
- コミットしたら、今のブランチを push し、`main` への Pull Request を作る（既にあれば足す）。今のブランチに `main` を取り込むのは、頼まれたときと、Pull Request が競合したときだけ
- `main` への取り込み（マージ）は、エージェントが行ってよい。テストとリンターが通り、Pull Request が競合していなければ、`gh pr merge --squash` で Pull Request を取り込む（手元の `main` にはコミットも push もしない）。利用者が取り込まないよう頼んだときは取り込まず、そのことを報告する。取り込んだ Pull Request のブランチは、GitHub がリモートから自動で消す（リポジトリの Automatically delete head branches は人が有効にしておき、エージェントは変えない）。取り込んだブランチには、その後コミットも push もせず、次の作業は新しいブランチで始める。手元に残ったブランチは、エージェントが消す。消すのは自分が作ったブランチだけで、Pull Request が取り込まれたこと（`gh pr view <番号> --json state` が `MERGED`）と、どの worktree でも使っていないこと（`git worktree list`）を確かめてから、`git branch -D <ブランチ>` で消す（squash で取り込むので `git branch -d` は通らない）。今いるブランチは、新しいブランチへ移ってから消す。ほかの担当のブランチは消さない
- 秘密情報（`.env`・鍵・トークン・パスワード）を読まない・書かない・出力しない
- レビューを頼まれたら、ファイルを変えずに、指摘を「重大度・場所（ファイル:行）・理由・直し方」で挙げる
- ほかの担当の変更は、`git diff main...agent/codex` のように git で読む（ほかの worktree へ移らない）

## 既定の分担

利用者が Claude Code に、分担を指定せずにファイルを変える作業を頼んだときは、Claude Code が取りまとめて次の 4 つで分担する。「共同作業の規則」の「分担は人が決める」で、人が分担を決めていないときの既定にする。利用者がほかのエージェントに直接頼んだときは、この節は使わず「共同作業の規則」に従う。

- Claude Code だけで行うもの: 利用者の質問への答え、ファイルを変えない調べもの、1 つのファイルの数行で振る舞いを変えない直し（誤字・リンク・値の直しなど）
- Claude Code: 計画・実機での確かめ・ほかの 3 つへの依頼・指摘の確かめ・統合・コミットと Pull Request・取り込み
- Codex: 実装と下書き。Claude Code が用意した別の clone か worktree の中だけで書く。この分担で頼まれたときは、「共同作業の規則」のコミット・push・Pull Request・取り込みを行わず、変更を残して報告する（Claude Code が確かめ、自分の worktree に移してからコミットする）
- Grok Build: 差分の読み取り専用のレビュー。ファイルを変えない（Windows 11 では、Claude Code は `--always-approve` を付けずに頼む）
- Antigravity CLI: 差分の読み取り専用のレビューと、その作業のための調べもの。ファイルを変えない（Claude Code は、入力を写した使い捨てのフォルダーで 1 回だけ実行し、`--dangerously-skip-permissions`・`--mode` を付けない）
- Claude Code から頼まれたエージェントは、上の自分の役割の範囲で作業する
- レビューの指摘は、実物で確かめてから採る。採らなかった指摘は、理由を付けて報告する
- 使えないエージェント（入っていない・ログインが切れた）は飛ばし、そのことを報告する
- 頼み方は、[setup-notes](https://github.com/ryo-aoki-pc/setup-notes) の `docs/ai-agents.md` の「コーディングエージェントの共同作業: 既定で分担する」と、`docs/reference/coding-agents.md` の「既定の分担」
