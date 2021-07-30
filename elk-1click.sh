#!/bin/bash
clear
# REQUISITOS
# DEBIAN 10 OU 11  /  2G RAM
#
# BRUNO KAMMERS RIBEIRO  -  28/07/21

echo -ne "\t VALIDANDO...\n"
ROOT=$(id -u)
VER=$(cat /etc/debian_version | egrep '10|11' > /dev/null 2>&1 ; echo $?)
GPG="https://artifacts.elastic.co/GPG-KEY-elasticsearch"
IP=$(ip a | grep global | awk '{print $2}' | cut -d\/ -f1)
MEM=$(free -m | grep Mem | awk '{print $2}')
fnCLEAN(){ echo 3 > /proc/sys/vm/drop_caches ; }
[[ $ROOT -ne 0 ]] && echo -ne "\n\n     PRECISA EXECUTAR COMO ROOT\n             SAINDO ...\n" && exit 1
[[ $VER -ne 0 ]] && echo -ne "\n\n     SEU SISTEMA PRECISA SER:  DEBIAN >= 10\n             SAINDO ...\n" && exit 1
[[ $MEM -lt 1950 ]] && echo -ne "\n\n     NECESSARIO NO MINIMO 2G DE RAM\n             SAINDO ...\n" && exit 1
export DEBIAN_FRONTEND=noninteractive
echo -ne "\t     OK!\n\n"

echo -ne "\t ATUALIZANDO O SISTEMA...\n"
fnCLEAN && apt-get update -qq > /dev/null
apt-get upgrade -qq > /dev/null
apt-get install curl wget vim net-tools openjdk-11-jdk apt-transport-https -qq > /dev/null 2>&1
JAVA=$(java --version | grep jdk > /dev/null)
[[ $JAVA -ne 0 ]] && echo "JAVA NAO INSTALADO ?" && exit 1
echo -ne "\t     OK!\n"

echo -ne "\n\t INSTALANDO ELASTICSEARCH..."
wget -qO - $GPG | apt-key add - > /dev/null 2>&1
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list
fnCLEAN && apt-get update -qq > /dev/null
apt-get install elasticsearch -qq > /dev/null

echo -ne "\n\t CONFIGURANDO ELASTICSEARCH...\n"
sed -ri 's/#cluster.name/cluster.name/g' /etc/elasticsearch/elasticsearch.yml
sed -ri 's/my-application/ELK/g' /etc/elasticsearch/elasticsearch.yml
sed -ri 's/#network.host: 192.168.0.1/network.host: '$IP'/g' /etc/elasticsearch/elasticsearch.yml
sed -ri 's/#http.port/http.port/g' /etc/elasticsearch/elasticsearch.yml
echo "discovery.seed_hosts: []" >> /etc/elasticsearch/elasticsearch.yml
echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml
# ESTA SENDO ATRIBUIDO 256M DE RAM PARA ALOCACAO DO JAVA NESTE SERVICO
# VOCE PODE AUMENTAR ISTO DE ACORDO COM OS RECURSOS DISPONIVEIS EM SEU SERVIDOR
sed -ri 's/## -Xms4g/-Xms256m/g' /etc/elasticsearch/jvm.options
sed -ri 's/## -Xmx4g/-Xmx512m/g' /etc/elasticsearch/jvm.options
systemctl enable --now elasticsearch > /dev/null 2>&1
RUN=$(systemctl --type=service --state=active | grep elasticsearch > /dev/null ; echo $?)
[[ $RUN -eq 0 ]] && echo -ne "\t     OK!\n"

echo -ne "\n\t INSTALANDO KIBANA..."
fnCLEAN && apt-get install kibana -qq > /dev/null

echo -ne "\n\t CONFIGURANDO KIBANA...\n"
sed -ri 's/#server.port/server.port/g' /etc/kibana/kibana.yml
sed -ri 's/#server.host: "localhost"/server.host: "'$IP'"/g' /etc/kibana/kibana.yml
sed -ri 's/#elasticsearch.hosts/elasticsearch.hosts/g' /etc/kibana/kibana.yml
sed -ri 's/localhost:/'$IP':/g' /etc/kibana/kibana.yml
systemctl enable --now kibana > /dev/null 2>&1
RUN=$(systemctl --type=service --state=active | grep kibana > /dev/null ; echo $?)
[[ $RUN -eq 0 ]] && echo -ne "\t     OK!\n"

echo -ne "\n\t INSTALANDO LOGSTASH..."
fnCLEAN && apt-get install logstash -qq > /dev/null

echo -ne "\n\t CONFIGURANDO LOGSTASH...\n"
# ESTA SENDO ATRIBUIDO 256M DE RAM PARA ALOCACAO DO JAVA NESTE SERVICO
# VOCE PODE AUMENTAR ISTO DE ACORDO COM OS RECURSOS DISPONIVEIS EM SEU SERVIDOR
sed -ri 's/-Xms1g/-Xms256m/g' /etc/logstash/jvm.options
sed -ri 's/-Xmx1g/-Xmx512m/g' /etc/logstash/jvm.options
systemctl enable --now logstash > /dev/null 2>&1
RUN=$(systemctl --type=service --state=active | grep logstash > /dev/null ; echo $?)
[[ $RUN -eq 0 ]] && echo -ne "\t     OK!\n"

echo -ne "\n\n\t\t FINALIZADO !!!\n"
echo -ne "\n\t\t ACESSE:  http://$IP:5601\n\n"
