#!/usr/bin/env bash
# ============================================================
# Setup Labels — Crée tous les labels GitHub nécessaires
# Usage: bash scripts/setup-labels.sh
#
# Prérequis: GitHub CLI (gh) installé et authentifié
#   brew install gh && gh auth login
# ============================================================

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo '')}"

if [ -z "$REPO" ]; then
  echo "❌ Impossible de détecter le repo. Passez-le en argument: bash setup-labels.sh owner/repo"
  exit 1
fi

echo "🏷️  Configuration des labels pour: $REPO"
echo ""

# Fonction helper pour créer/mettre à jour un label
create_label() {
  local name="$1"
  local color="$2"
  local description="$3"

  if gh label create "$name" \
    --repo "$REPO" \
    --color "$color" \
    --description "$description" \
    --force 2>/dev/null; then
    echo "  ✅ $name"
  else
    echo "  ⚠️  $name (erreur, label peut-être déjà existant)"
  fi
}

# ─── Status Labels ─────────────────────────────────────────────────────────────
echo "📊 Status labels..."
create_label "backlog"     "BFD4F2" "Dans le backlog, pas encore planifié"
create_label "in-progress" "0075CA" "En cours de développement"
create_label "in-review"   "FBCA04" "PR ouverte, en attente de review"
create_label "blocked"     "D93F0B" "Bloqué par une dépendance ou un obstacle"
create_label "done"        "0E8A16" "Complété et mergé"
create_label "stale"       "EDEDED" "Inactif depuis trop longtemps"
create_label "keep-open"   "1D76DB" "Ne pas fermer automatiquement"

# ─── Type Labels ───────────────────────────────────────────────────────────────
echo ""
echo "📁 Type labels..."
create_label "epic"        "6E3596" "Epic regroupant plusieurs User Stories"
create_label "user-story"  "84B6EB" "User Story fonctionnelle"
create_label "bug"         "D93F0B" "Comportement incorrect ou inattendu"
create_label "feature"     "84B6EB" "Nouvelle fonctionnalité"
create_label "task"        "E4E669" "Tâche technique"
create_label "chore"       "EDEDED" "Maintenance, dépendances, configuration"
create_label "documentation" "0075CA" "Mise à jour de documentation"
create_label "tests"       "E4E669" "Ajout ou modification de tests"
create_label "refactor"    "C2E0C6" "Refactoring du code"
create_label "performance" "FEF2C0" "Amélioration des performances"
create_label "security"    "B60205" "Correction de sécurité"
create_label "ci/cd"       "0052CC" "Changements CI/CD"
create_label "build"       "BFDADC" "Changements système de build"
create_label "release"     "5319E7" "Lié à une release"

# ─── Priority Labels ───────────────────────────────────────────────────────────
echo ""
echo "⚡ Priority labels..."
create_label "priority:critical" "B60205" "Critique - bloque la production"
create_label "priority:high"     "E4E669" "Priorité haute"
create_label "priority:medium"   "FEF2C0" "Priorité moyenne"
create_label "priority:low"      "C2E0C6" "Priorité faible - pas urgent"

# ─── Component Labels ──────────────────────────────────────────────────────────
echo ""
echo "🧩 Component labels..."
create_label "frontend"      "1D76DB" "Interface utilisateur / client"
create_label "backend"       "0E8A16" "API / logique serveur"
create_label "database"      "5319E7" "Base de données / migrations"
create_label "infrastructure" "006B75" "DevOps / infrastructure / cloud"
create_label "api"           "84B6EB" "API interne ou externe"
create_label "auth"          "D4C5F9" "Authentification / autorisation"

# ─── Asana Sync ────────────────────────────────────────────────────────────────
echo ""
echo "🔄 Asana sync labels..."
create_label "asana-sync"  "C5DEF5" "Synchronisé automatiquement depuis Asana"

# ─── Meta Labels ────────────────────────────────────────────────────────────────
echo ""
echo "🏷️  Meta labels..."
create_label "triage"          "E11D48" "Nécessite une analyse / classification"
create_label "duplicate"       "EDEDED" "Issue déjà signalée"
create_label "wontfix"         "EDEDED" "Ne sera pas corrigé"
create_label "good first issue" "7057FF" "Bonne issue pour les nouveaux contributeurs"
create_label "help wanted"     "008672" "Aide externe bienvenue"
create_label "retrospective"   "D93F0B" "Action de rétrospective"

echo ""
echo "✨ Labels configurés avec succès !"
echo ""
echo "💡 Pour visualiser les labels: https://github.com/$REPO/labels"
