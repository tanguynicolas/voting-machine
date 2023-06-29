#!/bin/bash -eu
#
# Script principal.

LOCAL_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)
source "$LOCAL_DIR/constants.sh"

err() {
    echo "${cOrange}[${nc}$(date +'%Y-%m-%d')${cOrange}]${nc} ${cRed}ERR${nc}: $*" >&2
}

usage() {
    echo -e "\n${cGreen}Use${nc}: ./$(basename "$0")\n"
    echo -e "${cGreen}Type${nc}:\n   -h to display this help\n"
}

### Gestion des paramètres

# Si au moins un argument obligatoire
#[[ $# -lt 1 ]] && err 'Missing arguments, type -h' && exit 1

options=$(getopt -a -o h -l help -- "$@") || usage

eval set -- "$options" # eval for remove simple quote

while true; do
    case "$1" in
        -h|--help)
            usage; exit 0;;
        --)
            shift; break;;
        *)
            err "Unexpected option: '$1' - pas d'argument attendu ici.";
    esac 
done


### Coeur du script

echo -e "\n${cYellow}Nettoyage${nc} des fichiers de logs et du répertoire temporaire 🧹"
truncate --size 0 "$LOCAL_DIR/"{"$s_prefecture","$s_bureau_vote","$s_machine_vote","$db_liste_votes"}
rm -rf "$LOCAL_DIR"/"$temp_dir"/*

echo -e "\n${cBlue}Initialisation${nc} des prérequis cryptographiques, veuillez patienter..."
source "$LOCAL_DIR/init.sh"

echo -e "\n${cCyan}${aBold}Affectation${nc} de l'utilisateur à la machine 🪪"
source "$LOCAL_DIR/affectation.sh"

# echo -e "\n${cCyan}${aBold}Connexion${nc} de l'utilisateur 🔒"
# source "$LOCAL_DIR/connexion.sh"

# echo -e "\n${cCyan}${aBold}Vote${nc} de l'utilisateur 🗳️"
# source "$LOCAL_DIR/vote.sh"

echo -e "\n${cCyan}${aBold}Dépouillement${nc} du scrutin 📺"
source "$LOCAL_DIR/depouillement.sh"
