#!/usr/bin/env bash
# clone 後に bash install.sh で実行する。設定本体は実行せず、読み込み口だけを作る。
# メッセージ内の ~ と ${...} は、利用者に示す操作としてそのまま表示する。
# shellcheck disable=SC2088,SC2016
if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
	printf '%s\n' '中断: source せず、bash ~/.config/bash/install.sh で実行する' >&2
	return 1
fi
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
if [[ ! "$repo_dir" -ef "$HOME/.config/bash" ]]; then
	printf '%s\n' '中断: このリポジトリを ~/.config/bash に clone してから実行する' >&2
	exit 1
fi
for file in bashrc migrate/remove-old-lines.awk migrate/old-lines.txt migrate/old-y.txt; do
	if [[ ! -r "$repo_dir/$file" ]]; then
		printf '中断: %s が読めない\n' "$repo_dir/$file" >&2
		exit 1
	fi
done
bash -n "$repo_dir/bashrc"

rc_file=$HOME/.bashrc
backup_file=$HOME/.bashrc.before-bash
if [[ -e "$rc_file" || -L "$rc_file" ]]; then
	if [[ ! -f "$rc_file" || ! -r "$rc_file" || ! -w "$rc_file" ]]; then
		printf '%s\n' '中断: ~/.bashrc が読み書きできる通常ファイルではない' >&2
		exit 1
	fi
	input_file=$rc_file
else
	input_file=/dev/null
fi

umask 077
stage_dir=$(mktemp -d "${TMPDIR:-/tmp}/bash-install.XXXXXX")
trap 'rm -rf -- "$stage_dir"' EXIT
awk -f "$repo_dir/migrate/remove-old-lines.awk" \
	"$repo_dir/migrate/old-lines.txt" "$repo_dir/migrate/old-y.txt" \
	"$input_file" > "$stage_dir/bashrc"
source_line='if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi'
if ! grep -qxF "$source_line" "$stage_dir/bashrc"; then
	printf '%s\n' "$source_line" >> "$stage_dir/bashrc"
fi
# 一致した行を消すと if の中が空になる場合などは、元のファイルを変える前に止まる。
if ! bash -n "$stage_dir/bashrc"; then
	printf '%s\n' '中断: 移行後の構文が不正。~/.bashrc は変更していない。docs/install.md の手動手順で移行する' >&2
	exit 1
fi

if cmp -s "$input_file" "$stage_dir/bashrc"; then
	printf '%s\n' '~/.bashrc: 変更なし'
else
	if [[ -e "$backup_file" || -L "$backup_file" ]]; then
		printf '%s\n' '中断: ~/.bashrc.before-bash が既にある。控えを確認して別名に退避してから再実行する' >&2
		exit 1
	fi
	# 空の .bashrc にも戻せるよう、新規導入では空ファイルを控える。
	if [[ "$input_file" == /dev/null ]]; then
		(set -o noclobber; : > "$backup_file")
	else
		(set -o noclobber; cat -- "$rc_file" > "$backup_file")
	fi
	# リンクと既存のパーミッションを保つ。控えは秘密を含み得るので 0600。
	cat -- "$stage_dir/bashrc" > "$rc_file"
	printf '%s\n' '~/.bashrc: 設定済み（元の内容: ~/.bashrc.before-bash）'
fi

profile_file=
for file in .bash_profile .bash_login .profile; do
	if [[ -e "$HOME/$file" || -L "$HOME/$file" ]]; then
		profile_file=$file
		break
	fi
done
if [[ -z "$profile_file" ]]; then
	(set -o noclobber; printf '%s\n' \
		'# bash/install.sh: ログインシェルでも ~/.bashrc を読む' \
		'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' > "$HOME/.bash_profile")
	printf '%s\n' '~/.bash_profile: 作成済み'
else
	printf '~/%s: 既存の内容を維持。ログインシェルから ~/.bashrc を読むことを確認する\n' "$profile_file"
fi
printf '%s\n' \
	'完了: 端末を開き直す。確認: echo "${__bash_config_loaded-読まれていない}"' \
	'独自のツール設定が残る場合は docs/install.md の手順 6 に従い、共通設定の読み込み行より後ろへ移す。'
