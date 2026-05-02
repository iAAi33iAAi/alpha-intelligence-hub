#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Alpha Intelligence Hub - Master Migration & Setup Script
# Consolidates all repos into one unified monorepo
# Author: John David Taylor Preston - Founder-Architect
# =============================================================================

echo "=== Alpha Intelligence Hub - Init ==="
echo "Consolidating all repos into master platform..."
echo ""

# --- Step 1: Create directory structure ---
echo "[1/7] Creating monorepo directory structure..."
mkdir -p ai/openclaw ai/alexarac ai/skills/quibidt-skill ai/skills/tribe-skill ai/skills/safety-skill
mkdir -p blockchain/world-tribe
mkdir -p core/undermoon/aethel-grid core/safety-kernel
mkdir -p platform/config platform/src platform/dashboard platform/frontend platform/infra platform/ops platform/scripts
mkdir -p experiments/notebooks
mkdir -p data docs tests humans invariants
mkdir -p .github/workflows
echo "  Done."

# --- Step 2: Merge project-mono (base platform) ---
echo "[2/7] Merging project-mono (base platform)..."
git remote add mono https://github.com/iAAi33iAAi/project-mono.git
git fetch mono
git merge mono/main --allow-unrelated-histories --no-edit -m "merge: project-mono as platform base"
# Relocate project-mono contents into platform/
for dir in config dashboard frontend src scripts ops infra; do
  [ -d "$dir" ] && git mv "$dir" "platform/" 2>/dev/null || true
done
echo "  Done."

# --- Step 3: Merge safety-kernel ---
echo "[3/7] Merging safety-kernel..."
git remote add sk https://github.com/iAAi33iAAi/safety-kernel.git
git fetch sk
git merge sk/main --allow-unrelated-histories --no-edit -m "merge: safety-kernel into core/"
[ -d "sk" ] && git mv sk/* core/safety-kernel/ 2>/dev/null || true
[ -f "test_sk.py" ] && git mv test_sk.py core/safety-kernel/ 2>/dev/null || true
[ -f "test_tamper.py" ] && git mv test_tamper.py core/safety-kernel/ 2>/dev/null || true
[ -f "hello.py" ] && git mv hello.py core/safety-kernel/ 2>/dev/null || true
echo "  Done."

# --- Step 4: Merge undermoon ---
echo "[4/7] Merging undermoon (coordination substrate)..."
git remote add um https://github.com/iAAi33iAAi/undermoon.git
git fetch um
git merge um/main --allow-unrelated-histories --no-edit -m "merge: undermoon into core/"
[ -d "aethel-grid" ] && git mv aethel-grid core/undermoon/ 2>/dev/null || true
[ -d "docs" ] && git mv docs core/undermoon/docs 2>/dev/null || true
for f in BEACON.md CALL.md EXPLAINER.md ORIGIN.md ROLLOUT.md STEWARDSHIP.md Cargo.toml; do
  [ -f "$f" ] && git mv "$f" core/undermoon/ 2>/dev/null || true
done
echo "  Done."

# --- Step 5: Merge World-Tribe-Protocol ---
echo "[5/7] Merging World-Tribe-Protocol (on-chain layer)..."
git remote add wtp https://github.com/iAAi33iAAi/World-Tribe-Protocol..git
git fetch wtp
git merge wtp/main --allow-unrelated-histories --no-edit -m "merge: World-Tribe-Protocol into blockchain/"
[ -f "WorldTribe.sol" ] && git mv WorldTribe.sol blockchain/world-tribe/ 2>/dev/null || true
[ -f "index.html" ] && git mv index.html blockchain/world-tribe/ 2>/dev/null || true
for dir in build config scripts; do
  [ -d "$dir" ] && git mv "$dir" blockchain/world-tribe/ 2>/dev/null || true
done
echo "  Done."

# --- Step 6: Merge ALEXARAC + CORE_CODEX ---
echo "[6/7] Merging ALEXARAC + CORE_CODEX..."
git remote add alex https://github.com/iAAi33iAAi/ALEXARAC.git
git fetch alex
git merge alex/main --allow-unrelated-histories --no-edit -m "merge: ALEXARAC into ai/"
[ -f "BOM_MAP.md" ] && git mv BOM_MAP.md ai/alexarac/ 2>/dev/null || true

git remote add codex https://github.com/iAAi33iAAi/CORE_CODEX.md.git
git fetch codex
git merge codex/main --allow-unrelated-histories --no-edit -m "merge: CORE_CODEX as root CODEX.md"
# Rename to avoid collision with main README
[ -f "CORE_CODEX.md" ] && git mv CORE_CODEX.md CODEX.md 2>/dev/null || true
echo "  Done."

# --- Step 7: Add OpenClaw as submodule + cleanup ---
echo "[7/7] Adding OpenClaw submodule + cleaning up remotes..."
git submodule add https://github.com/iAAi33iAAi/openclaw.git ai/openclaw

# Cleanup: remove all temporary remotes
git remote remove sk
git remote remove um
git remote remove wtp
git remote remove alex
git remote remove codex
git remote remove mono

# Initialize submodules
git submodule update --init --recursive

echo ""
echo "=== Migration Complete ==="
echo "Alpha Intelligence Hub is ready."
echo ""
echo "Structure:"
echo "  ai/          - OpenClaw Gateway + ALEXARAC + Custom Skills"
echo "  blockchain/  - World-Tribe Protocol (Solidity)"
echo "  core/        - Undermoon + Safety Kernel + Aethel Grid"
echo "  platform/    - Quibidt Treasury + Dashboard + Frontend"
echo ""
echo "Next steps:"
echo "  git add -A && git commit -m 'feat: consolidated monorepo structure'"
echo "  git push origin main"
echo "  docker-compose up --build"
