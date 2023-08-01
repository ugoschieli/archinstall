#!/bin/bash

set -xeuo pipefail

DISK=/dev/nvme0n1

if [[ "$DISK" =~ "nvme" ]]; then
    ESP="${DISK}p1";
    SWAP_PART="${DISK}p2";
    ROOT_PART="${DISK}p3";
elif [[ "$DISK" =~ "vd" ]]; then
    ESP="${DISK}1";
    SWAP_PART="${DISK}2";
    ROOT_PART="${DISK}3";
fi


parted --script $DISK mklabel gpt \
             mkpart '"ESP"' fat32 1MiB 501MiB \
             set 1 esp on \
             mkpart '"SWAP_PART"' linux-swap 501MiB 10.5GiB \
             mkpart '"ROOT_PART"' ext4 10.5Gib 100%

mkfs.fat -F 32 -n "EFI" $ESP
mkswap -L "SWAP" $SWAP_PART
mkfs.ext4 -L "ROOT_FS" $ROOT_PART

mount $ROOT_PART /mnt
mount --mkdir $ESP /mnt/boot
swapon $SWAP_PART

reflector --country fr,de --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap -K /mnt `grep -v '^#' ./pkglist.txt`

genfstab -U /mnt >> /mnt/etc/fstab

cp chroot.sh /mnt
arch-chroot /mnt ./chroot.sh

echo 'Installation finished'
