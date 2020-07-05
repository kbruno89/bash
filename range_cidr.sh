#!/bin/bash

## CAPTURA RANGE CIDR DE DOMINIOS ESPECIFICADOS EM DOMAIN.TXT
## CONSULTA NAS BASES  RADB.NET/CYMRU.COM  E SALVA EM TXT 
## SEPARADO POR DOMINIO
##
## SCRIPT CRIADO POR BRUNO KAMMERS RIBEIRO
## v0.1  EM 31/03/2016
##
## v0.2  EM 14/04/2016 - Adicionado uma segunda base para consulta, caso não encontre registros na primeira
##
## v0.3  EM 28/06/2016 - Ajustado a visualização dos resultados
##
## v0.4  EM 05/07/2020 - Validacao de binarios e ajuste no nome das variaveis

clear
echo -ne "\n\n\n                       Please Wait...\n"

if [ -z domain.txt ]
        then
                echo "    Please create file  domain.txt  with domains that you want see CIDR"
                exit
fi

NSL=`which nslookup > /dev/null 2>&1 ; echo $?`
if [ "$NSL" -ne "0" ]
        then
                echo "    Please install:  nslookup"
                exit
fi

WHO=`which whois > /dev/null 2>&1 ; echo $?`
if [ "$WHO" -ne "0" ]
        then
                echo "    Please install:  whois"
                exit
fi


for i in `cat domain.txt` ; do

VAR1=`nslookup $i | grep Address | awk '{print $2}' | tail -1`
VAR2=`whois $VAR1 | grep OriginAS | awk '{print $2}'`
VAR3=`whois -h v4.whois.cymru.com $VAR1 | tail -n1 | awk '{print $1}'`
whois -h whois.radb.net !g$VAR2 | tr ' ' '\n' | grep ^[0-9] | sort -un > $i.txt
whois -h whois.radb.net !gAS$VAR3 | tr ' ' '\n' | grep ^[0-9] | sort -un >> $i.txt
sort -un $i.txt -o $i.txt

done

echo -ne "\n\n    See the result:\n\n"

for i in `cat domain.txt` ; do

cat $i.txt

done
echo ""
