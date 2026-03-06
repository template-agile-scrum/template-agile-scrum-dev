# 🤝 Guide de Contribution

Merci de contribuer à ce projet ! Ce guide explique le processus de contribution et les conventions à respecter.

## Prérequis

- [Git](https://git-scm.com/) 2.40+
- [Node.js](https://nodejs.org/) 20+
- [GitHub CLI](https://cli.github.com/) (optionnel mais recommandé)

## Mise en place de l'environnement

```bash
# 1. Cloner le repository
git clone https://github.com/<owner>/<repo>.git
cd <repo>

# 2. Installer les dépendances
npm install

# 3. Configurer les hooks Git (pre-commit lint)
npm run prepare  # Configure Husky si présent

# 4. Vérifier que tout fonctionne
npm run lint && npm test && npm run build
```

## Processus de contribution

### 1. Trouver une issue à traiter

- Parcourir les issues avec le label `backlog`
- Lors du Sprint Planning, les issues vous seront assignées
- Ou créer une nouvelle issue si vous identifiez un bug/besoin

### 2. Créer votre branche

**Via GitHub Actions (recommandé)** :
- Assigner l'issue à vous-même → la branche est créée automatiquement

**Manuellement** :
```bash
git checkout develop
git pull origin develop
git checkout -b feature/<id>-<description-courte>
# ex: git checkout -b feature/42-auth-oauth2
```

### 3. Développer

- Faites des commits atomiques et fréquents
- Suivez les [Conventional Commits](https://www.conventionalcommits.org/)
- Testez votre code en local

```bash
# Commits valides
git commit -m "feat(auth): ajouter login Google OAuth2"
git commit -m "test(auth): ajouter tests unitaires pour OAuth"
git commit -m "docs(auth): documenter la configuration OAuth"
```

### 4. Ouvrir une Pull Request

```bash
git push origin feature/42-auth-oauth2
gh pr create --title "feat(auth): ajouter login Google OAuth2" \
             --body "Closes #42"
```

Ou via l'interface GitHub :
1. Aller sur la page du repository
2. Cliquer "Compare & pull request"
3. Remplir le template PR (ne pas effacer la checklist)
4. Lier l'issue : `Closes #42`
5. Assigner un reviewer

### 5. Code Review

- Répondez aux commentaires de review
- Si vous faites des modifications, notifiez le reviewer
- Une fois approuvée, la PR peut être mergée

### 6. Après le merge

```bash
# Mettre à jour develop en local
git checkout develop
git pull origin develop

# Supprimer la branche locale
git branch -d feature/42-auth-oauth2
```

## Conventions de code

### Format des commits

```
<type>(<scope>): <description>

[body optionnel — explication du "pourquoi"]

[footer: Closes #<issue>, BREAKING CHANGE: ...]
```

**Types** : `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`

**Exemples** :
```bash
feat(api): ajouter endpoint de recherche paginée
fix(auth): corriger expiration des tokens JWT
docs(readme): mettre à jour les instructions d'installation
test(user): ajouter tests d'intégration pour UserService
chore(deps): mettre à jour axios vers 1.6.0
ci(release): configurer semantic-release
refactor(cart): extraire logique de calcul des totaux
perf(db): ajouter index sur la colonne email
```

### Style de code

- Indentation : **2 espaces**
- Point-virgules : selon la config ESLint du projet
- Guillemets : selon la config Prettier du projet
- Longueur de ligne max : **120 caractères**
- Fichiers se terminent par une **newline**

### Nommage

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Variables | camelCase | `userEmail` |
| Fonctions | camelCase | `getUserById()` |
| Classes | PascalCase | `UserService` |
| Interfaces | PascalCase | `IUserRepository` |
| Constantes | UPPER_SNAKE_CASE | `MAX_RETRIES` |
| Fichiers | kebab-case | `user-service.ts` |
| Composants React | PascalCase | `UserProfile.tsx` |

## Tests

```bash
# Tous les tests
npm test

# Tests avec coverage
npm test -- --coverage

# Tests en mode watch
npm test -- --watch

# Tests d'un fichier spécifique
npm test -- user.service.test.ts
```

**Conventions de tests** :
- Un fichier `*.test.ts` par fichier source
- Pattern de nommage : `should <comportement> when <condition>`
- Coverage minimum : **80%**

```typescript
describe('UserService', () => {
  describe('getUserById', () => {
    it('should return user when valid id is provided', async () => {
      // Arrange
      const userId = '123';
      // Act
      const user = await userService.getUserById(userId);
      // Assert
      expect(user.id).toBe(userId);
    });

    it('should throw NotFoundError when user does not exist', async () => {
      // ...
    });
  });
});
```

## Checklist avant d'ouvrir une PR

- [ ] `npm run lint` passe sans erreurs
- [ ] `npm test` passe avec >80% coverage
- [ ] `npm run build` réussit
- [ ] Aucun `console.log` oublié
- [ ] Aucun secret ou credential hardcodé
- [ ] La documentation est mise à jour si nécessaire
- [ ] L'issue GitHub est liée dans la PR (`Closes #XX`)

## Questions ?

- 💬 Ouvrir une [Discussion GitHub](../../discussions)
- 📋 Consulter les [Issues existantes](../../issues)
- 📚 Lire la [documentation du processus Agile](./AGILE_PROCESS.md)
