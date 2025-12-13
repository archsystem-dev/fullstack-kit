------------------------------------------------------------------------------
Nom du script       : npm_dist_generate.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Génère la distribution de production du frontend via npm
                      run build, corrige les permissions du dossier dist et
                      autorise www-data (Nginx) à lire les fichiers statiques.
------------------------------------------------------------------------------

## Objectif du script

Générer les fichiers statiques de production du frontend (npm run build) et préparer le dossier dist pour être servi par Nginx en ajustant les permissions.

## Ce que fait le script étape par étape

1. Vérifie que le script n'est pas exécuté en root/sudo.
2. Récupère les chemins absolus du projet et du dossier frontend.
3. Passe dans le dossier frontend et exécute npm run build.
4. Ajoute l'utilisateur www-data au groupe de l'utilisateur réel (pour lecture).
5. Applique les permissions 755 récursives sur le dossier dist.
6. Affiche un récapitulatif final de succès.

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|

## Prérequis clairs

- Exécution en utilisateur standard (pas sudo/root)
- Dossier frontend/ présent avec package.json valide
- Script "build" défini dans package.json (ex: Vite, Vue CLI, etc.)
- Dépendances npm déjà installées
- Privilèges sudo disponibles pour ajuster les permissions/groups

## Utilisation précise

```bash
chmod +x npm_dist_generate.sh
./npm_dist_generate.sh