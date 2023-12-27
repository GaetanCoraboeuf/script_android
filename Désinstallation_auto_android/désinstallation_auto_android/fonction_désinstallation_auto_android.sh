#!/bin/bash

# voici des variables affectée des codes couleurs qu'on trouve sur le net
noir='\e[0;30m'
gris='\e[1;30m'
rougefonce='\e[0;31m'
rouge='\e[1;31m'
vertfonce='\e[0;32m'
vertclair='\e[1;32m'
orange='\e[0;33m'
jaune='\e[1;33m'
bleufonce='\e[0;34m'
mauve='\e[1;34m'
fuschia='\e[0;35m'
rose='\e[1;35m'
cyan='\e[0;36m'
bleuclair='\e[1;36m'
blanc='\e[1;37m'
normal='\e[0;m'

########################
# connection téléphone #
########################
connection-telephone(){
    adb start-server >/dev/null 2>/dev/null;
    adb devices | grep -w "device" >/dev/null;
    device=$?;
     
    if [ $device = 0 ];then
        printf "$vertfonce-------------------le mode débogage est activé-------------------$normal";
        return;
    fi
    
    lsusb | grep "MTP" >/dev/null;
    tel=$?;
    if [ $tel != 0 ];then
        lsusb | grep "Lenovo TB-X606F" >/dev/null;
        tel=$?;
    fi
    if [ $tel != 0 ];then
        printf "$rougefonce-------------------votre téléphone n'est pas connecté-------------------$normal";
        #nmap --host-timeout 5ms --max-rtt-timeout 5ms  192.168.1.0/24 2>/dev/null | grep "192.168.1." | grep -v "Skipping" | grep -v "livebox" | cut -d "(" -f2 |cut -d ")" -f1
        #nmap -sP 192.168.1.0/24
        #nmap -sP 192.168.1.0/24 | grep "192.168.1." | grep -v "livebox" | cut -d "(" -f2 |cut -d ")" -f1
        ip=$(nmap -sP 192.168.1.0/24 | grep "192.168.1." | grep -v "livebox" | cut -d "(" -f2 |cut -d ")" -f1);
        nombre_ip=$(echo "$ip" | sed -n '$=');
        while (( $nombre_ip > 0 ));
        do
            une_ip=$(echo "$ip" | sed -n "$nombre_ip p");
            nombre_ip=`expr $nombre_ip - 1`;
            #echo "$une_ip";
            adb connect $une_ip:5555 | grep "connected">/dev/null;
            if [ $? = 0 ];then
                printf "\n$vertfonce-------------------le mode débogage WIFI est activé-------------------$normal";
                return;
            fi
        done

        while [ $tel = 1 ];
        do
            lsusb | grep "MTP" >/dev/null;
            tel=$?;
            if [ $tel != 0 ];then
                lsusb | grep "Lenovo TB-X606F" >/dev/null;
                tel=$?;
            fi
        done
    fi
    printf "\n$vertfonce-------------------votre téléphone est connecté-------------------$normal";    

    
    if [ $device != 0 ];then
        printf "\n$rougefonce-------------------le mode débogage USB n'est pas activé-------------------$normal";
        while [ $device = 1 ];
        do
            adb devices | grep -w "device" >/dev/null;
            device=$?;
        done
    fi
    printf "\n$vertfonce-------------------le mode débogage USB est activé-------------------$normal";
}


######################
# niveau de batterie #
######################
niveau-batterie(){
    bat=$(adb shell dumpsys battery |grep "level" | cut -d ":" -f2);
    printf "\t$gris batterie :$bat%%";
    volt=$(adb shell dumpsys battery | grep -v "Max" | grep "voltage" | cut -d ":" -f2 | cut -d " " -f2 | cut -b1);
    volt+=",";
    volt+=$(adb shell dumpsys battery | grep -v "Max" | grep "voltage" | cut -d ":" -f2 | cut -d " " -f2 | cut -b2-);
    volt+="v";
    printf " voltage : $volt";
    temp=$(adb shell dumpsys battery | grep "temperature" | cut -d ":" -f2 | cut -d " " -f2 | cut -b-2);
    temp+=",";
    temp+=$(adb shell dumpsys battery | grep "temperature" | cut -d ":" -f2 | cut -d " " -f2 | cut -b3-);
    temp+=$(awk 'BEGIN { print "\xc2\xb0C"; }');
    printf " temperature : $temp";
    #adb shell df -h /storage/emulated | grep -v "Filesystem" | cut -d "/" -f3 | cut -d " " -f2-
    
    courant=$(adb shell dumpsys battery | grep "current now" | cut -d ":" -f2 | cut -d " " -f2 );
    if (( "$courant" < 1000 )); then
        if (( "$courant" < 100 )); then
            courant+="mA";
        else
            courant="0,";
            courant+=$(adb shell dumpsys battery | grep "current now" | cut -d ":" -f2 | cut -d " " -f2 );
            courant+="A";
        fi
    else
        courant=$(adb shell dumpsys battery | grep "current now" | cut -d ":" -f2 | cut -d " " -f2 | cut -b1);
        courant+=",";
        courant+=$(adb shell dumpsys battery | grep "current now" | cut -d ":" -f2 | cut -d " " -f2 | cut -b2-);
        courant+="A";
    fi
    printf " courant : $courant$normal";
    
}
désinstallation-des-applis(){
    printf "\n"
    while true; do
        read -p "voulez-vous désinstaller les applis inutiles ?[O/N]" yn
        case $yn in
            [Oo]* )
                break;;
            [Nn]* ) exit;;
            * ) printf "\aMettez oui ou non.\n";;
        esac
    done
    
    
    while true; do
        read -p "quelle option choisisez-vous ?[1/2/3]" option
        case $option in
            [1]* )
                break;;
            [2]* ) 
                break;;
            [3]* ) 
                break;;
            * ) printf "\aMettez un chiffre 1, 2 ou 3.\n";;
        esac
    done
    
    printf "$orange\0les applis suivante vont être désinstallé :\n$normal"
    #$(grep -v -E "(^#|^$)" /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt)
    nb_ligne=$(grep -v -E "(^#|^$)" /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | sed -n '$=')
    #echo $nb_ligne
    i=1;
    while (( $i <= $nb_ligne ));
    do
        while (( $(sed -n $i'p' /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | grep -v -E "(^#|^$)" | wc -w) == 0 ));
        do
            i=`expr $i + 1`;
            nb_ligne=`expr $nb_ligne + 1`;
        done
        #echo $(sed -n $i'p' /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | cut -d ":" -f2 | cut -d " " -f1)
        echo $(sed -n $i'p' /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | cut -d " " -f2-)
        i=`expr $i + 1`;
    done
    
    printf "$rouge\n"
    while true; do
        read -p "voulez-vous les désinstaller ?[O/N]" yn
        case $yn in
            [Oo]* )
                break;;
            [Nn]* ) exit;;
            * ) printf "\aMettez oui ou non.\n";;
        esac
    done
    printf "$normal\n"
    i=1;
    nb_ligne=$(grep -v -E "(^#|^$)" /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | sed -n '$=')
    while (( $i <= $nb_ligne ));
    do
        while (( $(sed -n $i'p' /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | grep -v -E "(^#|^$)" | wc -w) == 0 ));
        do
            i=`expr $i + 1`;
            nb_ligne=`expr $nb_ligne + 1`;
        done
        echo $(sed -n $i'p' /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | cut -d ":" -f2 | cut -d " " -f1)
        adb shell pm uninstall -k --user 0 $(sed -n $i'p' /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | cut -d ":" -f2 | cut -d " " -f1) #> /dev/null
        adb uninstall $(sed -n $i'p' /home/$USER/Bureau/.désinstallation_auto_android/option$option.txt | cut -d ":" -f2 | cut -d " " -f1) 
        i=`expr $i + 1`;
    done
    printf "\n$vertfonce\0Désinstallation effectué !\n$normal"
    
}

