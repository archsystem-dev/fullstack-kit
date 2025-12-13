------------------------------------------------------------------------------
Nom du script       : install_softwares.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Installe et configure Miniconda, PostgreSQL, Redis, Nginx,
                      Node.js/npm avec les paramètres définis dans install_softwares.ini,
                      nettoie les installations précédentes et prépare l'environnement
                      pour les projets full-stack.
------------------------------------------------------------------------------

## Objectif du script

Préparer un serveur Ubuntu/Debian propre en installant et configurant tous les logiciels nécessaires (Miniconda, PostgreSQL, Redis, Nginx, Node.js/npm) pour le développement de projets full-stack FastAPI + Vue.js.

## Ce que fait le script étape par étape

1. Vérifie l'exécution avec sudo et récupère l'utilisateur réel.
2. Installe crudini si nécessaire.
3. Lit tous les paramètres depuis `install_softwares.ini`.
4. Nettoie les installations précédentes (services, paquets, dossiers, blocs .bashrc).
5. Met à jour le système.
6. Installe et configure PostgreSQL (utilisateur, base, écoute locale).
7. Installe Miniconda pour l'utilisateur réel et ajoute l'initialisation au .bashrc.
8. Installe et configure Redis (port, mot de passe, ACL).
9. Installe et configure Nginx (site simple, port personnalisé).
10. Installe Node.js (version spécifiée via n) et configure le prefix npm global.
11. Crée le répertoire des projets avec les bons droits.
12. Affiche un récapitulatif avec tests rapides (Nginx, Redis, PostgreSQL).

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|
| get_config_value()  | Lit une valeur dans install_softwares.ini et remplace $USER          |
| add_block()         | Ajoute un bloc délimité dans le .bashrc de l'utilisateur réel        |

## Prérequis clairs

- Système Ubuntu/Debian récent
- Exécution avec `sudo`
- Accès internet (pour apt, wget)
- Fichier `install_softwares.ini` présent dans le même répertoire avec toutes les sections et clés requises

## Utilisation précise

```bash
sudo chmod +x install_softwares.sh
sudo ./install_softwares.sh