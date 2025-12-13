------------------------------------------------------------------------------
Nom du script       : launch_dev.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Ouvre deux terminaux graphiques séparés pour lancer en mode
                      développement le serveur backend FastAPI (api_dev.sh) et le
                      serveur frontend npm (npm_dev.sh).
------------------------------------------------------------------------------

## Objectif du script

Faciliter le développement en ouvrant automatiquement deux terminaux graphiques distincts : un pour le serveur backend FastAPI en mode rechargement automatique et un pour le serveur frontend npm dev.

## Ce que fait le script étape par étape

1. Récupère les chemins absolus du script courant et du dossier projet.
2. Vérifie la présence des scripts `api_dev.sh` et `npm_dev.sh`.
3. Détecte automatiquement le terminal graphique disponible (gnome-terminal, konsole, xfce4-terminal ou xterm).
4. Ouvre un nouveau terminal pour exécuter `api_dev.sh` (backend).
5. Ouvre un second terminal pour exécuter `npm_dev.sh` (frontend).
6. Affiche un message récapitulatif de succès avec les informations utiles.

## Liste des fonctions internes

| Fonction                | Rôle                                                                 |
|-------------------------|----------------------------------------------------------------------|
| info()                  | Affiche un message informatif avec préfixe [INFO]                    |
| success()               | Affiche un message de succès avec préfixe [OK]                       |
| error()                 | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|
| detect_terminal()       | Détecte et retourne la commande du terminal graphique disponible    |
| open_terminal_and_run() | Ouvre un nouveau terminal et exécute le script fourni                |

## Prérequis clairs

- Un terminal graphique supporté installé (gnome-terminal, konsole, xfce4-terminal ou xterm)
- Les scripts `api_dev.sh` et `npm_dev.sh` présents dans le dossier du projet
- Exécution depuis le dossier du projet (ou via lien symbolique)

## Utilisation précise

```bash
chmod +x launch_dev.sh
./launch_dev.sh