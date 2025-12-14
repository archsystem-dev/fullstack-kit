# npm_dist_generate.sh
___

## Objectif du script
Génère la distribution de production du frontend via npm run build, corrige les permissions du dossier dist et autorise www-data (Nginx) à lire les fichiers statiques.

## Ce que fait le script étape par étape
1. Vérifie qu'il n'est pas exécuté en root (opérations en utilisateur standard).
2. Définit les chemins absolus vers le dossier frontend et dist.
3. Vérifie la présence du dossier frontend.
4. Se positionne dans frontend et exécute npm run build silencieusement.
5. Affiche un récapitulatif final confirmant la génération de la distribution.

## Liste des fonctions internes

| Fonction  | Rôle                                                                 |
|-----------|----------------------------------------------------------------------|
| `info`    | Affiche un message informatif précédé de [INFO]                      |
| `success` | Affiche un message de succès précédé de [OK]                         |
| `error`   | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |

## Prérequis clairs
- Exécution en utilisateur standard (pas de sudo/root).
- Structure du projet avec un dossier frontend contenant package.json avec un script "build".
- Node.js et npm installés et configurés pour générer une distribution dans frontend/dist.
- Le script doit être lancé depuis la racine du projet (où se trouve le dossier frontend).

## Utilisation précise
```bash
chmod +x npm_dist_generate.sh   # une seule fois
./npm_dist_generate.sh          # lancer depuis la racine du projet