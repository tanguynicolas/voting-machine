#!/bin/bash
#
# Vote.


echo -e "Liste des candidats : "
while read line;do
    num=$(echo $line | cut -d ';' -f 1)
    nom=$(echo $line | cut -d ';' -f 3)
    pre=$(echo $line | cut -d ';' -f 2)
    echo -e "  [$num] $pre $nom "
done < $LOCAL_DIR/$db_liste_candidats

echo
read -rp "Choix : " choix

if grep -E "^${choix};.*$" "$LOCAL_DIR/$db_liste_candidats" >/dev/null; then
    echo -e " ${aBlink}>${nBlink} ${cYellow} A voter ! ${nc}"
else
    echo -e " ${aBlink}>${nBlink} ${choix} ${cYellow}pas présent${nc} sur la liste des candidats."
    exit 0
fi

### Signature en cercle 
echo "------ Début signature de cercle ------" >> $s_machine_vote
signature=$(openssl rand -base64 10)

echo "Generation de la signature de cercle en utilisant les clés publique des autres membres" >> $s_machine_vote
echo "Envoie de cette signature à la carte a puce pour signer avec la clé priver du votant" >> $s_machine_vote
echo "------ Fin signature de cercle ------" >> $s_machine_vote

### Chiffrement du vote
echo "------ Début chiffrement du vote ------" >> $s_machine_vote
echo "Chiffrement du vote avec un sel et la clé publique du bureau de vote" >> $s_machine_vote
echo "Re chiffrement du vote avec la clé publique de la préfecture" >> $s_machine_vote

#openssl rsautl -encrypt -inkey tmp2/serveur_RSA-pub.key -pubin -in tmp2/pms.dat -out tmp2/pms-chif.dat
#openssl rsautl -decrypt -inkey local/serveur_RSA.key -in tmp2/pms-chif.dat -out tmp2/pms-dec.dat

vote="le vote"
echo "------ Fin chiffrement du vote ------" >> $s_machine_vote

### Envoi du message
echo "------ Début envoi du message ------" >> $s_machine_vote
echo "Génération d'un identifiant pour le message" >> $s_machine_vote

id_vote=$(( RANDOM % 100 + 1 ))
message="${id_vote};${signature};${vote}"

echo "Envoie du message au serveur du bureau de vote à l'aide de TLS" >> $s_machine_vote
# id_vote+signature+EncKP(EncKBV(vote+aléa))
echo "------ Fin envoi du message ------" >> $s_machine_vote