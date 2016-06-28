#!/bin/bash -x

## CAPTURA RANGE IP DE DOMINIOS ESPECIFICADOS EM DOMAIN.TXT
## CONSULTA NA BASE RADB.NET E SALVA EM TXT 
## SEPARADO POR DOMINIO
##
## SCRIPT CRIADO POR BRUNO KAMMERS
## v0.1  EM 31/03/2016
##
## v0.2  EM 14/04/2016 - Adicionado uma segunda base para consulta, caso não encontre registros na primeira
##
## v0.3  EM 28/06/2016 - Ajustado a visualização dos resultados

clear
echo ""
echo ""
echo ""
echo "                       Please Wait..."

for A in `cat domain.txt` ; do

B=`nslookup $A | grep Address | awk '{print $2}' | tail -1`
C=`whois $B | grep OriginAS | awk '{print $2}'`
D=`whois -h v4.whois.cymru.com $B | tail -n1 | awk '{print $1}'`
whois -h whois.radb.net !g$C | tr ' ' '\n' | grep ^[0-9] | sort -un > $A.txt
whois -h whois.radb.net !gAS$D | tr ' ' '\n' | grep ^[0-9] | sort -un >> $A.txt
sort -un $A.txt -o $A.txt

done

echo ""
echo ""
echo "    See the result:"
echo ""

for i in `cat domain.txt` ; do

ls $i.txt

done
echo ""
