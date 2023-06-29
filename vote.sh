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

if grep -E "^${choix};.*$" "$LOCAL_DIR/$db_liste_candidats" >/dev/null; then
    echo -e " ${aBlink}>${nBlink} ${cYellow} A voter ! ${nc}"
else
    echo -e " ${aBlink}>${nBlink} ${choix} ${cYellow}pas présent${nc} sur la liste des candidats."
    exit 0
fi


echo "######### Nouveau vote #########" >> "$LOCAL_DIR/$s_machine_vote"


### Signature
echo "------> Signature" >> "$LOCAL_DIR/$s_machine_vote"

signature=$(openssl dgst -sha256 -passin pass:azerty -sign $LOCAL_DIR/$temp_pki/votants/01_priv.key $LOCAL_DIR/init.sh | openssl base64 -e)
echo "Generation de la signature de cercle en utilisant les clés publique des autres membres" >> "$LOCAL_DIR/$s_machine_vote"
echo "Envoie de cette signature à la carte a puce pour signer avec la clé priver du votant" >> "$LOCAL_DIR/$s_machine_vote"
echo -e "La signature de votre vote est : \n$signature"

### Chiffrement du vote
echo "------> Chiffrement du vote" >> "$LOCAL_DIR/$s_machine_vote"

echo "Chiffrement du vote avec un sel et la clé publique du bureau de vote" >> "$LOCAL_DIR/$s_machine_vote"
sel=$(openssl rand -base64 10)
vote="${choix};${sel}"
vote=$(echo "$vote" | openssl enc -aes-256-cbc -pass file:$LOCAL_DIR/$temp_pki/machine/aes_key.txt 2> /dev/null | openssl base64 -e)
# echo "$vote" | openssl base64 -d | openssl enc -aes-256-cbc -d -pass file:temp/pki/machine/aes_key.txt 2> /dev/null

### Envoi du message
echo "------> Envoi du message" >> "$LOCAL_DIR/$s_machine_vote"
echo "Génération d'un identifiant pour le message" >> "$LOCAL_DIR/$s_machine_vote"

id_vote=$(( RANDOM % 1000 + 1 ))
message="${id_vote};${signature};${vote}"

#echo "DEBUUUUUUUUUUUUUUUG: $message"

#### SEND TLS
# Chiffrement
echo -n "$message" > "$LOCAL_DIR/$temp_connexion/message"
echo -n "04$message" > "$LOCAL_DIR/$temp_connexion/seq+message"
openssl sha256 -hmac "$(cat "$LOCAL_DIR/$temp_connexion/client-mackey.dat")" \
    "$LOCAL_DIR/$temp_connexion/seq+message" > "$LOCAL_DIR/$temp_connexion/HMAC_seq+message"

echo -n "$(cat "$LOCAL_DIR/$temp_connexion/message")$(cat "$LOCAL_DIR/$temp_connexion/HMAC_seq+message")" \
    | openssl aes-256-cbc -nosalt -iv "$(cat "$LOCAL_DIR/$temp_connexion/client-iv.dat")" \
    -K "$(cat "$LOCAL_DIR/$temp_connexion/client-key.dat")" > "$LOCAL_DIR/$temp_connexion/message-chif"

# Envoi
cat "$LOCAL_DIR/$temp_connexion/message-chif" >> "$LOCAL_DIR/$db_liste_messages"

# Déchiffrement
echo -n "$(cat "$LOCAL_DIR/$temp_connexion/message-chif")" | openssl aes-256-cbc -d -nosalt \
    -iv "$(cat "$LOCAL_DIR/$temp_connexion/client-iv.dat")" -K "$(cat "$LOCAL_DIR/$temp_connexion/client-key.dat")" \
    > "$LOCAL_DIR/$temp_connexion/message-dec"

# echo $signature | openssl base64 -d > signature.bin
# echo $message | cut -d ';' -f 2 | openssl base64 -d | openssl dgst -sha256 -passin pass:azerty -verify temp/pki/votants/01_pub.key -signature signature.bin init.sh
# echo $message | cut -d ';' -f 3 | openssl base64 -d | openssl enc -aes-256-cbc -d -pass file:temp/pki/machine/aes_key.txt 2> /dev/null

echo "Message envoyé au serveur du bureau de vote à l'aide de TLS" >> $s_machine_vote
