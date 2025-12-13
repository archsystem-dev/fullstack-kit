------------------------------------------------------------------------------
Nom du script       : nginx_reload.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Copie la configuration nginx.conf du projet vers le site
                      default, valide la syntaxe, active le lien symbolique si
                      nécessaire et recharge proprement le service Nginx.
------------------------------------------------------------------------------

## Objectif du script

Appliquer la configuration Nginx spécifique au projet en copiant nginx.conf vers le site par défaut, en validant la syntaxe et en rechargeant le service sans interruption prolongée.

## Ce que fait le script étape par étape

1. Vérifie l'exécution avec sudo.
2. Récupère les chemins absolus du script et du fichier nginx.conf du projet.
3. Vérifie l'existence du fichier nginx.conf source.
4. Arrête temporairement Nginx pour éviter les conflits.
5. Copie la configuration du projet vers `/etc/nginx/sites-available/default`.
6. Crée le lien symbolique vers `/etc/nginx/sites-enabled/default` si absent.
7. Teste la syntaxe de la configuration avec `nginx -t`.
8. Recharge (ou démarre) le service Nginx.
9. Affiche un récapitulatif final de succès.

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|

## Prérequis clairs

- Exécution avec `sudo`
- Fichier `nginx.conf` présent dans le dossier du projet
- Nginx installé et configuré sur le système (Ubuntu/Debian)
- Structure standard `/etc/nginx/sites-available` et `/etc/nginx/sites-enabled`

## Utilisation précise

```bash
sudo chmod +x nginx_reload.sh
sudo ./nginx_reload.sh