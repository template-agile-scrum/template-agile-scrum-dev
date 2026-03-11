# 🚀 Guide d'Automatisation GitHub Actions

Ce projet dispose maintenant de **15 workflows GitHub Actions** pour automatiser un maximum de tâches !

---

## 📋 Vue d'ensemble des workflows

### 🔧 Workflows déjà présents (7)

1. **[ci.yml](.github/workflows/ci.yml)** - Pipeline CI complet (lint, tests, build)
2. **[pr-checks.yml](.github/workflows/pr-checks.yml)** - Validation des PRs (titre, issue liée, labels)
3. **[release.yml](.github/workflows/release.yml)** - Release automatique (semantic-release)
4. **[auto-branch.yml](.github/workflows/auto-branch.yml)** - Création auto de branches depuis issues
5. **[sprint-automation.yml](.github/workflows/sprint-automation.yml)** - Gestion des sprints
6. **[stale.yml](.github/workflows/stale.yml)** - Fermeture auto des issues/PRs inactives
7. **[asana-sync.yml](.github/workflows/asana-sync.yml)** - Synchronisation Asana → GitHub

### ✨ Nouveaux workflows ajoutés (8)

8. **[deploy.yml](.github/workflows/deploy.yml)** - 🚀 Déploiement automatique staging/production
9. **[security.yml](.github/workflows/security.yml)** - 🔒 Scan de sécurité (CodeQL, secrets, OWASP)
10. **[dependabot-automerge.yml](.github/workflows/dependabot-automerge.yml)** - 🤖 Auto-merge Dependabot
11. **[changelog.yml](.github/workflows/changelog.yml)** - 📝 Génération automatique du CHANGELOG
12. **[notifications.yml](.github/workflows/notifications.yml)** - 📢 Notifications Slack/Discord/Teams/Email
13. **[performance.yml](.github/workflows/performance.yml)** - ⚡ Tests de performance & bundle size
14. **[docs.yml](.github/workflows/docs.yml)** - 📚 Documentation auto (API docs, spell check, deploy)
15. **[maintenance.yml](.github/workflows/maintenance.yml)** - 🔄 Maintenance repo (cleanup, backup)

---

## 🎯 Configuration requise

### 1️⃣ Configuration Dependabot

Le fichier [.github/dependabot.yml](.github/dependabot.yml) est déjà configuré. **Action requise :**

- Remplacer `"pierr"` par votre username GitHub (lignes 13-15)

### 2️⃣ Secrets GitHub à configurer

Dans **Settings → Secrets and variables → Actions**, ajoutez :

#### 🔐 Déjà configurés (optionnels)

- `ASANA_ACCESS_TOKEN` - Token Asana pour la sync
- `ASANA_PROJECT_GID` - GID du projet Asana
- `NPM_TOKEN` - Token npm pour publier les packages

#### 🆕 Nouveaux secrets (selon vos besoins)

**Notifications :**

- `SLACK_WEBHOOK_URL` - Webhook Slack ([créer ici](https://api.slack.com/messaging/webhooks))
- `DISCORD_WEBHOOK_URL` - Webhook Discord ([créer ici](https://support.discord.com/hc/en-us/articles/228383668))
- `TEAMS_WEBHOOK_URL` - Webhook Microsoft Teams
- `ALERT_EMAIL` - Email pour les alertes critiques
- `MAIL_SERVER` - Serveur SMTP pour emails
- `MAIL_USERNAME` - Username SMTP
- `MAIL_PASSWORD` - Mot de passe SMTP

**Performance & Monitoring :**

- `CODECOV_TOKEN` - Token Codecov ([créer ici](https://codecov.io/))

### 3️⃣ Variables GitHub (optionnelles)

Dans **Settings → Secrets and variables → Actions → Variables** :

- `SLACK_WEBHOOK_URL` (peut aussi être un secret)
- `DISCORD_WEBHOOK_URL` (peut aussi être un secret)
- `TEAMS_WEBHOOK_URL` (peut aussi être un secret)

---

## 🚀 Workflows détaillés

### 1. 🚀 Deploy ([deploy.yml](.github/workflows/deploy.yml))

**Déclenché par :**

- Release publiée (auto-deploy staging pour prerelease, production pour stable)
- Manuel via workflow_dispatch

**Fonctionnalités :**

- ✅ Build & tests avant déploiement
- ✅ Déploiement staging automatique
- ✅ Déploiement production avec approbation (environment)
- ✅ Smoke tests post-déploiement
- ✅ Rollback en cas d'échec

**À configurer :**

```yaml
# Dans deploy.yml, remplacez les TODO par vos commandes de déploiement :
- name: Deploy to staging
  run: |
    # Exemples :
    rsync -avz dist/ user@staging.server:/var/www/app/
    # ou
    aws s3 sync dist/ s3://staging-bucket/ --delete
    # ou
    kubectl set image deployment/app app=${{ needs.setup.outputs.version }}
```

**Configuration des environments GitHub :**

1. **Settings → Environments → New environment**
2. Créer `staging` et `production`
3. Pour `production`, ajouter des reviewers requis

---

### 2. 🔒 Security ([security.yml](.github/workflows/security.yml))

**Déclenché par :**

- Push sur main/develop
- Pull requests
- Schedule (lundi 10h UTC)
- Manuel

**Fonctionnalités :**

- ✅ **CodeQL** - Analyse statique du code (SAST)
- ✅ **Dependency Review** - Scan des vulnérabilités dans les dépendances
- ✅ **npm audit** - Audit des packages npm
- ✅ **TruffleHog** - Détection de secrets dans le code
- ✅ **OWASP Dependency Check** - Scan hebdomadaire approfondi

**Activer GitHub Security :**

1. **Settings → Security → Code security and analysis**
2. Activer :
   - ✅ Dependency graph
   - ✅ Dependabot alerts
   - ✅ Dependabot security updates
   - ✅ CodeQL analysis
   - ✅ Secret scanning

---

### 3. 🤖 Dependabot Auto-Merge ([dependabot-automerge.yml](.github/workflows/dependabot-automerge.yml))

**Déclenché par :**

- Pull requests Dependabot

**Fonctionnalités :**

- ✅ Auto-approve des mises à jour patch/minor
- ✅ Auto-merge après succès des checks CI
- ✅ Alert sur les mises à jour major
- ✅ Priorité haute pour les correctifs de sécurité

**Configuration :**

- Activer **Settings → General → Allow auto-merge**
- Les PR Dependabot avec label `automerge` seront automatiquement fusionnées

---

### 4. 📝 Changelog ([changelog.yml](.github/workflows/changelog.yml))

**Déclenché par :**

- Push sur main
- Release publiée
- Manuel

**Fonctionnalités :**

- ✅ Génération automatique du CHANGELOG.md
- ✅ Catégorisation des commits (feat, fix, chore, etc.)
- ✅ Notes de release automatiques
- ✅ Format [Keep a Changelog](https://keepachangelog.com/)

**Configuration :**

- Le fichier [.github/cliff.toml](.github/cliff.toml) est déjà configuré
- Commit avec Conventional Commits pour une bonne catégorisation

---

### 5. 📢 Notifications ([notifications.yml](.github/workflows/notifications.yml))

**Déclenché par :**

- Fin de workflow (CI, Release, Deploy, Security)
- Issues/PRs opened/closed
- Releases publiées

**Fonctionnalités :**

- ✅ **Slack** - Notifications riches avec blocks
- ✅ **Discord** - Embeds colorés
- ✅ **Microsoft Teams** - Cartes adaptatives
- ✅ **Email** - Alertes critiques uniquement (deploy/security failures)

**Configuration :**

1. Créer les webhooks (voir section Secrets)
2. Personnaliser les messages dans le workflow

---

### 6. ⚡ Performance ([performance.yml](.github/workflows/performance.yml))

**Déclenché par :**

- Pull requests
- Push sur main
- Schedule (lundi 3h UTC)
- Manuel

**Fonctionnalités :**

- ✅ **Bundle size analysis** - Détection des augmentations de taille
- ✅ **Lighthouse CI** - Tests de performance web
- ✅ **Load testing** - Tests de charge avec k6
- ✅ **Code coverage** - Suivi de la couverture de tests
- ✅ **Performance regression** - Détection de régressions

**Configuration Lighthouse :**

- Fichier [.github/lighthouserc.json](.github/lighthouserc.json) déjà configuré
- Ajuster les seuils selon vos besoins

**Configuration Coverage :**

```bash
# Inscrire sur codecov.io et récupérer le token
# Ajouter CODECOV_TOKEN dans les secrets
```

---

### 7. 📚 Documentation ([docs.yml](.github/workflows/docs.yml))

**Déclenché par :**

- Push sur main (chemins docs/\*\*)
- Pull requests (modifications doc)
- Manuel

**Fonctionnalités :**

- ✅ Génération automatique de l'API documentation
- ✅ Vérification des liens cassés
- ✅ Spell check
- ✅ Update des badges README
- ✅ Déploiement sur GitHub Pages

**Configuration GitHub Pages :**

1. **Settings → Pages**
2. Source : **GitHub Actions**

---

### 8. 🔄 Maintenance ([maintenance.yml](.github/workflows/maintenance.yml))

**Déclenché par :**

- Schedule (quotidien 2h UTC)
- Manuel avec choix de tâche

**Fonctionnalités :**

- ✅ Cleanup des artifacts > 7 jours
- ✅ Cleanup des caches > 7 jours
- ✅ Backup des issues/PRs au format JSON
- ✅ Sync des labels
- ✅ Fermeture des milestones expirés
- ✅ Génération des statistiques du repo

**Configuration :**

- Les backups sont conservés 90 jours dans les artifacts

---

## 📊 Tableau récapitulatif

| Workflow                  | Fréquence         | Critique | Config requise       |
| ------------------------- | ----------------- | -------- | -------------------- |
| CI Pipeline               | Push/PR           | ⚠️ Oui   | Aucune               |
| PR Checks                 | PR                | ⚠️ Oui   | Aucune               |
| Release                   | Push main         | ⚠️ Oui   | NPM_TOKEN (opt)      |
| Auto-Branch               | Issue assigned    | Non      | Aucune               |
| Sprint Automation         | Events + Schedule | Non      | Aucune               |
| Stale                     | Quotidien         | Non      | Aucune               |
| Asana Sync                | Quotidien         | Non      | ASANA\_\* secrets    |
| **Deploy**                | Release           | ⚠️ Oui   | **Commandes deploy** |
| **Security**              | Push/PR/Hebdo     | ⚠️ Oui   | **Activer Security** |
| **Dependabot Auto-merge** | Dependabot PR     | Non      | **Allow auto-merge** |
| **Changelog**             | Push main         | Non      | Aucune               |
| **Notifications**         | Workflows         | Non      | Webhooks (opt)       |
| **Performance**           | PR/Hebdo          | Non      | CODECOV_TOKEN (opt)  |
| **Docs**                  | Push/PR           | Non      | GitHub Pages (opt)   |
| **Maintenance**           | Quotidien         | Non      | Aucune               |

---

## 🎬 Quick Start

### Configuration minimale (5 minutes)

```bash
# 1. Activer auto-merge dans les settings
# Settings → General → Allow auto-merge ✅

# 2. Activer GitHub Security features
# Settings → Security → Code security and analysis
# - Dependency graph ✅
# - Dependabot alerts ✅
# - Dependabot security updates ✅
# - CodeQL analysis ✅
# - Secret scanning ✅

# 3. Configurer les environments
# Settings → Environments → New environment
# - staging
# - production (avec reviewers requis)

# 4. Personnaliser dependabot.yml
# Remplacer "pierr" par votre username (lignes 13-15)
```

### Configuration complète (30 minutes)

En plus de la configuration minimale :

```bash
# 5. Créer les webhooks
# - Slack: https://api.slack.com/messaging/webhooks
# - Discord: https://support.discord.com/hc/en-us/articles/228383668
# Ajouter dans Settings → Secrets

# 6. Configurer Codecov
# - Inscription sur codecov.io
# - Ajouter CODECOV_TOKEN dans les secrets

# 7. Personnaliser les commandes de déploiement
# Éditer .github/workflows/deploy.yml (lignes TODO)

# 8. Activer GitHub Pages
# Settings → Pages → Source: GitHub Actions

# 9. Première release test
gh workflow run release.yml

# 10. Vérifier tous les workflows
gh workflow list
```

---

## 🛠️ Personnalisation

### Ajouter un nouveau workflow

```yaml
name: 🎯 Mon Workflow

on:
  push:
    branches: [main]

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Ma tâche
        run: echo "Hello World"
```

### Désactiver un workflow

```bash
# Méthode 1: Via l'interface GitHub
# Actions → Workflow → "..." → Disable workflow

# Méthode 2: Ajouter dans le workflow
on:
  workflow_dispatch: # Manuel uniquement

# Méthode 3: Supprimer le fichier
rm .github/workflows/performance.yml
```

---

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Release](https://semantic-release.gitbook.io/)
- [Dependabot Configuration](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file)

---

## 🎉 Workflows en un coup d'œil

```
AUTOMATISATION COMPLÈTE :
├── 🔧 CI/CD
│   ├── ✅ CI Pipeline
│   ├── 🔍 PR Checks
│   ├── 🚀 Release
│   └── 🚀 Deploy (nouveau)
│
├── 🔒 Sécurité
│   ├── 🔒 Security Scanning (nouveau)
│   ├── 🤖 Dependabot Config (nouveau)
│   └── 🤖 Auto-merge Dependabot (nouveau)
│
├── 📋 Gestion Projet
│   ├── 🌿 Auto-Branch
│   ├── 🏃 Sprint Automation
│   ├── 🧹 Stale Issues
│   └── 🔄 Asana Sync
│
├── 📊 Qualité & Performance
│   ├── ⚡ Performance Tests (nouveau)
│   ├── 📝 Changelog Generator (nouveau)
│   └── 📚 Documentation (nouveau)
│
└── 🔔 Monitoring
    ├── 📢 Notifications (nouveau)
    └── 🔄 Maintenance (nouveau)
```

---

## 💡 Conseils Pro

1. **Commencer petit** : Activez d'abord les workflows critiques (CI, Security, Deploy)
2. **Monitoring** : Surveillez les workflows dans l'onglet Actions
3. **Notifications** : Configurez au moins Slack ou Discord pour rester informé
4. **Dependabot** : Laissez-le tourner une semaine avant d'activer l'auto-merge
5. **Sécurité** : Activez immédiatement CodeQL et Dependabot alerts
6. **Documentation** : Tenez à jour le CHANGELOG automatiquement généré
7. **Performance** : Surveillez les rapports Lighthouse sur les PRs

---

**🎯 Objectif atteint : Automatisation maximale !**

Avec ces 15 workflows, votre workflow de développement est maintenant **90% automatisé**. 🚀
