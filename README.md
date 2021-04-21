# GameShell : un "jeu" pour apprendre le shell


GameShell (gash) est le résultat d'une réflexion sur comment enseigner les
rudiments (et un peu plus) du shell à des étudiants en première année à
l'université Savoie Mont Blanc.

L'idée initiale, due à Rodolphe Lepigre, était de lancer un shell bash avec un
fichier de configuration qui permettait d'effectuer des "missions", qui
seraient "validées" pour avancer.

N'hésitez pas à m'envoyer vos remarques, questions ou suggestions autour de
GameShell. En particulier, je suis preneur de nouvelles missions !


GameShell est soumis à la licence GPLv3 https://www.gnu.org/licenses/gpl-3.0.en.html

### Prérequis

GameShell devrait (??) fonctionner sur un système Linux standard. Pour
Debian/Ubuntu, il faut avoir les paquets suivants :

```
sudo apt install  psmisc nano tree x11 bsdmainutils  python3
```


Pour macOS, il faut installer ``coreutils`` et ``md5sha1sum``. Le plus simple
est d'utiliser le gestionnaire de paquets [homebrew](https://brew.sh/index_fr) :

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

puis d'installer les paquets nécessaires avec

    $ brew install coreutils
    $ brew install md5sha1sum


### contact

Pierre Hyvernat

http://www.lama.univ-smb.fr/~hyvernat

pierre.hyvernat@univ-smb.fr



Utilisation
-----------

Après avoir cloné le dépot :

    $ git clone https://github.com/epsi-poec-2021/GameShell.git
    $ ./GameShell/start.sh -F
    ...
    ...


Commandes de base
-----------------

GameShell est simplement une instance de bash avec des fonctions
supplémentaires. Ces fonctionnalités passent par la commande ``gash``.

  - `gash help` : affiche une petite liste des commandes
  - `gash HELP` : affiche une liste plus complète des commandes
  - `gash show` : affiche l'objectif de la mission courante
  - `gash check` : vérifie si la mission actuelle est validée
  - `gash reset` : recommence la mission courante



Ajout de mission
----------------

Chaque mission est contenue dans un répertoire dédié et peut fournir les
fichiers suivants

  - `bashrc`
        fichier ajouté à la configuration globale de la session utilisé pour
        la partie
        Ce fichier peut contenir des variables, aliases, etc. qui seront
        disponibles pendant toute la partie.
        (fichier bash, facultatif)

  - `static.sh`
        fichier lu par bash __au lancement de GameShell__. C'est par exemple
        dans ce fichier que l'on peut créer des répertoires qui existeront pour
        toutes les missions.
        Remarque : ce fichier est lu par bash (``source static.sh``) et peut
        donc par exemple définir des variables d'environnement.

  - `bin`
        répertoire contenant des exécutables utilisés pendant la partie
        Les fichiers contenus dans ce répertoire sont recopiés dans un
        répertoire caché `$GASH_HOME/.bin`, qui est ajouté au `PATH` global.
        (répertoire, facultatif)

  - `deps.sh`
        pour vérifier si le système contient les dépendances de la mission Il
        doit renvoyer `0` si les dépendances sont satisfaites, et une valeur
        non nulle sinon.
        Remarque : ce fichier est lancé au début de la mission, et en cas de
        dépendance non satisfaite, la mission est annulée.
        (fichier bash, facultatif)

  - `init.sh`
        fichier lu par bash __au lancement de la mission__. C'est par exemple
        dans ce fichier qu'on peut (re)générer des parties dynamiques de la
        mission.
        Remarque : ce fichier est lu (`source init.sh`) et peut donc
        créer des variables d'environnement.
        (fichier bash, facultatif)

  - `goal.txt`
        petite description de la mission, affichée par ``gash show``
        (fichier texte, obligatoire)

  - `check.sh`
        fichier lu par bash pour vérifier que la mission est validée.
        Remarque : ce fichier est lu par bash (``source check.sh``) et __doit
        se terminer__ par une commande renvoyant la valeur 0 (typiquement,
        ``true``) en cas de succès, et par une commande renvoyant une valeur
        différente de 0 (typiquement ``false``) en cas d'échec.
        (fichier bash, obligatoire)

  - `treasure.sh`
        fichier bash lu par bash après validation de la mission. Cela permet
        d'ajouter des fonctionnalités comme "récompense" à certaines missions.
        (fichier bash, facultatif)

  - `treasure.txt`
        fichier texte affiché par bash après validation de la mission
        (fichier texte, facultatif)

  - `auto.sh`
        fichier lu par bash pour valider automatiquement la mission
        Remarque : ce fichier est lu par bash (``source auto.sh``).
        (fichier bash, facultatif)



Contributeurs missions
----------------------

* Pierre Hyvernat
* Rodolphe Lepigre
* Christophe Raffalli
* Xavier Provencal
* Clovis Eberhart
* Sébastien Tavenas
* Tiemen Duvillard


Licence
-------

Ce code est distribué sous licence GPL.

Merci de pointer vers ce dépôt si vous l'utilisez.
