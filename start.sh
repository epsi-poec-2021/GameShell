#!/bin/bash


export GASH_BASE="$(dirname "$0")"
# shellcheck source=./lib/os_aliases.sh
source "$GASH_BASE"/lib/os_aliases.sh

export GASH_BASE=$(CANONICAL_PATH "$(dirname "$0")"/)
cd "$GASH_BASE"

source lib/utils.sh


display_help() {
cat <<EOH
options :
  -h      ce message
  -n      mode noir et blanc : n'utilise pas les séquences ANSI pour la couleur
  -P      passeport étudiant : demande les noms / email des étudiants
  -D <n>  mode debug / découverte en partant de la mission <n>
  -C      continue la partie en cours
  -R      rénitialise la partie en cours
  -F      force exécution dans le répertoire de développement
EOH
}


export GASH_COLOR="OK"
export GASH_DEBUG_MISSION=""
MODE="DEBUG"
RESET=""
FORCE="FALSE"
while getopts ":hcnPD:CRF" opt
do
  case $opt in
    h)
      display_help
      exit 0
      ;;
    n)
      GASH_COLOR=""
      ;;
    c)
      GASH_COLOR="OK"
      ;;
    P)
      MODE="PASSPORT"
      ;;
    D)
      MODE="DEBUG"
      GASH_DEBUG_MISSION=$OPTARG
      ;;
    C)
      RESET="FALSE"
      ;;
    R)
      RESET="TRUE"
      ;;
    F)
      FORCE="TRUE"
      ;;
    *)
      echo "option invalide : '-$OPTARG'" >&2
      exit 1
      ;;
  esac
done


local_passport() {
  local PASSPORT=$1
  local NB
  while true
  do
    read -erp "Combien de membres dans le groupe ? (1) " NB
    case "$NB" in
      "" )          NB=1; break             ;;
      *[!0-9]* )    echo "nombre invalide"  ;;
      *[1-9]*)      break                   ;;
      *)            echo "nombre invalide"  ;;
    esac
  done
  for I in $(seq "$NB"); do
    NOM=""
    while [ -z "$NOM" ]
    do
      read -erp "Membre $I, nom complet : " NOM
    done
    EMAIL=""
    while [ -z "$EMAIL" ]
    do
      read -erp "Membre $I, email : " EMAIL
    done
    echo "  $NOM <$EMAIL>" >> "$PASSPORT"
  done
}

confirm_passport() {
  local PASSPORT=$1
  echo "======================================================="
  cat "$PASSPORT"
  echo "======================================================="
  color_echo yellow "Les informations données ici ne pourront plus être modifiées."
  read -erp "Ces informations sont elles correctes ? (O / n) " OK
  echo
  [ "$OK" = "" ] || [ "$OK" = "o" ] || [ "$OK" = "O" ]
}


init_gash() {
  # dossiers d'installation

  # ces répertoires ne doivent pas être modifiés (statiques)
  export GASH_LIB="$GASH_BASE/lib"
  export GASH_MISSIONS="$GASH_BASE/missions"
  export GASH_BIN="$GASH_BASE/bin"

  # ces répertoires doivent être effacés en cas de réinitialisation du jeu
  export GASH_HOME="$GASH_BASE/World"
  export GASH_DATA="$GASH_BASE/.session_data"
  export GASH_TMP="$GASH_BASE/.tmp"
  export GASH_CONFIG="$GASH_BASE/.config"
  export GASH_LOCAL_BIN="$GASH_BASE/.bin"

  if [ -e "$GASH_BASE/.git" ] && [ "$FORCE" != "TRUE" ]
  then
    echo "Vous êtes en train d'exécuter GameShell dans l'arborescence de développement."
    read -erp "Faut-il continuer ? [o/N] " x
    [ "$x" != "o" ] && [ "$x" != "O" ] && exit 1
  fi

  if [ -e "$GASH_DATA" ]
  then
    if [ -z "$RESET" ]
    then
      read -erp "'$GASH_DATA' existe déjà... Faut-il le conserver ? [O/n] " x
      if [ "$x" = "o" ] || [ "$x" = "O" ] || [ "$x" = "" ]
      then
        return 1
      fi
    elif [ "$RESET" = "FALSE" ]
    then
      return 1
    fi
  fi


  rm -rf "$GASH_HOME"
  rm -rf "$GASH_DATA"
  rm -rf "$GASH_TMP"
  rm -rf "$GASH_CONFIG"
  rm -rf "$GASH_LOCAL_BIN"

  mkdir -p "$GASH_HOME"

  mkdir -p "$GASH_DATA"
  echo "# mission action date checksum" >> "$GASH_DATA/missions.log"

  mkdir -p "$GASH_CONFIG"
  cp "$GASH_LIB/bashrc" "$GASH_CONFIG"

  mkdir -p "$GASH_LOCAL_BIN"

  mkdir -p "$GASH_TMP"


  # Configuration pour la génération de la fiche étudiant.
  PASSPORT="$GASH_DATA/passport.txt"

  while true
  do
    # Lecture du login des étudiants.
    case "$MODE" in
      DEBUG)
        echo "MODE DÉCOUVERTE (DEBUG)" >> "$PASSPORT"
        break
        ;;
      PASSPORT)
        local_passport "$PASSPORT"
        ;;
      *)
        echo "mode de lancement inconnu: '$MODE'" >&2
        ;;
    esac

    # Confirmation des informations
    if confirm_passport "$PASSPORT"
    then
      break
    else
      rm -f "$PASSPORT"
      color_echo yellow "Recommencez du début, sans vous tromper."
      echo
      fi
    done


  # Génération de l'UID du groupe.
  export GASH_UID="$(sha1sum "$PASSPORT" | cut -c 1-40)"
  echo "GASH_UID=$GASH_UID" >> "$PASSPORT"
  echo "$GASH_UID" > "$GASH_DATA/uid"


  # Message d'accueil.
  clear
  echo "======== Initialisation de GameShell ========"


  # Installation des missions.
  for MISSION_DIR in "$GASH_BASE"/missions/[0-9]*; do
    export MISSION_DIR
    if [ -f "$MISSION_DIR/static.sh" ]
    then
      # shellcheck source=/dev/null
      source "$MISSION_DIR/static.sh"
    fi
    if [ -f "$MISSION_DIR/bashrc" ]
    then
      cp "$MISSION_DIR/bashrc" "$GASH_CONFIG/$(basename "$MISSION_DIR" /)-bashrc.sh"
    fi
    if [ -d "$MISSION_DIR/bin" ]
    then
      cp "$MISSION_DIR/bin/"* "$GASH_LOCAL_BIN"
    fi
    printf "."
  done
  echo
  unset MISSION_DIR
}


start_gash() {
  # Lancement du jeu.
  cd "$GASH_HOME"
  export GASH_UID=$(cat "$GASH_DATA/uid")
  bash --rcfile "$GASH_LIB/bashrc"
}


#######################################################################
init_gash
start_gash

# vim: shiftwidth=2 tabstop=2 softtabstop=2
