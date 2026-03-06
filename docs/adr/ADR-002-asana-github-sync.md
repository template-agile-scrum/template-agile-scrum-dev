# ADR-002: Synchronisation Asana → GitHub Issues

**Date :** 2024-01-01
**Statut :** Accepté
**Décideurs :** Équipe de développement

## Contexte

L'équipe utilise Asana pour la gestion de projet et GitHub pour le développement. Les développeurs doivent pouvoir accéder aux tâches directement depuis GitHub pour créer des branches et tracker le travail.

## Options considérées

### Option 1 : Synchronisation unidirectionnelle Asana → GitHub (choisie)
- **Avantages :** Simple, Asana reste la source de vérité, pas de conflits
- **Inconvénients :** Les mises à jour GitHub ne remontent pas dans Asana

### Option 2 : Synchronisation bidirectionnelle
- **Avantages :** Synchronisation complète
- **Inconvénients :** Complexe, risques de conflits, webhooks bidirectionnels difficiles

### Option 3 : Abandon d'Asana, tout dans GitHub
- **Avantages :** Un seul outil
- **Inconvénients :** Perte des fonctionnalités de gestion de projet d'Asana

## Décision

**Synchronisation unidirectionnelle** : Asana est la source de vérité pour la gestion de projet. Les tâches Asana sont synchronisées vers GitHub Issues via une GitHub Action quotidienne.

## Conséquences

### Positives
- Les développeurs voient les tâches dans GitHub
- Possibilité de créer des branches depuis les issues GitHub
- Pas de double saisie manuelle

### Négatives / Compromis
- La fermeture d'une issue GitHub ne met pas à jour Asana (à implémenter si besoin)
- Les issues avec le label `asana-sync` ne doivent pas être modifiées manuellement

## Implémentation

Voir `.github/workflows/asana-sync.yml` et `.github/scripts/asana-sync.js`.

### Configuration requise
- `ASANA_ACCESS_TOKEN` dans les secrets GitHub
- `ASANA_PROJECT_GID` dans les secrets GitHub
