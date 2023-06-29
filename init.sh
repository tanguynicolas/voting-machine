#!/bin/bash
#
# Script qui initialise les clés des différentes parties

LOCAL_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)
source "$LOCAL_DIR/constants.sh"

# Création de l'arborescence
#  les votants
#  machine de vote
#  serveur bv et préfecture
# certificats : préfecture, racine, bureau, machine
mkdir -p "$LOCAL_DIR/$temp_dir/pki/etat" \
    "$LOCAL_DIR/$temp_dir/pki/prefecture" \
    "$LOCAL_DIR/$temp_dir/pki/bureau" \
    "$LOCAL_DIR/$temp_dir/pki/votants" \
    "$LOCAL_DIR/$temp_dir/pki/machine"

# Création de l'autorité de certification (État)
openssl req -x509 -days 7300 -newkey rsa:4096 -sha256 -out "$LOCAL_DIR/$temp_dir/pki/etat/CA.crt" -keyout "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=etat" -nodes > /dev/null 2>&1 
openssl rsa -in "$LOCAL_DIR/$temp_dir/pki/etat/CA_priv.key" -pubout -out "$LOCAL_DIR/$temp_dir/pki/etat/CA_pub.key" > /dev/null 2>&1
cd "$LOCAL_DIR/$temp_dir/pki/etat/"
echo 1000 > serial
touch index.txt

#On copie la config du CA
cp "$LOCAL_DIR/$config_dir/ca-config.cnf" .

# Création de l'autorité intermédiaire (préfecture)
openssl req -newkey rsa:4096 -sha256 -out "../prefecture/CA_interm.csr" -keyout "../prefecture/CA_interm_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=prefecture" -nodes > /dev/null 2>&1
openssl rsa -in "../prefecture/CA_interm_priv.key" -pubout -out "../prefecture/CA_interm_pub.key" > /dev/null 2>&1
openssl ca -config "ca-config.cnf" -extensions v3_intermediate_ca -cert "CA.crt" -keyfile "CA_priv.key" -in "../prefecture/CA_interm.csr" -out "../prefecture/CA_interm.crt" -batch > /dev/null 2>&1
cd "$LOCAL_DIR/$temp_dir/pki/prefecture/"
echo 1000 > serial
touch index.txt

# On copie la config du CA intermédiaire
cp "$LOCAL_DIR/$config_dir/ca-interm-config.cnf" .

#Génération et signature des clés de la machine
openssl req -newkey rsa:2048 -sha256 -out "../machine/machine.csr" -keyout "../machine/machine_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=machine" -nodes > /dev/null 2>&1
openssl rsa -in "../machine/machine_priv.key" -pubout -out "../machine/machine_pub.key" > /dev/null 2>&1
openssl ca -config "ca-interm-config.cnf" -cert "CA_interm.crt" -keyfile "CA_interm_priv.key" -in "../machine/machine.csr" -out "../machine/machine.crt" -batch > /dev/null 2>&1

# Génération et signature des clés du bureau de vote
openssl req -newkey rsa:2048 -sha256 -out "../bureau/bureau.csr" -keyout "../bureau/bureau_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=bureau" -nodes > /dev/null 2>&1
openssl rsa -in "../bureau/bureau_priv.key" -pubout -out "../bureau/bureau_pub.key" > /dev/null 2>&1
openssl ca -config "ca-interm-config.cnf" -cert "CA_interm.crt" -keyfile "CA_interm_priv.key" -in "../bureau/bureau.csr" -out "../bureau/bureau.crt" -batch > /dev/null 2>&1

# Géneration et signature des clés des votants
while read line; do
    id="$(echo $line | cut -f1 -d ';')"
    openssl req -newkey rsa:2048 -sha256 -out "../votants/${id}.csr" -keyout "../votants/${id}_priv.key" -subj "/C=FR/ST=France/L=Paris/CN=$id" -nodes > /dev/null 2>&1
    openssl rsa -in "../votants/${id}_priv.key" -pubout -out "../votants/${id}_pub.key" > /dev/null 2>&1
    openssl ca -config "ca-interm-config.cnf" -cert "CA_interm.crt" -keyfile "CA_interm_priv.key" -in "../votants/${id}.csr" -out "../votants/${id}.crt" -batch > /dev/null 2>&1
done < "$LOCAL_DIR/$db_liste_electorale"

# Restauration clé aes
echo "1f7afe098b8a918a7124ed01444d33c2dfd7941ae8c32a4ca8280862dd94be1a" > $LOCAL_DIR/$temp_dir/pki/machine/aes_key.txt
echo "1f7afe098b8a918a7124ed01444d33c2dfd7941ae8c32a4ca8280862dd94be1a" > $LOCAL_DIR/$temp_dir/pki/bureau/aes_key.txt
