#!/bin/bash
clear
## REMOVE OLD DUPLICATED SNAP ENTRIES
## CLEAN OLD JOURNAL FILES
## THIS IS A LITTLE HELP WITH DISK SPACE SIZE  :)
## v0.2  EM 07/05/2021 - PRO Code :)

DISABLED=$(snap list --all | grep disabled | awk '{print $1" "$3}')
OLDIFS=$IFS ; IFS=$'\n'
for i in $DISABLED
do
        NAME=$(echo $i | awk '{print $1}')
        REV=$(echo $i | awk '{print $2}')
        echo -ne "\n    Purge snap: $NAME  revision $REV\n"
        snap remove $NAME --revision=$REV > /dev/null 2>&1
        echo -ne "\nOK!" ; echo -ne "\n\n"

done
IFS=$OLDIFS

echo -ne "\n\n Clean journal files:\n\n"
journalctl --rotate && journalctl --vacuum-size=256M
echo -ne "\n\n"
