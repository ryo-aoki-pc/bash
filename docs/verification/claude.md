# bash 開発ガイドの検証記録

対象の操作は [当時の導入手順](https://github.com/ryo-aoki-pc/bash/blob/67abb84ed5601b242870841ff1da381388f5427a/docs/install.md)、導入結果は [検証記録](install.md) を参照する。

## 新規 AlmaLinux VM での導入

2026-10-06 に AlmaLinux 10.2 Workstation の x86_64 新規 VM で `install.sh` の初回・再実行・root 自身の導入と 8 回帰テストを確認した。別の専用ユーザーでは既知の旧設定の手動移行も通した（[install.sh](quick-start.md#新規-almalinux-vm-での再検証2026-10-06)・[手動移行](install.md#付録-新規-almalinux-vm-での手動移行の再検証2026-10-06)の再検証記録）。Windows / WSL の新スクリプトの実導入、任意の手編集、全ツールの組み合わせは含まない。

## man ページャの表示

同日の実 PTY の `man bash` で、旧 `col -bx` パイプが SGR の断片を文字として残したため、bat 公式 README と同じ `MANPAGER="bat -plman"` へ変更した。移行一覧は旧値を残して新値も加えた。AlmaLinux 10.2 の表示を確認し、Windows / WSL / aarch64 の表示は再検証していない。

