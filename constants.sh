#!/bin/bash
#
# Constantes

# Single view 256 colors: https://robotmoon.com/256-colors/
# Detailed 256 colors: https://www.ditig.com/256-colors-cheat-sheet
# Guide to formatting: https://misc.flogisoft.com/bash/tip_colors_and_formatting

nc='\e[0m'
nfc='\e[39m'
cGreen='\e[38;5;34m'    # Help
cBlue='\e[38;5;27m'     # Work1
cCyan='\e[38;5;50m'     # Work2
cYellow='\e[38;5;184m'  # Warn
cOrange='\e[38;5;214m'  # Error1
cRed='\e[38;5;160m'     # Error2
aBold='\e[1m'
aBlink='\e[5m'
nBlink='\e[25m'

data_dir="data"
db_liste_electorale="$data_dir/liste_electorale.dat"
db_liste_candidats="$data_dir/liste_candidats.dat"
db_liste_cle_publique_votant="$data_dir/liste_cle_publique_votant.dat"
db_liste_messages="$data_dir/liste_messages.dat"
db_liste_votes="$data_dir/liste_votes.dat"

temp_dir="temp"
temp_pki="$temp_dir/pki"
temp_connexion="$temp_dir/connexion"

config_dir="config"

logs_dir="logs"
s_prefecture="$logs_dir/prefecture.log"
s_bureau_vote="$logs_dir/bureau_vote.log"
s_machine_vote="$logs_dir/machine_vote.log"
