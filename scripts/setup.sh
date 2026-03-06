#!/usr/bin/env bash
# ============================================================
# Setup — Script d'initialisation complet du projet
#
# Ce script:
#   1. Configure les branches Git
#   2. Installe les dépendances
#   3. Configure les labels GitHub
#   4. Configure la protection des branches
#   5. Vérifie les secrets requis
#
# Usage: bash scripts/setup.sh
# Prérequis: GitHub CLI (gh) installé et authentifié
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error()   { echo -e "${RED}❌ $1${NC}"; }

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   🚀 Setup — Template Agile-Scrum Dev        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ─── Check Prerequisites ──────────────────────────────────────────────────────
log_info "Vérification des prérequis..."

check_command() {
  if command -v "$1" &>/dev/null; then
    log_success "$1 trouvé: $(command -v "$1")"
  else
    log_error "$1 non trouvé. Installez-le avant de continuer."
    echo "  → $2"
    exit 1
  fi
}

check_command "git"  "https://git-scm.com/"
check_command "node" "https://nodejs.org/"
check_command "npm"  "https://npmjs.com/"

if ! command -v gh &>/dev/null; then
  log_warning "GitHub CLI (gh) non trouvé — certaines étapes seront ignorées"
  log_warning "Pour installer: https://cli.github.com/"
  GH_AVAILABLE=false
else
  log_success "GitHub CLI trouvé: $(gh --version | head -1)"
  GH_AVAILABLE=true
fi

echo ""

# ─── Git Configuration ────────────────────────────────────────────────────────
log_info "Configuration Git..."

# Create develop branch if it doesn't exist
cd "$REPO_ROOT"
if git show-ref --quiet "refs/heads/develop"; then
  log_success "Branch 'develop' existe déjà"
else
  git checkout -b develop
  git push origin develop 2>/dev/null || log_warning "Impossible de pousser 'develop' — faites-le manuellement"
  log_success "Branch 'develop' créée"
fi

# Return to main/default branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
git checkout "$DEFAULT_BRANCH" 2>/dev/null || true

echo ""

# ─── Install Dependencies ─────────────────────────────────────────────────────
if [ -f "$REPO_ROOT/package.json" ]; then
  log_info "Installation des dépendances npm..."
  cd "$REPO_ROOT"
  npm install
  log_success "Dépendances installées"
  echo ""
fi

# ─── GitHub Labels ────────────────────────────────────────────────────────────
if [ "$GH_AVAILABLE" = true ]; then
  log_info "Configuration des labels GitHub..."
  bash "$SCRIPT_DIR/setup-labels.sh"
  echo ""
else
  log_warning "GitHub CLI non disponible — labels non configurés"
  log_warning "Exécutez manuellement: bash scripts/setup-labels.sh"
  echo ""
fi

# ─── Branch Protection ────────────────────────────────────────────────────────
if [ "$GH_AVAILABLE" = true ]; then
  log_info "Configuration de la protection des branches..."
  bash "$SCRIPT_DIR/setup-branch-protection.sh" || log_warning "Protection des branches: droits admin requis"
  echo ""
else
  log_warning "Protection des branches non configurée automatiquement"
  log_warning "Consultez docs/BRANCHING_STRATEGY.md pour la configuration manuelle"
  echo ""
fi

# ─── Check Secrets Reminder ──────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   📋 Secrets GitHub à configurer                             ║"
echo "║                                                              ║"
echo "║   Settings → Secrets and variables → Actions                 ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║   ASANA_ACCESS_TOKEN    → Token Asana (app.asana.com/my-apps)║"
echo "║   ASANA_PROJECT_GID     → ID du projet Asana (dans l'URL)    ║"
echo "║   NPM_TOKEN (optionnel) → Pour publier sur npm               ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   ✨ Setup terminé !                                 ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║                                                      ║"
echo "║   📚 Documentation:                                  ║"
echo "║      docs/AGILE_PROCESS.md      — Processus Scrum    ║"
echo "║      docs/BRANCHING_STRATEGY.md — Stratégie branches ║"
echo "║      docs/RELEASE_PROCESS.md    — Processus release  ║"
echo "║      docs/CONTRIBUTING.md       — Guide contribution  ║"
echo "║                                                      ║"
echo "║   🤖 Agents BMAD (.github/prompts/):                 ║"
echo "║      product-manager.md  — PM / Scrum Master         ║"
echo "║      architect.md        — Architecte                ║"
echo "║      developer.md        — Développeur               ║"
echo "║      security-reviewer.md — Security Reviewer        ║"
echo "║                                                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
