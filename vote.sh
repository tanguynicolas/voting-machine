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

echo "######### Nouveau vote #########" >> $LOCAL_DIR/$s_machine_vote

### Chiffrement du vote
echo "------> Chiffrement du vote" >> $LOCAL_DIR/$s_machine_vote

echo "Chiffrement du vote avec un sel et la clé publique du bureau de vote" >> "$LOCAL_DIR"/"$s_machine_vote"
sel=$(openssl rand -base64 10)
vote_base="${choix};${sel}"
vote=$(echo "$vote_base" | openssl enc -aes-256-cbc -pass file:$LOCAL_DIR/$temp_dir/pki/machine/aes_key.txt 2> /dev/null | openssl base64 -e)

### Signature
echo "------> Signature" >> "$LOCAL_DIR"/"$s_machine_vote"
signature=$(echo "$vote_base" | openssl dgst -sha256 -passin pass:azerty -sign $LOCAL_DIR/$temp_dir/pki/votants/01_priv.key | openssl base64 -e)
echo "Generation de la signature de cercle en utilisant les clés publique des autres membres" >> "$LOCAL_DIR"/"$s_machine_vote"
echo "Envoie de cette signature à la carte a puce pour signer avec la clé priver du votant" >> "$LOCAL_DIR"/"$s_machine_vote"
echo -e "La signature de votre vote est : \n$signature"

### Envoi du message
echo "------> Envoi du message" >> "$LOCAL_DIR"/"$s_machine_vote"
echo "Génération d'un identifiant pour le message" >> "$LOCAL_DIR"/"$s_machine_vote"


id_vote=$(( RANDOM % 1000 + 1 ))
message="${id_vote};${signature};${vote}"


echo "Message envoyé au serveur du bureau de vote à l'aide de TLS" >> $LOCAL_DIR/$s_machine_vote

# Chiffrement
echo -n "$message" > "$LOCAL_DIR/$temp_connexion/message"
#echo -n "04$message" > "$LOCAL_DIR/$temp_connexion/seq+message"
#openssl sha256 -hmac "$(cat "$LOCAL_DIR/$temp_connexion/client-mackey.dat")" \
#    "$LOCAL_DIR/$temp_connexion/seq+message" > "$LOCAL_DIR/$temp_connexion/HMAC_seq+message"
#
#echo -n "$(cat "$LOCAL_DIR/$temp_connexion/message")$(cat "$LOCAL_DIR/$temp_connexion/HMAC_seq+message")" \
#    | openssl aes-256-cbc -nosalt -iv "$(cat "$LOCAL_DIR/$temp_connexion/client-iv.dat")" \
#    -K "$(cat "$LOCAL_DIR/$temp_connexion/client-key.dat")" > "$LOCAL_DIR/$temp_connexion/message-chif"

# Envoi
echo $message >> "$LOCAL_DIR"/"$db_liste_messages"

# Déchiffrement
#echo -n "$(cat "$LOCAL_DIR/$temp_connexion/message-chif")" | openssl aes-256-cbc -d -nosalt \
#    -iv "$(cat "$LOCAL_DIR/$temp_connexion/client-iv.dat")" -K "$(cat "$LOCAL_DIR/$temp_connexion/client-key.dat")" \
#    > "$LOCAL_DIR/$temp_connexion/message-dec"

echo "Message envoyé au serveur du bureau de vote à l'aide de TLS" >> $LOCAL_DIR/$s_machine_vote
