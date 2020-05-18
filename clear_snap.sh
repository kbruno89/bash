#!/bin/bash

## FOR LIKE DEBIAN / UBUNTU BASED

## REMOVE SNAP DUPLICATE (OLD VERSION) ENTRIES
## CLEAN OLD JOURNAL FILES
## HELP WITH DISK SPACE SIZE

NAME=`snap list --all | grep disabled | awk '{print $1}'`
REV=`snap list --all | grep disabled | awk '{print $3}'`

clear

for i in $NAME
do
	for j in $REV
	do
		echo -ne "\n	Purge snap: $i  revision $j\n"
		snap remove $i --revision=$j
	done
done

echo -ne "\n\n Clean journal files:\n\n"
journalctl --rotate && journalctl --vacuum-size=256M
echo -ne "\n\n"
