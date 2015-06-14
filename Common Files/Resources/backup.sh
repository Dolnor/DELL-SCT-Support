#!/bin/bash
logfil="/Library/Logs/SCT/sct_install_`date +%Y%m%d`.log"
echo "-------------- Kernel Extension Backup Start --------------" >> $logfil

## backup and delete previously installed kexts from SLE
ds=`date '+%Y-%m-%d'`
backup="$HOME/Desktop/Backups/$ds/Extensions"

echo "$(date +%T): backing up kernel extensions to $(echo $backup | cut -d/ -f4-)" >> $logfil
while read list;
do
    kext=`echo $list`
    if [ -e "$2$kext" ]
    then
        if [ ! -e "${backup}" ]
        then
            mkdir -p "${backup}"
			echo "$(date +%T): backup dir didn't exist, created one" >> $logfil
        fi
        cp -Rf "$2$kext" "${backup}"
        rm -rf "$2$kext"
		echo "$(date +%T): $(basename $kext) backed up & removed" >> $logfil
    fi
done < $1

echo "---------------  Kernel Extension Backup End --------------" >> $logfil
