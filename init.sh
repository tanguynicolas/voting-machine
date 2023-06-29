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
openssl req -x509 -days 7300 -newkey rsa:4096 -sha256 -out "$LOCAL_DIR/$temp_dir/pki/etat/CA.crt" -keyout "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=etat" -nodes 
openssl rsa -in "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -pubout > "$LOCAL_DIR/$temp_dir/pki/etat/CA_pub.key" 
cd "$LOCAL_DIR/$temp_dir/pki/etat/"
echo 1000 > serial
touch index.txt

#On copie la config du CA
cp "$LOCAL_DIR/$config_dir/ca-config.cnf" "$LOCAL_DIR/$temp_dir/pki/etat/"

#Creation de l'autorite intermediaire (Prefecture)
openssl req -newkey rsa:4096 -sha256 -out "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.csr" -keyout "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=prefecture" -nodes 
openssl rsa -in "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm_priv.key" -pubout > "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm_pub.key"
openssl ca -config "$LOCAL_DIR/$temp_dir/pki/etat/ca-config.cnf" -extensions v3_intermediate_ca -cert "$LOCAL_DIR/$temp_dir/pki/etat/CA.crt" -keyfile "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -in "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.csr" -out "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.crt" -batch
cd "$LOCAL_DIR/$temp_dir/pki/prefecture/"
echo 1000 > serial
touch index.txt

#On copie la config du CA intermédiaire
cp "$LOCAL_DIR/$config_dir/ca-interm-config.cnf" "$LOCAL_DIR/$temp_dir/pki/prefecture/"

#Generation et signature des clés des votants
while read line; do
    id="$(echo $line | cut -f1 -d ';')"
    openssl req -newkey rsa:2048 -sha256 -out "$LOCAL_DIR/$temp_dir/pki/votants/${id}.csr" -keyout "$LOCAL_DIR/$temp_dir/pki/votants/${id}_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=$id" -nodes
    openssl rsa -in "$LOCAL_DIR/$temp_dir/pki/votants/${id}_priv.key" -pubout > "$LOCAL_DIR/$temp_dir/pki/votants/${id}_pub.key"
    openssl ca -config "$LOCAL_DIR/$temp_dir/pki/prefecture/ca-interm-config.cnf" -cert "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm.crt" -keyfile "$LOCAL_DIR/$temp_dir/pki/prefecture/CA_interm_priv.key" -in "$LOCAL_DIR/$temp_dir/pki/votants/${id}.csr" -out "$LOCAL_DIR/$temp_dir/pki/votants/${id}.crt" -batch
done < "$LOCAL_DIR/$db_liste_electorale"