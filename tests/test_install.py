"""実際のホームを変更せず、導入と再実行を検証する。"""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SOURCE = "if [ -r ~/.config/bash/bashrc ]; then . ~/.config/bash/bashrc; fi\n"


class InstallTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="bash-test-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "空白 home"
        self.repo = self.home / ".config/bash"
        shutil.copytree(ROOT, self.repo, ignore=shutil.ignore_patterns(".git", "__pycache__"))
        self.env = {**os.environ, "HOME": str(self.home), "BASH_ENV": "/dev/null"}
        self.env.pop("TERMUX_VERSION", None)
        self.rc = self.home / ".bashrc"
        self.backup = self.home / ".bashrc.before-bash"

    def install(self, success=True):
        result = subprocess.run(
            ["bash", str(self.repo / "install.sh")],
            env=self.env, text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def test_fresh_and_repeat(self):
        result = self.install()
        self.assertIn("~/.bash_profile: 作成済み", result.stdout.splitlines())
        self.assertEqual(self.rc.read_text(), SOURCE)
        self.assertEqual(self.backup.read_bytes(), b"")
        profile = self.home / ".bash_profile"
        self.assertIn(". ~/.bashrc", profile.read_text())
        before = {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in (self.rc, profile, self.backup)}
        self.install()
        self.assertEqual(before, {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in before})
        result = subprocess.run(
            ["bash", "--noprofile", "--rcfile", str(self.rc), "-ic",
             'printf "%s\\n" "$__bash_config_loaded:$HISTSIZE:$HISTFILESIZE:$HISTCONTROL"; '
             'shopt -q histappend autocd cdspell dirspell globstar'],
            env=self.env, text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "1:100000:100000:ignoreboth\n")
        result = subprocess.run(
            ["bash", "-uc", '. "$HOME/.bashrc"'],
            env=self.env, text=True, capture_output=True, check=False,
        )
        self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "", ""))

    def bashrc_path(self, search_path, termux_version=None, repeat=1):
        env = {**self.env, "PATH": search_path}
        if termux_version is not None:
            env["TERMUX_VERSION"] = termux_version
        bash = shutil.which("bash")
        self.assertIsNotNone(bash)
        # 読み込み自体が無出力かも確かめるため、PATH は一時ホームのファイルに受ける。
        result = subprocess.run(
            [bash, "-uc", '. "$HOME/.bashrc"; ' * repeat
             + 'printf "%s" "$PATH" > "$HOME/path-after-bashrc"'],
            env=env, text=True, capture_output=True, check=False,
        )
        self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "", ""))
        return (self.home / "path-after-bashrc").read_text()

    def test_empty_termux_version_creates_profile(self):
        self.env["TERMUX_VERSION"] = ""
        result = self.install()
        self.assertIn("~/.bash_profile: 作成済み", result.stdout.splitlines())
        self.assertIn(". ~/.bashrc", (self.home / ".bash_profile").read_text())

    def test_termux_skips_profile_and_repeat(self):
        self.env["TERMUX_VERSION"] = "0.118.3"
        message = (
            "~/.bash_profile: 作成しない（Termux の $PREFIX/etc/profile が"
            "ログインシェルで ~/.bashrc を読む）"
        )
        result = self.install()
        self.assertIn(message, result.stdout.splitlines())
        self.assertFalse((self.home / ".bash_profile").exists())
        self.assertEqual(self.rc.read_text(), SOURCE)
        self.assertEqual(self.backup.read_bytes(), b"")
        before = {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in (self.rc, self.backup)}
        result = self.install()
        self.assertIn(message, result.stdout.splitlines())
        self.assertEqual(before, {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in before})
        for name in (".bash_profile", ".bash_login", ".profile"):
            self.assertFalse((self.home / name).exists())

    def test_termux_preserves_existing_login_profiles(self):
        self.env["TERMUX_VERSION"] = "0.118.3"
        profiles = [self.home / name for name in (".bash_profile", ".bash_login", ".profile")]
        for profile in profiles:
            profile.write_text("# 既存のログイン設定\n")
        before = {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in profiles}
        self.install()
        self.assertEqual(before, {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in profiles})

    def test_termux_prepends_local_bin_without_duplicates(self):
        self.install()
        local_bin = self.home / ".local/bin"
        local_bin.mkdir(parents=True)
        # Homebrew がある環境でも比較できるよう、通常の読み込み後の PATH を基準にする。
        baseline = self.bashrc_path(os.defpath)
        self.assertEqual(
            self.bashrc_path(os.defpath, "0.118.3"), f"{local_bin}:{baseline}",
        )
        repeated = self.bashrc_path(os.defpath, "0.118.3", repeat=2)
        self.assertEqual(repeated.split(":").count(str(local_bin)), 1)

    def test_termux_keeps_local_bin_already_in_path(self):
        self.install()
        local_bin = self.home / ".local/bin"
        local_bin.mkdir(parents=True)
        for search_path in (
            f"{local_bin}:{os.defpath}",
            f"{os.defpath}:{local_bin}",
            f"{os.defpath}:{local_bin}:{os.defpath}",
        ):
            with self.subTest(search_path=search_path):
                baseline = self.bashrc_path(search_path)
                self.assertEqual(self.bashrc_path(search_path, "0.118.3"), baseline)
                self.assertEqual(baseline.split(":").count(str(local_bin)), 1)

    def test_termux_does_not_confuse_similar_paths_with_local_bin(self):
        self.install()
        local_bin = self.home / ".local/bin"
        local_bin.mkdir(parents=True)
        for similar in (f"{local_bin}-other", f"{local_bin}/tools"):
            with self.subTest(similar=similar):
                search_path = f"{similar}:{os.defpath}"
                baseline = self.bashrc_path(search_path)
                self.assertEqual(
                    self.bashrc_path(search_path, "0.118.3"), f"{local_bin}:{baseline}",
                )

    def test_termux_leaves_path_when_local_bin_is_missing(self):
        self.install()
        baseline = self.bashrc_path(os.defpath)
        self.assertEqual(self.bashrc_path(os.defpath, "0.118.3"), baseline)
        self.assertFalse((self.home / ".local/bin").exists())

    def test_non_termux_does_not_add_local_bin(self):
        self.install()
        local_bin = self.home / ".local/bin"
        local_bin.mkdir(parents=True)
        baseline = self.bashrc_path(os.defpath)
        self.assertNotIn(str(local_bin), baseline.split(":"))
        self.assertEqual(self.bashrc_path(os.defpath, ""), baseline)

    def test_preserves_existing_lines_and_functions(self):
        original = (
            "# OS の設定\nexport HOST_ONLY=kept\nexport EDITOR=nvim\n"
            "function y() {\n  printf '%s\\n' custom\n}\n"
        )
        self.rc.write_text(original)
        self.install()
        self.assertEqual(self.backup.read_text(), original)
        self.assertEqual(self.backup.stat().st_mode & 0o777, 0o600)
        self.assertEqual(self.rc.read_text(), original + SOURCE)
        self.install()

    def test_preserves_custom_settings_and_missing_newline(self):
        self.rc.write_text('alias ll="eza -l --icons"\nexport LOCAL_VALUE=kept')
        self.install()
        self.assertEqual(self.rc.read_text(), 'alias ll="eza -l --icons"\nexport LOCAL_VALUE=kept\n' + SOURCE)

    def test_existing_backup_blocks_changes(self):
        self.rc.write_text("# unchanged\n")
        self.backup.write_text("previous backup\n")
        self.install(success=False)
        self.assertEqual(self.rc.read_text(), "# unchanged\n")
        self.assertEqual(self.backup.read_text(), "previous backup\n")
        self.assertFalse((self.home / ".bash_profile").exists())

    def test_invalid_result_leaves_original_untouched(self):
        original = 'if true; then\nexport EDITOR=nvim\n'
        self.rc.write_text(original)
        self.install(success=False)
        self.assertEqual(self.rc.read_text(), original)
        self.assertFalse(self.backup.exists())
        self.assertFalse((self.home / ".bash_profile").exists())

    def test_preserves_symlink_permissions_and_existing_profile(self):
        target = self.home / "local-rc"
        target.write_text("# original\n")
        target.chmod(0o640)
        self.rc.symlink_to(target)
        profile = self.home / ".profile"
        profile.write_text("# keep this profile\n")
        self.install()
        self.assertTrue(self.rc.is_symlink())
        self.assertEqual(target.stat().st_mode & 0o777, 0o640)
        self.assertEqual(profile.read_text(), "# keep this profile\n")
        self.assertFalse((self.home / ".bash_profile").exists())
        self.assertEqual(self.backup.read_text(), "# original\n")

    def test_dangling_rc_symlink_is_not_overwritten(self):
        self.rc.symlink_to(self.home / "missing")
        self.install(success=False)
        self.assertTrue(self.rc.is_symlink())
        self.assertFalse(self.backup.exists())

    def test_wrong_clone_location_does_not_write_home(self):
        moved = self.home / "elsewhere"
        self.repo.rename(moved)
        result = subprocess.run(
            ["bash", str(moved / "install.sh")],
            env=self.env, text=True, capture_output=True, check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.rc.exists())


if __name__ == "__main__":
    unittest.main()
