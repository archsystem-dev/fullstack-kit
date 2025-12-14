# nginx_reload.sh
___

## Objectif du script
Copie la configuration nginx.conf du projet vers le site default, valide la syntaxe, active le lien symbolique si nécessaire et recharge proprement le service Nginx.

## Ce que fait le script étape par étape
1. Vérifie l'exécution avec privilèges root (sudo requis).
2. Définit les chemins absolus vers la configuration projet et les répertoires système Nginx.
3. Vérifie la présence du fichier nginx.conf dans le répertoire projet.
4. Arrête temporairement Nginx pour éviter les conflits pendant la copie.
5. Copie la configuration projet vers /etc/nginx/sites-available/default.
6. Crée le lien symbolique vers sites-enabled si absent.
7. Teste la syntaxe de la nouvelle configuration (annule si erreur).
8. Recharge Nginx (reload) ou démarre si arrêté.
9. Affiche un récapitulatif final confirmant l'application de la configuration.

## Liste des fonctions internes

| Fonction  | Rôle                                                                 |
|-----------|----------------------------------------------------------------------|
| `info`    | Affiche un message informatif précédé de [INFO]                      |
| `success` | Affiche un message de succès précédé de [OK]                         |
| `error`   | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |

## Prérequis clairs
- Exécution avec `sudo` (obligatoire pour modifications dans /etc/nginx).
- Fichier `nginx.conf` présent dans le répertoire du projet (racine).
- Nginx installé et configuré sur le système.
- Répertoires standards /etc/nginx/sites-available et sites-enabled existants.

## Utilisation précise
```bash
chmod +x nginx_reload.sh   # une seule fois
sudo ./nginx_reload.sh     # obligatoire : exécuter avec sudo