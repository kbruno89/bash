#!/bin/bash

VERSION="Waydroid LikeAPro 1.0"

##############################################################################################################
#### AUTENTICAR ID DO DEVICE NO GOOGLE
#
# sudo waydroid shell
#
# Dentro do shell que abrir:
# ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
#
# PEGAR O CODIGO GERADO E ATIVAR NO LINK ABAIXO (COM SUA CONTA GOOGLE)
# https://www.google.com/android/uncertified
##############################################################################################################

#7) fnFINISH
fnFINISH(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo  -e "##############################################################################"
echo  -e "#                                                                            #"
echo  -e "#                           F I N A L I Z A D O                              #"
echo  -e "#                                                                            #"
echo  -e "#                 OBRIGATORIO REINICIAR O COMPUTADOR PARA                    #"
echo  -e "#                     AS ALTERACOES ENTRAREM EM VIGOR                        #"
echo  -e "#                                                                            #"
echo  -e "#                APOS REBOOT, INICIAR O WAYDROID PELO SHELL:                 #"
echo  -e "#                              (SEM ROOT)                                    #"
echo  -e "#                                                                            #"
echo  -e "#                                                                            #"
echo  -e "#                      $ ANDROID (TUDO MAIUSCULO)                            #"
echo  -e "#                                                                            #"
echo  -e "##############################################################################"
echo -ne "\n\t PRESSIONE ENTER PARA REINICIAR..."
read
reboot
}


#6) fnAJUSTE
fnAJUSTE(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo -ne " AJUSTES PARA O MELHOR FUNCIONAMENTO DO WAYDROID...\n\n"
systemctl disable --now ufw.service firewall.service firewalld.service > /dev/null 2>&1
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/d' /etc/default/grub
echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1"' >> /etc/default/grub
update-grub
if [ $STYPE = x11 ]
    then
cat << EOF > /home/$USU/.android.sh
#!/bin/bash
unset WAYLAND_DISPLAY
pkill weston
weston --width=645 --height=900 & export WAYLAND_DISPLAY=wayland-1
waydroid session stop
waydroid show-full-ui
EOF
    else
cat << EOF > /home/$USU/.android.sh
#!/bin/bash
waydroid session stop
waydroid show-full-ui
EOF
fi
echo "alias ANDROID='/home/$USU/.android.sh > /dev/null 2>&1 &'" >> /home/$USU/.bash_aliases
chown $USU:$USU /home/$USU/.android.sh
chmod 770 /home/$USU/.android.sh
if [ $VTYPE = VM ]
    then
        echo "ro.hardware.gralloc=default" >> /var/lib/waydroid/waydroid.cfg
        echo "ro.hardware.egl=swiftshader" >> /var/lib/waydroid/waydroid.cfg
        waydroid upgrade -o
fi
fnFINISH
}




#5) fnINSTALL
fnINSTALL(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo -ne " INSTALANDO WAYDROID (COM PLAYSTORE)...\n\n"
waydroid init -s GAPPS
git clone https://github.com/casualsnek/waydroid_script
cd waydroid_script
python3 -m venv venv
venv/bin/pip install -r requirements.txt
if [ $PROC -eq 0 ]
    then
        venv/bin/python3 main.py install libhoudini magisk widevine
    else
        venv/bin/python3 main.py install libndk magisk widevine
fi
waydroid container restart
cd ..
fnAJUSTE
}


#4) fnDOWN
fnDOWN(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo -ne " BAIXANDO WAYDROID...\n\n"
apt install ca-certificates git python3-venv python3-pip sudo vim net-tools -y > /dev/null 2>&1
adduser $USU sudo
curl https://repo.waydro.id | bash
apt install waydroid -y
[[ $STYPE != wayland ]] && apt install weston -y
fnINSTALL
}


#3) fnKERNEL
fnKERNEL(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo -ne " INSTALANDO KERNEL XANMOD...\n\n"
wget -qO - https://dl.xanmod.org/archive.key | gpg --batch --yes --dearmor -vo /usr/share/keyrings/xanmod-archive-keyring.gpg 2> /dev/null
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' > /etc/apt/sources.list.d/xanmod-release.list 2> /dev/null
cat /proc/cpuinfo | grep flags | head -n1 | egrep 'sse2|cx8|fxsr' > /dev/null ; [[ $? -eq 0 ]] && LEVEL=1
cat /proc/cpuinfo | grep flags | head -n1 | egrep 'ssse3|sse4_1|sse4_2' > /dev/null ; [[ $? -eq 0 ]] && LEVEL=2
cat /proc/cpuinfo | grep flags | head -n1 | egrep 'avx2|bmi|movbe' > /dev/null ; [[ $? -eq 0 ]] && LEVEL=3
cat /proc/cpuinfo | grep flags | head -n1 | grep avx512 > /dev/null ; [[ $? -eq 0 ]] && LEVEL=4
apt update > /dev/null && apt upgrade > /dev/null && apt install linux-xanmod-lts-x64v$LEVEL -y
fnDOWN
}


#2) fnINFO
fnINFO(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo  -e "##############################################################################"
echo  -e "#                                                                            #"
echo  -e "#                             INFORMACOES                                    #"
echo  -e "#                                                                            #"
echo  -e "#             TEREMOS QUE INSTALAR UM CUSTOM KERNEL COM OS MODULOS           #"
echo  -e "#                 NECESSARIOS PARA FUNCIONAMENTO DO WAYDROID                 #"
echo  -e "#                                                                            #"
echo  -e "#                    KERNEL XANMOD:   https://xanmod.org                     #"
echo  -e "#                                                                            #"
echo  -e "#                          SE ESTIVER DE ACORDO                              #"
echo  -e "#                    PRESSIONE ENTER PARA CONTINUAR >>                       #"
echo  -e "#                                                                            #"
echo  -e "#                         CTRL + C  PARA CANCELAR                            #"
echo  -e "#                                                                            #"
echo  -e "##############################################################################"
echo -ne "\n\n\n\n"
read
fnKERNEL
}


#1) TELA PRINCIPAL
clear
echo -e " CARREGANDO ..."
ROOT=$(id -u)
VER=$(cat /etc/os-release | egrep 'debian|ubuntu' > /dev/null 2>&1 ; echo $?)
RAM=$(free -h | grep Mem | awk '{print $2}' | cut -d, -f1)
PROC=$(cat /proc/cpuinfo | grep -i intel > /dev/null ; echo $?)
USU=$(ls -1 /home/ | head -n1)
NENV=$(ps aux | grep gvfsd | head -n1 | awk '{print $2}')
XDGS=$(cat /proc/$NENV/environ | grep wayland > /dev/null ; echo $?)
VOUF=$(hostnamectl | grep Virtualization > /dev/null ; echo $?)
[[ $ROOT -ne 0 ]] && echo -ne "\n\n     PRECISA EXECUTAR COMO ROOT\n\n SAINDO ...\n\n" && exit 1
[[ $VER -ne 0 ]] && echo -ne "\n\n     SEU SISTEMA PRECISA SER:  DEBIAN / UBUNTU BASED\n\n SAINDO ...\n\n" && exit 1
[[ $RAM -lt 7 ]] && echo -ne "\n\n     MEMORIA MINIMA NECESSARIA:  8 GB\n\n SAINDO ...\n\n" && exit 1
[[ $XDGS -eq 0 ]] && STYPE="wayland" || STYPE="x11"
[[ $VOUF -eq 0 ]] && VTYPE="VM"
export DEBIAN_FRONTEND=noninteractive
[[ $(cat /etc/sysctl.conf | grep vm.swappiness > /dev/null ; echo $?) -ne 0 ]] && echo "vm.swappiness=15" >> /etc/sysctl.conf && sysctl -p > /dev/null
[[ $(cat /etc/environment | grep TERM > /dev/null ; echo $?) -ne 0 ]] && echo "TERM=xterm-256color" >> /etc/environment
apt-get update -qq > /dev/null
apt-get install curl figlet -qq > /dev/null
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo "Title          : $VERSION"
echo "Description    : Implanta Waydroid Like a PRO!"
echo "Author         : Bruno Kammers Ribeiro"
echo "Version        : $(echo $VERSION | cut -d" " -f3)"
echo -ne "\n\n\n\n"
echo -e " DESEJA INICIAR O PROCESSO DE INSTALACAO DO WAYDROID NESTE SERVIDOR? [s/N]"
echo -e " DEFAULT:  s"
echo ""
read resposta
[[ -z $resposta || $resposta = [Ss] ]] && fnINFO || exit 1
