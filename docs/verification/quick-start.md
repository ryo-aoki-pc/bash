# 共通 bash 設定の導入の検証記録

以下は既存文書から移した記録。本文の「本書」「この文書」と手順番号は、記録元の手順書を指す。新しく検証した記録ではない。

操作は [quick-start.md](../quick-start.md) を参照する。

## 導入スクリプトの検証範囲

- 新しい導入スクリプトは Linux の一時ホームと、AlmaLinux 10.2 の新規 x86_64 VM で検証。Windows 11 / WSL の実機では未検証

## setup-notes の追記との照合記録

2026-10-05（日本時間）に setup-notes の全 Markdown を検索し、追記手順のある 12 文書と、WezTerm の参照先を照合した。標準の `~/.bashrc` の設定はすべて `bashrc` にある。各ツールの手順書は設定の確認を行い、同じ設定を `~/.bashrc` に重ねて書かない。

### 新規 AlmaLinux VM での再検証（2026-10-06）

- 同じ VM の CLI 検証中に `man bash` で SGR の断片が残ることを再現し、ページャは `bat -plman` に修正した（[修正の記録](install.md#付録-man-ページャの修正と再検証2026-10-06)）。以下の初回導入と手動移行は修正前の `3d5323e` を対象とする

- 対象は `3d5323e`。公式 ISO から新規導入した AlmaLinux 10.2 Workstation の x86_64 VM（kernel `6.12.0-211.61.1.el10_2.x86_64`、SELinux Enforcing、firewalld active）で、一般ユーザーの SSH 対話 bash に初回導入のブロックを渡した
- OS 既定の `~/.bashrc` と `~/.bash_profile` から導入した。控えは 0600、読み込み行は 1 個。再実行後、両設定ファイルと控えの SHA256 が変わらなかった。読み直した対話シェルで印は `1`、履歴は `100000` / `100000` / `ignoreboth`、5 つの `shopt` は `on`
- `python3 -m unittest discover -s tests` は 8 件成功。`bash -n install.sh` / `bash -n bashrc` も成功し、既知の旧設定の移行・控え保護・リンク保持・既存ログイン設定保持を一時ホームで確認した。設定本体を非対話シェルで読むと出力は 0 byte、`set -u` の非対話・対話シェルも成功
- 同じ VM の root 自身にも公開 URL から clone して導入し、root の対話シェルで印・履歴・`shopt` と Homebrew の PATH を確認した。root の控えも 0600、読み込み行は 1 個、再実行は変更なしだった
- この記録は自動導入スクリプトと読み込みの確認。既知の旧設定の手動移行は [install.md の別の記録](install.md#付録-新規-almalinux-vm-での手動移行の再検証2026-10-06)に分けた。Windows / WSL、任意の手編集、すべてのツールの組み合わせを検証済みにはしない
