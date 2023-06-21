#!/bin/bash
#
# Affectation d'un isoloir à un utilisateur si il est bien inscrit sur la liste électorale.

nombre_isoloirs=5

echo "Vérification de la carte d'identité."
read -rp "Prénom : " prenom
read -rp "Nom : " nom

if grep -E "^[0-9]+;${prenom};${nom}$" "$LOCAL_DIR/$db_liste_electorale" >/dev/null; then
    echo -e " ${aBlink}>${nBlink} ${prenom} ${nom} dans l'${cYellow}isoloir n°$(( RANDOM % nombre_isoloirs + 1 ))${nc}."
else
    echo -e " ${aBlink}>${nBlink} ${prenom} ${nom} ${cYellow}pas inscrit${nc} sur la liste de ce bureau de vote."
    exit 0
fi
