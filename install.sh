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
if [[ ! -r "$repo_dir/bashrc" ]]; then
	printf '中断: %s が読めない\n' "$repo_dir/bashrc" >&2
	exit 1
fi
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
cat -- "$input_file" > "$stage_dir/bashrc"
source_line='if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi'
if ! grep -qxF "$source_line" "$stage_dir/bashrc"; then
	if [[ -s "$stage_dir/bashrc" && -n $(tail -c 1 "$stage_dir/bashrc") ]]; then
		printf '\n' >> "$stage_dir/bashrc"
	fi
	printf '%s\n' "$source_line" >> "$stage_dir/bashrc"
fi
# 読み込み行を足した内容を確かめてから、元のファイルへ書く。
if ! bash -n "$stage_dir/bashrc"; then
	printf '%s\n' '中断: 読み込み行を足した内容の構文が不正。~/.bashrc は変更していない。導入手順: https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定' >&2
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

if [[ -n "${TERMUX_VERSION-}" ]]; then
	printf '%s\n' '~/.bash_profile: 作成しない（Termux の $PREFIX/etc/profile がログインシェルで ~/.bashrc を読む）'
else
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
fi
printf '%s\n' \
	'完了: 端末を開き直す。確認: echo "${__bash_config_loaded-読まれていない}"' \
	'独自設定は共通設定の読み込み行より後ろへ移す（導入手順: https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/shell-terminal.md#共通の-bash-設定）。'
