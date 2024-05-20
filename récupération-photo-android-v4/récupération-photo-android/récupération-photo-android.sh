#!/bin/bash
#V4
source /home/$USER/Bureau/.récupération-photo-android/fonction-récupération-photo-android.sh #fonction pour le script

sed -i 's/\$USER/'$USER'/g' /home/$USER/Bureau/récupération-photo-android.desktop;


###########################
# installation outils adb #
###########################

apt list adb 2>/dev/null | grep "instal" >/dev/null;
ins=$?;

if [ $ins != 0 ];then
    printf "\n\033[0;31m-------------------vous n'avez pas le paquet adb installé-------------------\033[0;0m\n";
    printf "\nAvez-vous le mot de passe administrateur pour installer le paquet ?\n";
    su -c "apt install adb";
    apt list adb 2>/dev/null | grep "instal" >/dev/null;
    ins=$?;
    if [ $ins != 0 ];then
        printf "\n\033[0;31m-------------------ERREUR : essayer d'installer manuellement adb-------------------\033[0;0m\n";
    fi
    sleep 5
    exit 1; 
fi

printf "start...\b\r\b";

connection-telephone;

niveau-batterie;

calcul-nombre-photos;

copie-photo;

ecruture-dates-photos;

tri-par-date;

suppression-photo-telephone;

sleep 5;
exit 1;













