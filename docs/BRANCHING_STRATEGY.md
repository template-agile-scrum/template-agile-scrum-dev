# 🌿 Stratégie de Branches

Ce document décrit la stratégie de branches utilisée dans ce projet, basée sur **Git Flow** adapté aux pratiques Agile-Scrum.

## Schéma des branches

```
main ──────────────────────────────────────────────── 🏷️ v1.0.0
  │                                                        ↑
  │    develop ──────────────────────────────────────────── merge (release)
  │       │                                                  ↑
  │       ├── feature/42-auth-oauth ──────────────────────── PR → develop
  │       │
  │       ├── feature/43-user-profile ──────────────────── PR → develop
  │       │
  │       └── fix/50-login-redirect ──────────────────── PR → develop
  │
  └── hotfix/critical-security-fix ─────────── PR → main + develop
```

## Branches permanentes

### `main`
- **Rôle** : Code en **production**
- **Protection** : Oui — PRs obligatoires, reviews requises, CI doit passer
- **Qui peut merger** : Release manager uniquement (via PR)
- **Source de** : `release/*` ou `hotfix/*`

### `develop`
- **Rôle** : Branche d'**intégration** — code prêt pour le prochain sprint
- **Protection** : Oui — PRs obligatoires, CI doit passer
- **Qui peut merger** : Tout développeur via PR validée
- **Source de** : `feature/*`, `fix/*`, `chore/*`

## Branches temporaires

### `feature/<issue-id>-<description>`
- **Rôle** : Développement d'une **nouvelle fonctionnalité**
- **Créée depuis** : `develop`
- **Mergée dans** : `develop`
- **Exemples** :
  - `feature/42-auth-oauth2`
  - `feature/85-user-dashboard`
- **Durée de vie** : Durée du développement de la feature (≤ 1 sprint)

### `fix/<issue-id>-<description>`
- **Rôle** : Correction d'un **bug non-critique**
- **Créée depuis** : `develop`
- **Mergée dans** : `develop`
- **Exemples** :
  - `fix/67-login-redirect-loop`
  - `fix/72-date-format`

### `hotfix/<issue-id>-<description>`
- **Rôle** : Correction **urgente en production**
- **Créée depuis** : `main`
- **Mergée dans** : `main` ET `develop`
- **Exemples** :
  - `hotfix/99-security-xss`
  - `hotfix/100-payment-crash`

### `release/<version>`
- **Rôle** : Préparation d'une **nouvelle release**
- **Créée depuis** : `develop`
- **Mergée dans** : `main` ET `develop`
- **Exemples** :
  - `release/v1.2.0`
  - `release/v2.0.0-rc1`

### `chore/<description>`
- **Rôle** : Maintenance, mise à jour de dépendances, configuration
- **Créée depuis** : `develop`
- **Mergée dans** : `develop`
- **Exemples** :
  - `chore/update-dependencies`
  - `chore/setup-docker`

### `docs/<description>`
- **Rôle** : Documentation uniquement
- **Créée depuis** : `develop`
- **Mergée dans** : `develop`

## Règles de nommage

| Type | Format | Exemple |
|------|--------|---------|
| Feature | `feature/<id>-<desc>` | `feature/42-oauth2-login` |
| Bug fix | `fix/<id>-<desc>` | `fix/67-null-pointer` |
| Hotfix | `hotfix/<id>-<desc>` | `hotfix/99-xss-vulnerability` |
| Release | `release/v<semver>` | `release/v1.2.0` |
| Chore | `chore/<desc>` | `chore/upgrade-node-20` |
| Docs | `docs/<desc>` | `docs/api-endpoints` |
| Test | `test/<desc>` | `test/e2e-auth-flow` |

**Règles :**
- Utiliser des minuscules et des tirets uniquement
- Inclure l'ID de l'issue GitHub pour les features et fixes
- Description courte et explicite (max 50 caractères après le préfixe)

## Cycle de vie d'une feature

```bash
# 1. Créer la branche depuis develop (ou utiliser l'auto-creation via GitHub)
git checkout develop
git pull origin develop
git checkout -b feature/42-auth-oauth2

# 2. Développer et committer régulièrement
git add -p
git commit -m "feat(auth): ajouter stratégie OAuth2 Google"
git commit -m "feat(auth): implémenter callback et création de session"
git commit -m "test(auth): ajouter tests unitaires OAuth2"

# 3. Garder la branche à jour
git fetch origin
git rebase origin/develop

# 4. Push et ouvrir une PR
git push origin feature/42-auth-oauth2
# Ouvrir la PR sur GitHub avec le template

# 5. Après review et approbation → merge dans develop
# 6. Supprimer la branche locale et distante
git branch -d feature/42-auth-oauth2
git push origin --delete feature/42-auth-oauth2
```

## Protection des branches

### Configuration recommandée pour `main`
- ✅ Require a pull request before merging
- ✅ Require approvals: **2**
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners
- ✅ Require status checks to pass (CI, lint, tests)
- ✅ Require branches to be up to date before merging
- ✅ Include administrators
- ❌ Allow force pushes
- ❌ Allow deletions

### Configuration recommandée pour `develop`
- ✅ Require a pull request before merging
- ✅ Require approvals: **1**
- ✅ Require status checks to pass (CI, lint, tests)
- ❌ Allow force pushes (sauf rebase)
- ❌ Allow deletions
