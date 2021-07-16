#!/bin/bash
## CAPTURA RANGE CIDR DE DOMINIOS ESPECIFICADOS EM DOMAIN.TXT
## CONSULTA NAS BASES  RADB.NET/CYMRU.COM
##
## SCRIPT CRIADO POR BRUNO KAMMERS RIBEIRO

clear
echo -ne "\n\n\n                       Please Wait...\n\n"
NSL=$(which nslookup > /dev/null 2>&1 ; echo $?)
WHO=$(which whois > /dev/null 2>&1 ; echo $?)
[[ ! -f domain.txt ]] && echo "    Please create file  domain.txt  with domains that you want query CIDR" && exit 1 || FILE=$(wc -l domain.txt | awk '{print $1}')
[[ $FILE -eq 0 ]] && echo "    Please input at least one domain on domain.txt" && exit 1
[[ $NSL -ne 0 ]] && echo "    Please install:  nslookup" && exit 1
[[ $WHO -ne 0 ]] && echo "    Please install:  whois" && exit 1

for i in $(cat domain.txt)
do
        VAR1=$(nslookup $i | grep Address | awk '{print $2}' | tail -1)
        VAR2=$(whois $VAR1 | grep OriginAS | awk '{print $2}')
        VAR3=$(whois -h v4.whois.cymru.com $VAR1 | tail -n1 | awk '{print $1}')
        whois -h whois.radb.net !g$VAR2 | tr ' ' '\n' | grep ^[0-9] | sort -un > $i.txt
        whois -h whois.radb.net !gAS$VAR3 | tr ' ' '\n' | grep ^[0-9] | sort -un >> $i.txt
        sort -un $i.txt -o $i.txt
        echo -ne "\n $i \n" && cat $i.txt && echo -ne "\n"
done
