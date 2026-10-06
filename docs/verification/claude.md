# bash 開発ガイドの検証記録

以下は既存文書から移した記録。本文の「本書」「この文書」と手順番号は、記録元の手順書を指す。新しく検証した記録ではない。

操作は [導入手順](../install.md)、導入結果は [検証記録](install.md) を参照する。

## 既存ガイドの背景と履歴

いろいろなホスト（AlmaLinux 10 の x86_64 / aarch64・WSL、Windows 11 の Git Bash）で共有する bash の設定。各ホストの `~/.config/bash` に clone し、`~/.bashrc` の末尾の 1 行（`if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi`）で読む。ホストごとに入っているツールが違うので、どの設定もツールがあるかを起動のたびに確かめる。root のシェルでも読める（2026-10-05。root は `/root/.config/bash` に自分の clone を作り、`/root/.bashrc` の同じ 1 行で読む。自分専用のマシンで一般ユーザーを信用できる前提で、root でも `brew shellenv`・starship・zoxide・fzf を同じように読む。違うのは `DOCKER_HOST` だけで、root は `/run/podman/podman.sock`）。公開のリポジトリで（2026-10-03 に公開）、どのホストも HTTPS で clone する（`https://github.com/ryo-aoki-pc/bash.git`。認証は要らない。HTTPS の git は setup-notes の ssh-socks-tunnel.md のトンネルも通る）。非公開だった間は、HTTPS（gh の資格情報）、2026-10-01 からは SSH（GitHub に登録した鍵）で clone していた。

## 既存ガイドの実施結果

2026-10-06 に AlmaLinux 10.2 Workstation の x86_64 新規 VM で `install.sh` の初回・再実行・root 自身の導入と 8 回帰テストを確認した。別の専用ユーザーでは既知の旧設定の手動移行も通した（`docs/quick-start.md`・`docs/install.md` の再検証記録）。Windows / WSL の新スクリプトの実導入、任意の手編集、全ツールの組み合わせは含まない。

## 既存ガイドの実施結果

同日の実 PTY の `man bash` で、旧 `col -bx` パイプが SGR の断片を文字として残したため、bat 公式 README と同じ `MANPAGER="bat -plman"` へ変更した。移行一覧は旧値を残して新値も加えた。AlmaLinux 10.2 の表示を確認し、Windows / WSL / aarch64 の表示は再検証していない。

