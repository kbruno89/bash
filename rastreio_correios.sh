#!/bin/bash
clear

## TRACKER CORREIOS SHIPS FROM TERMINAL


URL="https://www.websro.com.br/detalhes.php?P_COD_UNI"
which curl > /dev/null 2>&1

if [ "$?" != "0" ]
        then
                echo ""
                echo " CURL IS REQUIRED...  PLEASE INSTALL CURL PACKAGE!"
                echo ""
                exit
fi

if [ "$1" = "" ]
        then
                echo ""
                echo "  PARAMETER NOT FOUND..."
                echo ""
                echo "  USAGE:  ./rastreio_correios.sh CODIGO_DE_RASTREIO"
                echo ""
                exit
fi


curl "$URL=$1" 2> /dev/null | grep '<table' -A21 | tr '[:blank:]' ' ' | tail -n+12 | sed -e 's/<tr>//g' -e 's/<td>//g' -e s/"<td valign='top'>"//g -e 's/<br>/\n/g' -e 's/<label>//g' -e s/"<\/label><\/td>"//g -e 's/<strong>//g' -e s/"<\/strong>"//g -e s/"<\/td>"//g -e s/"<\/tr>"//g -e s/"                 \/"//g -e 's/^[ \t]*//'
