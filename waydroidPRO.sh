#!/bin/bash

VERSION="Waydroid LikeAPro 1.5"

# CHANGELOG
# 1.5 - Adicionado método para identificar se o shell em uso é BASH ou ZSH
# 1.4 - Adicionado método para setar corretamente o kernel xanmod como DEFAULT
# 1.3 - Adicionado função para identificar se existe mais de um usuário no sistema e indicar o correto
# 1.2 - Corrigido bug que trancava o processo no apt upgrade    /    unificado função de validação VTYPE e VGA
# 1.1 - Corrigido bug que traz a palavra "GiB" junto da memória RAM, pois a condição só aceita número inteiro

##############################################################################################################
#### AUTENTICAR ID DO DEVICE NO GOOGLE
#
# COMO ROOT
# waydroid shell   /   sudo waydroid shell
#
# Dentro do shell que abrir:
# ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
#
# PEGAR O CODIGO GERADO E ATIVAR NO LINK ABAIXO (DEVE LOGAR COM UMA CONTA GOOGLE)
# https://www.google.com/android/uncertified
##############################################################################################################

#8) fnFINISH
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
echo  -e "#                      $ ANDROID  (TUDO MAIUSCULO)                           #"
echo  -e "#                                                                            #"
echo  -e "##############################################################################"
echo -ne "\n\t PRESSIONE ENTER PARA REINICIAR..."
read
reboot
}


#7) fnAJUSTE
fnAJUSTE(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo -ne " AJUSTES PARA O MELHOR FUNCIONAMENTO DO WAYDROID...\n\n"
git clone https://github.com/casualsnek/waydroid_script
cd waydroid_script
python3 -m venv venv
venv/bin/pip install -r requirements.txt 2>/dev/null
if [ $PROC -eq 0 ]
    then
        venv/bin/python3 main.py install libhoudini magisk widevine
    else
        venv/bin/python3 main.py install libndk magisk widevine
fi
waydroid container restart
cd ..
systemctl disable --now ufw.service > /dev/null 2>&1 
systemctl disable --now firewall.service  > /dev/null 2>&1
systemctl disable --now firewalld.service > /dev/null 2>&1
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/d' /etc/default/grub
if [ $VERS = debian ]
    then
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1"' >> /etc/default/grub
    else
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1 $vt_handoff"' >> /etc/default/grub
fi
#sed -i '/GRUB_TIMEOUT/ s/0/3/g' /etc/default/grub
#sed -i '/GRUB_TIMEOUT_STYLE/ s/hidden/menu/g' /etc/default/grub
K1=$(grep submenu /boot/grub/grub.cfg | awk -F \' '{print $4}')
K2=$(grep xanmod /boot/grub/grub.cfg | grep menuentry | grep -v recovery | head -n1 | awk -F \' '{print $4}')
K3="$K1>$K2"
sed -i '/GRUB_DEFAULT/ s/0/"'$K3'"/g' /etc/default/grub
sed -i '/GRUB_TIMEOUT/d' /etc/default/grub
echo "GRUB_TIMEOUT=0" >> /etc/default/grub
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
if [[ $SS = 0 ]]
    then
        echo "alias ANDROID='nohup /home/$USU/.android.sh > /dev/null 2>&1 &'" >> /home/$USU/.zshrc
    else
        echo "alias ANDROID='nohup /home/$USU/.android.sh > /dev/null 2>&1 &'" >> /home/$USU/.bash_aliases
fi
chown $USU:$USU /home/$USU/.android.sh
chmod 770 /home/$USU/.android.sh
if [[ $VTYPE = VM || $VGA -eq 0 ]]
    then
        echo "ro.hardware.gralloc=default" >> /var/lib/waydroid/waydroid.cfg
        echo "ro.hardware.egl=swiftshader" >> /var/lib/waydroid/waydroid.cfg
        waydroid upgrade -o
fi
apt clean && apt autoremove -y > /dev/null 2>&1
fnFINISH
}


#6) fnINSTALL
fnINSTALL(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo -ne " INSTALANDO WAYDROID (COM PLAYSTORE)...\n\n"
waydroid init -s GAPPS
fnAJUSTE
}


#5) fnDOWN
fnDOWN(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo -ne " BAIXANDO WAYDROID...\n\n"
apt install ca-certificates git python3-venv python3-pip sudo vim net-tools -y > /dev/null 2>&1
adduser $USU sudo > /dev/null 2>&1
curl https://repo.waydro.id | bash
apt install waydroid -y
[[ $STYPE != wayland ]] && apt install weston -y
fnINSTALL
}


#4) fnKERNEL
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
apt update > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install linux-xanmod-lts-x64v$LEVEL -y
fnDOWN
}


#3) fnINFO
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


#2) fnUSU
fnUSU(){
clear && figlet -c "$VERSION"
echo -ne "\n\n"
echo -ne " IDENTIFICANDO USUARIO...\n\n"
if [ $VUSU -gt 1 ]
        then
                echo -ne " FOI IDENTIFICADO MAIS DE UM USUARIO EM SEU SISTEMA\n\n"
                ls -1 /home | grep -v root
                echo -ne "\n INFORME O USUARIO CORRETO:  " ; read USU
                [[ -z $USU ]] && echo "OBRIGADO A INFORMAR O USUARIO..." && sleep 3 && fnUSU
        else
                USU=$(ls -1 /home | grep -v root)
                echo -ne "\n USUARIO: $USU" && sleep 2
fi
fnINFO
}


#1) TELA PRINCIPAL
clear
echo -e " CARREGANDO ..."
ROOT=$(id -u)
VER=$(cat /etc/os-release | egrep -i 'debian|ubuntu' > /dev/null 2>&1 ; echo $?)
VERF=$(cat /etc/os-release | grep -i ubuntu > /dev/null 2>&1 ; echo $?)
RAM=$(free -h | grep Mem | awk '{print $2}' | cut -d, -f1 | sed 's/[Gg]i//g')
PROC=$(cat /proc/cpuinfo | grep -i intel > /dev/null ; echo $?)
VUSU=$(ls -1 /home | grep -v root | wc -l)
NENV=$(ps aux | grep gvfsd | head -n1 | awk '{print $2}')
XDGS=$(cat /proc/$NENV/environ | grep wayland > /dev/null ; echo $?)
VOUF=$(hostnamectl | grep Virtualization > /dev/null ; echo $?)
VGA=$(lspci | grep VGA | grep -i nvidia > /dev/null ; echo $?)
SS=$(echo $SHELL | grep zsh > /dev/null ; echo $?)
[[ $ROOT -ne 0 ]] && echo -ne "\n\n     PRECISA EXECUTAR COMO ROOT\n\n SAINDO ...\n\n" && exit 1
[[ $VER -ne 0 ]] && echo -ne "\n\n     SEU SISTEMA PRECISA SER:  DEBIAN / UBUNTU BASED\n\n SAINDO ...\n\n" && exit 1
[[ $RAM -lt 7 ]] && echo -ne "\n\n     MEMORIA MINIMA NECESSARIA:  8 GB\n\n SAINDO ...\n\n" && exit 1
[[ $VERF -eq 0 ]] && VERS="ubuntu" || VERS="debian"
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
[[ -z $resposta || $resposta = [Ss] ]] && fnUSU || exit 1
