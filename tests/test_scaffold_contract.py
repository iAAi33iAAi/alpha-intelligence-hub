"""Contract tests for the Alpha Intelligence Hub integration scaffold.

These tests validate the repository's current deliverable (a migration script,
a target Compose topology, and truthful scaffold documentation). They do not
claim that target services have been assembled or are production-ready.
"""

from __future__ import annotations

import re
import unittest
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]


class AlphaScaffoldContractTests(unittest.TestCase):
    def test_compose_declares_the_expected_target_services(self) -> None:
        compose_path = ROOT / "docker-compose.yml"
        self.assertTrue(compose_path.is_file(), "target Compose topology is required")
        compose = yaml.safe_load(compose_path.read_text(encoding="utf-8"))
        self.assertIsInstance(compose, dict)
        services = compose.get("services")
        self.assertIsInstance(services, dict)

        expected = {
            "gateway": ("./ai/openclaw", "Dockerfile"),
            "treasury": ("./platform", "Dockerfile"),
            "world-tribe": ("./blockchain/world-tribe", "Dockerfile"),
            "safety-kernel": ("./core/safety-kernel", "Dockerfile"),
            "aethel-validator": ("./core/undermoon/aethel-grid", "Dockerfile"),
            "alexarac-ui": ("./ai/alexarac", "Dockerfile"),
            "dashboard": ("./platform/dashboard", "Dockerfile"),
        }
        self.assertEqual(set(services), set(expected))
        missing_contexts: list[str] = []
        for service_name, (expected_context, expected_dockerfile) in expected.items():
            with self.subTest(service=service_name):
                build = services[service_name].get("build")
                self.assertIsInstance(build, dict)
                self.assertEqual(build.get("context"), expected_context)
                self.assertEqual(build.get("dockerfile"), expected_dockerfile)

                context = (ROOT / expected_context).resolve()
                self.assertTrue(
                    context == ROOT or ROOT in context.parents,
                    f"{service_name} build context escapes repository",
                )
                if not context.is_dir():
                    missing_contexts.append(service_name)
                else:
                    self.assertTrue(
                        (context / expected_dockerfile).is_file(),
                        f"{service_name} has a context but its Dockerfile is missing",
                    )

        if missing_contexts:
            readme = (ROOT / "README.md").read_text(encoding="utf-8").lower()
            self.assertIn("scaffold", readme)
            self.assertIn("target integrations", readme)
            self.assertIn("not all present", readme)

    def test_migration_script_is_fail_fast_and_shell_valid(self) -> None:
        script = (ROOT / "init-hub.sh").read_text(encoding="utf-8")
        self.assertTrue(script.startswith("#!/usr/bin/env bash\n"))
        self.assertIn("set -euo pipefail", script)
        self.assertIn("Migration Complete", script)

    def test_every_declared_remote_has_a_well_formed_https_git_url(self) -> None:
        script = (ROOT / "init-hub.sh").read_text(encoding="utf-8")
        adds = re.findall(
            r"^git remote add ([A-Za-z0-9_-]+) (https://github\.com/\S+)$",
            script,
            re.MULTILINE,
        )
        self.assertGreaterEqual(len(adds), 6)
        names = [name for name, _ in adds]
        self.assertEqual(len(names), len(set(names)))
        for name, url in adds:
            with self.subTest(remote=name):
                self.assertRegex(
                    url,
                    r"^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git$",
                )
                self.assertNotIn("..git", url)

    def test_every_temporary_remote_is_removed_and_every_merge_uses_declared_remote(self) -> None:
        script = (ROOT / "init-hub.sh").read_text(encoding="utf-8")
        added = set(
            re.findall(
                r"^git remote add ([A-Za-z0-9_-]+) https://github\.com/\S+$",
                script,
                re.MULTILINE,
            )
        )
        removed = set(
            re.findall(
                r"^git remote remove ([A-Za-z0-9_-]+)$",
                script,
                re.MULTILINE,
            )
        )
        merged = set(
            re.findall(r"^git merge ([A-Za-z0-9_-]+)/", script, re.MULTILINE)
        )
        self.assertEqual(added, removed)
        self.assertTrue(merged)
        self.assertTrue(merged.issubset(added))


if __name__ == "__main__":
    unittest.main()
