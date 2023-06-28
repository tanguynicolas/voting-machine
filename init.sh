#!/bin/bash
#Script qui initialise les cles des differentes parties

LOCAL_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)
source "$LOCAL_DIR/constants.sh"

#Creation de l'arborescence
#les votants
#machine de vote
#serveur bv et prefec
# certificats : prefec, racine, bureau, machine, 
mkdir -p "$LOCAL_DIR/$temp_dir/pki/etat" \
"$LOCAL_DIR/$temp_dir/pki/prefecture" \
"$LOCAL_DIR/$temp_dir/pki/bureau" \
"$LOCAL_DIR/$temp_dir/pki/votants" \
"$LOCAL_DIR/$temp_dir/pki/machine"


#Creation de l'autorite de certification (Etat)
openssl genrsa -aes256 -out "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -passout pass:azerty 4096
openssl rsa -in "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -passin pass:azerty -pubout > "$LOCAL_DIR/$temp_dir/pki/etat/CA_pub.key" > /dev/null 2>&1
openssl req -x509 -new -nodes -key "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -sha256 -days 7300 -out "$LOCAL_DIR/$temp_dir/pki/etat/CA.crt" -passin pass:azerty -subj "/C=FR/ST=France/L=Paris/CN=etat"
cd "$LOCAL_DIR/$temp_dir/pki/etat/"
echo 1000 > serial
touch index.txt

#On copie la config du CA
cp "$LOCAL_DIR/$config_dir/ca-config.cnf" "$LOCAL_DIR/$temp_dir/pki/etat/"

#Creation de l'autorite intermediaire (Prefecture)
openssl genrsa -aes256 -out "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm_priv.key" -passout pass:azerty 4096
openssl rsa -in "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm_priv.key" -passin pass:azerty -pubout > "$LOCAL_DIR/$temp_dir/pki/etat/CA_interm_pub.key" > /dev/null 2>&1
openssl req -in "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm_priv.key" -out "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.csr" -passin pass:azerty -subj "/C=FR/ST=France/L=Paris/CN=prefecture" -new -nodes > /dev/null 2>&1
openssl ca -config "$LOCAL_DIR/$temp_dir/pki/etat/ca-config.cnf" -extensions v3_intermediate_ca -cert "$LOCAL_DIR/$temp_dir/pki/etat/CA.crt" -keyfile "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -in "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.csr" -out "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.crt" -passin pass:azerty -batch > /dev/null 2>&1

#Generation des cles des votants
cd $LOCAL_DIR
while read line; do
    id="$(echo $line | cut -f1 -d ';')"
    openssl genrsa -aes256 -out "$LOCAL_DIR/$temp_dir/pki/votants/${id}_priv.key" -passout pass:azerty 2048
    openssl rsa -in "$LOCAL_DIR/$temp_dir/pki/votants/${id}_priv.key" -passin pass:azerty -pubout > "$LOCAL_DIR/$temp_dir/pki/votants/${id}_pub.key"
done < "$db_liste_electorale" > /dev/null 2>&1

#Generation des demandes de certificat des votants
