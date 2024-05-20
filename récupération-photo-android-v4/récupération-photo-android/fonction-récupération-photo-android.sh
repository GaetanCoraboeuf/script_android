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




###########################
# calcul nombre de photos #
###########################
calcul-nombre-photos () {
    nbphoto=0;
    photocorbeille=0;
    nbfichier=0
    nbfichier+=$(adb ls /storage/self/primary/DCIM/ | grep -v -w '\.' | sed -n '$=')
    
    nbphotocorbeille=$(adb ls /storage/self/primary/Android/.Trash/com.sec.android.gallery3d/ | grep -v -w '\.' | sed -n '$=')
    
    if ((nbphotocorbeille == 0));then
        nbphotocorbeille=$(adb ls /storage/self/primary/Android/data/com.sec.android.gallery3d/files/.Trash/ | grep -v -w '\.' | sed -n '$=')
        photocorbeille=1;
    fi
    
    #########################################
    # vérification de la présence de photos #
    #########################################
    if (( nbfichier == 0 ));then
        printf "\n$rougefonce-------------------il n'y a pas de photo sur votre téléphone-------------------$normal\n";
        sleep 10;
        exit 1;
    fi
    
    
    while [ $nbfichier -ge 1 ];
    do
        fin=$(adb ls /storage/self/primary/DCIM/ | grep -v -w '\.' | sed -n "$nbfichier p" | cut -d ' ' -f4);
        nbphototmp=0;
        nbphototmp+=$(adb ls /storage/self/primary/DCIM/$fin | grep -v -w '\.' | sed -n "$=");
        nbphoto=`expr $nbphoto + $nbphototmp 2>/dev/null`;
        #echo "$nbphoto";
        nbfichier=`expr $nbfichier - 1` ;
        
    done
    printf "\n$orange\0nombre de photo : $nbphoto$normal";
    
    if ((nbphotocorbeille != 0));then
        printf "$orange\0\tnombre de photo dans la corbeille : $nbphotocorbeille$normal";
    fi
    
    printf "\n";

}



######################################
# calcul nombre de photos téléchargé #
######################################
calcul-nombre-photos-telecharge () {
    nbphotoTelecharge=0;
    nbfichier=$(ls -a /home/$USER/Bureau/DCIM/ | cut -d '/' -f6 | grep -v -w '\.' | grep -v -w '.directory' | sed -n '$=')

    while [ $nbfichier -ge 1 ];
    do
        fin=$(ls -a /home/$USER/Bureau/DCIM/ | cut -d '/' -f6 | grep -v -w '\.' | grep -v -w '.directory' | sed -n "$nbfichier p");
        nbphotoTelechargetmp=0;
        nbphotoTelechargetmp+=$(ls -a /home/$USER/Bureau/DCIM/$fin | cut -d '/' -f6 | grep -v -w '\.' | grep -v -w '.directory' | sed -n "$=");
        nbphotoTelecharge=`expr $nbphotoTelecharge + $nbphotoTelechargetmp 2>/dev/null`;
        #echo "$nbphotoTelecharge";
        nbfichier=`expr $nbfichier - 1` ;
        
    done
    printf "\n$orange\0nombre de photo téléchargé : $nbphotoTelecharge$normal\n";
    return $nbphotoTelecharge;

}







#################################
# écriture des dates des photos #
#################################
ecruture-dates-photos (){
    #touch -t 202206271315 /home/$USER/Bureau/DCIM/
    
    
    nbfichier=$(ls -a /home/$USER/Bureau/DCIM/ | cut -d '/' -f6 | grep -v -w '\.' | grep -v -w '.directory' | sed -n '$=')

    while (( nbfichier > 0 ));
    do
        fin=$(ls -a /home/$USER/Bureau/DCIM/ | cut -d '/' -f6 | grep -v -w '\.' | grep -v -w '.directory' | sed -n "$nbfichier p");
        
        nomdiff=$(ls -a /home/$USER/Bureau/DCIM/$fin/  | cut -d '/' -f6 | grep -v -w '\.' | grep -v -w '.directory' | cut -d '_' -f1 | cut -c -1 | uniq);

        nbfichierphoto=$(ls -a /home/$USER/Bureau/DCIM/$fin/ | cut -d '/' -f6 | grep -v -w '\.' | grep -v -w '.directory' | sed -n '$=');
        
        while (( nbfichierphoto > 0 ));
        do

            nomfichierphoto=$(ls -a /home/$USER/Bureau/DCIM/$fin/ | cut -d '/' -f6 | grep -v -w '\.' | grep -v -w '.directory' | sed -n "$nbfichierphoto p");
            
            #echo "$nomfichierphoto";
            
            date=$(adb shell stat "/storage/self/primary/DCIM/$fin/$nomfichierphoto" | grep 'Change:' | cut -c 9-40);
            
            touch -d "$date" "/home/$USER/Bureau/DCIM/$fin/$nomfichierphoto";

            nbfichierphoto=`expr $nbfichierphoto - 1` ;
        done
        
        nbfichier=`expr $nbfichier - 1` ;
    done

}











################
# copie photos #
################
copie-photo(){

    while true; do
        read -p "voulez-vous les télécharger ?[O/N]" yn
        case $yn in
            [Oo]* )
                break;;
            [Nn]* ) exit;;
            * ) printf "\aMettez oui ou non.\n";;
        esac
    done

    ls /home/$USER/Bureau/DCIM >/dev/null 2>/dev/null;

    if [ $? = 0 ];then
        while true; do
            printf "\n$rougefonce\0un dossier DCIM existe déjà, $normal"
            read -p "voulez-vous le renommer ?[O/N]" yn
            case $yn in
                [Oo]* )
                    renommage-automatique;
                    break;;
                [Nn]* )
                    while true; do
                        read -p "voulez-vous l'écraser ?[O/N]" yn
                        case $yn in
                            [Oo]* )
                                rm -r /home/$USER/Bureau/DCIM/;
                                break;;
                            [Nn]* ) exit;;
                            * ) printf "\aMettez oui ou non.\n";;
                        esac
                    done
                    break;;
                * ) printf "\aMettez oui ou non.\n";;
            esac
        done
    fi
    
    #####################################
    # vérification connection téléphone #
    #####################################
    
    lsusb | grep "MTP" >/dev/null;
    tel=$?;

    if [ $tel != 0 ];then
        printf "\n$rougefonce-------------------votre téléphone s'est déconnecté-------------------$normal\n\n";
        while [ $tel = 1 ];
        do
            lsusb | grep "MTP" >/dev/null;
            tel=$?;
        done
        sleep 1;
    fi
    
    
    printf "\n$cyan-------------------début de la copie-------------------\n\n$fuschia";

    adb pull "/storage/self/primary/DCIM/" "/home/$USER/Bureau/" ;
    
    if((nbphotocorbeille != 0));then
        while true; do
            printf "$normal"
            read -p "voulez-vous télécharger aussi la corbeille ?[O/N]" yn
            case $yn in
                [Oo]* )
                    printf "\n$cyan-------------------début de la copie-------------------\n\n$fuschia";
                    if((photocorbeille == 0));then
                        adb pull "/storage/self/primary/Android/.Trash/com.sec.android.gallery3d/" "/home/$USER/Bureau/DCIM/" ;
                    else
                        adb pull "/storage/self/primary/Android/data/com.sec.android.gallery3d/files/.Trash/" "/home/$USER/Bureau/DCIM/" ;
                    fi
                        mv "/home/$USER/Bureau/DCIM/.Trash" "/home/$USER/Bureau/DCIM/Corbeille"
                    break;;
                [Nn]* ) break;;
                * ) printf "\aMettez oui ou non.\n";;
            esac
        done
    fi
    
    calcul-nombre-photos-telecharge;
    
    if (( "$nbphotoTelecharge" < "$nbphoto" ));then
        printf "\n$rougefonce-------------------il y eu une erreur-------------------$normal\n\n";
        #sleep 15;
        #exit;
    fi

    printf "\n$vertfonce-------------------fin de la copie-------------------$normal\n\n";
}



#########################
# renommage automatique #
#########################

renommage-automatique (){
    
    nombre=0;
    ls /home/$USER/Bureau/DCIM;
    while (( $? == 0 ));
    do
       nombre=`expr $nombre + 1`; 
       ls /home/$USER/Bureau/DCIM$nombre;
    done
    mv /home/$USER/Bureau/DCIM /home/$USER/Bureau/DCIM$nombre;
    printf "\n$mauve\0il a été renommé en DCIM$nombre$normal\n"
}









################
# tri par date #
################
tri-par-date () {
    printf "\n"
    while true; do
        read -p "voulez-vous les trier par date ?[O/N]" yn
        case $yn in
            [Oo]* )
                break;;
            [Nn]* ) return;;
            * ) printf "\aMettez oui ou non.\n";;
        esac
    done


    nbfichier=$(ls /home/$USER/Bureau/DCIM/ | sed -n '$=')


    while (( nbfichier > 0 ));
    do
        fin=$(ls /home/$USER/Bureau/DCIM/ | sed -n "$nbfichier p");
        
        nomdiff=$(ls /home/$USER/Bureau/DCIM/$fin/  | cut -d '_' -f1 | cut -c -1 | uniq);
        
        #################
        # tri par année #
        #################
        if [ "$nomdiff" = 2 ];then
            nbfichierannee=$(ls /home/$USER/Bureau/DCIM/$fin/  | cut -d '_' -f1 | cut -c -4 | uniq | sed -n '$=');
        else
            nbfichierannee=$(ls /home/$USER/Bureau/DCIM/$fin/  | cut -d '_' -f2 | cut -c -4 | uniq | sed -n '$=');
            texte=$(ls /home/$USER/Bureau/DCIM/$fin/*.*  | cut -d '/' -f7 | cut -d '_' -f1 | uniq);
        fi
        
        while (( nbfichierannee > 0 ));
        do
            texteplusannee=0;
            if [ "$nomdiff" = 2 ];then
                annee=$(ls /home/$USER/Bureau/DCIM/$fin/  | cut -d '_' -f1 | cut -c -4 | uniq | sed -n "$nbfichierannee p");
            else
                annee=$(ls /home/$USER/Bureau/DCIM/$fin/  | cut -d '_' -f2 | cut -c -4 | uniq | sed -n "$nbfichierannee p");
                texteplusannee=$texte;
                texteplusannee+='_';
                texteplusannee+=$annee;
            fi
            
            mkdir /home/$USER/Bureau/DCIM/$fin/$annee/;
            printf "\n$vertclair création de /home/$USER/Bureau/DCIM/$fin/$annee/ $normal\n"
            
            if [ "$nomdiff" = 2 ];then
                mv /home/$USER/Bureau/DCIM/$fin/$annee* /home/$USER/Bureau/DCIM/$fin/$annee/;
                printf "\n$bleuclair déplacement de /home/$USER/Bureau/DCIM/$fin/$annee $normal\n"
                printf "$bleuclair vers /home/$USER/Bureau/DCIM/$fin/$annee/ $normal\n"
            else
                mv /home/$USER/Bureau/DCIM/$fin/$texteplusannee* /home/$USER/Bureau/DCIM/$fin/$annee/;
                printf "\n$bleuclair déplacement de /home/$USER/Bureau/DCIM/$fin/$texteplusannee $normal\n"
                printf "$bleuclair vers /home/$USER/Bureau/DCIM/$fin/$annee/ $normal\n"
                #echo "************texteplusannee=$texteplusannee*************************";
            fi
            
            ################
            # tri par mois #
            ################
            if [ "$nomdiff" = 2 ];then
                nbfichiermois=$(ls /home/$USER/Bureau/DCIM/$fin/$annee/  | cut -d '_' -f1 | cut -c 5-6 | uniq | sed -n '$=');
            else
                nbfichiermois=$(ls /home/$USER/Bureau/DCIM/$fin/$annee/  | cut -d '_' -f2 | cut -c 5-6 | uniq | sed -n '$=');
                textemois=$(ls /home/$USER/Bureau/DCIM/$fin/$annee/*.*  | cut -d '/' -f8 | cut -d '_' -f1 | uniq);
            fi
            
            while (( nbfichiermois >= 1 ));
            do
                texteplusmois=0;
                if [ "$nomdiff" = 2 ];then
                    mois=$(ls /home/$USER/Bureau/DCIM/$fin/$annee/*.* | cut -d '/' -f8  | cut -d '_' -f1 | cut -c 5-6 | uniq | sed -n "$nbfichiermois p");
                    anneeplusmois=$annee;
                    anneeplusmois+=$mois;
                else
                    mois=$(ls /home/$USER/Bureau/DCIM/$fin/$annee/*.* | cut -d '/' -f8  | cut -d '_' -f2 | cut -c 5-6 | uniq | sed -n "$nbfichiermois p");
                    texteplusmois=$textemois;
                    texteplusmois+='_';
                    texteplusmois+=$annee;
                    texteplusmois+=$mois;
                fi
                
                mkdir /home/$USER/Bureau/DCIM/$fin/$annee/$mois/;
                printf "\n$vertfonce création de /home/$USER/Bureau/DCIM/$fin/$annee/$mois/ $normal\n"
                
                if [ "$nomdiff" = 2 ];then
                    mv /home/$USER/Bureau/DCIM/$fin/$annee/$anneeplusmois* /home/$USER/Bureau/DCIM/$fin/$annee/$mois/;
                    printf "\n$bleuclair déplacement de /home/$USER/Bureau/DCIM/$fin/$annee/$anneeplusmois $normal\n"
                    printf "$bleuclair vers /home/$USER/Bureau/DCIM/$fin/$annee/$mois/ $normal\n"
                else
                    mv /home/$USER/Bureau/DCIM/$fin/$annee/$texteplusmois* /home/$USER/Bureau/DCIM/$fin/$annee/$mois/;
                    printf "\n$bleuclair déplacement de /home/$USER/Bureau/DCIM/$fin/$annee/$texteplusmois $normal\n"
                    printf "$bleuclair vers /home/$USER/Bureau/DCIM/$fin/$annee/$mois/ \033[0;0m\n"
                    #echo "************texteplusannee=$texteplusannee*************************";
                fi
    
                nbfichiermois=`expr $nbfichiermois - 1` ;
            done
                
            
            nbfichierannee=`expr $nbfichierannee - 1` ;
        done
        
        nbfichier=`expr $nbfichier - 1` ;
    done

}




#######################################
# suppression des photos du téléphone #
#######################################

suppression-photo-telephone () {
    printf "\n"
    while true; do
        read -p "voulez-vous supprimer définitivement toutes les photos de votre téléphone ?[O/N]" yn
        case $yn in
            [Oo]* )
                break;;
            [Nn]* ) return;;
            * ) printf "\aMettez oui ou non.\n";;
        esac
    done
    adb shell rm -r /storage/self/primary/DCIM/*;
    adb shell rm -r /storage/self/primary/DCIM/.*;
    
    printf "\n$vertfonce-------------------fin de la suppression des photos du téléphone-------------------$normal\n\n";
}
