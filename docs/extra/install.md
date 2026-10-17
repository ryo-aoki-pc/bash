# 共通の bash 設定の注意点

手順は setup-notes の[共通の bash 設定](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定)。背景は[参考資料](../reference/install.md)、検証は[検証記録](https://github.com/ryo-aoki-pc/setup-notes-verification/blob/main/repos/bash/docs/verification/install.md)、戻すときは [install.sh のロールバック](quick-start.md#ロールバック)を参照する。

## 注意点

- 非対話のシェルでも `~/.bashrc` が読まれる。scp・sftp・rsync を壊さないよう、ホスト固有の追記から出力しない
- Windows の対話 SSH で scoop の shim が起動できないときは、setup-notes の [Windows 11 の初期設定の「scoop のツールを SSH のセッションで使う」](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md#scoop-のツールを-ssh-のセッションで使う)を行う
- ツールを後から入れたときは `. ~/.bashrc` で読み直す。starship を入れたときは、読み込み順を保つため端末を開き直す
- トークン・パスワード・トンネルの変数は共通設定に書かない（README の[ホストだけの設定](../../README.md#ホストだけの設定)）
- root に導入するのは一般ユーザーを信用できるホストだけ。root は一般ユーザーが書き換えられる Homebrew のコマンドを実行する
