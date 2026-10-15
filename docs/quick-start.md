# 共通の bash 設定の導入

Windows 11・AlmaLinux 10 の導入・利用・更新手順は setup-notes のシェルと端末のセットアップに集約した。

## 実施手順

[AlmaLinux 10](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定) / [Windows 11](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#git-bash-と-wezterm-の設定)

## 更新

[AlmaLinux 10](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を更新する) / [Windows 11](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#windows-11-で共通の-bash-設定を更新する)

## 検証

- `python3 -m unittest discover -s tests` で新規導入、既知の旧設定の移行、再実行、控えの保護、構文エラー時の無変更、リンクと既存ログイン設定の保持を検証する
- `bash -n install.sh && bash -n bashrc` と `shellcheck -s bash install.sh bashrc` で構文と静的検査を行う
- 過去の設定本体の検証は [設定本体の検証記録](verification/install.md)。新しいスクリプトの検証と、過去の実機検証は別のもの

## ロールバック

[元に戻す手順](extra/quick-start.md#ロールバック)

## 手動移行

[確認しながら移行する](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定を手動で移行する)（Windows 11 も Git Bash で同じ全節を行う）
