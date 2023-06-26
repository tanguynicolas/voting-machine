#!/bin/bash
#
# Dépouillement.


### Suppresion de l'id de vote et de la signature

echo "Nettoyage de la liste des messages reçus" >> $s_bureau_vote

while read line;do
    vote=$(echo $line | cut -d ';' -f 3)
    echo $vote >> $db_liste_votes
done < $db_liste_messages

echo "Mélange de la liste des votes" >> $s_bureau_vote

sort -R $db_liste_votes

echo "La préfecture donne sa clé privée au bureau de vote" >> $s_bureau_vote
echo "Le bureau de vote donne sa clé privé à la préfecture" >> $s_bureau_vote

echo "Le bureau de vote déchiffre et comptabilise les votes" >> $s_bureau_vote
while read line;do
    # openssl rsautl -decrypt -inkey local/serveur_RSA.key -in tmp2/pms-chif.dat -out tmp2/pms-dec.dat
    # openssl rsautl -decrypt -inkey local/serveur_RSA.key -in tmp2/pms-chif.dat -out tmp2/pms-dec.dat
done < $db_liste_votes

echo "La préfecture déchiffre et comptabilise les votes" >> $s_bureau_vote
while read line;do
    # openssl rsautl -decrypt -inkey local/serveur_RSA.key -in tmp2/pms-chif.dat -out tmp2/pms-dec.dat
    # openssl rsautl -decrypt -inkey local/serveur_RSA.key -in tmp2/pms-chif.dat -out tmp2/pms-dec.dat
done < $db_liste_votes

echo "Publication des résultats"
