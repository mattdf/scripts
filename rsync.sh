#!/bin/bash

DESTDIR="DIR_NAME"
BACKUP="DIR_TO_BACK_UP"
EXCLUDE="$BACKUP/FOLDERS_TO_EXCLUDE"


COLORED=`tput setaf 3`
NOCOLOR=`tput sgr0`

DISK_TOP=`lsblk -Ppas "$1" | grep -i disk | awk '{print $1}' | awk -F "=" '{print $2}' | sed s/\"//g`
DISK_NAME=`lsblk $DISK_TOP -o model | sed '/^$/d' | tail -n 1 | sed ' s/[ \t]*$//g'`
DISK_VEND=`lsblk $DISK_TOP -o vendor | sed '/^$/d' | tail -n 1 | sed ' s/[ \t]*$//g'`

confirm () {
    # call with a prompt string or use a default
	read -r -p "${1:-Is this ($COLORED$DISK_NAME, $DISK_VEND$NOCOLOR) the right disk? [YES/N]} " response
    case $response in
        [Y][E][S]) 
            true
            ;;	
        *)
            false
            ;;
    esac
}


if [ $# -lt 2 ]; then
	echo "Usage: ./rsync.sh <dest-device> <mount-point>"
	exit
fi

if [ ! -b "$1" ]; then
	echo "Error: Device '$1' does not exist, or permission denied"
	exit
fi

if [ ! -d "$2" ]; then
	mkdir "$2" || echo "Error: Failure creating mountpoint" && exit
fi


if ! fdisk -l $1 | grep Disk; then
	echo "Error: Can't list disks"
	exit
fi


if ! confirm; then
	exit
fi

if ! cryptsetup luksOpen $1 securebackup; then
	echo "Error: Disk decryption failed - wrong password?"
	exit
fi

if ! mount /dev/mapper/securebackup "$2"; then
	echo "Error: Can't mount disk, closing LUKS device...";
	cryptsetup luksClose securebackup
	exit
fi

rsync -avx --delete $BACKUP --exclude $EXCLUDE "$2/$DESTDIR"

echo "rsync finished, calling sync..."
sync

umount "$2"
cryptsetup luksClose securebackup
echo "Finished"
