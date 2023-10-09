#!/bin/bash

set -xeuo pipefail

DISK=/dev/nvme0n1

if [[ "$DISK" =~ "nvme" ]]; then
    ESP="${DISK}p1";
    SWAP_PART="${DISK}p2";
    ROOT_PART="${DISK}p3";
    HOME_PART="${DISK}p4";
elif [[ "$DISK" =~ "vd" ]]; then
    ESP="${DISK}1";
    SWAP_PART="${DISK}2";
    ROOT_PART="${DISK}3";
    HOME_PART="${DISK}4";
elif [[ "$DISK" =~ "sd" ]]; then
    ESP="${DISK}1";
    SWAP_PART="${DISK}2";
    ROOT_PART="${DISK}3";
    HOME_PART="${DISK}4";
fi


parted --script $DISK mklabel gpt \
             mkpart '"efi"' fat32 1MiB 501MiB \
             set 1 esp on \
             mkpart '"swap"' linux-swap 501MiB 10.5GiB \
             mkpart '"root"' ext4 10.5GiB 60.5GiB \
	     mkpart '"home"' ext4 60.5GiB 100%

mkfs.fat -F 32 -n "efi" $ESP
mkswap -L "swap" $SWAP_PART
mkfs.ext4 -L "root" $ROOT_PART
mkfs.ext4 -L "home" $HOME_PART

mount $ROOT_PART /mnt
mount --mkdir $ESP /mnt/boot
mount --mkdir $HOME_PART /mnt/home
swapon $SWAP_PART

reflector --country fr,de --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
echo 'ParallelDownloads=5' >> /etc/pacman.conf
pacstrap -K /mnt `grep -v '^#' ./pkglist.txt`

genfstab -U /mnt >> /mnt/etc/fstab

cp chroot.sh /mnt
arch-chroot /mnt ./chroot.sh

umount $ROOT_PART
umount $ESP
umount $HOME_PART
swapoff $SWAP_PAR

echo 'Installation finished'
