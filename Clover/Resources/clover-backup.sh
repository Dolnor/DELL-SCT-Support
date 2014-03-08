#!/bin/bash

## determine date and timsetamp create backup folder for that day
ds=`date '+%Y-%m-%d'`
fbackup="$HOME/Desktop/Backups/$ds"
if [ ! -e "${fbackup}" ]
then
    mkdir -p "${fbackup}"
fi

##  determine efi partition
efi=$( df | grep EFI | sed -nE 's/.*% +([-A-F0-9]+)*/\1/p' )
config="${efi}/EFI/CLOVER/config.plist"

## backup config.plist just in case
if [ -e $config ];
then
    cp "${config}" "$HOME/Desktop/Backups/$ds/config.plist"
fi

## backup ACPI tables just in case too
if [ -e "${efi}/EFI/CLOVER/ACPI/patched" ]
then
    cp -R "${efi}/EFI/CLOVER/ACPI/patched" "$HOME/Desktop/Backups/$ds/ACPI"
fi

## delete previous CLOVER folder from ESP
if [ -e "${efi}/EFI/CLOVER" ]
then
    rm -R "${efi}/EFI/CLOVER"
fi

