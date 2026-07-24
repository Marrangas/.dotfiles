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

    def test_config_yml_syntax(self):
        """
        Verify that config.yml exists and can be parsed correctly as a valid YAML document.
        """
        config_path = os.path.join(DOTFILES_ROOT, "config.yml")
        self.assertTrue(os.path.exists(config_path), f"config.yml not found at {config_path}")
        
        with open(config_path, "r") as f:
            try:
                data = yaml.safe_load(f)
            except yaml.YAMLError as exc:
                self.fail(f"config.yml failed to parse as valid YAML: {exc}")
                
        self.assertIsNotNone(data, "config.yml parsed as empty or None")
        self.assertIn("profile", data, "config.yml is missing 'profile' key")
        self.assertIn("packages", data, "config.yml is missing 'packages' key")

    def test_stow_ignore_contains_tests(self):
        """
        Verify that .stow-local-ignore is correctly configured to ignore the tests directory.
        """
        ignore_path = os.path.join(DOTFILES_ROOT, ".stow-local-ignore")
        self.assertTrue(os.path.exists(ignore_path), f".stow-local-ignore not found at {ignore_path}")
        
        with open(ignore_path, "r") as f:
            content = f.read()
            
        self.assertIn("(^|/)tests/.*", content, "tests/ directory is not ignored in .stow-local-ignore")


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
                f"stow link command failed with code {result_stow.returncode}.\nSTDOUT: {result_stow.stdout}\nSTDERR: {result_stow.stderr}"
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
                f"Path {expected_link} does not contain any symlinks (Stow failed to link)"
            )
            
            # Resolve the symlink target and verify it matches the absolute path of the source file
            resolved_path = os.path.realpath(expected_link)
            expected_target = os.path.join(DOTFILES_ROOT, "bat", ".config", "bat", "config")
            self.assertEqual(
                resolved_path,
                expected_target,
                f"Resolved path {resolved_path} does not match expected source {expected_target}"
            )
            
            # 3. Run GNU Stow to unstow (unlink) the 'bat' package
            unstow_cmd = ["stow", "-D", "-t", temp_home, "--dotfiles", "-v", "bat"]
            result_unstow = subprocess.run(
                unstow_cmd,
                cwd=DOTFILES_ROOT,
                capture_output=True,
                text=True
            )
            
            self.assertEqual(
                result_unstow.returncode, 0,
                f"stow unlink command failed with code {result_unstow.returncode}.\nSTDOUT: {result_unstow.stdout}\nSTDERR: {result_unstow.stderr}"
            )
            
            # 4. Verify that the symlink is gone
            self.assertFalse(
                os.path.exists(expected_link),
                f"Symlink {expected_link} still exists after unstow"
            )


if __name__ == "__main__":
    unittest.main()
