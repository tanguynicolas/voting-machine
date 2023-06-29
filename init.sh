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
openssl req -x509 -days 7300 -newkey rsa:4096 -sha256 -out "$LOCAL_DIR/$temp_dir/pki/etat/CA.crt" -keyout "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=etat" -nodes > /dev/null 2>&1 
openssl rsa -in "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -pubout > "$LOCAL_DIR/$temp_dir/pki/etat/CA_pub.key" > /dev/null 2>&1
cd "$LOCAL_DIR/$temp_dir/pki/etat/"
echo 1000 > serial
touch index.txt

#On copie la config du CA
cp "$LOCAL_DIR/$config_dir/ca-config.cnf" .

#Creation de l'autorite intermediaire (Prefecture)
openssl req -newkey rsa:4096 -sha256 -out "../prefecture/CA_interm.csr" -keyout "../prefecture/CA_interm_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=prefecture" -nodes > /dev/null 2>&1
openssl rsa -in "../prefecture/CA_interm_priv.key" -pubout > "../prefecture/CA_interm_pub.key" > /dev/null 2>&1
openssl ca -config "ca-config.cnf" -extensions v3_intermediate_ca -cert "CA.crt" -keyfile "CA_priv.key" -in "../prefecture/CA_interm.csr" -out "../prefecture/CA_interm.crt" -batch > /dev/null 2>&1
cd "$LOCAL_DIR/$temp_dir/pki/prefecture/"
echo 1000 > serial
touch index.txt

#On copie la config du CA intermédiaire
cp "$LOCAL_DIR/$config_dir/ca-interm-config.cnf" .

#Génération et signature des clés de la machine
openssl req -newkey rsa:2048 -sha256 -out "../machine/machine.csr" -keyout "../machine/machine_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=machine" -nodes > /dev/null 2>&1
openssl rsa -in "../machine/machine_priv.key" -pubout > "../machine/machine_pub.key" > /dev/null 2>&1
openssl ca -config "ca-interm-config.cnf" -cert "CA_interm.crt" -keyfile "CA_interm_priv.key" -in "../machine/machine.csr" -out "../machine/machine.crt" -batch > /dev/null 2>&1

#Generation et signature des clés des votants
while read line; do
    id="$(echo $line | cut -f1 -d ';')"
    openssl req -newkey rsa:2048 -sha256 -out "../votants/${id}.csr" -keyout "../votants/${id}_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=$id" -nodes > /dev/null 2>&1
    openssl rsa -in "../votants/${id}_priv.key" -pubout > "../votants/${id}_pub.key" > /dev/null 2>&1
    openssl ca -config "ca-interm-config.cnf" -cert "CA_interm.crt" -keyfile "CA_interm_priv.key" -in "../votants/${id}.csr" -out "../votants/${id}.crt" -batch > /dev/null 2>&1
done < "$LOCAL_DIR/$db_liste_electorale"
cd "$LOCAL_DIR"