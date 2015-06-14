#!/bin/bash
logfil="/Library/Logs/SCT/sct_install_`date +%Y%m%d`.log"
echo "------------------ Clover Data Backup Start -----------------" >> $logfil

## determine date and timsetamp create backup folder for that day
ds=`date '+%Y-%m-%d'`
fbackup="$HOME/Desktop/Backups/$ds"
if [ ! -e "${fbackup}" ]
then
	mkdir -p "${fbackup}"
	echo "$(date +%T): created $(echo $fbackup | cut -d/ -f4-)" >> $logfil
else
	echo "$(date +%T): using backup dir $(echo $fbackup | cut -d/ -f4-)" >> $logfil
fi

##  determine efi partition
efi=$( df | grep EFI | sed -nE 's/.*% +([-A-F0-9]+)*/\1/p' )
config="${efi}/EFI/CLOVER/config.plist"

## backup config.plist just in case
if [ -e $config ];
then
    cp "${config}" "$HOME/Desktop/Backups/$ds/config.plist"
	echo "$(date +%T): $config file backed up" >> $logfil
fi

# perhaps OEM folder used?

## backup ACPI tables just in case too
if [ -e "${efi}/EFI/CLOVER/ACPI/patched" ]
then
    cp -R "${efi}/EFI/CLOVER/ACPI/patched" "$HOME/Desktop/Backups/$ds/ACPI"
	echo "$(date +%T): patched acpi tables backed up" >> $logfil
fi

## delete previous CLOVER folder from ESP
if [ -e "${efi}/EFI/CLOVER" ]
then
    rm -R "${efi}/EFI/CLOVER"
	echo "$(date +%T): previous clover folder removed from mapped efi partition" >> $logfil
fi

mkdir -p "${efi}/EFI/CLOVER/ACPI/patched"

echo "------------------- Clover Data Backup End ------------------" >> $logfil


