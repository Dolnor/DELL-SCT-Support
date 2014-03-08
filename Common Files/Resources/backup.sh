#!/bin/bash

## backup and delete previously installed kexts from SLE
ds=`date '+%Y-%m-%d'`
backup="$HOME/Desktop/Backups/$ds/Extensions"
while read list;
do
    kext=`echo $list`
    if [ -e "$2$kext" ]
    then
        if [ ! -e "${backup}" ]
        then
            mkdir -p "${backup}"
        fi
        cp -Rf "$2$kext" "${backup}"
        rm -rf "$2$kext"
    fi
done < $1
