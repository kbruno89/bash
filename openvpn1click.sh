#!/bin/bash

# IMPLANTA SERVIDOR OPENVPN COM APENAS 1 CLICK !
# ELABORADO PARA DEBIAN 11 (SE VOCÊ TIVER CONHECIMENTO, COM PEQUENOS AJUSTES CONSEGUE PORTAR PARA OUTRAS DISTROS)

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
echo  -e "              SERVIDOR CONFIGURADO COM"
echo  -e "              AS SEGUINTES INFORMACOES"
echo ""
echo ""
echo -e '\e[36;3m' "    IP:  \e[m" $IP
echo -e '\e[36;3m' "    PORTA:  \e[m" $PORTA
echo -e '\e[36;3m' "    PROTOCOLO:  \e[m" $PROTO
echo -e '\e[36;3m' "    HOSTNAME:  \e[m" $NAME
echo -e '\e[36;3m' "    SUBNET VPN:  \e[m" 10.8.0.0/24
echo -e '\e[36;3m' "    CAMINHO DA CONF CLIENT.OVPN:  \e[m" /etc/openvpn/client/client.ovpn
echo ""
echo ""
echo ""
echo -e "   VOCE PRECISA REINICIAR O SERVIDOR PARA CONCLUIR O PROCESSO ..."
echo ""
echo -e "   DESEJA REINICIAR O SERVIDOR AGORA? [s/N]"
echo -e "   DEFAULT:  s"
echo ""
echo  -e "##############################################################################"
echo ""
read resposta
[[ -z $resposta || $resposta = [Ss] ]] && reboot || exit
}


fnCONFIG(){
clear && figlet -c "$VERSION"
hostnamectl set-hostname "$NAME"
mkdir /etc/openvpn/server/keys
cd /etc/openvpn/server/keys
cp ~/openvpn-ca/pki/ca.crt .
cp ~/openvpn-ca/pki/issued/*.crt .
cp ~/openvpn-ca/pki/private/*.key .
cp ~/openvpn-ca/pki/dh.pem .
cd /etc/openvpn
echo "port $PORTA" > server/server.conf
echo "proto $PROTO" >> server/server.conf
echo "dev tun" >> server/server.conf
echo "mode server" >> server/server.conf
echo "persist-tun" >> server/server.conf
echo "persist-key" >> server/server.conf
echo "status openvpn.log" >> server/server.conf
echo "user nobody" >> server/server.conf
echo "group nogroup" >> server/server.conf
echo "tls-server" >> server/server.conf
echo "ca /etc/openvpn/server/keys/ca.crt" >> server/server.conf
echo "cert /etc/openvpn/server/keys/$NAME.crt" >> server/server.conf
echo "key /etc/openvpn/server/keys/$NAME.key" >> server/server.conf
echo "dh /etc/openvpn/server/keys/dh.pem" >> server/server.conf
echo "data-ciphers AES-256-CBC" >> server/server.conf
echo "data-ciphers-fallback AES-256-CBC" >> server/server.conf
echo "topology subnet" >> server/server.conf
echo "server 10.8.0.0 255.255.255.0" >> server/server.conf
echo "ifconfig-pool-persist ipp.txt" >> server/server.conf
echo "auth SHA512" >> server/server.conf
echo "push \"dhcp-option DNS $DNS\"" >> server/server.conf
echo "push \"route $REDE\"" >> server/server.conf
echo "push \"route-gateway 10.8.0.1\"" >> server/server.conf
echo "push \"topology subnet\"" >> server/server.conf
echo "client-to-client" >> server/server.conf
echo "verb 3" >> server/server.conf
echo "keepalive 15 60" >> server/server.conf
echo "mute 20" >> server/server.conf

echo "client" > client/client.base
echo "dev tun" >> client/client.base
echo "proto $PROTO" >> client/client.base
echo "remote $IP $PORTA" >> client/client.base
echo "auth SHA512" >> client/client.base
echo "cipher AES-256-CBC" >> client/client.base
echo "data-ciphers AES-256-CBC" >> client/client.base
echo "resolv-retry infinite" >> client/client.base
echo "nobind" >> client/client.base
echo "persist-tun" >> client/client.base
echo "persist-key" >> client/client.base
echo "remote-cert-tls server" >> client/client.base
echo "verb 3" >> client/client.base
echo "mute 20" >> client/client.base
echo "auth-nocache" >> client/client.base
KEY_DIR=server/keys
OUTPUT_DIR=client
BASE_CONFIG=$(cat client/client.base)
CA=$(cat $KEY_DIR/ca.crt)
CLIENT=$(cat $KEY_DIR/client.crt | tail -n20)
KEY=$(cat $KEY_DIR/client.key)
cat << EOF > $OUTPUT_DIR/client.ovpn
$BASE_CONFIG
<ca>
$CA
</ca>
<cert>
$CLIENT
</cert>
<key>
$KEY
</key>
EOF
systemctl enable --now openvpn-server@server.service
fnFINISH
}


fnMAKECERTS(){
clear && figlet -c "$VERSION"
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
tar -xzvf ~/easytls.tar.gz --strip-components=1
echo "export KEY_COUNTRY="$PAIS"" >> vars
echo "export KEY_PROVINCE="$ESTADO"" >> vars
echo "export KEY_CITY="$CIDADE"" >> vars
echo "export KEY_ORG="$ORGANIZACAO"" >> vars
echo "export KEY_EMAIL="$EMAIL"" >> vars
echo "export KEY_OU="Server"" >> vars
echo "export KEY_NAME="$NAME"" >> vars
clear
source vars
./easyrsa clean-all
printf "\n" | ./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa build-server-full $NAME nopass
./easyrsa build-client-full client nopass
./easytls init-tls
./easytls build-tls-auth
./easytls build-tls-crypt
./easytls build-tls-crypt-v2-server $NAME
./easytls build-tls-crypt-v2-client $NAME client
./easytls inline-tls-auth $NAME 0
fnCONFIG
}


fnDOWN(){
clear && figlet -c "$VERSION"
echo -e ""
echo -e ""
apt-get install openvpn easy-rsa -y
wget -cO - https://github.com/TinCanTech/easy-tls/archive/refs/tags/v2.7.0.tar.gz > ~/easytls.tar.gz
fnMAKECERTS
}


fnCLEAR(){
clear && figlet -c "$VERSION"
echo ""
echo " VERIFICANDO O SERVIDOR, AGUARDE ..."
echo ""
killall openvpn* > /dev/null 2>&1
systemctl stop openvpn-server > /dev/null 2>&1
apt-get remove openvpn -y > /dev/null 2>&1
rm -rf /etc/openvpn > /dev/null 2>&1
echo ""
echo " CONCLUIDO!"
sleep 2
fnDOWN
}


fnCONFREDE(){
clear && figlet -c "$VERSION"
ping -c 1 google.com > /dev/null
if [[ $? -eq 0 ]]
        then
                echo ""
                echo -e '\e[1;32m' "SERVIDOR ESTA CONECTADO A INTERNET! CONTINUANDO ...  \e[m"
                sleep 3
                fnCLEAR
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
echo "          BEM VINDO AO OPENVPN 1 CLICK !"
echo ""
echo ""
echo "          A SEGURANCA DESTE SERVICO EH BASEADA EM TLS E FAZ USO DE CERTIFICADOS"
echo "          VAMOS SETAR ALGUMAS CONFIGURACOES PARA GERAR OS CERTS AUTOMATICAMENTE"
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
echo -e '\e[36;3m' " QUAL SIGLA DO PAIS PARA O CERTIFICADO?   \e[m"
echo -e '\e[36;3m' " DEFAULT: BR   \e[m"
echo "------------------------------------------------------------- "
read -e PAIS
[[ -z $PAIS ]] && PAIS="BR" && echo $PAIS
echo ""
echo -e '\e[36;3m' " QUAL SIGLA DO ESTADO PARA O CERTIFICADO?   \e[m"
echo "------------------------------------------------------------- "
read -e ESTADO
[[ -z $ESTADO ]] && { echo "FAVOR PREENCHER A SIGLA DO ESTADO..." && sleep 3 && fnINFO ; }
echo ""
echo -e '\e[36;3m' " QUAL CIDADE PARA O CERTIFICADO?    \e[m"
echo "------------------------------------------------------------- "
read -e CIDADE
[[ -z $CIDADE ]] && { echo "FAVOR PREENCHER A CIDADE..." && sleep 3 && fnINFO ; }
echo ""
echo -e '\e[36;3m' " QUAL O NOME DA SUA ORGANIZACAO PARA O CERTIFICADO?    \e[m"
echo "------------------------------------------------------------- "
read -e ORGANIZACAO
[[ -z $ORGANIZACAO ]] && { echo "FAVOR PREENCHER A ORGANIZACAO..." && sleep 3 && fnINFO ; }
echo ""
echo -e '\e[36;3m' " QUAL ENDERECO DE EMAIL PARA O CERTIFICADO?    \e[m"
echo "------------------------------------------------------------- "
read -e EMAIL
[[ -z $EMAIL ]] && { echo "FAVOR PREENCHER O EMAIL..." && sleep 3 && fnINFO ; }
echo ""
echo -e '\e[36;3m' " QUAL HOSTNAME PARA ESTE SERVIDOR?    \e[m"
echo -e '\e[36;3m' " DEFAULT: vpnserver   \e[m"
echo "------------------------------------------------------------- "
read -e NAME
[[ -z $NAME ]] && NAME="vpnserver" && echo $NAME
echo ""
echo -e '\e[36;3m' " QUAL IP PARA ESTE SERVIDOR?    \e[m"
echo "------------------------------------------------------------- "
read -e IP
[[ -z $IP ]] && { echo "FAVOR PREENCHER O IP DO SERVIDOR..." && sleep 3 && fnINFO ; }
echo ""
CHECKIP=$(cat /etc/network/interfaces | grep dhcp > /dev/null & echo $?)
[[ $CHECKIP -eq 0 ]] && { echo "PARECE QUE O IP ESTA SENDO USADO POR DHCP, O CORRETO SERIA AJUSTAR PARA ESTATICO ..." && sleep 3 ; }
echo -e '\e[36;3m' " QUAL PORTA USAR NO SERVICO VPN?    \e[m"
echo -e '\e[36;3m' " DEFAULT: 1194   \e[m"
echo "------------------------------------------------------------- "
read -e PORTA
[[ -z $PORTA ]] && PORTA="1194" && echo $PORTA
echo ""
echo -e '\e[36;3m' " QUAL PROTOCOLO USAR NO SERVICO VPN? (TCP / UDP)    \e[m"
echo -e '\e[36;3m' " DEFAULT: udp   \e[m"
echo "------------------------------------------------------------- "
read -e PROTO
[[ -z $PROTO ]] && PROTO="udp" && echo $PROTO
echo ""
echo -e '\e[36;3m' " QUAL REDE LAN SERA ACESSADA PELA VPN?    \e[m"
echo -e '\e[36;3m' " A REDE LOCAL DA SUA EMPRESA OU CASA   \e[m"
echo -e '\e[36;3m' " NESSE PADRAO:  r.e.d.e ma.sc.ar.a   \e[m"
echo -e '\e[36;3m' " EX: 192.168.0.0 255.255.255.0   \e[m"
echo "------------------------------------------------------------- "
read -e REDE
[[ -z "$REDE" ]] && { echo "ERRO... NECESSARIO ESPECIFICAR A REDE LOCAL!!!" && echo "REINICIANDO O PROCESSO..." && sleep 3 && fnINFO ; }
CHECKREDE=$(echo "$REDE" | egrep '[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} 255\.255\.[0-9]{1,3}\.[0-9]{1,3}' > /dev/null 2>&1 ; echo $?)
[[ $CHECKREDE -ne 0 ]] && { echo "INFORMACAO INCORRETA!  O PADRAO DEVE SER REDE E MASCARA" && echo "EX: 192.168.1.0 255.255.255.0" \
&& echo "REINICIANDO O PROCESSO..." && sleep 5 && fnINFO  ; }
echo ""
echo -e '\e[36;3m' " QUAL SERVIDOR DNS PARA A REDE LAN DENTRO DA VPN?    \e[m"
echo "------------------------------------------------------------- "
read -e DNS
[[ -z $DNS ]] && { echo "FAVOR PREENCHER O DNS..." && sleep 3 && fnINFO ; }


clear && figlet -c "$VERSION"
echo ""
echo ""
echo -e " CONFIRA AS INFORMACOES"
echo "------------------------------------------------------------- "
echo ""
echo ""
echo -e '\e[36;3m' " PAIS:  \e[m" $PAIS
echo -e '\e[36;3m' " ESTADO:  \e[m" $ESTADO
echo -e '\e[36;3m' " CIDADE:  \e[m" $CIDADE
echo -e '\e[36;3m' " ORGANIZACAO:  \e[m" $ORGANIZACAO
echo -e '\e[36;3m' " EMAIL:  \e[m" $EMAIL
echo -e '\e[36;3m' " HOSTNAME:  \e[m" $NAME
echo -e '\e[36;3m' " IP:  \e[m" $IP
echo -e '\e[36;3m' " PORTA:  \e[m" $PORTA
echo -e '\e[36;3m' " PROTOCOLO:  \e[m" $PROTO
echo -e '\e[36;3m' " REDE:  \e[m" $REDE
echo -e '\e[36;3m' " DNS:  \e[m" $DNS
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
VERSION="OpenVPN 1 Click 1.1"
ROOT=$(id -u)
VER=$(cat /etc/debian_version | grep 11 > /dev/null 2>&1)
[[ $ROOT -ne 0 ]] && echo -ne "\n\n     PRECISA EXECUTAR COMO ROOT\n             SAINDO ..." && exit
[[ $VER -ne 0 ]] && echo -ne "\n\n     SEU SISTEMA PRECISA SER:  DEBIAN 11.x\n             SAINDO ..." && exit
export DEBIAN_FRONTEND=noninteractive
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
echo "vm.swappiness=15" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p > /dev/null
systemctl disable connman > /dev/null 2>&1
apt-get update -qq > /dev/null
apt-get install figlet vim net-tools -qq > /dev/null
clear && figlet -c "$VERSION"
echo ""
echo ""
echo "Title          : $(echo $VERSION | cut -d" " -f1,2,3)"
echo "Description    : Implanta OpenVPN Server Automaticamente"
echo "Author         : Bruno Kammers Ribeiro"
echo "Version        : $(echo $VERSION | cut -d" " -f4)"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo -e " DESEJA INICIAR O PROCESSO DE INSTALACAO DO OPENVPN NESTE SERVIDOR? [s/N]"
echo -e " DEFAULT:  s"
echo ""
read resposta
[[ -z $resposta || $resposta = [Ss] ]] && fnINFO || exit
