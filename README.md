# Template Agile-Scrum Dev

Un template GitHub complet pour équipes de développement Agile-Scrum, inspiré de la [méthode BMAD](https://github.com/bmad-code-org/BMAD-METHOD). Synchronisation Asana → GitHub Issues, automatisation CI/CD, gestion des releases, agents IA pour chaque rôle.

---

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Démarrage rapide](#-démarrage-rapide)
- [Architecture du projet](#-architecture-du-projet)
- [GitHub Actions](#-github-actions)
- [Agents BMAD](#-agents-bmad)
- [Intégration Asana](#-intégration-asana)
- [Conventions](#-conventions)
- [Documentation](#-documentation)

---

## ✨ Fonctionnalités

| Fonctionnalité | Description |
|---------------|-------------|
| 🔄 **Asana Sync** | Synchronisation automatique Asana → GitHub Issues |
| 🌿 **Auto-Branch** | Création automatique de branches depuis les issues |
| ✅ **CI/CD** | Pipeline CI complet (lint, tests, build, sécurité) |
| 🚀 **Semantic Release** | Versioning automatique basé sur les commits |
| 📋 **Issue Templates** | Epic, User Story, Bug Report, Task technique |
| 🤖 **Agents BMAD** | Agents IA pour PM, Architect, Developer, Security |
| 🏃 **Sprint Automation** | Gestion automatique des milestones et labels |
| 🔒 **Branch Protection** | Scripts de configuration des règles de branches |
| 🧹 **Stale Automation** | Fermeture automatique des issues/PRs inactives |

---

## 🚀 Démarrage rapide

### 1. Utiliser ce template

Cliquez sur **"Use this template"** en haut de la page GitHub.

### 2. Setup initial

```bash
# Cloner votre nouveau repo
git clone https://github.com/<owner>/<nouveau-repo>.git
cd <nouveau-repo>

# Lancer le script de setup
bash scripts/setup.sh
```

Le script va :
- Créer la branche `develop`
- Configurer les labels GitHub
- Configurer la protection des branches
- Afficher les secrets à configurer

### 3. Configurer les secrets GitHub

Dans **Settings → Secrets and variables → Actions** :

| Secret | Description | Obligatoire |
|--------|-------------|-------------|
| `ASANA_ACCESS_TOKEN` | Token Asana ([créer ici](https://app.asana.com/0/my-apps)) | Pour Asana Sync |
| `ASANA_PROJECT_GID` | GID du projet Asana (dans l'URL du projet) | Pour Asana Sync |
| `NPM_TOKEN` | Token npm pour la publication | Si publié sur npm |

### 4. Configurer les outils IA

**VS Code + Copilot** :
- Les extensions recommandées s'installent automatiquement (`.vscode/extensions.json`)
- Copilot utilise les agents définis dans `.github/prompts/`

**Cursor** :
- Les règles sont dans `.cursor/rules/project-conventions.mdc`
- Cursor lit automatiquement ces règles dans vos sessions

### 5. Créer votre premier sprint

```bash
# Créer un milestone pour le Sprint 1
gh workflow run sprint-automation.yml \
  -f action=create-sprint-milestone \
  -f sprint_name="Sprint 1" \
  -f sprint_due_date="2024-02-02"
```

---

## 🏗️ Architecture du projet

```
.
├── .github/
│   ├── ISSUE_TEMPLATE/          # Templates pour les issues
│   │   ├── epic.yml             # Epic
│   │   ├── user-story.yml       # User Story (Agile)
│   │   ├── bug-report.yml       # Bug Report
│   │   ├── task.yml             # Tâche technique
│   │   └── config.yml           # Configuration du choix de template
│   ├── prompts/                 # Agents BMAD (IA)
│   │   ├── product-manager.md   # Agent PM / Scrum Master
│   │   ├── architect.md         # Agent Architecte
│   │   ├── developer.md         # Agent Développeur
│   │   └── security-reviewer.md # Agent Security
│   ├── scripts/
│   │   └── asana-sync.js        # Script de synchronisation Asana
│   ├── workflows/
│   │   ├── asana-sync.yml       # Sync Asana → GitHub Issues (daily)
│   │   ├── auto-branch.yml      # Création auto de branches (on assign)
│   │   ├── ci.yml               # CI: lint, tests, build, sécurité
│   │   ├── pr-checks.yml        # Validation des PRs
│   │   ├── release.yml          # Semantic Release automatique
│   │   ├── sprint-automation.yml # Gestion des sprints
│   │   └── stale.yml            # Nettoyage des issues/PRs inactives
│   ├── CODEOWNERS               # Propriétaires du code
│   ├── PULL_REQUEST_TEMPLATE.md # Template PR
│   └── SECURITY.md              # Politique de sécurité
├── .cursor/
│   └── rules/
│       └── project-conventions.mdc  # Règles pour Cursor AI
├── .vscode/
│   ├── extensions.json          # Extensions recommandées
│   ├── settings.json            # Configuration VS Code
│   └── tasks.json               # Tâches VS Code
├── docs/
│   ├── adr/                     # Architecture Decision Records
│   │   ├── ADR-001-semantic-release.md
│   │   └── ADR-002-asana-github-sync.md
│   ├── AGILE_PROCESS.md         # Processus Scrum complet
│   ├── BRANCHING_STRATEGY.md    # Stratégie de branches Git
│   ├── CONTRIBUTING.md          # Guide de contribution
│   └── RELEASE_PROCESS.md       # Processus de release
├── scripts/
│   ├── setup.sh                 # Script de setup initial
│   ├── setup-labels.sh          # Configuration des labels GitHub
│   └── setup-branch-protection.sh # Protection des branches
└── .releaserc.json              # Configuration Semantic Release
```

---

## 🤖 GitHub Actions

### 🔄 Asana → GitHub Issues Sync

Synchronise les tâches Asana vers GitHub Issues.

```yaml
# Déclenché quotidiennement (lun-ven 8h UTC) ou manuellement
gh workflow run asana-sync.yml
gh workflow run asana-sync.yml -f dry_run=true  # Preview sans créer
```

### 🌿 Auto-Branch

Crée automatiquement une branche quand une issue est assignée.

```yaml
# Déclenché automatiquement sur l'événement 'issues.assigned'
# Ou manuellement:
gh workflow run auto-branch.yml \
  -f issue_number=42 \
  -f branch_type=feature
```

### ✅ CI Pipeline

Lint, tests, build et audit de sécurité sur chaque push/PR.

### 🚀 Release

Semantic Release automatique sur `main`. Génère :
- Tag Git avec le numéro de version
- GitHub Release avec CHANGELOG
- Déploiement en production (à configurer)

### 🏃 Sprint Automation

```bash
# Créer un milestone sprint
gh workflow run sprint-automation.yml \
  -f action=create-sprint-milestone \
  -f sprint_name="Sprint 3" \
  -f sprint_due_date="2024-02-16"
```

---

## 🧠 Agents BMAD

Inspirés de la [méthode BMAD](https://github.com/bmad-code-org/BMAD-METHOD), ces agents guident votre IA (Copilot Chat, Cursor) dans différents rôles.

### Comment utiliser les agents

**VS Code + Copilot Chat :**
```
@workspace /product-manager rédige une User Story pour le login OAuth
@workspace /architect conçois l'architecture du service d'authentification
@workspace /developer implémente le endpoint POST /auth/login
```

**Cursor :**
Les règles dans `.cursor/rules/` sont automatiquement appliquées à toutes vos sessions.

### Agents disponibles

| Agent | Fichier | Rôle |
|-------|---------|------|
| 📋 Product Manager | `product-manager.md` | User Stories, Backlog, Sprint ceremonies |
| 🏗️ Architect | `architect.md` | Décisions techniques, ADRs, Design patterns |
| 👨‍💻 Developer | `developer.md` | Implémentation, Code review, Tests |
| 🔒 Security | `security-reviewer.md` | OWASP, Audit, Threat modeling |

---

## 🔄 Intégration Asana

### Configuration

1. Créer un token Asana : [app.asana.com/0/my-apps](https://app.asana.com/0/my-apps)
2. Trouver le GID du projet dans l'URL Asana
3. Ajouter dans GitHub Secrets :
   - `ASANA_ACCESS_TOKEN`
   - `ASANA_PROJECT_GID`

### Comportement

- **Quotidien** : Sync automatique lun-ven à 8h UTC
- **Nouveau task Asana** → Nouvelle GitHub Issue avec label `asana-sync`
- **Task complété** → Issue GitHub fermée
- **Sous-tâches** → Ignorées (pour éviter la surcharge)

---

## 📝 Conventions

### Branches

```
feature/<id>-<description>    # Nouvelle fonctionnalité
fix/<id>-<description>         # Correction de bug
hotfix/<id>-<description>      # Fix urgent en production
release/v<major>.<minor>.<patch>
chore/<description>            # Maintenance
docs/<description>             # Documentation
```

### Commits (Conventional Commits)

```
feat(scope): description       → Release MINOR
fix(scope): description        → Release PATCH
feat!: breaking change         → Release MAJOR
docs: description              → Pas de release
chore: description             → Pas de release
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Processus Agile](docs/AGILE_PROCESS.md) | Cérémonies Scrum, labels, intégration Asana |
| [Stratégie branches](docs/BRANCHING_STRATEGY.md) | Git Flow adapté, règles de nommage |
| [Processus release](docs/RELEASE_PROCESS.md) | Semantic Release, phases, rollback |
| [Guide contribution](docs/CONTRIBUTING.md) | Setup, conventions, checklist |
| [ADR-001](docs/adr/ADR-001-semantic-release.md) | Décision Semantic Release |
| [ADR-002](docs/adr/ADR-002-asana-github-sync.md) | Décision Asana Sync |

---

## 📄 Licence

MIT — voir [LICENSE](LICENSE)
