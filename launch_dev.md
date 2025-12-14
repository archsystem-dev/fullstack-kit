# launch_dev.sh

## Objectif du script
Ouvre deux terminaux graphiques séparés pour lancer en mode développement le serveur backend FastAPI (via api_dev.sh) et le serveur frontend npm (via npm_dev.sh).

## Ce que fait le script étape par étape
1. Vérifie qu'il n'est pas exécuté en root (opérations en utilisateur standard).
2. Définit les fonctions d'affichage standardisées info, success et error.
3. Définit la fonction open_terminal_and_run pour ouvrir un terminal adapté au desktop.
4. Détermine les chemins absolus des scripts api_dev.sh et npm_dev.sh.
5. Vérifie la présence des deux scripts requis.
6. Lance les deux scripts dans des terminaux séparés en arrière-plan.
7. Affiche un récapitulatif final indiquant que l'environnement de développement est prêt.

## Liste des fonctions internes

| Fonction               | Rôle                                                                 |
|------------------------|----------------------------------------------------------------------|
| `info`                 | Affiche un message informatif précédé de [INFO]                      |
| `success`              | Affiche un message de succès précédé de [OK]                         |
| `error`                | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |
| `open_terminal_and_run`| Ouvre un terminal graphique adapté et exécute le script passé       |

## Prérequis clairs
- Exécution en utilisateur standard (pas de sudo/root).
- Un terminal graphique installé : konsole (préféré), gnome-terminal, xfce4-terminal ou xterm.
- Scripts api_dev.sh et npm_dev.sh présents dans le même répertoire que launch_dev.sh.
- Environnement X11/Wayland fonctionnel avec support des terminaux graphiques.

## Utilisation précise
```bash
chmod +x launch_dev.sh   # une seule fois
./launch_dev.sh          # lancer depuis la racine du projet