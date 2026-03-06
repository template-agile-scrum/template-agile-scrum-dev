# 🚀 Processus de Release

Ce document décrit le processus de release de ce projet, utilisant le **Semantic Versioning** (SemVer) et le **Semantic Release** automatisé.

## Philosophie de versioning

Ce projet suit le **Semantic Versioning 2.0.0** : `MAJOR.MINOR.PATCH`

| Version | Quand l'incrémenter | Exemple |
|---------|---------------------|---------|
| **MAJOR** | Breaking changes (incompatibilité API) | `1.0.0` → `2.0.0` |
| **MINOR** | Nouvelle fonctionnalité rétrocompatible | `1.0.0` → `1.1.0` |
| **PATCH** | Correction de bug rétrocompatible | `1.0.0` → `1.0.1` |

**Pre-releases :**
- `v1.1.0-beta.1` — Branch `develop`
- `v1.1.0-rc.1` — Branch `release/v1.1.0`
- `v1.1.0` — Branch `main`

## Versioning automatique via Conventional Commits

Le versioning est **entièrement automatisé** grâce à [Semantic Release](https://semantic-release.gitbook.io/).

| Type de commit | Impact sur la version |
|---------------|----------------------|
| `feat: ...` | MINOR (`1.0.0` → `1.1.0`) |
| `fix: ...` | PATCH (`1.0.0` → `1.0.1`) |
| `perf: ...` | PATCH |
| `refactor: ...` | PATCH |
| `BREAKING CHANGE: ...` dans le footer | MAJOR (`1.0.0` → `2.0.0`) |
| `feat!: ...` ou `fix!: ...` | MAJOR |
| `docs:`, `chore:`, `test:`, `style:` | Aucun (pas de release) |

## Phases de release

### Phase 1 — Développement (Branch `develop`)

```
feature/* ──PR──→ develop ──auto──→ v1.1.0-beta.X
```

- Chaque merge dans `develop` génère automatiquement une **pre-release beta**
- Déployée sur l'environnement de **staging**
- Tests automatisés (CI)

### Phase 2 — Release Candidate (Branch `release/v*`)

```
develop ──PR──→ release/v1.1.0 ──auto──→ v1.1.0-rc.X
```

1. Créer une branche `release/v1.1.0` depuis `develop`
2. Seuls les **bug fixes** sont acceptés sur cette branche
3. Chaque commit génère un **Release Candidate**
4. Tests de recette (UAT) réalisés sur cette version
5. Quand validée → PR vers `main`

### Phase 3 — Production (Branch `main`)

```
release/v1.1.0 ──PR──→ main ──auto──→ v1.1.0 (GitHub Release)
```

1. La PR est reviewée par le release manager
2. CI doit passer entièrement
3. Merge → Semantic Release publie automatiquement :
   - Tag Git `v1.1.0`
   - GitHub Release avec CHANGELOG
   - Déploiement en production

## Checklist de release

### Avant d'ouvrir la PR de release

- [ ] Tous les tickets du sprint sont fermés ou reportés
- [ ] Les tests E2E passent sur staging
- [ ] Le CHANGELOG est à jour (auto-généré)
- [ ] La documentation est mise à jour
- [ ] Les migrations de base de données sont testées
- [ ] Les variables d'environnement de production sont configurées
- [ ] Les rollback procedures sont documentées

### Pendant le merge

- [ ] 2 reviewers ont approuvé
- [ ] Tous les checks CI passent
- [ ] La branche est à jour avec `main`

### Après le merge

- [ ] Vérifier la GitHub Release créée automatiquement
- [ ] Vérifier le déploiement en production
- [ ] Fermer le Milestone du sprint correspondant
- [ ] Notifier les stakeholders (Slack, email, etc.)
- [ ] Merger `main` dans `develop` (pour les hotfixes)

## Hotfix Process

Pour les bugs critiques en production :

```bash
# 1. Créer une branche hotfix depuis main
git checkout main
git pull origin main
git checkout -b hotfix/99-critical-security-fix

# 2. Corriger le bug
git commit -m "fix(security): corriger injection SQL dans endpoint /users"

# 3. PR vers main (processus accéléré)
# 4. Après merge → release automatique (PATCH bump)

# 5. Merger dans develop également
git checkout develop
git merge origin/main
git push origin develop
```

## Environnements

| Environnement | Branch | URL | Auto-déployé |
|--------------|--------|-----|--------------|
| Development | `feature/*` | local | Non |
| Staging | `develop` | staging.app.com | Oui (beta) |
| Pre-production | `release/*` | preprod.app.com | Oui (rc) |
| Production | `main` | app.com | Oui (release) |

## Rollback

En cas de problème en production :

```bash
# Option 1 : Revert via PR (recommandé)
gh pr create --base main --title "revert: annuler v1.1.0" ...

# Option 2 : Rollback manuel via GitHub Releases
# Identifier la dernière release stable et re-déployer

# Option 3 : Git revert
git revert <commit-sha>
git push origin main
```
