# 🏃 Processus Agile-Scrum

Ce document décrit le processus Agile-Scrum utilisé dans ce projet, adapté à une équipe de développement et intégrant les outils GitHub.

## Vue d'ensemble

```
Asana (Tasks) ──sync──→ GitHub Issues
                              │
                              ▼
               ┌──────────────────────────────┐
               │         Product Backlog       │
               │   (Issues triées par priorité)│
               └──────────────────┬───────────┘
                                  │ Sprint Planning
                                  ▼
               ┌──────────────────────────────┐
               │         Sprint Backlog        │
               │  (Issues du sprint courant)   │
               └──────────────────┬───────────┘
                                  │
                         ┌────────┴────────┐
                         │                 │
                    Development         Testing
                         │                 │
                         └────────┬────────┘
                                  │ Sprint Review
                                  ▼
               ┌──────────────────────────────┐
               │          Release              │
               │   (main → v1.x.x deployed)   │
               └──────────────────────────────┘
```

## Durée du sprint

**Sprint = 2 semaines**

| Jour | Activité |
|------|---------|
| Lundi S1 | Sprint Planning |
| Mardi S1 - Vendredi S2 | Développement + Daily Standups |
| Vendredi S2 (matin) | Sprint Review + Demo |
| Vendredi S2 (après-midi) | Retrospective |

## Cérémonies Scrum

### 📋 Sprint Planning (Lundi matin, 2h max)

**Participants** : Toute l'équipe

**Objectifs** :
1. Revoir la vélocité du sprint précédent
2. Présenter les User Stories priorisées du backlog
3. Estimer et sélectionner les stories pour le sprint
4. Définir l'objectif du sprint (Sprint Goal)

**GitHub Actions** :
- Assigner les issues sélectionnées au Milestone du sprint
- Assigner les développeurs aux issues
- L'action `auto-branch` crée automatiquement les branches

**Commande pour créer un milestone sprint** :
```bash
gh workflow run sprint-automation.yml \
  -f action=create-sprint-milestone \
  -f sprint_name="Sprint 3" \
  -f sprint_due_date="2024-02-16"
```

### ☀️ Daily Standup (Quotidien, 15min max)

**Format** (chacun répond en 1-2 phrases) :
1. **Hier** : Qu'ai-je accompli ? (issue GitHub → PR)
2. **Aujourd'hui** : Que vais-je faire ? (issue GitHub assignée)
3. **Blocages** : Y a-t-il des obstacles ?

**Indicateurs GitHub** :
- Issues avec label `in-progress` = en cours
- Issues avec label `blocked` = bloquées
- PRs en attente de review = goulots d'étranglement

### 🎯 Sprint Review (Vendredi S2, 1h)

**Participants** : Équipe + Stakeholders

**Format** :
1. Démo des features complétées (issues fermées du sprint)
2. Feedback des stakeholders
3. Mise à jour du backlog

**GitHub Actions** :
- Vérifier que toutes les issues du Milestone sont fermées
- Les issues non complétées sont déplacées au prochain sprint
- Release déclenchée si objectifs atteints

### 🔄 Rétrospective (Vendredi S2, 1h)

**Format (Keep/Drop/Try)** :
- ✅ **Keep** : Ce qui a bien fonctionné
- ❌ **Drop** : Ce qui n'a pas fonctionné
- 💡 **Try** : Ce qu'on veut essayer au prochain sprint

Créer une issue avec le label `retrospective` pour tracker les actions.

## Labels GitHub

### Statut des issues

| Label | Couleur | Description |
|-------|---------|-------------|
| `backlog` | ⬜ Gris | Dans le backlog, pas encore planifié |
| `in-progress` | 🔵 Bleu | En cours de développement |
| `in-review` | 🟡 Jaune | PR ouverte, en attente de review |
| `blocked` | 🔴 Rouge | Bloqué par une dépendance |
| `done` | 🟢 Vert | Complété et mergé |

### Type des issues

| Label | Couleur | Description |
|-------|---------|-------------|
| `epic` | 🟣 Violet | Epic regroupant plusieurs stories |
| `user-story` | 🔵 Bleu clair | User Story fonctionnelle |
| `bug` | 🔴 Rouge | Bug à corriger |
| `task` | ⬜ Gris | Tâche technique |
| `asana-sync` | 🟤 Marron | Synchronisé depuis Asana |

### Priorité

| Label | Couleur | Description |
|-------|---------|-------------|
| `priority:critical` | 🔴 Rouge foncé | Bloque la production |
| `priority:high` | 🟠 Orange | Urgence élevée |
| `priority:medium` | 🟡 Jaune | Priorité normale |
| `priority:low` | 🟢 Vert | Pas urgent |

### Composants

| Label | Description |
|-------|-------------|
| `frontend` | Interface utilisateur |
| `backend` | API, logique métier |
| `database` | Base de données |
| `infrastructure` | DevOps, CI/CD |
| `documentation` | Documentation |
| `security` | Sécurité |

## Intégration Asana → GitHub

### Configuration

1. Aller dans **Settings → Secrets and variables → Actions**
2. Ajouter :
   - `ASANA_ACCESS_TOKEN` : [Créer sur app.asana.com/0/my-apps](https://app.asana.com/0/my-apps)
   - `ASANA_PROJECT_GID` : L'ID du projet Asana (dans l'URL)

### Synchronisation automatique

La synchronisation se fait :
- **Automatiquement** : Tous les jours ouvrables à 8h UTC
- **Manuellement** : Via Actions → "Asana → GitHub Issues Sync" → "Run workflow"

### Comportement

- Les tâches Asana deviennent des **GitHub Issues** avec le label `asana-sync`
- Les tâches complétées dans Asana ferment les issues correspondantes
- Les sous-tâches Asana sont ignorées (pour éviter la surcharge)
- Une mise à jour de tâche Asana met à jour l'issue GitHub

## Définition of Done (DoD)

Une issue est considérée **Done** quand :

- [ ] Le code est implémenté et fonctionne
- [ ] Les tests unitaires passent (coverage >80%)
- [ ] Le linter ne retourne pas d'erreurs
- [ ] La PR est approuvée par au moins 1 reviewer
- [ ] La branche est mergée dans `develop`
- [ ] L'issue GitHub est fermée
- [ ] La documentation est mise à jour si nécessaire

## Métriques du sprint

Accessibles via **GitHub Insights** :

- **Vélocité** : Story points complétés par sprint
- **Burndown** : Progression des issues dans le Milestone
- **Lead Time** : Temps de l'ouverture de l'issue au merge
- **Cycle Time** : Temps du début du développement au merge
