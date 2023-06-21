#!/bin/bash
#
# Affectation.

nombre_isoloirs=5

echo "Vérification de la carte d'identité."
read -rp "Prénom : " prenom
read -rp "Nom : " nom

if grep -E "^[0-9]+;${prenom};${nom}$" "$LOCAL_DIR/$db_identities" >/dev/null; then
    echo -e " > ${aBlink}${prenom} ${nom} dans l'${cYellow}isoloir n°$(( RANDOM % nombre_isoloirs + 1 ))${nfc}${nc}"
else
    echo -e "> ${aBlink}${prenom} ${nom} ${cYellow}pas inscrit${nfc} sur la liste de ce bureau de vote${nc}"
    exit 0
fi
