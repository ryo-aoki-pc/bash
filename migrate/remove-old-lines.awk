# 元の手順書が ~/.bashrc に書いた行を消す（docs/install.md 手順 3）
#
#   awk -f remove-old-lines.awk old-lines.txt old-y.txt <~/.bashrc の控え> > ~/.bashrc
#
# - old-lines.txt の行と、行全体が同じ行を消す（空行は数えない）
# - old-y.txt の行の並び（以前の setup-notes の yazi.md の y 関数）と、続く行がすべて同じときだけ、その並びを消す
#   （範囲の sed だと、閉じ括弧が無いときに最後の行まで消してしまうため）
#   old-y.txt は空行で区切って、いくつかの形を置ける（どれか 1 つと同じなら消す）
# 少しでも違う行（手で直した行・別の --cmd や EZA_OPTS の行）は消さずに残す

FILENAME == ARGV[1] { if ($0 != "") drop[$0] = 1; next }
FILENAME == ARGV[2] {
	if ($0 == "") { cur = 0; next }
	if (!cur) cur = ++ny
	y[cur, ++len[cur]] = $0
	next
}
{ line[++n] = $0 }

END {
	for (i = 1; i <= n; i++) {
		hit = 0
		for (k = 1; k <= ny && !hit; k++) {
			if (i + len[k] - 1 > n) continue
			same = 1
			for (j = 1; j <= len[k]; j++) {
				if (line[i + j - 1] != y[k, j]) { same = 0; break }
			}
			if (same) hit = len[k]
		}
		if (hit) { i += hit - 1; continue }
		if (line[i] in drop) continue
		print line[i]
	}
}
