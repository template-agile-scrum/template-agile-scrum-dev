#!/usr/bin/env bash
# ============================================================
# Setup Branch Protection — Configure les règles de protection
# des branches sur GitHub via l'API
#
# Usage: bash scripts/setup-branch-protection.sh
# Prérequis: GitHub CLI (gh) authentifié avec un token admin
# ============================================================

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo '')}"

if [ -z "$REPO" ]; then
  echo "❌ Impossible de détecter le repo. Passez-le en argument."
  exit 1
fi

echo "🔒 Configuration des protections de branches pour: $REPO"
echo ""

# ─── Protection de 'main' ────────────────────────────────────────────────────
echo "🌿 Configuration de 'main'..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/branches/main/protection" \
  --field required_status_checks='{"strict":true,"contexts":["lint","test (18)","test (20)","build","security"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"dismissal_restrictions":{},"dismiss_stale_reviews":true,"require_code_owner_reviews":true,"required_approving_review_count":2,"require_last_push_approval":true}' \
  --field restrictions=null \
  --field required_linear_history=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field block_creations=false \
  --field required_conversation_resolution=true \
  2>/dev/null && echo "  ✅ main protégée" || echo "  ⚠️  main: vérifier les permissions (nécessite droits admin)"

echo ""

# ─── Protection de 'develop' ─────────────────────────────────────────────────
echo "🌿 Configuration de 'develop'..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/branches/develop/protection" \
  --field required_status_checks='{"strict":true,"contexts":["lint","test (20)","build"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"dismiss_stale_reviews":false,"require_code_owner_reviews":false,"required_approving_review_count":1}' \
  --field restrictions=null \
  --field required_linear_history=false \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_conversation_resolution=true \
  2>/dev/null && echo "  ✅ develop protégée" || echo "  ⚠️  develop: vérifier les permissions ou créer la branche d'abord"

echo ""
echo "✨ Protection des branches configurée !"
echo ""
echo "💡 Pour vérifier: https://github.com/$REPO/settings/branches"
echo ""
echo "📋 Branches à créer si elles n'existent pas:"
echo "   git checkout -b develop && git push origin develop"
