#!/bin/bash
#
# Script principal.

LOCAL_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)
source "$LOCAL_DIR/constants.sh"

err() {
    echo "[$(date +'%Y-%m-%d')]: $*" >&2
}

usage() {
    echo -e "\nUse: ./$(basename "$0")\n"
    echo -e "Type:\n   -h to display this help\n"
}

### Gestion des paramètres

# Si au moins un argument obligatoire
#[[ $# -lt 1 ]] && err 'Missing arguments, type -h' && exit 1

options=$(getopt -a -o h -l help -- "$@") || usage

eval set -- "$options" # eval for remove simple quote

while true; do
    case "$1" in
        -h|--help)
            usage
	        shift;;
        --)
            shift; break;;
        *)
            err "Unexpected option: '$1' - pas d'argument attendu ici.";
    esac 
done


### Coeur du script

echo -e "This is... not colored."
echo -e "${cGreen}This is... colored${nc}."
echo -e "${cBlue}This is... colored${nc}."
echo -e "${cCyan}This is... colored${nc}."
echo -e "${cYellow}This is... colored${nc}."
echo -e "${cOrange}This is... colored${nc}."
echo -e "${cRed}This is... colored${nc}."
