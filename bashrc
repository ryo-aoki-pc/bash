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
if [ -z "${DOCKER_HOST-}" ] && [ -S "${XDG_RUNTIME_DIR-}/podman/podman.sock" ]; then
	export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
fi

# --- 対話の bash だけ ---------------------------------------------------------
case $- in
*i*) ;;
*) return 0 ;;
esac

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
if command -v yazi >/dev/null 2>&1; then
	function y() {
		local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
		command yazi "$@" --cwd-file="$tmp"
		IFS= read -r -d '' cwd < "$tmp"
		[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
		command rm -f -- "$tmp"
	}
fi

# --- プロンプトのフック（PROMPT_COMMAND を触るので、この順に読む。理由は README） ---

# starship（docs/starship.md 手順 3）
# 読み直したときは初期化し直さない（starship は初期化のたびに PS0 に自分を足す）
if command -v starship >/dev/null 2>&1 && ! declare -F starship_precmd >/dev/null; then
	eval "$(starship init bash)"
fi

# WezTerm のシェル統合（wezterm の docs/install.md 手順 6）
if [ -r "${WEZTERM_SHELL_INTEGRATION:=$HOME/.config/wezterm/shell/wezterm.sh}" ]; then
	# shellcheck source=/dev/null
	. "$WEZTERM_SHELL_INTEGRATION"
fi

# zoxide（docs/zoxide.md 手順 6）
# 読み直したときは初期化し直さない（AlmaLinux の /etc/bashrc は PROMPT_COMMAND を配列にし、
# zoxide は配列の先頭しか見ないので、初期化のたびにフックを重ねて足す）
# ~/.bashrc の読み込みの行より後ろで別の形（--cmd cd など）の zoxide を読むなら、--hook none を付ける
# （付けないとフックが 2 つになる。docs/install.md 手順 6）
if command -v zoxide >/dev/null 2>&1 && ! declare -F __zoxide_hook >/dev/null; then
	eval "$(zoxide init bash)"
fi

# 読み込んだ印（docs/install.md の手順 10 で確かめる用。非対話のシェルでは上で抜けるので付かない）
__bash_config_loaded=1
