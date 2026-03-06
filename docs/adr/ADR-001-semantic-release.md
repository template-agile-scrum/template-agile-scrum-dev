# ADR-001: Stratégie de versioning — Semantic Release

**Date :** 2024-01-01
**Statut :** Accepté
**Décideurs :** Équipe de développement

## Contexte

Le projet nécessite un processus de release cohérent et automatisé. La gestion manuelle des versions est source d'erreurs et de frictions dans le workflow.

## Options considérées

### Option 1 : Versioning manuel
- **Avantages :** Contrôle total, simple à comprendre
- **Inconvénients :** Erreurs humaines, processus fastidieux, CHANGELOG difficile à maintenir

### Option 2 : Semantic Release (choisie)
- **Avantages :** Automatique, basé sur les commits, CHANGELOG généré, tags Git automatiques
- **Inconvénients :** Nécessite la discipline des Conventional Commits

### Option 3 : Release Please (Google)
- **Avantages :** Similaire à Semantic Release, crée des PRs de release
- **Inconvénients :** Moins flexible, workflow différent

## Décision

Utilisation de **Semantic Release** avec la convention **Conventional Commits**.

## Conséquences

### Positives
- Versioning automatique basé sur le type de commit
- CHANGELOG généré automatiquement
- Tags Git créés automatiquement
- GitHub Releases créées automatiquement

### Négatives / Compromis
- L'équipe doit respecter la convention Conventional Commits
- Configuration initiale plus complexe

## Implémentation

Voir `.releaserc.json` et `.github/workflows/release.yml`.
