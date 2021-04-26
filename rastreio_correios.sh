#!/bin/bash
clear

## TRACKER CORREIOS SHIPS FROM TERMINAL
# 26/04/2021 - Clean Code (From 29 lines to 13)

URL="https://www.websro.com.br/detalhes.php?P_COD_UNI"
CURL=$(which curl > /dev/null 2>&1 ; echo $?)

[[ "$?" -ne "0" ]] && echo " CURL IS REQUIRED...  PLEASE INSTALL CURL PACKAGE!" || exit 1
[[ -z "$1" ]] && echo -ne "\n  PARAMETER NOT FOUND... \n\n USAGE:  ./rastreio_correios.sh CODIGO_DE_RASTREIO\n"

curl "$URL=$1" 2> /dev/null | grep '<table' -A21 | tr '[:blank:]' ' ' | tail -n+12 | sed -e 's/<tr>//g' -e 's/<td>//g' -e s/"<td valign='top'>"//g -e 's/<br>/\n/g' -e 's/<label>//g' -e s/"<\/label><\/td>"//g -e 's/<strong>//g' -e s/"<\/strong>"//g -e s/"<\/td>"//g -e s/"<\/tr>"//g -e s/"                 \/"//g -e 's/^[ \t]*//'
