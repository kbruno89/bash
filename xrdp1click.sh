#!/bin/bash

# IMPLANTA SERVIDOR XRDP COM APENAS 1 CLICK !
# ELABORADO PARA DEBIAN 11 (SE VOCÊ TIVER CONHECIMENTO, COM PEQUENOS AJUSTES CONSEGUE PORTAR PARA OUTRAS DISTROS)
# CRIAR USUARIOS COM:  useradd -m
# PODE CRIAR E CONFIGURAR UM USER DEFAULT, AJUSTAR TODO LAYOUT E DEPOIS COPIAR SUA PASTA /home/xxx/* PARA DENTRO DE /etc/skel
# NOVOS USUARIOS FICARAO COM O LAYOUT IDENTICO, PADRONIZADO
# /etc/xdg/autostart DESATIVAR KLIPPER

fnFINISH(){
clear && figlet -c "$VERSION"
echo ""
echo ""
echo  -e "##############################################################################"
echo  -e ""
echo  -e ""
echo  -e ""
echo  -e ""
echo  -e ""
echo  -e "              SERVIDOR CONFIGURADO E PRONTO PRA USO"
echo  -e ""
echo  -e "              PORTA PADRAO 3389"
echo  -e ""
echo  -e "              PODE USAR COM MSTSC / RDESKTOP / REMMINA / ETC..."
echo  -e ""
echo  -e "              :)"
echo  -e ""
echo  -e ""
echo  -e ""
echo  -e "##############################################################################"
}

fnCONFIG(){
clear && figlet -c "$VERSION"
echo -e ""
echo -e ""
echo -e " CONFIGURANDO ..."
cd xrdp
./bootstrap
./configure
make
make install
cd ../xorgxrdp
./bootstrap
./configure
make
make install
systemctl unmask xrdp
systemctl unmask xrdp-sesman
sed -ri s/console/anybody/g /etc/X11/Xwrapper.config
sed -ri s/Policy=Default/Policy=UBDC/g /etc/xrdp/sesman.ini
systemctl enable --now xrdp
systemctl enable --now xrdp-sesman
fnFINISH
}


fnDOWN(){
clear && figlet -c "$VERSION"
echo -e ""
echo -e ""
echo -e " INSTALANDO PACOTES ..."
apt-get install curl wget gcc make autoconf libtool git pkg-config libssl-dev libpam0g-dev libx11-dev libxfixes-dev libxrandr-dev nasm xserver-xorg-dev -qq > /dev/null
git clone --recursive https://github.com/neutrinolabs/xrdp
git clone --recursive https://github.com/neutrinolabs/xorgxrdp
fnCONFIG
}


fnCONFREDE(){
clear && figlet -c "$VERSION"
ping -c 1 google.com > /dev/null
if [[ $? -eq 0 ]]
        then
                echo ""
                echo -e '\e[1;32m' "SERVIDOR ESTA CONECTADO A INTERNET! CONTINUANDO ...  \e[m"
                sleep 3
                fnDOWN
        else
                clear && figlet -c "$VERSION"
                echo ""
                echo ""
                echo ""
                echo -e '\e[1;31m' "Oooops !!!! PARECE QUE O SERVIDOR ESTA SEM INTERNET ... \e[m"
                echo -e '\e[1;31m' "VERIFIQUE A CONEXAO E TENTE NOVAMENTE ... \e[m"
                echo ""
                echo ""
                sleep 5
                exit
fi
}


clear
echo -e " CARREGANDO ..."
VERSION="XRDP 1 Click 1.0"
ROOT=$(id -u)
VER=$(cat /etc/debian_version | grep 11 > /dev/null 2>&1)
[[ $ROOT -ne 0 ]] && echo -ne "\n\n     PRECISA EXECUTAR COMO ROOT\n             SAINDO ..." && exit
[[ $VER -ne 0 ]] && echo -ne "\n\n     SEU SISTEMA PRECISA SER:  DEBIAN 11.x\n             SAINDO ..." && exit
export DEBIAN_FRONTEND=noninteractive
[[ $(cat /etc/sysctl.conf | grep net.ipv6.conf.all.disable_ipv6 > /dev/null ; echo $?) -ne 0 ]] && echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf   
[[ $(cat /etc/sysctl.conf | grep vm.swappiness > /dev/null ; echo $?) -ne 0 ]] && echo "vm.swappiness=15" >> /etc/sysctl.conf && sysctl -p > /dev/null
systemctl disable connman > /dev/null 2>&1
apt-get update -qq > /dev/null
apt-get install figlet vim net-tools -qq > /dev/null
clear && figlet -c "$VERSION"
echo ""
echo ""
echo "Title          : $(echo $VERSION | cut -d" " -f1,2,3)"
echo "Description    : Implanta XRDP Server Automaticamente"
echo "Author         : Bruno Kammers Ribeiro"
echo "Version        : $(echo $VERSION | cut -d" " -f4)"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo -e " DESEJA INICIAR O PROCESSO DE INSTALACAO DO XRDP NESTE SERVIDOR? [s/N]"
echo -e " DEFAULT:  s"
echo ""
read resposta
[[ -z $resposta || $resposta = [Ss] ]] && fnCONFREDE || exit
