# npm_dev.sh

## Objectif du script
Arrête les processus Node.js/npm existants liés au serveur de développement et lance npm run dev dans le dossier frontend.

## Ce que fait le script étape par étape
1. Active les options strictes Bash et définit les séparateurs IFS sécurisés.
2. Définit les fonctions d'affichage standardisées info, success et error.
3. Détermine le répertoire racine du projet et le chemin vers frontend.
4. Vérifie la présence du dossier frontend.
5. Arrête gracieusement les processus Node.js de développement existants via plusieurs motifs (npm run, dev, Vite/React/Next).
6. Attend 2 secondes pour une terminaison propre.
7. Se positionne dans le dossier frontend et exécute npm run dev (reste interactif).

## Liste des fonctions internes

| Fonction  | Rôle                                                                 |
|-----------|----------------------------------------------------------------------|
| `info`    | Affiche un message informatif précédé de [INFO]                      |
| `success` | Affiche un message de succès précédé de [OK]                         |
| `error`   | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |

## Prérequis clairs
- Exécution en utilisateur standard (pas de sudo/root).
- Structure du projet avec un dossier frontend contenant package.json avec un script "dev".
- Node.js et npm installés et configurés.
- Le script doit être lancé depuis la racine du projet (où se trouve le dossier frontend).

## Utilisation précise
```bash
chmod +x npm_dev.sh   # une seule fois
./npm_dev.sh          # lancer depuis la racine du projet