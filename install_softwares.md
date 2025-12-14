# install_softwares.sh
___

## Objectif du script
Installe et configure Miniconda, PostgreSQL, Redis, Nginx, Node.js/npm avec les paramètres définis dans install_softwares.ini, nettoie les installations précédentes et prépare l'environnement pour les projets full-stack.

## Ce que fait le script étape par étape
1. Vérifie l'exécution avec sudo et récupère l'utilisateur réel.
2. Lit la configuration globale depuis `install_softwares.ini`.
3. Installe crudini si nécessaire.
4. Nettoie les installations précédentes (services, paquets, répertoires, blocs .bashrc).
5. Met à jour le système.
6. Installe et configure PostgreSQL (utilisateur système, rôle, base, authentification).
7. Installe Miniconda et ajoute l'initialisation au .bashrc.
8. Installe et configure Redis (mot de passe, port, ACL).
9. Installe et configure Nginx (site test, désactivation version).
10. Installe Node.js via n et configure le prefix npm global.
11. Crée le répertoire des projets avec bons droits.
12. Affiche un récapitulatif final avec tests rapides des services.

## Liste des fonctions internes

| Fonction         | Rôle                                                                 |
|------------------|----------------------------------------------------------------------|
| `info`           | Affiche un message informatif précédé de [INFO]                      |
| `success`        | Affiche un message de succès précédé de [OK]                         |
| `error`          | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |
| `get_config_value`| Lit une valeur dans install_softwares.ini et substitue $USER         |
| `add_block`      | Ajoute un bloc délimité dans .bashrc si absent                       |

## Prérequis clairs
- Système Debian/Ubuntu (utilisation de apt).
- Exécution avec `sudo` (obligatoire pour installations système).
- Fichier `install_softwares.ini` présent dans le même répertoire que le script.
- Accès internet pour téléchargements (Miniconda, mises à jour).
- Machine x86_64 Linux.

## Utilisation précise
```bash
chmod +x install_softwares.sh   # une seule fois
sudo ./install_softwares.sh     # obligatoire : exécuter avec sudo