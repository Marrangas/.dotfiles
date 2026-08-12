#!/usr/bin/env python3
import os
import subprocess
import tempfile
import unittest
import yaml

DOTFILES_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


class DotfilesUnitTests(unittest.TestCase):
    """
    Unit tests validating the syntax and structure of configuration files
    within the dotfiles repository.
    """

    def test_bootstrap_sh_syntax(self):
        """
        Verify that build.sh exists, is syntactically valid bash, and exposes configuration data.
        """
        bootstrap_path = os.path.join(DOTFILES_ROOT, ".", "build.sh")
        self.assertTrue(os.path.exists(bootstrap_path),
                        f"build.sh not found at {bootstrap_path}")

        # 1. Run bash syntax check
        result = subprocess.run(
            ["bash", "-n", bootstrap_path],
            capture_output=True,
            text=True
        )
        self.assertEqual(
            result.returncode, 0,
            f"build.sh has bash syntax errors:\n{result.stderr}"
        )

        # 2. Source the file and output key variables to ensure they are defined
        source_cmd = [
            "bash", "-c",
            f"source {
                bootstrap_path} && declare -p DOTFILE_PACKAGES DOTFILE_LAYERED"
        ]
        result_vars = subprocess.run(
            source_cmd,
            capture_output=True,
            text=True
        )
        self.assertEqual(
            result_vars.returncode, 0,
            f"build.sh is missing expected arrays DOTFILE_PACKAGES or DOTFILE_LAYERED when sourced.\nSTDERR: {
                result_vars.stderr}"
        )

    def test_stow_ignore_contains_tests(self):
        """
        Verify that .stow-local-ignore is correctly configured to ignore the tests directory.
        """
        ignore_path = os.path.join(DOTFILES_ROOT, ".stow-local-ignore")
        self.assertTrue(os.path.exists(ignore_path),
                        f".stow-local-ignore not found at {ignore_path}")

        with open(ignore_path, "r") as f:
            content = f.read()

        self.assertIn("(^|/)tests/.*", content,
                      "tests/ directory is not ignored in .stow-local-ignore")

    def test_verify_config_sh(self):
        """
        Verify that verify_config.sh passes, indicating that all files
        and packages in the repo are fully documented and accounted for.
        """
        verify_path = os.path.join(DOTFILES_ROOT, "verify_config.sh")
        self.assertTrue(os.path.exists(verify_path), f"verify_config.sh not found at {verify_path}")
        
        result = subprocess.run(
            [verify_path],
            cwd=DOTFILES_ROOT,
            capture_output=True,
            text=True
        )
        self.assertEqual(
            result.returncode, 0,
            f"verify_config.sh failed:\nSTDOUT: {result.stdout}\nSTDERR: {result.stderr}"
        )


class DotfilesIntegrationTests(unittest.TestCase):
    """
    Integration tests invoking Stow directly in an isolated temporary directory
    to verify linking and unlinking behaviors.
    """

    def test_stow_and_unstow_bat(self):
        """
        Simulate standard deployment and cleanup of the 'bat' package inside a temporary home directory.
        """
        # Create an isolated temporary directory simulating a user's $HOME
        with tempfile.TemporaryDirectory() as temp_home:
            # 1. Run GNU Stow to link the 'bat' package
            stow_cmd = ["stow", "-t", temp_home, "--dotfiles", "-v", "bat"]
            result_stow = subprocess.run(
                stow_cmd,
                cwd=DOTFILES_ROOT,
                capture_output=True,
                text=True
            )

            self.assertEqual(
                result_stow.returncode, 0,
                f"stow link command failed with code {result_stow.returncode}.\nSTDOUT: {
                    result_stow.stdout}\nSTDERR: {result_stow.stderr}"
            )

            # 2. Verify that the path exists and is linked to the repository
            # Because of Stow's directory folding, the symlink may be created at a parent level
            # (e.g., .config/ or .config/bat/) rather than the leaf file itself.
            # We assert that the path exists, and that resolving it leads back to the source repository.
            expected_link = os.path.join(temp_home, ".config", "bat", "config")
            self.assertTrue(
                os.path.exists(expected_link),
                f"Expected path {expected_link} does not exist"
            )

            # Verify that at least one component of the path is a symbolic link by checking
            # that realpath (resolved) differs from the absolute path.
            self.assertNotEqual(
                os.path.abspath(expected_link),
                os.path.realpath(expected_link),
                f"Path {
                    expected_link} does not contain any symlinks (Stow failed to link)"
            )

            # Resolve the symlink target and verify it matches the absolute path of the source file
            resolved_path = os.path.realpath(expected_link)
            expected_target = os.path.join(
                DOTFILES_ROOT, "bat", ".config", "bat", "config")
            self.assertEqual(
                resolved_path,
                expected_target,
                f"Resolved path {resolved_path} does not match expected source {
                    expected_target}"
            )

            # 3. Run GNU Stow to unstow (unlink) the 'bat' package
            unstow_cmd = ["stow", "-D", "-t",
                          temp_home, "--dotfiles", "-v", "bat"]
            result_unstow = subprocess.run(
                unstow_cmd,
                cwd=DOTFILES_ROOT,
                capture_output=True,
                text=True
            )

            self.assertEqual(
                result_unstow.returncode, 0,
                f"stow unlink command failed with code {result_unstow.returncode}.\nSTDOUT: {
                    result_unstow.stdout}\nSTDERR: {result_unstow.stderr}"
            )

            # 4. Verify that the symlink is gone
            self.assertFalse(
                os.path.exists(expected_link),
                f"Symlink {expected_link} still exists after unstow"
            )


class DotfilesProfileTests(unittest.TestCase):
    """
    Integration tests verifying environment profile generation (.env files)
    via build.sh.
    """

    def setUp(self):
        self.env_file = os.path.join(DOTFILES_ROOT, ".env")
        self.envrc_file = os.path.join(DOTFILES_ROOT, ".envrc")
        self.test_profile = os.path.join(DOTFILES_ROOT, ".testprofile.env")

        # Backup existing .env and .envrc if they exist
        self.env_backup = None
        if os.path.lexists(self.env_file):
            try:
                # If .env is a symlink, resolve and backup target
                if os.path.islink(self.env_file):
                    self.env_link_target = os.readlink(self.env_file)
                else:
                    self.env_link_target = None
                    with open(self.env_file, "rb") as f:
                        self.env_backup = f.read()
                os.remove(self.env_file)
            except Exception:
                pass

        self.envrc_backup = None
        if os.path.lexists(self.envrc_file):
            try:
                with open(self.envrc_file, "rb") as f:
                    self.envrc_backup = f.read()
                os.remove(self.envrc_file)
            except Exception:
                pass

    def tearDown(self):
        # Remove any generated test profile
        if os.path.lexists(self.test_profile):
            try:
                os.remove(self.test_profile)
            except Exception:
                pass
        if os.path.lexists(self.env_file):
            try:
                os.remove(self.env_file)
            except Exception:
                pass
        if os.path.lexists(self.envrc_file):
            try:
                os.remove(self.envrc_file)
            except Exception:
                pass

        # Restore backups
        if self.env_backup is not None:
            try:
                with open(self.env_file, "wb") as f:
                    f.write(self.env_backup)
            except Exception:
                pass
        elif hasattr(self, 'env_link_target') and self.env_link_target is not None:
            try:
                if os.path.lexists(self.env_file):
                    os.remove(self.env_file)
                os.symlink(self.env_link_target, self.env_file)
            except Exception:
                pass

        if self.envrc_backup is not None:
            try:
                with open(self.envrc_file, "wb") as f:
                    f.write(self.envrc_backup)
            except Exception:
                pass

    def test_profile_generation_minimal_layer(self):
        """
        Run bootstrap.sh for MINIMAL layer and verify generated package arrays.
        """
        # Execute build.sh
        env = os.environ.copy()
        env["ENV"] = "testprofile"
        env["LAYER"] = "MINIMAL"

        result = subprocess.run(
            ["./build.sh"],
            cwd=DOTFILES_ROOT,
            env=env,
            capture_output=True,
            text=True
        )
        self.assertEqual(
            result.returncode, 0,
            f"build.sh failed during test. STDOUT: {result.stdout}\nSTDERR: {result.stderr}"
        )

        # Verify .testprofile.env exists
        self.assertTrue(
            os.path.exists(self.test_profile),
            f"Expected profile file {self.test_profile} was not created."
        )

        # Read and check contents of the generated profile
        with open(self.test_profile, "r") as f:
            content = f.read()

        # 1. Verify general variables
        self.assertIn('WORKSPACE_NAME="testprofile"', content)
        self.assertIn('DOTFILE_LAYER="MINIMAL"', content)

        # 2. Verify DEPLOY_FILES is generated and contains standard package files
        self.assertIn('DEPLOY_FILES=(', content)
        self.assertIn('"bat/.config/bat/config"', content)

        # 3. Verify ONLY minimal files are present in DEPLOY_FILES for MINIMAL layer
        self.assertIn('"nvim/.config/nvim/init.lua"', content)
        self.assertNotIn(
            '"nvim/.config/nvim/lua/plugins/treesitter.lua"', content)

    def test_profile_generation_all_layer(self):
        """
        Run bootstrap.sh for ALL layer and verify generated package arrays.
        """
        env = os.environ.copy()
        env["ENV"] = "testprofile"
        env["LAYER"] = "ALL"

        result = subprocess.run(
            ["./build.sh"],
            cwd=DOTFILES_ROOT,
            env=env,
            capture_output=True,
            text=True
        )
        self.assertEqual(
            result.returncode, 0,
            f"build.sh failed during test. STDOUT: {result.stdout}\nSTDERR: {result.stderr}"
        )

        with open(self.test_profile, "r") as f:
            content = f.read()

        self.assertIn('DOTFILE_LAYER="ALL"', content)

        # Verify DEPLOY_FILES has standard/specific files in ALL layer
        self.assertIn('"nvim/.config/nvim/init.lua"', content)
        self.assertIn(
            '"nvim/.config/nvim/lua/plugins/treesitter.lua"', content)
        self.assertIn('"nvim/.config/nvim/lua/plugins/markdown.lua"', content)


if __name__ == "__main__":
    unittest.main()
