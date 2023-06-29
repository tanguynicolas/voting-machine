#!/bin/bash
#
# Dépouillement.

echo "######### Dépouillement #########" >> $LOCAL_DIR/$s_bureau_vote

### Préparation de la liste des votes
echo "Nettoyage de la liste des messages reçus" >> $LOCAL_DIR/$s_bureau_vote
while read line;do
    vote=$(echo $line | cut -d ';' -f 3)
    echo $vote >> $LOCAL_DIR/$db_liste_votes
done < $LOCAL_DIR/$db_liste_messages


echo "Mélange de la liste des votes" >> $LOCAL_DIR/$s_bureau_vote
# sort -R $db_liste_votes
sort -R $LOCAL_DIR/$db_liste_votes > sorted.tmp && mv sorted.tmp $LOCAL_DIR/$db_liste_votes


### Publication des clés des machines de vote
echo "Chaque machine de vote envoie sa clé secrète au bureau de vote en utilisant TLS" >> $LOCAL_DIR/$s_bureau_vote


### Compte des votes

cpt_Manuel_Macaron=0
cpt_Marie_Le_stylo=0
cpt_Jean_Roblochon=0
cpt_Filipe_Boubou=0

echo "Le bureau de vote déchiffre et comptabilise les votes" >> $LOCAL_DIR/$s_bureau_vote
while read line;do
    vote=$(echo $line | openssl base64 -d | openssl enc -aes-256-cbc -d -pass file:$LOCAL_DIR/$temp_dir/pki/bureau/aes_key.txt 2> /dev/null | cut -d ';' -f 1)

    if [ "$vote" == "01" ];then
        ((cpt_Manuel_Macaron=cpt_Manuel_Macaron+1))
    elif [ "$vote" == "02" ];then
        ((cpt_Marie_Le_stylo=cpt_Marie_Le_stylo+1))
    elif [ "$vote" == "03" ];then
        ((cpt_Jean_Roblochon=cpt_Jean_Roblochon+1))
    elif [ "$vote" == "04" ];then
        ((cpt_Filipe_Boubou=cpt_Filipe_Boubou+1))
    fi

done < $LOCAL_DIR/$db_liste_votes

echo "Publication des résultats"
echo "  Manuel Macaron : $cpt_Manuel_Macaron"
echo "  Marie Le stylo : $cpt_Marie_Le_stylo"
echo "  Jean Roblochon : $cpt_Jean_Roblochon"
echo "  Filipe Boubou  : $cpt_Filipe_Boubou"

echo -e "\nPublication de la liste des signatures"
while read line;do
    vote=$(echo $line | cut -d ';' -f 2)
    echo $vote >> $LOCAL_DIR/$db_liste_signatures
done < $LOCAL_DIR/$db_liste_messages
