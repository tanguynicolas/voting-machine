#!/bin/bash
#
# Connexion de l'électeur à la machine de vote. Initialisation de TLS.

echo -e "\nDébut du handshake TLS" | tee -a "$LOCAL_DIR/$s_machine_vote"

echo "01 Client : Hello - voici mes algorithmes AES256, RSA4096, DSA, SHA256." >> "$LOCAL_DIR/$s_machine_vote"
echo "02 Serveur : Hello - ok cool, on prend ça."

echo "03 Serveur : certificat - tiens mon certificat « $LOCAL_DIR/$temp_pki/machine/machine.crt »."

echo "04 Serveur : Hello Done."

echo "05 Vérification du certificat du serveur."
# ICI FAIRE LA VÉRIFICATION DE TOUTE LA CHAÎNE
echo "06 Certificat valide."

echo "07 Client : certificat - tiens mon certificat « $LOCAL_DIR/$temp_pki/votants/id.crt »." >> "$LOCAL_DIR/$s_machine_vote"

echo "08 Vérification du certificat du client." >> "$LOCAL_DIR/$s_machine_vote"
# ICI FAIRE LA VÉRIFICATION DE TOUTE LA CHAÎNE
echo "09 Certificat valide." >> "$LOCAL_DIR/$s_machine_vote"

mkdir -p "$LOCAL_DIR/$temp_connexion"

echo "10 Génération du PMS."
openssl rand -out "$LOCAL_DIR/$temp_connexion/pms.dat" 16
echo "11 Chiffrement du PMS."
openssl rsautl -encrypt -inkey "$LOCAL_DIR/$temp_pki/machine/machine_pub.key" \
    -pubin -in "$LOCAL_DIR/$temp_connexion/pms.dat" -out "$LOCAL_DIR/$temp_connexion/pms-chif.dat"  > /dev/null 2>&1
echo "12 Envoi du PMS chiffré à la machine de vote."
echo "13 Client : Key Exchange - PMS chiffré reçu, déchiffrement avec clé privée." >> "$LOCAL_DIR/$s_machine_vote"

echo "14 Dérivation du PMS." | tee -a "$LOCAL_DIR/$s_machine_vote"
split -b4 -a1 -d --numeric-suffixes=1 "$LOCAL_DIR/$temp_connexion/pms.dat" "$LOCAL_DIR/$temp_connexion/p"
openssl aes-256-cbc -kfile "$LOCAL_DIR/$temp_connexion/p1" -nosalt -P 2> /dev/null | grep "^key\s*=" | cut -d'=' -f2 > "$LOCAL_DIR/$temp_connexion/client-key.dat"
openssl aes-256-cbc -kfile "$LOCAL_DIR/$temp_connexion/p1" -nosalt -P 2> /dev/null | grep "^key\s*=" | cut -d'=' -f2 > "$LOCAL_DIR/$temp_connexion/client-iv.dat"
openssl aes-256-cbc -kfile "$LOCAL_DIR/$temp_connexion/p2" -nosalt -P 2> /dev/null | grep "^key\s*=" | cut -d'=' -f2 > "$LOCAL_DIR/$temp_connexion/server-key.dat"
openssl aes-256-cbc -kfile "$LOCAL_DIR/$temp_connexion/p2" -nosalt -P 2> /dev/null | grep "^key\s*=" | cut -d'=' -f2 > "$LOCAL_DIR/$temp_connexion/server-iv.dat"
openssl dgst -sha256 -out "$LOCAL_DIR/$temp_connexion/client-mackey.dat" "$LOCAL_DIR/$temp_connexion/p3"
openssl dgst -sha256 -out "$LOCAL_DIR/$temp_connexion/server-mackey.dat" "$LOCAL_DIR/$temp_connexion/p4"

echo "15 Client : CCS - je passe en mode chiffré." >> "$LOCAL_DIR/$s_machine_vote"
echo "16 HMac des communications précédentes"
echo "17 Client : End Handshake - 4A4Ubka2ncZokKSCyAuBnBSWlIbGWZQHz5Ds+LmmqtNWD" >> "$LOCAL_DIR/$s_machine_vote"
echo "18 Déchiffrement du message et vérification de l'intégrité des échanges précédents." >> "$LOCAL_DIR/$s_machine_vote"

echo "19 Serveur : CCS - Le serveur indique qu'il passe en mode chiffré."
echo "20 HMac des communications précédentes" >> "$LOCAL_DIR/$s_machine_vote"
echo "21 Serveur : End Handshake - Ls+EjRvadziWoZ3hjOGfwdJhKvikhipTw1aPQCyJ4TSyz"
echo "22 Déchiffrement du message et vérification de l'intégrité des échanges précédents."
