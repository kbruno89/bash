#!/bin/bash

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
echo  -e "              SEU SERVIDOR OPENVPN FOI INTEGRADO COM AD"
echo ""
echo ""
echo -e '\e[36;3m' "    CAMINHO DA CONF  CLIENT.OVPN  ATUALIZADA:  \e[m" /etc/openvpn/client/client.ovpn
echo ""
echo ""
echo ""
exit 0
}


fnCONFIG(){
clear && figlet -c "$VERSION"
cd /etc/openvpn && mkdir auth > /dev/null 2>&1
cat << EOF > auth/ldap.conf
<LDAP>
    URL ldap://$IP
    BindDN $DN
    Password $SENHA
    Timeout 15
    TLSEnable no
    FollowReferrals no
</LDAP>

<Authorization>
    BaseDN $BASE
    SearchFilter "(samaccountname=%u)"
    RequireGroup false
</Authorization>
EOF
cp server/server.conf server/server.confOLD >/dev/null 2>&1
cp client/client.ovpn client/clientOLD.ovpn >/dev/null 2>&1
sed -i '/user nobody/d' $CONF > /dev/null 2>&1
sed -i '/group nogroup/d' $CONF > /dev/null 2>&1
echo "plugin /usr/lib/openvpn/openvpn-auth-ldap.so /etc/openvpn/auth/ldap.conf" >> $CONF
echo "auth-user-pass" >> client/client.ovpn
systemctl restart openvpn-server@server.service
fnFINISH
}


fnDOWN(){
clear && figlet -c "$VERSION"
echo -e ""
echo -e ""
apt-get install openvpn-auth-ldap -y
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


fnINFO(){
clear && figlet -c "$VERSION"
echo ""
echo ""
echo "          BEM VINDO AO OPENVPN 2 AD !"
echo ""
echo ""
echo "          SEU OPENVPN SERVER SERA INTEGRADO COM AD MICROSOFT / SAMBA4"
echo "          VAMOS AJUSTAR ALGUMAS CONFIGURACOES PARA A INTEGRACAO"
echo ""
echo "          PRESSIONE ENTER PARA CONTINUAR..."
echo ""
echo ""
echo ""
read
clear && figlet -c "$VERSION"
echo ""
echo ""
echo ""
echo -e '\e[36;3m' " QUAL IP DO SERVIDOR AD?    \e[m"
echo "------------------------------------------------------------- "
read -e IP
[[ -z $IP ]] && echo "FAVOR PREENCHER O IP DO AD..." && sleep 3 && fnINFO
echo ""
echo -e '\e[36;3m' " QUAL BIND DN DO USUARIO?   \e[m"
echo -e '\e[36;3m' " EX: CN=Administrador,CN=Users,DC=Domain,DC=Local   \e[m"
echo "------------------------------------------------------------- "
read -e DN
[[ -z $DN ]] && echo "FAVOR PREENCHER O BIND DN DO USUARIO..." && sleep 3 && fnINFO
echo $DN | grep [dDcC]\. > /dev/null
[[ $? -ne 0 ]] && echo "PREENCHER CORRETAMENTE O BIND DN..." && sleep 3 && fnINFO
echo ""
echo -e '\e[36;3m' " QUAL A SENHA DO USUARIO BIND DN?    \e[m"
echo "------------------------------------------------------------- "
read -s SENHA
[[ -z $SENHA ]] && { echo "FAVOR PREENCHER A SENHA..." && sleep 3 && fnINFO ; }
echo ""
echo -e '\e[36;3m' " QUAL A BASE DN PARA CONSULTAR OS USUARIOS?    \e[m"
echo -e '\e[36;3m' " EX: CN=Users,DC=Domain,DC=Local  \e[m"
echo "------------------------------------------------------------- "
read -e BASE
[[ -z $BASE ]] && echo "FAVOR PREENCHER A BASE DN..." && sleep 3 && fnINFO
echo $BASE | grep [dDcC]\. > /dev/null
[[ $? -ne 0 ]] && echo "PREENCHER CORRETAMENTE A BASE DN..." && sleep 3 && fnINFO
clear && figlet -c "$VERSION"
echo ""
echo ""
echo -e " CONFIRA AS INFORMACOES"
echo "------------------------------------------------------------- "
echo ""
echo ""
echo -e '\e[36;3m' " IP AD:  \e[m" $IP
echo -e '\e[36;3m' " BIND DN:  \e[m" $DN
echo -e '\e[36;3m' " BASE DN:  \e[m" $BASE
echo ""
echo ""
echo "------------------------------------------------------------- "
echo ""
echo -e " ESTAO CORRETAS? [s/N]"
echo ""
read resposta
if [[ -z $resposta || $resposta = [Ss] ]]
        then
                fnCONFREDE
        else
                clear
                figlet -c "Ooops !!"
                echo -ne '\e[1;31m' "\n\n                        OK! VAMOS COMECAR NOVAMENTE! \e[m \n"
                sleep 4
                fnINFO
fi
}


clear
echo -e " CARREGANDO ..."
VERSION="OpenVPN 2 AD 1.0"
ROOT=$(id -u)
VER=$(cat /etc/debian_version | grep 11 > /dev/null 2>&1)
PKG=$(dpkg -s openvpn > /dev/null 2>&1 ; echo $?)
CHECKCONF=$(ls /etc/openvpn/server/server.conf > /dev/null 2>&1 ; echo $?)
[[ $ROOT -ne 0 ]] && echo -ne "\n\n     PRECISA EXECUTAR COMO ROOT\n             SAINDO ..." && exit
[[ $VER -ne 0 ]] && echo -ne "\n\n     SEU SISTEMA PRECISA SER:  DEBIAN 11.x\n             SAINDO ..." && exit
[[ $PKG -ne 0 ]] && echo -ne "\n\n     OPENVPN NAO INSTALADO!\n\n SEGUIR O TUTORIAL EM:  https://youtu.be/oJ_9RsMmBOc\n\n             SAINDO ..." && exit
[[ $CHECKCONF -ne 0 ]] && echo -ne "\n\n     OPENVPN NAO FOI INSTALADO CONFORME O TUTORIAL EM:  https://youtu.be/oJ_9RsMmBOc\n\n             SAINDO ..." && exit
export DEBIAN_FRONTEND=noninteractive
systemctl disable connman > /dev/null 2>&1
apt-get update -qq > /dev/null
apt-get install figlet vim net-tools -qq > /dev/null
clear && figlet -c "$VERSION"
echo ""
echo ""
echo "Title          : $(echo $VERSION | cut -d" " -f1,2,3)"
echo "Description    : Integra OpenVPN Com AD"
echo "Author         : Bruno Kammers Ribeiro"
echo "Version        : $(echo $VERSION | cut -d" " -f4)"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo -e " DESEJA INICIAR O PROCESSO DE CONFIGURACAO DO OPENVPN NESTE SERVIDOR? [s/N]"
echo -e " DEFAULT:  s"
echo ""
read resposta
[[ -z $resposta || $resposta = [Ss] ]] && fnINFO || exit
