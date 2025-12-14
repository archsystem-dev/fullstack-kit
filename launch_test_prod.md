# launch_test_prod.sh
___

## Objectif du script
Génère la distribution frontend, démarre le serveur backend FastAPI en mode production et recharge Nginx pour déployer l'application en environnement de test/production.

## Ce que fait le script étape par étape
1. Vérifie qu'il n'est pas exécuté en root (opérations en utilisateur standard).
2. Définit les chemins absolus vers les scripts dépendants (npm_dist_generate.sh, api_start.sh, nginx_reload.sh).
3. Vérifie la présence des trois scripts requis.
4. Exécute npm_dist_generate.sh pour générer la build de production frontend.
5. Exécute api_start.sh pour démarrer Uvicorn en mode production.
6. Exécute avec sudo nginx_reload.sh pour recharger la configuration Nginx.
7. Affiche un récapitulatif final confirmant le déploiement réussi.

## Liste des fonctions internes

| Fonction  | Rôle                                                                 |
|-----------|----------------------------------------------------------------------|
| `info`    | Affiche un message informatif précédé de [INFO]                      |
| `success` | Affiche un message de succès précédé de [OK]                         |
| `error`   | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |

## Prérequis clairs
- Exécution en utilisateur standard (pas de sudo/root pour ce script principal).
- Scripts npm_dist_generate.sh, api_start.sh et nginx_reload.sh présents dans le même répertoire.
- npm et Node.js configurés pour la build frontend.
- Droits sudo disponibles pour le rechargement Nginx (demande mot de passe si nécessaire).
- Nginx configuré pour servir la distribution frontend et proxifier vers Uvicorn.

## Utilisation précise
```bash
chmod +x launch_test_prod.sh   # une seule fois
./launch_test_prod.sh         # lancer depuis la racine du projet