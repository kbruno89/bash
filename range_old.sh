#!/bin/bash

## CAPTURA RANGE IP DE DOMINIOS ESPECIFICADOS EM DOMAIN.TXT
## CONSULTA NA BASE RADB.NET E SALVA EM TXT 
## SEPARADO POR DOMINIO
##
## SCRIPT CRIADO POR BRUNO KAMMERS
## EM 31/03/2016


clear
echo ""
echo ""
echo ""
echo "                       Please Wait..."

for A in `cat domain.txt` ; do

B=`nslookup $A | grep Address | awk '{print $2}' | tail -1`
C=`whois $B | grep OriginAS | awk '{print $2}'`
whois -h whois.radb.net !g$C | tr ' ' '\n' | grep ^[0-9] | sort -un > $A.txt

done

echo ""
echo ""
echo "    See the result:"
echo ""
ls *.txt | grep -v domain.txt
echo ""
