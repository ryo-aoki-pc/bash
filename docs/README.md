# bash 設定の文書索引

共通の bash 設定の概要は [リポジトリの README](../README.md) を参照する。通常の導入は `quick-start.md`、移行を手で確認する場合は `install.md` を使う。

## 導入・運用

| 目的 | 手順 |
| --- | --- |
| 通常の導入 | [quick-start.md の実施手順](quick-start.md#実施手順) |
| 手動での導入・旧設定からの移行 | [install.md の実施手順](install.md#実施手順) |
| root のシェルでも使う | [install.md の任意節](install.md#root-のシェルでも読む任意) |
| 共通設定を更新する | [通常導入の更新](quick-start.md#更新)・[手動導入の更新](install.md#更新) |
| 変更前に戻す | [通常導入のロールバック](quick-start.md#ロールバック)・[手動導入のロールバック](install.md#ロールバック) |
| ホスト固有の設定を残す | [README のホストだけの設定](../README.md#ホストだけの設定) |

## 背景と検証記録

| 対象 | 補足資料 | 検証記録 |
| --- | --- | --- |
| 通常の導入・setup-notes の追記との対応 | [reference/quick-start.md](reference/quick-start.md) | [verification/quick-start.md](verification/quick-start.md) |
| 手動での導入・移行・root のシェル | [reference/install.md](reference/install.md) | [verification/install.md](verification/install.md) |
| 読む設定・読む順番・移行で消す行 | [reference/readme.md](reference/readme.md) | [verification/readme.md](verification/readme.md) |

## 設定を変更する

- [README の設定を足すとき](../README.md#設定を足すとき)で、共通設定と元の手順書を合わせて更新する箇所を確認する
- [CLAUDE.md](../CLAUDE.md)で、コードの注意・手順書の書き方・検証方法を確認する
- 開発ガイドの既存の実施結果と背景は [verification/claude.md](verification/claude.md) を参照する
