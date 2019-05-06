#!/bin/bash

## FOR LIKE DEBIAN

NAME=`snap list --all | grep disabled | awk '{print $1}'`
REV=`snap list --all | grep disabled | awk '{print $3}'`

clear

for i in $NAME
do
	for j in $REV
	do
		echo -ne "\n	Removendo snap: $i  revision $j\n"
		snap remove $i --revision=$j
	done
done

echo -ne "\n\n Limpando journal:\n\n"
journalctl --rotate && journalctl --vacuum-size=256M
echo -ne "\n\n"
