#!/bin/bash
#
# Vote.


echo -e "Liste des candidats : "
while read line;do
    num=$(echo "$line" | cut -d ';' -f 1)
    nom=$(echo "$line" | cut -d ';' -f 3)
    pre=$(echo "$line" | cut -d ';' -f 2)
    echo -e "  [$num] $pre $nom "
done < $LOCAL_DIR/$db_liste_candidats

echo
read -rp "Choix : " choix

echo -e " ${aBlink}>${nBlink} ${cYellow} A voter ! ${nc}"

echo "######### Nouveau vote #########" >> "$s_machine_vote"

### Chiffrement du vote
echo "------> Chiffrement du vote" >> "$s_machine_vote"

echo "Chiffrement du vote avec un sel et la clé publique du bureau de vote" >> "$s_machine_vote"
sel=$(openssl rand -base64 10)
vote_base="${choix};${sel}"
vote=$(echo "$vote_base" | openssl enc -aes-256-cbc -pass file:temp/pki/machine/aes_key.txt 2> /dev/null | openssl base64 -e)
# echo "$vote" | openssl base64 -d | openssl enc -aes-256-cbc -d -pass file:temp/pki/machine/aes_key.txt 2> /dev/null

### Signature
echo "------> Signature" >> "$s_machine_vote"
signature=$(echo "$vote_base" | openssl dgst -sha256 -passin pass:azerty -sign temp/pki/votants/01_priv.key | openssl base64 -e)
echo "Generation de la signature de cercle en utilisant les clés publique des autres membres" >> "$s_machine_vote"
echo "Envoie de cette signature à la carte a puce pour signer avec la clé priver du votant" >> "$s_machine_vote"
echo -e "La signature de votre vote est : \n$signature"

### Envoi du message
echo "------> Envoi du message" >> "$s_machine_vote"
echo "Génération d'un identifiant pour le message" >> "$s_machine_vote"

id_vote=$(( RANDOM % 1000 + 1 ))
message="${id_vote};${signature};${vote}"

#### TLS ####
echo $message >> "$db_liste_messages"
#### FIN TLS ####



# echo $signature | openssl base64 -d > signature.bin
# echo $message | cut -d ';' -f 2 | openssl base64 -d | openssl dgst -sha256 -passin pass:azerty -verify temp/pki/votants/01_pub.key -signature signature.bin init.sh
# echo $message | cut -d ';' -f 3 | openssl base64 -d | openssl enc -aes-256-cbc -d -pass file:temp/pki/machine/aes_key.txt 2> /dev/null

echo "Message envoyé au serveur du bureau de vote à l'aide de TLS" >> $s_machine_vote