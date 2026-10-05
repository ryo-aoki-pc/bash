"""実際のホームを変更せず、導入・移行と再実行を検証する。"""

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
        self.install()
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

    def test_migrates_every_known_line_and_function(self):
        old = (self.repo / "migrate/old-lines.txt").read_text()
        old += (self.repo / "migrate/old-y.txt").read_text()
        original = "# OS の設定\nexport HOST_ONLY=kept\n" + old
        self.rc.write_text(original)
        self.install()
        self.assertEqual(self.backup.read_text(), original)
        self.assertEqual(self.backup.stat().st_mode & 0o777, 0o600)
        self.assertIn("export HOST_ONLY=kept\n", self.rc.read_text())
        self.assertIn(SOURCE, self.rc.read_text())
        for line in (self.repo / "migrate/old-lines.txt").read_text().splitlines():
            self.assertNotIn(line, self.rc.read_text().splitlines())
        self.assertNotIn("function y()", self.rc.read_text())
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

    def test_invalid_migration_leaves_original_untouched(self):
        original = 'if true; then\nexport EDITOR=nvim\nfi\n'
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
