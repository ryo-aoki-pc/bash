# いろいろなホストで共有する bash の設定
#
# 読み込み方（~/.bashrc の末尾に次の 1 行を書く。docs/install.md）:
#
#   if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi
#
# ホストによって入っているツールが違うので、どの設定も、そのコマンドがあるかを
# シェルを開くたびに確かめ、無ければ何もしない。ツールを後から入れても、次に開いた
# シェルから効く（今のシェルで使うなら . ~/.bashrc で読み直す。starship だけは、
# 読み直すと WezTerm のシェル統合より後ろになるので、端末を開き直す。README の「読む順番」）。
# ホストだけの設定（トークンなど）はここに書かず、~/.bashrc の上の 1 行より後ろに書く。
#
# ※ 何も出力しない（scp・rsync・ssh <ホスト> <コマンド> の非対話のシェルでも読まれる）
# ※ 判定は if … fi で書く。[ … ] && … だと、ツールが無いときに $? が 1 のまま残り、
#   最初のプロンプトが失敗の扱いになる（WezTerm の OSC 133 の D;1 など）
# ※ set -u のシェルでも読めるよう、未設定かもしれない変数は ${変数-} で参照する
# ※ 関数の中から読まない（読み込むものが関数の外で declare を使うと、その関数のローカル変数になる。
#   今の Homebrew・starship・WezTerm・zoxide の初期化には無いが、上がったときに壊れないように）

# --- すべての bash ------------------------------------------------------------
# ssh <ホスト> <コマンド> や ssh -t <ホスト> lazygit のような非対話のシェルでも要る、
# PATH と環境変数だけを置く

# Homebrew（setup-notes の docs/homebrew.md 手順 3）
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi

# Neovim を既定のエディタにする（docs/neovim.md「既定のエディタにする」）
if command -v nvim >/dev/null 2>&1; then
	export EDITOR=nvim
	export VISUAL=nvim
fi

# man のページャに bat を使う（docs/bat.md「ページャに使う」）
if command -v bat >/dev/null 2>&1; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# Docker の API を使うツールに podman のソケットを教える（docs/podman.md「Docker 向けのツールから使う」）
# ソケットがあるときだけ足す（podman.socket を有効にしていないホストや、
# XDG_RUNTIME_DIR の無い sudo -iu のシェルでは足さない）
# root は、root のコンテナを扱うシステムの podman.socket のソケットにする（docs/lazydocker.md「root でも使う」）
if [ -z "${DOCKER_HOST-}" ]; then
	if [ "${EUID-}" = 0 ]; then
		if [ -S /run/podman/podman.sock ]; then
			export DOCKER_HOST=unix:///run/podman/podman.sock
		fi
	elif [ -S "${XDG_RUNTIME_DIR-}/podman/podman.sock" ]; then
		export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
	fi
fi

# --- 対話の bash だけ ---------------------------------------------------------
case $- in
*i*) ;;
*) return 0 ;;
esac

# 履歴と shopt（setup-notes の docs/bash-settings.md 手順 3）。ツールの有無によらず入れる
# histappend は AlmaLinux 10 の /etc/bashrc が対話のシェルに入れているが、Git Bash の既定は off なのでここでも入れる
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s autocd cdspell dirspell globstar

if command -v nvim >/dev/null 2>&1; then
	alias vi=nvim
fi

# eza（docs/eza.md「エイリアスを足す」。ls は置き換えない）
if command -v eza >/dev/null 2>&1; then
	alias ll="eza -l --git --group-directories-first"
	alias la="eza -la --git --group-directories-first"
	alias lt="eza --tree --level=2"
fi

# gdu（docs/gdu.md「gdu の名前で呼ぶ」。Homebrew 版の実行ファイルは gdu-go）
if command -v gdu-go >/dev/null 2>&1; then
	alias gdu=gdu-go
fi

# yazi を閉じたときに、そのディレクトリへ移る y（docs/yazi.md 手順 3）
# 移ったかは、文字列ではなく同じディレクトリか（-ef）で比べる（Git Bash では yazi が C:\… の形で書き、
# $PWD の /c/… と文字列では一致しないので、動かずに閉じても cd し直して cd - の戻り先が変わる）
if command -v yazi >/dev/null 2>&1; then
	function y() {
		local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
		command yazi "$@" --cwd-file="$tmp"
		IFS= read -r -d '' cwd < "$tmp"
		! [ "$cwd" -ef "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
		command rm -f -- "$tmp"
	}
fi

# Homebrew で入れたコマンドの補完（docs/bash-settings.md 手順 4）
# Homebrew は補完を etc/bash_completion.d に置き、bash-completion の遅延読み込み（XDG_DATA_DIRS の下）では見つからない。
# fzf より前に読む（fzf は bat などの既にある補完を包んで ** の補完を足す。後ろだと元に戻ってしまう）
if [ -d "${HOMEBREW_PREFIX-}/etc/bash_completion.d" ]; then
	for __f in "${HOMEBREW_PREFIX}"/etc/bash_completion.d/*; do
		# shellcheck source=/dev/null
		if [ -r "$__f" ]; then . "$__f"; fi
	done
	unset __f
fi

# fzf のキー操作（Ctrl+R・Ctrl+T・Alt+C）と ** の補完（docs/fzf.md 手順 3）
# PROMPT_COMMAND・PS0・PS1 には触らないので、下のプロンプトのフックの並びには入らない。読み直しても二重にならない
if command -v fzf >/dev/null 2>&1; then
	eval "$(fzf --bash)"
	# 候補を fd に、Ctrl+T のプレビューを bat にする（docs/fzf.md「fd と bat を候補とプレビューに使う」）
	if command -v fd >/dev/null 2>&1; then
		export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
		export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
		export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
	fi
	if command -v bat >/dev/null 2>&1; then
		export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
	fi
fi

# --- プロンプトのフック（PROMPT_COMMAND を触るので、この順に読む。理由は README） ---

# starship（docs/starship.md 手順 4・5）
# 読み直したときは初期化し直さない（starship は初期化のたびに PS0 に自分を足す）
if command -v starship >/dev/null 2>&1 && ! declare -F starship_precmd >/dev/null; then
	eval "$(starship init bash)"
fi

# WezTerm のシェル統合（wezterm の docs/install.md 手順 6）
if [ -r "${WEZTERM_SHELL_INTEGRATION:=$HOME/.config/wezterm/shell/wezterm.sh}" ]; then
	# shellcheck source=/dev/null
	. "$WEZTERM_SHELL_INTEGRATION"
fi

# zoxide（docs/zoxide.md 手順 3）
# 読み直したときは初期化し直さない（AlmaLinux の /etc/bashrc は PROMPT_COMMAND を配列にし、
# zoxide は配列の先頭しか見ないので、初期化のたびにフックを重ねて足す）
# ~/.bashrc の読み込みの行より後ろで別の形（--cmd cd など）の zoxide を読むなら、--hook none を付ける
# （付けないとフックが 2 つになる。docs/install.md 手順 6）
if command -v zoxide >/dev/null 2>&1 && ! declare -F __zoxide_hook >/dev/null; then
	eval "$(zoxide init bash)"
fi

# 読み込んだ印（docs/install.md の手順 10 で確かめる用。非対話のシェルでは上で抜けるので付かない）
__bash_config_loaded=1
