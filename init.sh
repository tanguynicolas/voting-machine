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
openssl genrsa -aes256 -out "$LOCAL_DIR/$temp_dir/pki/etat/CA.key" -passout pass:azerty 4096
openssl req -x509 -new -nodes -key "$LOCAL_DIR/$temp_dir/pki/etat/CA.key" -sha256 -days 7300 -out "$LOCAL_DIR/$temp_dir/pki/etat/CA.crt" -passin pass:azerty -subj "/C=FR/ST=France/L=Paris/CN=etat"
cd "$LOCAL_DIR/$temp_dir/pki/etat/"
echo 1000 > serial
touch index.txt

#On copie la config du CA
cp "$LOCAL_DIR/$config_dir/ca-config.cnf" "$LOCAL_DIR/$temp_dir/pki/etat/"

#Creation de l'autorite intermediaire (Prefecture)
openssl genrsa -aes256 -out "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.key" -passout pass:azerty 4096
openssl req -in "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.key" -out "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.csr" -passin pass:azerty -subj "/C=FR/ST=France/L=Paris/CN=prefecture" -new -nodes
openssl ca -config "$LOCAL_DIR/$temp_dir/pki/etat/ca-config.cnf" -extensions v3_intermediate_ca -cert "$LOCAL_DIR/$temp_dir/pki/etat/CA.crt" -keyfile "$LOCAL_DIR/$temp_dir/pki/etat/CA.key" -in "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.csr" -out "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.crt" -passin pass:azerty -batch

#Generation des cles des votants
cd $LOCAL_DIR
while read line; do
    id="$(echo $line | cut -f1 -d ';')"
    openssl genrsa -aes256 -out "$LOCAL_DIR/$temp_dir/pki/votants/$id.key" -passout pass:azerty 2048
done < "$db_liste_electorale"

#Generation des demandes de certificat des votants
